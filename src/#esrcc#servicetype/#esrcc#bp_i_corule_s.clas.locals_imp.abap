CLASS lcl_custom_validation DEFINITION INHERITING FROM cl_abap_behv.
  PUBLIC SECTION.
    TYPES:
      ts_rule      TYPE STRUCTURE FOR READ RESULT /ESRCC/I_CoRule_S\\Rule,
      ts_weightage TYPE STRUCTURE FOR READ RESULT /ESRCC/I_CoRule_S\\Weightage,

      BEGIN OF ts_control_rule,
        costversion        TYPE if_abap_behv=>t_xflag,
        chargeoutmethod    TYPE if_abap_behv=>t_xflag,
        capacityversion    TYPE if_abap_behv=>t_xflag,
        consumptionversion TYPE if_abap_behv=>t_xflag,
        keyversion         TYPE if_abap_behv=>t_xflag,
        uom                TYPE if_abap_behv=>t_xflag,
        adhocallocationkey TYPE if_abap_behv=>t_xflag,
      END OF ts_control_rule,

      BEGIN OF ts_control_weightage,
        allocationperiod TYPE if_abap_behv=>t_xflag,
        refperiod        TYPE if_abap_behv=>t_xflag,
        weightage        TYPE if_abap_behv=>t_xflag,
      END OF ts_control_weightage.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_rule
        IMPORTING
          entity  TYPE ts_rule
          control TYPE ts_control_rule,
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
    DATA: config_util_ref TYPE REF TO /esrcc/cl_config_util,
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

  METHOD validate_rule.
    DATA:
      fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    DATA(co_rule_relevances) = /esrcc/cl_config_util=>get_co_rule_config( ).
    DATA(co_rule_relevance) = VALUE #( co_rule_relevances[ chargeout_method = entity-ChargeoutMethod ] ).

    IF control-chargeoutmethod = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'CHARGEOUTMETHOD' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields     = fields
      entity     = entity
    ).

    CLEAR fields.

    IF control-costversion = if_abap_behv=>mk-on AND co_rule_relevance-cost_version = abap_true.
      APPEND VALUE #( fieldname = 'COSTVERSION' ) TO fields.
    ENDIF.

    IF control-capacityversion = if_abap_behv=>mk-on AND co_rule_relevance-capacity_version = abap_true.
      APPEND VALUE #( fieldname = 'CAPACITYVERSION' ) TO fields.
    ENDIF.

    IF control-consumptionversion = if_abap_behv=>mk-on AND co_rule_relevance-consumption_version = abap_true.
      APPEND VALUE #( fieldname = 'CONSUMPTIONVERSION' ) TO fields.
    ENDIF.

    IF control-uom = if_abap_behv=>mk-on AND co_rule_relevance-uom = abap_true.
      APPEND VALUE #( fieldname = 'UOM' ) TO fields.
    ENDIF.

    IF control-keyversion = if_abap_behv=>mk-on AND co_rule_relevance-key_version = abap_true.
      APPEND VALUE #( fieldname = 'KEYVERSION' ) TO fields.
    ENDIF.

    IF control-adhocallocationkey = if_abap_behv=>mk-on AND co_rule_relevance-adhoc_allocation_key = abap_true.
      APPEND VALUE #( fieldname = 'ADHOCALLOCATIONKEY' ) TO fields.
    ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
  ENDMETHOD.

  METHOD validate_weightage.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF gt_ref_period IS INITIAL.
      SELECT DISTINCT *
        FROM /esrcc/i_allocationperiod
        INTO TABLE @gt_ref_period.                      "#EC CI_NOWHERE
    ENDIF.

    IF control-allocationperiod = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'ALLOCATIONPERIOD' ) TO fields. ENDIF.

    IF control-refperiod = if_abap_behv=>mk-on.
      IF entity-allocationperiod = '03' OR entity-allocationperiod = '04' OR entity-allocationperiod = '06'.
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
      IMPORTING REQUEST requested_features FOR Weightage RESULT result.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE Weightage.
    METHODS ValidateData FOR VALIDATE ON SAVE
      IMPORTING keys FOR Weightage~ValidateData.

ENDCLASS.

CLASS lhc_weightage IMPLEMENTATION.

  METHOD get_global_features.
    DATA edit_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.
    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
         iv_objectname = '/ESRCC/ALOC_WGT'
         iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.

  METHOD precheck_update.
    DATA: weightage TYPE STRUCTURE FOR READ RESULT /ESRCC/I_CoRule_S\\Weightage.

    DATA(lo_validation) = lcl_custom_validation=>create( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'RuleAll' )
                                      ( path = 'Rule' ) )
        source_entity_name = '/ESRCC/C_ALLOCWEIGHTAGE'
      CHANGING
        reported_entity    = reported-weightage
        failed_entity      = failed-weightage ) ).

    SELECT ruleid, allocationkey, allocationperiod
        FROM /esrcc/d_alocwgt
        FOR ALL ENTRIES IN @entities
        WHERE ruleid        = @entities-ruleid
          AND allocationkey = @entities-allocationkey
          AND draftentityoperationcode NOT IN ( 'D', 'L' )
        INTO TABLE @DATA(draft).

    LOOP AT entities INTO DATA(entity) WHERE %control-allocationperiod = if_abap_behv=>mk-on
                                          OR %control-refperiod        = if_abap_behv=>mk-on
                                          OR %control-weightage        = if_abap_behv=>mk-on.
      weightage = CORRESPONDING #( entity ).
*      weightage-singletonid = '1'.     " Commented to avoid dump, that occurs when removing the value of mandatory field and hitting enter without tab out.

      IF entity-%control-allocationperiod = if_abap_behv=>mk-off.
        weightage-allocationperiod = VALUE #( draft[ ruleid        = entity-ruleid
                                                     allocationkey = entity-allocationkey ]-allocationperiod OPTIONAL ).
      ENDIF.

      lo_validation->validate_weightage(
        entity  = weightage
        control = VALUE #( allocationperiod = entity-%control-allocationperiod
                           refperiod        = entity-%control-refperiod
                           weightage        = entity-%control-weightage )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD ValidateData.
    DATA:
      fieldnames TYPE /esrcc/cl_config_util=>tt_fields,
      ls_rule    TYPE STRUCTURE FOR READ RESULT /ESRCC/I_CoRule_S\\Rule.

    READ ENTITIES OF /ESRCC/I_CoRule_S IN LOCAL MODE
         ENTITY Weightage
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

    DATA(unique_entities) = entities.
    SORT unique_entities BY RuleId.
    DELETE ADJACENT DUPLICATES FROM unique_entities COMPARING RuleId.

    SELECT ent~%is_draft AS is_draft, ent~singletonid, wgt~ruleid, SUM( wgt~weightage ) AS weightage
      FROM /esrcc/d_alocwgt AS wgt
      INNER JOIN @unique_entities AS ent
        ON  ent~RuleId = wgt~ruleid
      WHERE wgt~draftentityoperationcode NOT IN ( 'D', 'L' )
    GROUP BY ent~%is_draft, ent~singletonid, wgt~ruleid
      HAVING SUM( wgt~weightage ) <> 100
      INTO TABLE @DATA(weightages).

    DATA(lo_weightage) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'RuleAll' )
                                      ( path = 'Rule' ) )
        source_entity_name = '/ESRCC/C_ALLOCWEIGHTAGE'
      CHANGING
        reported_entity    = reported-weightage
        failed_entity      = failed-weightage ).

    DATA(lo_validation) = lcl_custom_validation=>create( config_util_ref = lo_weightage ).

    READ ENTITIES OF /ESRCC/I_CoRule_S IN LOCAL MODE
        ENTITY Rule
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(rules).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_weightage(
        entity  = entity
        control = VALUE #( allocationperiod = if_abap_behv=>mk-on
                           refperiod        = if_abap_behv=>mk-on
                           weightage        = if_abap_behv=>mk-on )
      ).

      IF line_exists( weightages[ ruleid = entity-RuleId ] ).
        lo_weightage->set_state_message(
          entity     = entity
          msg        = new_message( id = /esrcc/cl_config_util=>c_config_msg number = '009' severity = if_abap_behv_message=>severity-error v1 = lo_weightage->get_field_text( fieldname = 'WEIGHTAGE' data_element = '/ESRCC/WEIGHTAGE' ) )
          state_area = CONV #( /esrcc/cl_config_util=>percentage )
        ).
      ENDIF.

      IF VALUE #( rules[ RuleId = entity-RuleId ]-ChargeoutMethod OPTIONAL ) = 'D'.
        lo_weightage->set_state_message(
          entity     = entity
          msg        = new_message( id = /esrcc/cl_config_util=>c_config_msg number = '012' severity = if_abap_behv_message=>severity-error )
          state_area = CONV #( /esrcc/cl_config_util=>child_non_mandatory )
        ).
      ENDIF.
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
                                         ( entity = 'Rule' table = '/ESRCC/CO_RULE' )
                                         ( entity = 'RuleText' table = '/ESRCC/CO_RULET' )
                                       ) ).
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_corule_s DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR RuleAll
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION RuleAll~SelectCustomizingTransptReq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR RuleAll
        RESULT result,
      precheck_cba_Rule FOR PRECHECK
        IMPORTING entities FOR CREATE RuleAll\_Rule.
ENDCLASS.

CLASS lhc_/esrcc/i_corule_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA: selecttransport_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled,
          edit_flag            TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.

    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
        iv_objectname = '/ESRCC/CO_RULE'
        iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    DATA(transport_service) = cl_bcfg_cd_reuse_api_factory=>get_transport_service_instance(
                                iv_objectname = '/ESRCC/CO_RULE'
                                iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table ).
    IF transport_service->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /ESRCC/I_CoRule_S IN LOCAL MODE
    ENTITY RuleAll
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(all).
    IF all[ 1 ]-%is_draft = if_abap_behv=>mk-off.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result = VALUE #( (
               %tky = all[ 1 ]-%tky
               %action-edit = edit_flag
               %assoc-_Rule = edit_flag
               %action-SelectCustomizingTransptReq = selecttransport_flag ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF /ESRCC/I_CoRule_S IN LOCAL MODE
      ENTITY RuleAll
        UPDATE FIELDS ( TransportRequestID HideTransport )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          TransportRequestID = key-%param-transportrequestid
                          HideTransport      = abap_false ) ).

    READ ENTITIES OF /ESRCC/I_CoRule_S IN LOCAL MODE
      ENTITY RuleAll
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_CORULE' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%update      = is_authorized.
    result-%action-Edit = is_authorized.
    result-%action-SelectCustomizingTransptReq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_Rule.
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_corule_s DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
*      adjust_numbers REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_corule_s IMPLEMENTATION.
  METHOD save_modified.
    DATA:
      co_rules TYPE TABLE OF /esrcc/co_rule,
      rule_ids TYPE RANGE OF /esrcc/chargeout_rule_id.

    READ TABLE update-RuleAll INDEX 1 INTO DATA(all).
    IF all-TransportRequestID IS NOT INITIAL.
      lhc_rap_tdat_cts=>get( )->record_changes(
                                  transport_request = all-TransportRequestID
                                  create            = REF #( create )
                                  update            = REF #( update )
                                  delete            = REF #( delete ) ).
    ENDIF.

    IF update-rule IS INITIAL.
      RETURN.
    ENDIF.

*    DATA(chargeout_modified) = update-rule.
    DATA(co_rule_relevances) = /esrcc/cl_config_util=>get_co_rule_config( ).

*    LOOP AT chargeout_modified ASSIGNING FIELD-SYMBOL(<chargeout>) WHERE %control-ChargeoutMethod <> if_abap_behv=>mk-on.
    LOOP AT update-rule ASSIGNING FIELD-SYMBOL(<chargeout>) WHERE %control-ChargeoutMethod <> if_abap_behv=>mk-on.
      DATA(co_rule_relevance) = VALUE #( co_rule_relevances[ chargeout_method = <chargeout>-ChargeoutMethod ] OPTIONAL ).

      APPEND VALUE /esrcc/co_rule( rule_id = <chargeout>-RuleId
                                   chargeout_method      = <chargeout>-ChargeoutMethod
                                   cost_version          = COND #( WHEN co_rule_relevance-cost_version         = abap_true THEN <chargeout>-CostVersion )
                                   capacity_version      = COND #( WHEN co_rule_relevance-capacity_version     = abap_true THEN <chargeout>-CapacityVersion )
                                   consumption_version   = COND #( WHEN co_rule_relevance-consumption_version  = abap_true THEN <chargeout>-ConsumptionVersion )
                                   key_version           = COND #( WHEN co_rule_relevance-key_version          = abap_true THEN <chargeout>-KeyVersion )
                                   uom                   = COND #( WHEN co_rule_relevance-uom                  = abap_true THEN <chargeout>-Uom )
                                   adhoc_allocation_key  = COND #( WHEN co_rule_relevance-adhoc_allocation_key = abap_true THEN <chargeout>-AdhocAllocationKey )
                                   created_by            = <chargeout>-CreatedBy
                                   created_at            = <chargeout>-CreatedAt
                                   last_changed_by       = <chargeout>-LastChangedBy
                                   last_changed_at       = <chargeout>-LastChangedAt
                                   local_last_changed_at = <chargeout>-LocalLastChangedAt ) TO co_rules.

      IF co_rule_relevance-weightage_tab = abap_false.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = <chargeout>-RuleId ) TO rule_ids.
      ENDIF.
    ENDLOOP.

*      indirect = VALUE #( FOR dir IN chargeout_modified WHERE ( %control-ChargeoutMethod = if_abap_behv=>mk-on AND ChargeoutMethod = 'I' )
*                          ( CORRESPONDING /esrcc/co_rule( dir MAPPING cost_version          = costversion
*                                                                      created_by            = createdby
*                                                                      created_at            = createdat
*                                                                      last_changed_by       = lastchangedby
*                                                                      last_changed_at       = lastchangedat
*                                                                      local_last_changed_at = locallastchangedat ) ) ).
*      IF indirect IS NOT INITIAL.
*        MODIFY indirect FROM VALUE #( ) TRANSPORTING consumption_version capacity_version WHERE consumption_version IS NOT INITIAL OR capacity_version IS NOT INITIAL.
*        UPDATE /esrcc/co_rule FROM TABLE @indirect.
*      ENDIF.

    IF co_rules IS NOT INITIAL.
      UPDATE /esrcc/co_rule FROM TABLE @co_rules.
    ENDIF.

*    SELECT wgt~* FROM /esrcc/aloc_wgt AS wgt
*      INNER JOIN @chargeout_modified AS ch
*         ON ch~ruleid = wgt~rule_id
*      INTO TABLE @DATA(weightage).
*    IF weightage IS NOT INITIAL.
    IF rule_ids IS NOT INITIAL.
*      DELETE /esrcc/aloc_wgt FROM TABLE @weightage.
      DELETE FROM /esrcc/aloc_wgt WHERE rule_id IN @rule_ids.
    ENDIF.
  ENDMETHOD.
  METHOD cleanup_finalize.
  ENDMETHOD.

*  METHOD adjust_numbers.
**    EXIT.
*  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_corule DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validaterecordchanges FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR Rule~ValidateRecordChanges,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR Rule
        RESULT result,
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE Rule.

    METHODS ValidateData FOR VALIDATE ON SAVE
      IMPORTING keys FOR Rule~ValidateData.
ENDCLASS.

CLASS lhc_/esrcc/i_corule IMPLEMENTATION.
  METHOD validaterecordchanges.
    DATA change TYPE REQUEST FOR CHANGE /ESRCC/I_CoRule_S.
    SELECT SINGLE TransportRequestID FROM /esrcc/d_co_ru_s INTO @DATA(TransportRequestID). "#EC CI_NOORDER
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = TransportRequestID
                                table             = '/ESRCC/CO_RULE'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-Rule ) ).
  ENDMETHOD.
  METHOD get_global_features.
    DATA edit_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.
    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
         iv_objectname = '/ESRCC/CO_RULE'
         iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
    result-%assoc-_RuleText = edit_flag.
  ENDMETHOD.
  METHOD precheck_update.
    DATA(lo_validation) = lcl_custom_validation=>create( config_util_ref = /esrcc/cl_config_util=>create(
        EXPORTING
          paths              = VALUE #( ( path = 'RuleAll' ) )
          source_entity_name = '/ESRCC/C_CORULE'
        CHANGING
          reported_entity    = reported-rule
          failed_entity      = failed-rule ) ).

    SELECT ruleid, chargeoutmethod
      FROM /esrcc/d_co_rule
      FOR ALL ENTRIES IN @entities
      WHERE ruleid = @entities-ruleid
      INTO TABLE @DATA(rules).

    LOOP AT entities INTO DATA(entity) WHERE %control-ChargeoutMethod    = if_abap_behv=>mk-on
                                          OR %control-CostVersion        = if_abap_behv=>mk-on
                                          OR %control-uom                = if_abap_behv=>mk-on
                                          OR %control-capacityversion    = if_abap_behv=>mk-on
                                          OR %control-consumptionversion = if_abap_behv=>mk-on
                                          OR %control-keyversion         = if_abap_behv=>mk-on
                                          OR %control-AdhocAllocationKey = if_abap_behv=>mk-on.

      IF entity-%control-ChargeoutMethod = if_abap_behv=>mk-off.
        entity-ChargeoutMethod = VALUE #( rules[ ruleid = entity-ruleid ]-chargeoutmethod OPTIONAL ).
      ENDIF.

      lo_validation->validate_rule(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( chargeoutmethod    = entity-%control-ChargeoutMethod
                           costversion        = entity-%control-CostVersion
                           uom                = entity-%control-uom
                           capacityversion    = entity-%control-capacityversion
                           consumptionversion = entity-%control-consumptionversion
                           keyversion         = entity-%control-keyversion
                           adhocallocationkey = entity-%control-AdhocAllocationKey ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD ValidateData.
    DATA draft TYPE STRUCTURE FOR READ RESULT /ESRCC/I_CoRule_S\\Rule.

    READ ENTITIES OF /ESRCC/I_CoRule_S IN LOCAL MODE
         ENTITY Rule
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

    SELECT wgt~ruleid, SUM( wgt~weightage ) AS weightage
      FROM /esrcc/d_alocwgt AS wgt
      INNER JOIN @entities AS ent
         ON ent~ruleid = wgt~ruleid
      WHERE wgt~draftentityoperationcode NOT IN ( 'D', 'L' )
      GROUP BY wgt~ruleid
      INTO TABLE @DATA(weightages).

    DATA(lo_rule) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'RuleAll' ) )
        source_entity_name = '/ESRCC/C_CORULE'
      CHANGING
        reported_entity    = reported-rule
        failed_entity      = failed-rule ).

    DATA(lo_validation) = lcl_custom_validation=>create( config_util_ref = lo_rule ).

    DATA(co_rule_relevances) = /esrcc/cl_config_util=>get_co_rule_config( ).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_rule(
        entity  = entity
        control = VALUE #( chargeoutmethod    = if_abap_behv=>mk-on
                           costversion        = if_abap_behv=>mk-on
                           uom                = if_abap_behv=>mk-on
                           capacityversion    = if_abap_behv=>mk-on
                           consumptionversion = if_abap_behv=>mk-on
                           keyversion         = if_abap_behv=>mk-on
                           adhocallocationkey = if_abap_behv=>mk-on )
      ).

      DATA(weightage) = VALUE #( weightages[ ruleid = entity-ruleid ] OPTIONAL ).

*      IF entity-ChargeoutMethod = 'I'.
      IF VALUE #( co_rule_relevances[ chargeout_method = entity-ChargeoutMethod ]-weightage_tab OPTIONAL ) = abap_true.
        " Validate Weightage %
        IF weightage IS INITIAL.
          lo_rule->set_state_message(
            entity     = entity
            msg        = new_message( id = /esrcc/cl_config_util=>c_config_msg number = '011' severity = if_abap_behv_message=>severity-error )
            state_area = CONV #( /esrcc/cl_config_util=>child_mandatory )
          ).
        ELSEIF weightage-weightage <> 100.
          lo_rule->set_state_message(
            entity     = entity
            msg        = new_message( id = /esrcc/cl_config_util=>c_config_msg number = '009' severity = if_abap_behv_message=>severity-error v1 = lo_rule->get_field_text( fieldname = 'WEIGHTAGE' data_element = '/ESRCC/WEIGHTAGE' ) )
            state_area = CONV #( /esrcc/cl_config_util=>percentage )
          ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
CLASS lhc_/esrcc/i_coruletext DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      validaterecordchanges FOR VALIDATE ON SAVE
        IMPORTING
          keys FOR RuleText~ValidateRecordChanges,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR RuleText
        RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_coruletext IMPLEMENTATION.
  METHOD validaterecordchanges.
    DATA change TYPE REQUEST FOR CHANGE /ESRCC/I_CoRule_S.
    SELECT SINGLE TransportRequestID FROM /esrcc/d_co_ru_s INTO @DATA(TransportRequestID). "#EC CI_NOORDER
    lhc_rap_tdat_cts=>get( )->validate_changes(
                                transport_request = TransportRequestID
                                table             = '/ESRCC/CO_RULET'
                                keys              = REF #( keys )
                                reported          = REF #( reported )
                                failed            = REF #( failed )
                                change            = REF #( change-RuleText ) ).
  ENDMETHOD.
  METHOD get_global_features.
    DATA edit_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.
    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
         iv_objectname = '/ESRCC/CO_RULET'
         iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.
ENDCLASS.
