CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_cost_element TYPE STRUCTURE FOR READ RESULT /esrcc/i_srvcelem_s\\costelementtole,
      BEGIN OF ts_control,
        validfrom TYPE if_abap_behv=>t_xflag,
        validto   TYPE if_abap_behv=>t_xflag,
        costind   TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_cost_element
        IMPORTING
          entity  TYPE ts_cost_element
          control TYPE ts_control.

  PRIVATE SECTION.
    DATA: config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_cost_element.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-validto = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALIDTO' ) TO fields. ENDIF.
    IF control-costind = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'COSTIND' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).

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
                                         ( entity = 'CostElementToLe' table = '/ESRCC/SRVCELEM' )
                                       ) ).
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_srvcelem_s DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR costelementtoleall
        RESULT    result,
*      selectcustomizingtransptreq FOR MODIFY
*        IMPORTING
*                  keys   FOR ACTION costelementtoleall~selectcustomizingtransptreq
*        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR costelementtoleall
        RESULT result,
      precheck_cba_costelementtole FOR PRECHECK
        IMPORTING entities FOR CREATE costelementtoleall\_costelementtole.
ENDCLASS.

CLASS lhc_/esrcc/i_srvcelem_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA: selecttransport_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled,
          edit_flag            TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.

    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
        iv_objectname = '/ESRCC/SRVCELEM'
        iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    DATA(transport_service) = cl_bcfg_cd_reuse_api_factory=>get_transport_service_instance(
      iv_objectname = '/ESRCC/SRVCELEM'
      iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table ).
    IF transport_service->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /esrcc/i_srvcelem_s IN LOCAL MODE
    ENTITY costelementtoleall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(all).
    IF all[ 1 ]-%is_draft = if_abap_behv=>mk-off.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result = VALUE #( (
               %tky = all[ 1 ]-%tky
               %action-edit = edit_flag
               %assoc-_costelementtole = edit_flag ) ).
*               %action-selectcustomizingtransptreq = selecttransport_flag ) ).
  ENDMETHOD.
*  METHOD selectcustomizingtransptreq.
*    MODIFY ENTITIES OF /esrcc/i_srvcelem_s IN LOCAL MODE
*      ENTITY costelementtoleall
*        UPDATE FIELDS ( transportrequestid hidetransport )
*        WITH VALUE #( FOR key IN keys
*                        ( %tky               = key-%tky
*                          transportrequestid = key-%param-transportrequestid
*                          hidetransport      = abap_false ) ).
*
*    READ ENTITIES OF /esrcc/i_srvcelem_s IN LOCAL MODE
*      ENTITY costelementtoleall
*        ALL FIELDS WITH CORRESPONDING #( keys )
*        RESULT DATA(entities).
*    result = VALUE #( FOR entity IN entities
*                        ( %tky   = entity-%tky
*                          %param = entity ) ).
*  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_SRVCELEM' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
*    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_costelementtole.
    TYPES ts_cost_element TYPE STRUCTURE FOR READ RESULT /esrcc/i_srvcelem_s\\costelementtole.

    DATA(target) = entities[ 1 ]-%target.

*   Validate System ID
    SELECT DISTINCT ele~sysid, ele~costelement
      FROM /esrcc/i_costele AS ele
      INNER JOIN @target AS target
        ON  target~sysid = ele~sysid
        AND target~costelement = ele~costelement
      INTO TABLE @DATA(cost_elements).

    DATA(lo_config_util) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths           = VALUE #( ( path = 'CostElementToLeAll' ) )
        is_transition   = abap_true
      CHANGING
        reported_entity = reported-costelementtole
        failed_entity   = failed-costelementtole ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_config_util ).

    LOOP AT target INTO DATA(entity).
      lo_validation->validate_cost_element(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( validfrom = if_abap_behv=>mk-on )
      ).

      IF NOT line_exists( cost_elements[ sysid = entity-sysid costelement = entity-costelement ] ).
        lo_config_util->set_state_message(
          entity     = CORRESPONDING ts_cost_element( entity )
          msg        = new_message( id       = /esrcc/cl_config_util=>c_config_msg
                                    number   = '008'
                                    severity = cl_abap_behv=>ms-error
                                    v1       = lo_config_util->get_field_text( fieldname = 'COSTELEMENT' )
                                    v2       = entity-costelement
                                    v3       = entity-sysid )
          state_area = CONV #( /esrcc/cl_config_util=>invalid_data )
        ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_srvcelem_s DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_srvcelem_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-costelementtoleall INDEX 1 INTO DATA(all).
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
CLASS lhc_/esrcc/i_srvcelem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
*      validaterecordchanges FOR VALIDATE ON SAVE
*        IMPORTING
*          keys FOR costelementtole~validaterecordchanges,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR costelementtole
        RESULT result,
      validatedata FOR VALIDATE ON SAVE
        IMPORTING keys FOR costelementtole~validatedata,
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE costelementtole.
ENDCLASS.

CLASS lhc_/esrcc/i_srvcelem IMPLEMENTATION.
*  METHOD validaterecordchanges.
*    DATA change TYPE REQUEST FOR CHANGE /ESRCC/I_SrvCeleM_S.
*    SELECT SINGLE TransportRequestID FROM /ESRCC/D_SRVCE_S INTO @DATA(TransportRequestID). "#EC CI_NOORDER
*    lhc_rap_tdat_cts=>get( )->validate_changes(
*                                transport_request = TransportRequestID
*                                table             = '/ESRCC/SRVCELEM'
*                                keys              = REF #( keys )
*                                reported          = REF #( reported )
*                                failed            = REF #( failed )
*                                change            = REF #( change-CostElementToLe ) ).
*  ENDMETHOD.
  METHOD get_global_features.
    DATA edit_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.
    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
         iv_objectname = '/ESRCC/SRVCELEM'
         iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.

  METHOD validatedata.
    DATA: draft TYPE STRUCTURE FOR READ RESULT /esrcc/i_srvcelem_s\\costelementtole.

    READ ENTITIES OF /esrcc/i_srvcelem_s IN LOCAL MODE
         ENTITY costelementtole
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

*   Draft version data
    SELECT ele~*
      FROM /esrcc/d_srvcele AS ele
      INNER JOIN @keys AS key
        ON  key~sysid        = ele~sysid
        AND key~legalentity  = ele~legalentity
        AND key~ccode        = ele~ccode
        AND key~costelement  = ele~costelement
        AND key~validfrom   <> ele~validfrom
      WHERE ele~draftentityoperationcode NOT IN ( 'D', 'L' )
      INTO TABLE @DATA(draft_entities).

    DATA(lo_cost_element) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths           = VALUE #( ( path = 'CostElementToLeAll' ) )
      CHANGING
        reported_entity = reported-costelementtole
        failed_entity   = failed-costelementtole ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_cost_element ).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_cost_element(
        entity  = entity
        control = VALUE #( validto = if_abap_behv=>mk-on costind = if_abap_behv=>mk-on )
      ).

      LOOP AT draft_entities ASSIGNING FIELD-SYMBOL(<draft>)
           WHERE     sysid        = entity-sysid
                 AND legalentity  = entity-legalentity
                 AND ccode        = entity-ccode
                 AND costelement  = entity-costelement
                 AND validfrom   <> entity-validfrom.
        draft = CORRESPONDING #( <draft> ).
        draft = CORRESPONDING #( BASE ( draft ) entity MAPPING %is_draft = %is_draft singletonid = singletonid EXCEPT * ).
        lo_cost_element->validate_overlapping_validity( EXPORTING src_from    = <draft>-validfrom
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
        paths           = VALUE #( ( path = 'CostElementToLeAll' ) )
      CHANGING
        reported_entity = reported-costelementtole
        failed_entity   = failed-costelementtole ) ).

    LOOP AT entities INTO DATA(entity) WHERE %control-costind = if_abap_behv=>mk-on
                                          OR %control-validto = if_abap_behv=>mk-on.
      lo_validation->validate_cost_element(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( validto = entity-%control-validto costind = entity-%control-costind )
      ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
