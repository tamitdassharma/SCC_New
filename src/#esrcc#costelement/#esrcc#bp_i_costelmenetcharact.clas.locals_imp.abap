CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_ce_char TYPE STRUCTURE FOR READ RESULT /esrcc/i_costelmenetcharacte_s\\costelementchar,
      BEGIN OF ts_control,
        validfrom      TYPE if_abap_behv=>t_xflag,
        validto        TYPE if_abap_behv=>t_xflag,
        cost_indicator TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_ce_char
        IMPORTING
          entity  TYPE ts_ce_char
          control TYPE ts_control.

  PRIVATE SECTION.
    DATA: config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_ce_char.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-validfrom      = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALIDFROM' ) TO fields. ENDIF.
    IF control-validto        = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALIDTO' ) TO fields. ENDIF.
    IF control-cost_indicator = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'COSTINDICATOR' ) TO fields. ENDIF.

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
                                         ( entity = 'CostElementChar' table = '/ESRCC/CSTELMTCH' )
                                       ) ).
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_costelmenetcharac DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR costelementcharall
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR costelementcharall
        RESULT result,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR costelementchar
        RESULT result,
      precheck_cba_costelementchar FOR PRECHECK
        IMPORTING entities FOR CREATE costelementcharall\_costelementchar,
      validatedata FOR VALIDATE ON SAVE
        IMPORTING keys FOR costelementchar~validatedata,
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE costelementchar.
ENDCLASS.

CLASS lhc_/esrcc/i_costelmenetcharac IMPLEMENTATION.
  METHOD get_instance_features.
    DATA: selecttransport_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled,
          edit_flag            TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.

    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
        iv_objectname = '/ESRCC/CSTELMTCH'
        iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    DATA(transport_service) = cl_bcfg_cd_reuse_api_factory=>get_transport_service_instance(
                                iv_objectname = '/ESRCC/CSTELMTCH'
                                iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table ).
    IF transport_service->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
    ENTITY costelementcharall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(all).
    IF all[ 1 ]-%is_draft = if_abap_behv=>mk-off.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result = VALUE #( (
               %tky = all[ 1 ]-%tky
               %action-edit = edit_flag
               %assoc-_costelementchar = edit_flag ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_COSTELMENETCHARACTE' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
  ENDMETHOD.
  METHOD get_global_features.
    DATA edit_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.
    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
         iv_objectname = '/ESRCC/CSTELMTCH'
         iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.

  METHOD precheck_cba_costelementchar.
    TYPES ts_ce_char TYPE STRUCTURE FOR READ RESULT /esrcc/i_costelmenetcharacte_s\\costelementchar.

    DATA(lo_config_util) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'CostElementCharAll' ) )
        source_entity_name = '/ESRCC/C_COSTELMENETCHARACTE'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported-costelementchar
        failed_entity      = failed-costelementchar ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_config_util ).
    DATA(target_entities) = VALUE #( entities[ 1 ]-%target ).

    SELECT DISTINCT
           celem~costelementuuid
        FROM /esrcc/d_cstelmt AS celem
        INNER JOIN @target_entities AS tent
            ON  tent~costelementuuid = celem~costelementuuid
            AND tent~validfrom       = celem~validfrom
        WHERE celem~draftentityoperationcode NOT IN ( 'D', 'L' )
        INTO TABLE @DATA(duplicate_entities).

    LOOP AT target_entities INTO DATA(entity) GROUP BY ( costelementuuid = entity-costelementuuid
                                                         validfrom       = entity-validfrom
                                                         size            = GROUP SIZE )
        ASCENDING REFERENCE INTO DATA(group_ref).
      lo_validation->validate_ce_char(
        entity  = CORRESPONDING #( group_ref->* )
        control = VALUE #( validfrom = if_abap_behv=>mk-on )
      ).

      IF line_exists( duplicate_entities[ costelementuuid = group_ref->costelementuuid ] ) OR group_ref->size > 1.
        lo_config_util->set_state_message(
          entity     = CORRESPONDING ts_ce_char( entity )
          msg        = new_message(
                         id       = /esrcc/cl_config_util=>c_config_msg
                         number   = '023'
                         severity = if_abap_behv_message=>severity-error
                       )
          state_area = CONV #( /esrcc/cl_config_util=>duplicate ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatedata.
    DATA: draft TYPE STRUCTURE FOR READ RESULT /esrcc/c_costelmenetcharacte_s\\costelementchar.

    READ ENTITIES OF /esrcc/i_costelmenetcharacte_s IN LOCAL MODE
         ENTITY costelementchar
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

**   Draft version data
*    SELECT ele~*
*      FROM /esrcc/d_cstelmt AS ele
*      INNER JOIN @keys AS key
*        ON  key~sysid        = ele~sysid
*        AND key~legalentity  = ele~legalentity
*        AND key~ccode        = ele~ccode
*        AND key~costelement  = ele~costelement
*        AND key~validfrom   <> ele~validfrom
*      WHERE ele~draftentityoperationcode NOT IN ( 'D', 'L' )
*      INTO TABLE @DATA(draft_entities).

    DATA(lo_ce_char) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'CostElementCharAll' ) )
        source_entity_name = '/ESRCC/C_COSTELMENETCHARACTE'
      CHANGING
        reported_entity    = reported-costelementchar
        failed_entity      = failed-costelementchar ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_ce_char ).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_ce_char(
        entity  = entity
        control = VALUE #( validto = if_abap_behv=>mk-on cost_indicator = if_abap_behv=>mk-on )
      ).

*      LOOP AT draft_entities ASSIGNING FIELD-SYMBOL(<draft>)
*           WHERE     sysid        = entity-sysid
*                 AND legalentity  = entity-legalentity
*                 AND ccode        = entity-ccode
*                 AND costelement  = entity-costelement
*                 AND validfrom   <> entity-validfrom.
*        draft = CORRESPONDING #( <draft> ).
*        draft = CORRESPONDING #( BASE ( draft ) entity MAPPING %is_draft = %is_draft singletonid = singletonid EXCEPT * ).
*        lo_ce_char->validate_overlapping_validity( EXPORTING src_from    = <draft>-validfrom
*                                                             src_to      = <draft>-validto
*                                                             src_entity  = draft
*                                                             curr_from   = entity-validfrom
*                                                             curr_to     = entity-validto
*                                                             curr_entity = entity ).
*      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
        EXPORTING
          paths              = VALUE #( ( path = 'CostElementCharAll' ) )
          source_entity_name = '/ESRCC/C_COSTELMENETCHARACTE'
        CHANGING
          reported_entity    = reported-costelementchar
          failed_entity      = failed-costelementchar ) ).

    LOOP AT entities INTO DATA(entity) WHERE %control-costindicator = if_abap_behv=>mk-on
                                          OR %control-validto = if_abap_behv=>mk-on.
      lo_validation->validate_ce_char(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( validto = entity-%control-validto cost_indicator = entity-%control-costindicator )
      ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_costelmenetcharac DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_costelmenetcharac IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-costelementcharall INDEX 1 INTO DATA(all).
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
