CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_stewardship     TYPE STRUCTURE FOR READ RESULT /ESRCC/I_Stewrdshp_S\\Stewardship,
      ts_service_product TYPE STRUCTURE FOR READ RESULT /ESRCC/I_Stewrdshp_S\\ServiceProduct,
      tt_sharecost       TYPE STANDARD TABLE OF /esrcc/stwd_sp WITH EMPTY KEY,
      tt_stewardship     TYPE TABLE FOR READ RESULT /ESRCC/I_Stewrdshp_S\\Stewardship,

      BEGIN OF ts_control_stewardship,
        validfrom   TYPE if_abap_behv=>t_xflag,
        validto     TYPE if_abap_behv=>t_xflag,
        stewardship TYPE if_abap_behv=>t_xflag,
      END OF ts_control_stewardship,
      BEGIN OF ts_control_service_product,
        validfrom TYPE if_abap_behv=>t_xflag,
        validto   TYPE if_abap_behv=>t_xflag,
        costshare TYPE if_abap_behv=>t_xflag,
      END OF ts_control_service_product.

    METHODS:
      constructor
        IMPORTING
          config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_stewardship
        IMPORTING
          entity  TYPE ts_stewardship
          control TYPE ts_control_stewardship,
      validate_service_product
        IMPORTING
          entity  TYPE ts_service_product
          control TYPE ts_control_service_product,
      calculate_costshare_sum
        IMPORTING
          sharecost     TYPE tt_sharecost
        EXPORTING
          sharecost_sum TYPE tt_sharecost,
      check_duplicate
        IMPORTING
          entities TYPE tt_stewardship.

  PRIVATE SECTION.
    DATA:
      config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_stewardship.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-validfrom   = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALIDFROM' ) TO fields. ENDIF.
    IF control-validto     = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALIDTO' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).

    IF control-stewardship = if_abap_behv=>mk-on.
      config_util_ref->validate_percentage(
        fields = VALUE #( ( fieldname = 'STEWARDSHIP' ) )
        entity = entity
      ).
    ENDIF.

    IF control-validfrom = if_abap_behv=>mk-on OR control-validto = if_abap_behv=>mk-on.
      config_util_ref->validate_validity(
        from   = entity-validfrom
        to     = entity-validto
        entity = entity
      ).

      DATA(lv_validfrom) = entity-validfrom.
      DATA(lv_validto) = entity-validto.

      config_util_ref->validate_start_end_of_month(
        EXPORTING
          entity     = entity
        CHANGING
          start_date = lv_validfrom
          end_date   = lv_validto
      ).
    ENDIF.
  ENDMETHOD.

  METHOD validate_service_product.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-costshare = if_abap_behv=>mk-on.
      config_util_ref->validate_percentage(
        fields = VALUE #( ( fieldname = 'COSTSHARE' ) )
        entity = entity
      ).
    ENDIF.

    IF control-validfrom = if_abap_behv=>mk-on OR control-validto = if_abap_behv=>mk-on.
      config_util_ref->validate_validity(
        from   = entity-validfrom
        to     = entity-validto
        entity = entity
      ).

      DATA(lv_validfrom) = entity-validfrom.
      DATA(lv_validto) = entity-validto.
      config_util_ref->validate_start_end_of_month(
        EXPORTING
          entity     = entity
        CHANGING
          start_date = lv_validfrom
          end_date   = lv_validto
      ).

      IF control-validto = if_abap_behv=>mk-on.
        config_util_ref->validate_initial(
          fields = VALUE #( ( fieldname = 'VALIDTO' ) )
          entity = entity
        ).
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD calculate_costshare_sum.
*    SELECT sysid, legalentity, ccode, costobject, costcenter, costcenter_vf, validfrom AS date
*      FROM @sharecost AS share
*      WHERE share~validto <> '00000000'
*      INTO TABLE @DATA(dates).
*
*    SELECT sysid, legalentity, ccode, costobject, costcenter, costcenter_vf,
*           CASE WHEN share~validto <> '99991231' THEN dats_add_days(  share~validto , 1 ) ELSE share~validto END AS date
*      FROM @sharecost AS share
*      WHERE share~validto <> '00000000'
*      APPENDING TABLE @dates.
*
*    SORT dates BY sysid legalentity ccode costobject costcenter costcenter_vf date.
*    DELETE ADJACENT DUPLICATES FROM dates COMPARING sysid legalentity ccode costobject costcenter costcenter_vf date.
*    DATA(count) = lines( dates ).
*
*    DATA curr LIKE LINE OF dates.
*    LOOP AT dates INTO DATA(date).
*      IF curr-sysid         <> date-sysid OR
*         curr-legalentity   <> date-legalentity OR
*         curr-ccode         <> date-ccode OR
*         curr-costobject    <> date-costobject OR
*         curr-costcenter    <> date-costcenter OR
*         curr-costcenter_vf <> date-costcenter_vf.
*        curr = CORRESPONDING #( date ).
*        APPEND CORRESPONDING #( date MAPPING validfrom = date ) TO sharecost_sum ASSIGNING FIELD-SYMBOL(<sum>).
*      ELSE.
*        <sum>-validto = COND #( WHEN date-date <> '99991231' THEN date-date - 1 ELSE date-date ).
*        LOOP AT sharecost INTO DATA(share) WHERE sysid         = date-sysid
*                                             AND legalentity   = date-legalentity
*                                             AND ccode         = date-ccode
*                                             AND costobject    = date-costobject
*                                             AND costcenter    = date-costcenter
*                                             AND costcenter_vf = date-costcenter_vf.
*          IF <sum>-validfrom BETWEEN share-validfrom AND share-validto OR
*             <sum>-validto BETWEEN share-validfrom AND share-validto.
*            <sum>-costshare = <sum>-costshare + share-costshare.
*          ENDIF.
*        ENDLOOP.
*        IF count <> sy-tabix.
*          APPEND CORRESPONDING #( date MAPPING validfrom = date ) TO sharecost_sum ASSIGNING <sum>.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.
  ENDMETHOD.

  METHOD check_duplicate.

  ENDMETHOD.
ENDCLASS.

CLASS lhc_servicereceiver DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ServiceReceiver RESULT result.

ENDCLASS.

CLASS lhc_servicereceiver IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_serviceproduct DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ServiceProduct RESULT result.

ENDCLASS.

CLASS lhc_serviceproduct IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_rap_tdat_cts DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      get
        RETURNING
          VALUE(result) TYPE REF TO if_mbc_cp_rap_table_cts.

ENDCLASS.

CLASS lhc_rap_tdat_cts IMPLEMENTATION.
  METHOD get.
    result = mbc_cp_api=>rap_table_cts( table_entity_relations = VALUE #(
                                         ( entity = 'Stewardship' table = '/ESRCC/STEWRDSHP' )
                                       ) ).
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_stewrdshp_s DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR StewardshipAll
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR StewardshipAll
        RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_stewrdshp_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA: selecttransport_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled,
          edit_flag            TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.

    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
        iv_objectname = '/ESRCC/STEWRDSHP'
        iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    DATA(transport_service) = cl_bcfg_cd_reuse_api_factory=>get_transport_service_instance(
                                iv_objectname = '/ESRCC/STEWRDSHP'
                                iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table ).
    IF transport_service->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /ESRCC/I_Stewrdshp_S IN LOCAL MODE
    ENTITY StewardshipAll
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(all).
    IF all[ 1 ]-%is_draft = if_abap_behv=>mk-off.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result = VALUE #( (
               %tky = all[ 1 ]-%tky
               %action-edit = edit_flag
               %assoc-_Stewardship = edit_flag ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_STEWRDSHP' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%update      = is_authorized.
    result-%action-Edit = is_authorized.
  ENDMETHOD.
ENDCLASS.
CLASS lsc_/esrcc/i_stewrdshp_s DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_stewrdshp_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-StewardshipAll INDEX 1 INTO DATA(all).
    IF all-TransportRequestID IS NOT INITIAL.
      lhc_rap_tdat_cts=>get( )->record_changes(
                                  transport_request = all-TransportRequestID
                                  create            = REF #( create )
                                  update            = REF #( update )
                                  delete            = REF #( delete ) ).
    ENDIF.
  ENDMETHOD.
  METHOD cleanup_finalize.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_stewrdshp DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR Stewardship
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR Stewardship RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_stewrdshp IMPLEMENTATION.
  METHOD get_global_features.
    DATA edit_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.
    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
         iv_objectname = '/ESRCC/STEWRDSHP'
         iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.
  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.
