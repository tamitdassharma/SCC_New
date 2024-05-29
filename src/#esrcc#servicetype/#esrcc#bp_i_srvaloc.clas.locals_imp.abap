CLASS lcl_custom_validation DEFINITION INHERITING FROM cl_abap_behv.
  PUBLIC SECTION.
    TYPES:
      ts_srv_aloc  TYPE STRUCTURE FOR READ RESULT /esrcc/i_srvaloc_s\\serviceallocation,
      ts_weightage TYPE STRUCTURE FOR READ RESULT /esrcc/i_srvaloc_s\\weightage,

      BEGIN OF ts_control_alloc,
        validfrom          TYPE if_abap_behv=>t_xflag,
        validto            TYPE if_abap_behv=>t_xflag,
        uom                TYPE if_abap_behv=>t_xflag,
        capacityversion    TYPE if_abap_behv=>t_xflag,
        consumptionversion TYPE if_abap_behv=>t_xflag,
        keyversion         TYPE if_abap_behv=>t_xflag,
        chargeout          TYPE if_abap_behv=>t_xflag,
      END OF ts_control_alloc,
      BEGIN OF ts_control_weightage,
        allocationperiod TYPE if_abap_behv=>t_xflag,
        refperiod        TYPE if_abap_behv=>t_xflag,
        weightage        TYPE if_abap_behv=>t_xflag,
      END OF ts_control_weightage.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_service_allocation
        IMPORTING
          entity  TYPE ts_srv_aloc
          control TYPE ts_control_alloc,
      validate_weightage
        IMPORTING
          entity  TYPE ts_weightage
          control TYPE ts_control_weightage.
    CLASS-METHODS:
      create
        IMPORTING
                  config_util_ref TYPE REF TO /esrcc/cl_config_util
        RETURNING VALUE(instance) TYPE REF TO lcl_custom_validation.

  PRIVATE SECTION.
    DATA:
      config_util_ref TYPE REF TO /esrcc/cl_config_util,
      gt_ref_period   TYPE TABLE OF /esrcc/i_allocationperiod.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD create.
    instance = NEW lcl_custom_validation( config_util_ref = config_util_ref ).
  ENDMETHOD.

  METHOD validate_service_allocation.
    DATA:
      fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-chargeout = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'CHARGEOUT' ) TO fields. ENDIF.
    IF control-validto   = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALIDTO' ) TO fields. ENDIF.

    IF entity-chargeout = 'D'.
      IF control-uom                = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'UOM' ) TO fields. ENDIF.
      IF control-capacityversion    = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'CAPACITYVERSION' ) TO fields. ENDIF.
      IF control-consumptionversion = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'CONSUMPTIONVERSION' ) TO fields. ENDIF.
    ELSEIF entity-chargeout = 'I'.
      IF control-keyversion         = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'KEYVERSION' ) TO fields. ENDIF.
    ENDIF.

    config_util_ref->validate_initial(
      fields     = fields
      entity     = entity
      message_no = '015'
    ).

    IF control-validfrom = if_abap_behv=>mk-on OR control-validto = if_abap_behv=>mk-on.
      config_util_ref->validate_validity(
        from   = entity-validfrom
        to     = entity-validto
        entity = entity
      ).

      IF control-validfrom = if_abap_behv=>mk-on. DATA(validfrom) = entity-validfrom. ENDIF.
      IF control-validto   = if_abap_behv=>mk-on. DATA(validto) = entity-validto. ENDIF.
      config_util_ref->validate_start_end_of_month(
        EXPORTING
          entity     = entity
        CHANGING
          start_date = validfrom
          end_date   = validto
      ).
    ENDIF.
  ENDMETHOD.

  METHOD validate_weightage.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF gt_ref_period IS INITIAL.
      SELECT DISTINCT *
        FROM /esrcc/i_allocationperiod
        INTO TABLE @gt_ref_period.
    ENDIF.

    IF control-allocationperiod = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'ALLOCATIONPERIOD' ) TO fields. ENDIF.

    IF control-refperiod = if_abap_behv=>mk-on.
      IF entity-allocationperiod <> '01' AND entity-allocationperiod <> '02'.
        APPEND VALUE #( fieldname = 'REFPERIOD' ) TO fields.
      ELSEIF entity-refperiod IS NOT INITIAL.
        config_util_ref->set_state_message(
          fieldname = 'REFPERIOD'
          entity    = entity
          msg       = new_message( id       = /esrcc/cl_config_util=>c_config_msg
                                   number   = '010'
                                   severity = if_abap_behv_message=>severity-error
                                   v1       = VALUE #( gt_ref_period[ allocationperiod = entity-allocationperiod ]-text OPTIONAL ) )
         state_area = CONV #( /esrcc/cl_config_util=>non_mandatory )
        ).
      ENDIF.
    ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).

    IF control-weightage = if_abap_behv=>mk-on.
      config_util_ref->validate_percentage(
        fields = VALUE #( ( fieldname = 'WEIGHTAGE' ) )
        entity = entity
      ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lhc_weightage DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_features FOR GLOBAL FEATURES
      IMPORTING REQUEST requested_features FOR weightage RESULT result.
    METHODS validatedata FOR VALIDATE ON SAVE
      IMPORTING keys FOR weightage~validatedata.
    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE weightage.
ENDCLASS.

CLASS lhc_weightage IMPLEMENTATION.

  METHOD get_global_features.
    DATA edit_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.
    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
         iv_objectname = '/ESRCC/ALLOC_WGT'
         iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.

  METHOD validatedata.
    DATA:
      fieldnames            TYPE /esrcc/cl_config_util=>tt_fields,
      ls_service_allocation TYPE STRUCTURE FOR READ RESULT /esrcc/i_srvaloc_s\\serviceallocation.

    READ ENTITIES OF /esrcc/i_srvaloc_s IN LOCAL MODE
         ENTITY weightage
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

    DATA(unique_entities) = entities.
    SORT unique_entities BY serviceproduct costversion validfromalloc.
    DELETE ADJACENT DUPLICATES FROM unique_entities COMPARING serviceproduct costversion validfromalloc.

    SELECT ent~%is_draft AS is_draft, ent~singletonid, wgt~serviceproduct, wgt~costversion, wgt~validfromalloc, SUM( wgt~weightage ) AS weightage
      FROM /esrcc/d_allocwg AS wgt
      INNER JOIN @unique_entities AS ent
        ON  ent~serviceproduct = wgt~serviceproduct
        AND ent~costversion    = wgt~costversion
        AND ent~validfromalloc = wgt~validfromalloc
      WHERE wgt~draftentityoperationcode NOT IN ( 'D', 'L' )
    GROUP BY ent~%is_draft, ent~singletonid, wgt~serviceproduct, wgt~costversion, wgt~validfromalloc
      HAVING SUM( wgt~weightage ) <> 100
      INTO TABLE @DATA(weightages).

    DATA(lo_weightage) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'ServiceAllocatioAll' )
                                   ( path = 'ServiceAllocation' ) )
        source_entity_name = '/ESRCC/C_ALLOCATIONWEIGHTAGE'
      CHANGING
        reported_entity    = reported-weightage
        failed_entity      = failed-weightage ).

    DATA(lo_validation) = lcl_custom_validation=>create( config_util_ref = lo_weightage ).

    READ ENTITIES OF /esrcc/i_srvaloc_s IN LOCAL MODE
        ENTITY serviceallocation
        ALL FIELDS WITH CORRESPONDING #( keys MAPPING validfrom = validfromalloc )
        RESULT DATA(service_allocations).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_weightage(
        entity  = entity
        control = VALUE #( allocationperiod = if_abap_behv=>mk-on
                           refperiod        = if_abap_behv=>mk-on
                           weightage        = if_abap_behv=>mk-on )
      ).

      IF line_exists( weightages[ serviceproduct = entity-serviceproduct costversion = entity-costversion validfromalloc = entity-validfromalloc ] ).
        lo_weightage->set_state_message(
          entity     = entity
          msg        = new_message( id = /esrcc/cl_config_util=>c_config_msg number = '009' severity = if_abap_behv_message=>severity-error v1 = lo_weightage->get_field_text( fieldname = 'WEIGHTAGE' data_element = '/ESRCC/WEIGHTAGE' ) )
          state_area = CONV #( /esrcc/cl_config_util=>percentage )
        ).
      ENDIF.

      IF VALUE #( service_allocations[ serviceproduct = entity-serviceproduct
                                       costversion    = entity-costversion
                                       validfrom      = entity-validfromalloc ]-chargeout OPTIONAL ) = 'D'.
        lo_weightage->set_state_message(
          entity     = entity
          msg        = new_message( id = /esrcc/cl_config_util=>c_config_msg number = '012' severity = if_abap_behv_message=>severity-error )
          state_area = CONV #( /esrcc/cl_config_util=>child_non_mandatory )
        ).
      ENDIF.

      LOOP AT reported-weightage ASSIGNING FIELD-SYMBOL(<fs_reported>) WHERE %tky = entity-%tky AND %path IS NOT INITIAL.
        <fs_reported>-%path-serviceallocation-validfrom = entity-validfromalloc.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    DATA: weightage TYPE STRUCTURE FOR READ RESULT /esrcc/i_srvaloc_s\\weightage.

    DATA(lo_validation) = lcl_custom_validation=>create( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'ServiceAllocatioAll' )
                                      ( path = 'ServiceAllocation' ) )
        source_entity_name = '/ESRCC/C_ALLOCATIONWEIGHTAGE'
      CHANGING
        reported_entity    = reported-weightage
        failed_entity      = failed-weightage ) ).

    SELECT serviceproduct, costversion, validfromalloc, allockey, alloctype, allocationperiod
        FROM /esrcc/d_allocwg
        FOR ALL ENTRIES IN @entities
        WHERE serviceproduct = @entities-serviceproduct
          AND costversion    = @entities-costversion
          AND validfromalloc = @entities-validfromalloc
          AND allockey       = @entities-allockey
          AND alloctype      = @entities-alloctype
          AND draftentityoperationcode NOT IN ( 'D', 'L' )
        INTO TABLE @DATA(draft).

    LOOP AT entities INTO DATA(entity) WHERE %control-allocationperiod = if_abap_behv=>mk-on
                                          OR %control-refperiod = if_abap_behv=>mk-on
                                          OR %control-weightage = if_abap_behv=>mk-on.
      weightage = CORRESPONDING #( entity ).
      weightage-singletonid = '1'.

      IF entity-%control-allocationperiod = if_abap_behv=>mk-off.
        weightage-allocationperiod = VALUE #( draft[ serviceproduct = entity-serviceproduct
                                                     costversion    = entity-costversion
                                                     validfromalloc = entity-validfromalloc
                                                     allockey       = entity-allockey
                                                     alloctype      = entity-alloctype ]-allocationperiod OPTIONAL ).
      ENDIF.

      lo_validation->validate_weightage(
        entity  = weightage
        control = VALUE #( allocationperiod = entity-%control-allocationperiod
                           refperiod        = entity-%control-refperiod
                           weightage        = entity-%control-weightage )
      ).

      LOOP AT reported-weightage ASSIGNING FIELD-SYMBOL(<fs_reported>) WHERE %tky = entity-%tky AND %path IS NOT INITIAL.
        <fs_reported>-%path-serviceallocation-validfrom = entity-validfromalloc.
      ENDLOOP.
    ENDLOOP.
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
                                         ( entity = 'ServiceAllocation' table = '/ESRCC/SRVALOC' )
                                       ) ).
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_srvaloc_s DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR serviceallocatioall
        RESULT    result,
*      selectcustomizingtransptreq FOR MODIFY
*        IMPORTING
*                  keys   FOR ACTION serviceallocatioall~selectcustomizingtransptreq
*        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR serviceallocatioall
        RESULT result,
      precheck_cba_serviceallocation FOR PRECHECK
        IMPORTING entities FOR CREATE serviceallocatioall\_serviceallocation.
ENDCLASS.

CLASS lhc_/esrcc/i_srvaloc_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA: selecttransport_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled,
          edit_flag            TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.

    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
        iv_objectname = '/ESRCC/SRVALOC'
        iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    DATA(transport_service) = cl_bcfg_cd_reuse_api_factory=>get_transport_service_instance(
      iv_objectname = '/ESRCC/SRVALOC'
      iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table ).
    IF transport_service->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /esrcc/i_srvaloc_s IN LOCAL MODE
    ENTITY serviceallocatioall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(all).
    IF all[ 1 ]-%is_draft = if_abap_behv=>mk-off.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result = VALUE #( (
               %tky = all[ 1 ]-%tky
               %action-edit = edit_flag
               %assoc-_serviceallocation = edit_flag ) ).
*               %action-selectcustomizingtransptreq = selecttransport_flag ) ).
  ENDMETHOD.
*  METHOD selectcustomizingtransptreq.
*    MODIFY ENTITIES OF /esrcc/i_srvaloc_s IN LOCAL MODE
*      ENTITY serviceallocatioall
*        UPDATE FIELDS ( transportrequestid hidetransport )
*        WITH VALUE #( FOR key IN keys
*                        ( %tky               = key-%tky
*                          transportrequestid = key-%param-transportrequestid
*                          hidetransport      = abap_false ) ).
*
*    READ ENTITIES OF /esrcc/i_srvaloc_s IN LOCAL MODE
*      ENTITY serviceallocatioall
*        ALL FIELDS WITH CORRESPONDING #( keys )
*        RESULT DATA(entities).
*    result = VALUE #( FOR entity IN entities
*                        ( %tky   = entity-%tky
*                          %param = entity ) ).
*  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_SRVALOC' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
*    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_serviceallocation.
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_srvaloc_s DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_srvaloc_s IMPLEMENTATION.
  METHOD save_modified.
    DATA indirect TYPE TABLE OF /esrcc/srvaloc.

    READ TABLE update-serviceallocatioall INDEX 1 INTO DATA(all).
    IF all-transportrequestid IS NOT INITIAL.
      lhc_rap_tdat_cts=>get( )->record_changes(
                                  transport_request = all-transportrequestid
                                  create            = REF #( create )
                                  update            = REF #( update )
                                  delete            = REF #( delete ) ).
    ENDIF.

    IF update-serviceallocation IS INITIAL.
      RETURN.
    ENDIF.

    DATA(chargeout_modified) = update-serviceallocation.
    DELETE chargeout_modified WHERE %control-chargeout <> if_abap_behv=>mk-on.

    indirect = VALUE #( FOR dir IN chargeout_modified WHERE ( %control-chargeout = if_abap_behv=>mk-on AND chargeout = 'I' )
                        ( CORRESPONDING /esrcc/srvaloc( dir MAPPING cost_version          = costversion
                                                                    created_by            = createdby
                                                                    created_at            = createdat
                                                                    last_changed_by       = lastchangedby
                                                                    last_changed_at       = lastchangedat
                                                                    local_last_changed_at = locallastchangedat ) ) ).
    IF indirect IS NOT INITIAL.
      MODIFY indirect FROM VALUE #( ) TRANSPORTING consumption_version capacity_version WHERE consumption_version IS NOT INITIAL OR capacity_version IS NOT INITIAL.
      UPDATE /esrcc/srvaloc FROM TABLE @indirect.
    ENDIF.

    SELECT wgt~* FROM /esrcc/alloc_wgt AS wgt
      INNER JOIN @chargeout_modified AS ch
         ON ch~serviceproduct = wgt~serviceproduct
        AND ch~costversion = wgt~cost_version
        AND ch~validfrom = wgt~validfrom_alloc
      INTO TABLE @DATA(weightage).
    IF weightage IS NOT INITIAL.
      DELETE /esrcc/alloc_wgt FROM TABLE @weightage.
    ENDIF.

  ENDMETHOD.
  METHOD cleanup_finalize.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_srvaloc DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
*      validaterecordchanges FOR VALIDATE ON SAVE
*        IMPORTING
*          keys FOR serviceallocation~validaterecordchanges,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR serviceallocation
        RESULT result,
      validatedata FOR VALIDATE ON SAVE
        IMPORTING keys FOR serviceallocation~validatedata,
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE serviceallocation.
ENDCLASS.

CLASS lhc_/esrcc/i_srvaloc IMPLEMENTATION.
*  METHOD validaterecordchanges.
*    DATA change TYPE REQUEST FOR CHANGE /ESRCC/I_SrvAloc_S.
*    SELECT SINGLE TransportRequestID FROM /ESRCC/D_SRVAL_S INTO @DATA(TransportRequestID). "#EC CI_NOORDER
*    lhc_rap_tdat_cts=>get( )->validate_changes(
*                                transport_request = TransportRequestID
*                                table             = '/ESRCC/SRVALOC'
*                                keys              = REF #( keys )
*                                reported          = REF #( reported )
*                                failed            = REF #( failed )
*                                change            = REF #( change-ServiceAllocation ) ).
*  ENDMETHOD.
  METHOD get_global_features.
    DATA edit_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.
    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
         iv_objectname = '/ESRCC/SRVALOC'
         iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.

  METHOD validatedata.
    DATA draft TYPE STRUCTURE FOR READ RESULT /esrcc/i_srvaloc_s\\serviceallocation.

    READ ENTITIES OF /esrcc/i_srvaloc_s IN LOCAL MODE
         ENTITY serviceallocation
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

    " Draft version data
    SELECT alloc~*
      FROM /esrcc/d_srvaloc AS alloc
      INNER JOIN @keys AS key
         ON key~serviceproduct  = alloc~serviceproduct
        AND key~validfrom       <> alloc~validfrom
      WHERE alloc~draftentityoperationcode NOT IN ( 'D', 'L' )
      INTO TABLE @DATA(draft_entities).

    SELECT wgt~serviceproduct, wgt~costversion, wgt~validfromalloc, SUM( wgt~weightage ) AS weightage
      FROM /esrcc/d_allocwg AS wgt
      INNER JOIN @entities AS ent
         ON ent~serviceproduct = wgt~serviceproduct
        AND ent~costversion    = wgt~costversion
        AND ent~validfrom      = wgt~validfromalloc
      WHERE wgt~draftentityoperationcode NOT IN ( 'D', 'L' )
      GROUP BY wgt~serviceproduct, wgt~costversion, wgt~validfromalloc
      INTO TABLE @DATA(weightages).

    DATA(lo_service_allocation) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'ServiceAllocatioAll' ) )
        source_entity_name = '/ESRCC/C_SRVALOC'
      CHANGING
        reported_entity    = reported-serviceallocation
        failed_entity      = failed-serviceallocation ).

    DATA(lo_validation) = lcl_custom_validation=>create( config_util_ref = lo_service_allocation ).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_service_allocation(
        entity  = entity
        control = VALUE #( validto            = if_abap_behv=>mk-on
                           chargeout          = if_abap_behv=>mk-on
                           uom                = if_abap_behv=>mk-on
                           capacityversion    = if_abap_behv=>mk-on
                           consumptionversion = if_abap_behv=>mk-on
                           keyversion         = if_abap_behv=>mk-on )
      ).

      DATA(weightage) = VALUE #( weightages[ serviceproduct = entity-serviceproduct
                                             costversion    = entity-costversion
                                             validfromalloc = entity-validfrom ] OPTIONAL ).

      IF entity-chargeout = 'I'.
        " Validate Weightage %
        IF weightage IS INITIAL.
          lo_service_allocation->set_state_message(
            entity     = entity
            msg        = new_message( id = /esrcc/cl_config_util=>c_config_msg number = '011' severity = if_abap_behv_message=>severity-error )
            state_area = CONV #( /esrcc/cl_config_util=>child_mandatory )
          ).
        ELSEIF weightage-weightage <> 100.
          lo_service_allocation->set_state_message(
            entity     = entity
            msg        = new_message( id = /esrcc/cl_config_util=>c_config_msg number = '009' severity = if_abap_behv_message=>severity-error v1 = lo_service_allocation->get_field_text( fieldname = 'WEIGHTAGE' data_element = '/ESRCC/WEIGHTAGE' ) )
            state_area = CONV #( /esrcc/cl_config_util=>percentage )
          ).
        ENDIF.
      ENDIF.

      LOOP AT draft_entities ASSIGNING FIELD-SYMBOL(<draft>)
           WHERE     serviceproduct  = entity-serviceproduct
                 AND costversion     = entity-costversion
                 AND validfrom      <> entity-validfrom.
        draft = CORRESPONDING #( <draft> ).
        draft = CORRESPONDING #( BASE ( draft ) entity MAPPING %is_draft = %is_draft singletonid = singletonid EXCEPT * ).
        lo_service_allocation->validate_overlapping_validity( EXPORTING src_from    = <draft>-validfrom
                                                                        src_to      = <draft>-validto
                                                                        src_entity  = draft
                                                                        curr_from   = entity-validfrom
                                                                        curr_to     = entity-validto
                                                                        curr_entity = entity ).
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = lcl_custom_validation=>create( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'ServiceAllocatioAll' ) )
        source_entity_name = '/ESRCC/C_SRVALOC'
      CHANGING
        reported_entity    = reported-serviceallocation
        failed_entity      = failed-serviceallocation ) ).

    SELECT serviceproduct, validfrom, costversion, chargeout
      FROM /esrcc/d_srvaloc
      FOR ALL ENTRIES IN @entities
      WHERE serviceproduct = @entities-serviceproduct
        AND costversion    = @entities-costversion
        AND validfrom      = @entities-validfrom
      INTO TABLE @DATA(allocation).

    LOOP AT entities INTO DATA(entity) WHERE %control-chargeout          = if_abap_behv=>mk-on
                                          OR %control-uom                = if_abap_behv=>mk-on
                                          OR %control-capacityversion    = if_abap_behv=>mk-on
                                          OR %control-consumptionversion = if_abap_behv=>mk-on
                                          OR %control-keyversion         = if_abap_behv=>mk-on
                                          OR %control-validto            = if_abap_behv=>mk-on.

      IF entity-%control-chargeout = if_abap_behv=>mk-off.
        entity-chargeout = VALUE #( allocation[ serviceproduct = entity-serviceproduct
                                                costversion    = entity-costversion
                                                validfrom      = entity-validfrom ]-chargeout OPTIONAL ).
      ENDIF.

      lo_validation->validate_service_allocation(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( chargeout          = entity-%control-chargeout
                           uom                = entity-%control-uom
                           capacityversion    = entity-%control-capacityversion
                           consumptionversion = entity-%control-consumptionversion
                           keyversion         = entity-%control-keyversion
                           validto            = entity-%control-validto ) ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
