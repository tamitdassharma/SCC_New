CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_cost_center TYPE STRUCTURE FOR READ RESULT /esrcc/i_coscen_s\\costcenter,

      BEGIN OF ts_control,
        sysid         TYPE if_abap_behv=>t_xflag,
        costobject    TYPE if_abap_behv=>t_xflag,
        costnumber    TYPE if_abap_behv=>t_xflag,
        billfrequency TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_costcenter
        IMPORTING
          entity  TYPE ts_cost_center
          control TYPE ts_control.

  PRIVATE SECTION.
    DATA: config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_costcenter.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-sysid         = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'SYSID' ) TO fields. ENDIF.
    IF control-costobject    = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'COSTOBJECT' ) TO fields. ENDIF.
    IF control-costnumber    = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'COSTCENTER' ) TO fields. ENDIF.
    IF control-billfrequency = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'BILLFREQUENCY' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
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
                                         ( entity = 'CostCenter' table = '/ESRCC/COSCEN' )
                                         ( entity = 'CostCenterText' table = '/ESRCC/COSCENT' )
                                       ) ).
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_coscen_s DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR costcenterall
        RESULT    result,
*      selectcustomizingtransptreq FOR MODIFY
*        IMPORTING
*                  keys   FOR ACTION costcenterall~selectcustomizingtransptreq
*        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR costcenterall
        RESULT result,
      precheck_cba_costcenter FOR PRECHECK
        IMPORTING entities FOR CREATE costcenterall\_costcenter,
      edit FOR MODIFY
        IMPORTING keys FOR ACTION costcenterall~edit.
ENDCLASS.

CLASS lhc_/esrcc/i_coscen_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA: selecttransport_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled,
          edit_flag            TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.

    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
        iv_objectname = '/ESRCC/COSCEN'
        iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    DATA(transport_service) = cl_bcfg_cd_reuse_api_factory=>get_transport_service_instance(
      iv_objectname = '/ESRCC/COSCEN'
      iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table ).
    IF transport_service->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /esrcc/i_coscen_s IN LOCAL MODE
    ENTITY costcenterall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(all).
    IF all[ 1 ]-%is_draft = if_abap_behv=>mk-off.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result = VALUE #( (
               %tky = all[ 1 ]-%tky
               %action-edit = edit_flag
               %assoc-_costcenter = edit_flag ) ).
*               %action-selectcustomizingtransptreq = selecttransport_flag ) ).
  ENDMETHOD.
*  METHOD selectcustomizingtransptreq.
*    MODIFY ENTITIES OF /esrcc/i_coscen_s IN LOCAL MODE
*      ENTITY costcenterall
*        UPDATE FIELDS ( transportrequestid hidetransport )
*        WITH VALUE #( FOR key IN keys
*                        ( %tky               = key-%tky
*                          transportrequestid = key-%param-transportrequestid
*                          hidetransport      = abap_false ) ).
*
*    READ ENTITIES OF /esrcc/i_coscen_s IN LOCAL MODE
*      ENTITY costcenterall
*        ALL FIELDS WITH CORRESPONDING #( keys )
*        RESULT DATA(entities).
*    result = VALUE #( FOR entity IN entities
*                        ( %tky   = entity-%tky
*                          %param = entity ) ).
*  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_COSCEN' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
*    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.

  METHOD precheck_cba_costcenter.
    TYPES ts_cost_center TYPE STRUCTURE FOR READ RESULT /esrcc/i_coscen_s\\costcenter.

    DATA(lo_cost_center) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'CostCenterAll' ) )
        source_entity_name = '/ESRCC/C_COSCEN'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported-costcenter
        failed_entity      = failed-costcenter
    ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_cost_center ).

    LOOP AT entities[ 1 ]-%target INTO DATA(entity).
      lo_cost_center->check_authorization(
        EXPORTING
          entity      = CORRESPONDING ts_cost_center( entity )
          cost_object = entity-costobject
          activity    = /esrcc/cl_config_util=>c_authorization_activity-create
      ).

      lo_validation->validate_costcenter(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( sysid      = if_abap_behv=>mk-on
                           costobject = if_abap_behv=>mk-on
                           costnumber = if_abap_behv=>mk-on )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD edit.
    DATA(lo_util) = /esrcc/cl_config_util=>create_for_authorization( ).
    SELECT DISTINCT costobject FROM /esrcc/i_coscen INTO TABLE @DATA(cost_objects).     "#EC CI_NOWHERE

    LOOP AT cost_objects INTO DATA(cost_object).
      DATA(is_unauthorized) = lo_util->is_unauthorized(
        EXPORTING
          cost_object = cost_object-costobject
          create      = abap_true
          update      = abap_true
          delete      = abap_true
      ).

      IF is_unauthorized = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF is_unauthorized = abap_true.
      reported-costcenterall = VALUE #( ( %msg = new_message( id       = /esrcc/cl_config_util=>c_config_msg
                                                              number   = '019'
                                                              severity = if_abap_behv_message=>severity-success ) ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_coscen_s DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_coscen_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-costcenterall INDEX 1 INTO DATA(all).
    IF all-transportrequestid IS NOT INITIAL.
      lhc_rap_tdat_cts=>get( )->record_changes(
                                  transport_request = all-transportrequestid
                                  create            = REF #( create )
                                  update            = REF #( update )
                                  delete            = REF #( delete ) ).
    ENDIF.
  ENDMETHOD.
  METHOD cleanup_finalize.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_coscen DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
*      validaterecordchanges FOR VALIDATE ON SAVE
*        IMPORTING
*          keys FOR costcenter~validaterecordchanges,
      validatedata FOR VALIDATE ON SAVE
        IMPORTING keys FOR costcenter~validatedata,
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE costcenter,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR costcenter RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_coscen IMPLEMENTATION.
*  METHOD validaterecordchanges.
*    DATA change TYPE REQUEST FOR CHANGE /ESRCC/I_CosCen_S.
*    SELECT SINGLE TransportRequestID FROM /ESRCC/D_COSCE_S INTO @DATA(TransportRequestID). "#EC CI_NOORDER
*    lhc_rap_tdat_cts=>get( )->validate_changes(
*                                transport_request = TransportRequestID
*                                table             = '/ESRCC/COSCEN'
*                                keys              = REF #( keys )
*                                reported          = REF #( reported )
*                                failed            = REF #( failed )
*                                change            = REF #( change-CostCenter ) ).
*  ENDMETHOD.
  METHOD validatedata.
    READ ENTITIES OF /esrcc/i_coscen_s IN LOCAL MODE
         ENTITY costcenter
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'CostCenterAll' ) )
        source_entity_name = '/ESRCC/C_COSCEN'
      CHANGING
        reported_entity    = reported-costcenter
        failed_entity      = failed-costcenter ) ).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>) WHERE billfrequency IS INITIAL.
      lo_validation->validate_costcenter(
        entity  = <entity>
        control = VALUE #( billfrequency = if_abap_behv=>mk-on )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
          EXPORTING
            paths              = VALUE #( ( path = 'CostCenterAll' ) )
            source_entity_name = '/ESRCC/C_COSCEN'
          CHANGING
            reported_entity    = reported-costcenter
            failed_entity      = failed-costcenter ) ).

    LOOP AT entities INTO DATA(entity) WHERE %control-billfrequency = if_abap_behv=>mk-on.
      lo_validation->validate_costcenter(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( billfrequency = entity-%control-billfrequency )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.
    IF keys[ 1 ]-%is_draft = if_abap_behv=>mk-on.
      /esrcc/cl_config_util=>create_for_authorization( )->set_instance_authorization(
        EXPORTING
          keys            = keys
          update          = abap_true
          delete          = abap_true
          create_by_assoc = abap_true
          field_mapping   = VALUE #( cost_object = 'COSTOBJECT' )
          assoc_path      = VALUE #( ( path = '_CostCenterText' ) )
        CHANGING
          result          = result
      ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
CLASS lhc_/esrcc/i_coscentext DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
*      validaterecordchanges FOR VALIDATE ON SAVE
*        IMPORTING
*          keys FOR costcentertext~validaterecordchanges,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR costcentertext RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_coscentext IMPLEMENTATION.
*  METHOD validaterecordchanges.
*    DATA change TYPE REQUEST FOR CHANGE /ESRCC/I_CosCen_S.
*    SELECT SINGLE TransportRequestID FROM /ESRCC/D_COSCE_S INTO @DATA(TransportRequestID). "#EC CI_NOORDER
*    lhc_rap_tdat_cts=>get( )->validate_changes(
*                                transport_request = TransportRequestID
*                                table             = '/ESRCC/COSCENT'
*                                keys              = REF #( keys )
*                                reported          = REF #( reported )
*                                failed            = REF #( failed )
*                                change            = REF #( change-CostCenterText ) ).
*  ENDMETHOD.

  METHOD get_instance_features.
    IF keys[ 1 ]-%is_draft = if_abap_behv=>mk-on.
      /esrcc/cl_config_util=>create_for_authorization( )->set_instance_authorization(
          EXPORTING
            keys            = keys
            update          = abap_true
            delete          = abap_true
            field_mapping   = VALUE #( cost_object = 'COSTOBJECT' )
          CHANGING
            result          = result
        ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
