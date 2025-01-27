CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_markup TYPE STRUCTURE FOR READ RESULT /esrcc/i_srvmkp_s\\servicemarkup,
      BEGIN OF ts_control,
        origcost      TYPE if_abap_behv=>t_xflag,
        passcost      TYPE if_abap_behv=>t_xflag,
        intraorigcost TYPE if_abap_behv=>t_xflag,
        intrapasscost TYPE if_abap_behv=>t_xflag,
        validfrom     TYPE if_abap_behv=>t_xflag,
        validto       TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_service_markup
        IMPORTING
          entity  TYPE ts_markup
          control TYPE ts_control.

  PRIVATE SECTION.
    DATA config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_service_markup.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-validto = if_abap_behv=>mk-on.
      config_util_ref->validate_initial(
        fields = VALUE #( ( fieldname = 'VALIDTO' ) )
        entity = entity
      ).
    ENDIF.

    IF control-origcost      = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'ORIGCOST' ) TO fields. ENDIF.
    IF control-passcost      = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'PASSCOST' ) TO fields. ENDIF.
    IF control-intraorigcost = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'INTRAORIGCOST' ) TO fields. ENDIF.
    IF control-intrapasscost = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'INTRAPASSCOST' ) TO fields. ENDIF.

    config_util_ref->validate_percentage(
      fields = fields
      entity = entity
    ).

    IF control-validfrom = if_abap_behv=>mk-on OR control-validto = if_abap_behv=>mk-on.
      config_util_ref->validate_validity(
        from   = entity-validfrom
        to     = entity-validto
        entity = entity
      ).

      DATA(lv_from) = entity-validfrom.
      DATA(lv_to) = entity-validto.
      config_util_ref->validate_start_end_of_month(
        EXPORTING
          entity     = entity
        CHANGING
          start_date = lv_from
          end_date   = lv_to
      ).
    ENDIF.
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
                                         ( entity = 'ServiceMarkup' table = '/ESRCC/SRVMKP' )
                                       ) ).
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_srvmkp_s DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR servicemarkupall
        RESULT    result,
*      selectcustomizingtransptreq FOR MODIFY
*        IMPORTING
*                  keys   FOR ACTION servicemarkupall~selectcustomizingtransptreq
*        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR servicemarkupall
        RESULT result,
      precheck_cba_servicemarkup FOR PRECHECK
        IMPORTING entities FOR CREATE servicemarkupall\_servicemarkup.
ENDCLASS.

CLASS lhc_/esrcc/i_srvmkp_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA: selecttransport_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled,
          edit_flag            TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.

    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
        iv_objectname = '/ESRCC/SRVMKP'
        iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    DATA(transport_service) = cl_bcfg_cd_reuse_api_factory=>get_transport_service_instance(
      iv_objectname = '/ESRCC/SRVMKP'
      iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table ).
    IF transport_service->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /esrcc/i_srvmkp_s IN LOCAL MODE
    ENTITY servicemarkupall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(all).
    IF all[ 1 ]-%is_draft = if_abap_behv=>mk-off.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result = VALUE #( (
               %tky = all[ 1 ]-%tky
               %action-edit = edit_flag
               %assoc-_servicemarkup = edit_flag ) ).
*               %action-selectcustomizingtransptreq = selecttransport_flag ) ).
  ENDMETHOD.
*  METHOD selectcustomizingtransptreq.
*    MODIFY ENTITIES OF /esrcc/i_srvmkp_s IN LOCAL MODE
*      ENTITY servicemarkupall
*        UPDATE FIELDS ( transportrequestid hidetransport )
*        WITH VALUE #( FOR key IN keys
*                        ( %tky               = key-%tky
*                          transportrequestid = key-%param-transportrequestid
*                          hidetransport      = abap_false ) ).
*
*    READ ENTITIES OF /esrcc/i_srvmkp_s IN LOCAL MODE
*      ENTITY servicemarkupall
*        ALL FIELDS WITH CORRESPONDING #( keys )
*        RESULT DATA(entities).
*    result = VALUE #( FOR entity IN entities
*                        ( %tky   = entity-%tky
*                          %param = entity ) ).
*  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_SRVMKP' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
*    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.

  METHOD precheck_cba_servicemarkup.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'ServiceMarkupAll' ) )
        source_entity_name = '/ESRCC/C_SRVMKP'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported-servicemarkup
        failed_entity      = failed-servicemarkup ) ).

    LOOP AT entities[ 1 ]-%target INTO DATA(entity).
      lo_validation->validate_service_markup(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( validfrom = if_abap_behv=>mk-on )
      ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_srvmkp_s DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_srvmkp_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-servicemarkupall INDEX 1 INTO DATA(all).
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
CLASS lhc_/esrcc/i_srvmkp DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
*      validaterecordchanges FOR VALIDATE ON SAVE
*        IMPORTING
*          keys FOR servicemarkup~validaterecordchanges,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR servicemarkup
        RESULT result,
      validatedata FOR VALIDATE ON SAVE
        IMPORTING keys FOR servicemarkup~validatedata,
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE servicemarkup.
ENDCLASS.

CLASS lhc_/esrcc/i_srvmkp IMPLEMENTATION.
*  METHOD validaterecordchanges.
*    DATA change TYPE REQUEST FOR CHANGE /ESRCC/I_SrvMkp_S.
*    SELECT SINGLE TransportRequestID FROM /ESRCC/D_SRVMK_S INTO @DATA(TransportRequestID). "#EC CI_NOORDER
*    lhc_rap_tdat_cts=>get( )->validate_changes(
*                                transport_request = TransportRequestID
*                                table             = '/ESRCC/SRVMKP'
*                                keys              = REF #( keys )
*                                reported          = REF #( reported )
*                                failed            = REF #( failed )
*                                change            = REF #( change-ServiceMarkup ) ).
*  ENDMETHOD.
  METHOD get_global_features.
    DATA edit_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.
    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
         iv_objectname = '/ESRCC/SRVMKP'
         iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.

  METHOD validatedata.
    DATA draft TYPE STRUCTURE FOR READ RESULT /esrcc/i_srvmkp_s\\servicemarkup.

    READ ENTITIES OF /esrcc/i_srvmkp_s IN LOCAL MODE
         ENTITY servicemarkup
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

    " Draft version data
    SELECT mkp~*
      FROM /esrcc/d_srvmkp AS mkp
      INNER JOIN @keys AS key
          ON key~serviceproduct = mkp~serviceproduct
         AND key~validfrom <> mkp~validfrom
      WHERE mkp~draftentityoperationcode NOT IN ( 'D', 'L' )
      INTO TABLE @DATA(draft_entities).

    DATA(lo_service_markup) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'ServiceMarkupAll' ) )
        source_entity_name = '/ESRCC/C_SRVMKP'
      CHANGING
        reported_entity    = reported-servicemarkup
        failed_entity      = failed-servicemarkup ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_service_markup ).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_service_markup(
        entity  = entity
        control = VALUE #( origcost      = if_abap_behv=>mk-on
                           passcost      = if_abap_behv=>mk-on
                           intraorigcost = if_abap_behv=>mk-on
                           intrapasscost = if_abap_behv=>mk-on
                           validto       = if_abap_behv=>mk-on )
      ).

      LOOP AT draft_entities ASSIGNING FIELD-SYMBOL(<draft>)
           WHERE     serviceproduct  = entity-serviceproduct
                 AND validfrom      <> entity-validfrom.
        draft = CORRESPONDING #( <draft> ).
        draft = CORRESPONDING #( BASE ( draft ) entity MAPPING %is_draft = %is_draft singletonid = singletonid EXCEPT * ).

        lo_service_markup->validate_overlapping_validity( EXPORTING src_from    = <draft>-validfrom
                                                                    src_to      = <draft>-validto
                                                                    src_entity  = draft
                                                                    curr_from   = entity-validfrom
                                                                    curr_to     = entity-validto
                                                                    curr_entity = entity ).
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'ServiceMarkupAll' ) )
        source_entity_name = '/ESRCC/C_SRVMKP'
      CHANGING
        reported_entity    = reported-servicemarkup
        failed_entity      = failed-servicemarkup ) ).

    LOOP AT entities INTO DATA(entity) WHERE %control-origcost      = if_abap_behv=>mk-on
                                          OR %control-passcost      = if_abap_behv=>mk-on
                                          OR %control-intraorigcost = if_abap_behv=>mk-on
                                          OR %control-intrapasscost = if_abap_behv=>mk-on
                                          OR %control-validfrom     = if_abap_behv=>mk-on
                                          OR %control-validto       = if_abap_behv=>mk-on.
      lo_validation->validate_service_markup(
        EXPORTING
          entity  = CORRESPONDING #( entity )
          control = VALUE #( origcost      = entity-%control-origcost
                             passcost      = entity-%control-passcost
                             intraorigcost = entity-%control-IntraOrigcost
                             intrapasscost = entity-%control-IntraPasscost
                             validfrom     = entity-%control-validfrom
                             validto       = entity-%control-validto )
      ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
