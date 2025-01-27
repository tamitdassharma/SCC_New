CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_cost_element TYPE STRUCTURE FOR READ RESULT /ESRCC/I_CostElements_S\\CostElement,

      BEGIN OF ts_control,
        sysid       TYPE if_abap_behv=>t_xflag,
        legalentity TYPE if_abap_behv=>t_xflag,
        companycode TYPE if_abap_behv=>t_xflag,
        costelement TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_cost_element
        IMPORTING
          entity  TYPE ts_cost_element
          control TYPE ts_control,
      check_duplicate
        IMPORTING
          entity TYPE ts_cost_element.

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

    IF control-sysid         = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'SYSID' ) TO fields. ENDIF.
    IF control-legalentity   = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'LEGALENTITY' ) TO fields. ENDIF.
    IF control-companycode   = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'COMPANYCODE' ) TO fields. ENDIF.
    IF control-costelement   = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'COSTELEMENT' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
  ENDMETHOD.

  METHOD check_duplicate.
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
                                         ( entity = 'CostElements' table = '/ESRCC/CST_ELMNT' )
                                         ( entity = 'CostElementsText' table = '/ESRCC/CST_ELMTT' )
                                       ) ).
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_costelements_s DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR CostElementsAll
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR CostElementsAll
        RESULT result,
      precheck_cba_Costelements FOR PRECHECK
        IMPORTING entities FOR CREATE CostElementsAll\_Costelements.
ENDCLASS.

CLASS lhc_/esrcc/i_costelements_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA: selecttransport_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled,
          edit_flag            TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.

    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
        iv_objectname = '/ESRCC/CST_ELMNT'
        iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    DATA(transport_service) = cl_bcfg_cd_reuse_api_factory=>get_transport_service_instance(
                                iv_objectname = '/ESRCC/CST_ELMNT'
                                iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table ).
    IF transport_service->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /ESRCC/I_CostElements_S IN LOCAL MODE
    ENTITY CostElementsAll
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(all).
    IF all[ 1 ]-%is_draft = if_abap_behv=>mk-off.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result = VALUE #( (
               %tky = all[ 1 ]-%tky
               %action-edit = edit_flag
               %assoc-_CostElements = edit_flag ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_COSTELEMENTS' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%update      = is_authorized.
    result-%action-Edit = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_Costelements.
    TYPES ts_cost_element TYPE STRUCTURE FOR READ RESULT /ESRCC/I_CostElements_S\\CostElement.

    DATA(lo_cost_element) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'CostElementsAll' ) )
        source_entity_name = '/ESRCC/C_COSTELEMENTS'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported-costelement
        failed_entity      = failed-costelement
    ).

*    DATA(lo_cost_element) = /esrcc/cl_config_cost_element=>create_sub_instance(
*                         EXPORTING
*                           paths              = VALUE #( ( path = 'CostElementsAll' ) )
*                           source_entity_name = '/ESRCC/C_COSTELEMENTS'
*                           is_transition      = abap_true
*                         CHANGING
*                           reported_entity    = reported-costelement
*                           failed_entity      = failed-costelement
*                       ).
*
*    lo_cost_element->validate_duplicate( entities = entities[ 1 ]-%target ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_cost_element ).

    DATA(target_entities) = entities[ 1 ]-%target.

    DATA: ls_entity TYPE ts_cost_element.

    SELECT
        new~Sysid, new~LegalEntity, new~CompanyCode, new~CostElement
      FROM @target_entities AS new
      LEFT OUTER JOIN /esrcc/cst_elmnt AS db
        ON  db~sysid        = new~Sysid
        AND db~legal_entity = new~LegalEntity
        AND db~company_code = new~CompanyCode
        AND db~cost_element = new~CostElement
      LEFT OUTER JOIN /esrcc/d_cstelmt AS draft
        ON  draft~sysid       = new~Sysid
        AND draft~legalentity = new~LegalEntity
        AND draft~companycode = new~CompanyCode
        AND draft~costelement = new~CostElement
      WHERE db~sysid IS NOT NULL OR draft~sysid IS NOT NULL
      INTO TABLE @DATA(duplicate_entities).

    LOOP AT entities[ 1 ]-%target INTO DATA(entity).
*      lo_cost_center->check_authorization(
*        EXPORTING
*          entity      = CORRESPONDING ts_cost_center( entity )
*          cost_object = entity-costobject
*          activity    = /esrcc/cl_config_util=>c_authorization_activity-create
*      ).

      IF line_exists( duplicate_entities[ Sysid       = entity-Sysid
                                          LegalEntity = entity-LegalEntity
                                          CompanyCode = entity-CompanyCode
                                          CostElement = entity-CostElement ] ).
        lo_cost_element->set_state_message(
          entity     = CORRESPONDING ts_cost_element( entity )
          msg        = new_message(
                         id       = /esrcc/cl_config_util=>c_config_msg
                         number   = '023'
                         severity = if_abap_behv_message=>severity-error
                       )
          state_area = CONV #( /esrcc/cl_config_util=>duplicate )
        ).
        CONTINUE.
      ENDIF.

      lo_validation->validate_cost_element(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( sysid       = if_abap_behv=>mk-on
                           legalentity = if_abap_behv=>mk-on
                           companycode = if_abap_behv=>mk-on
                           costelement = if_abap_behv=>mk-on )
      ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_costelements_s DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_costelements_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-CostElementsAll INDEX 1 INTO DATA(all).
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
CLASS lhc_/esrcc/i_costelements DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR CostElement
        RESULT result,
      ValidateData FOR VALIDATE ON SAVE
        IMPORTING keys FOR CostElement~ValidateData,
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE CostElement.
ENDCLASS.

CLASS lhc_/esrcc/i_costelements IMPLEMENTATION.
  METHOD get_global_features.
    DATA edit_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.
    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
         iv_objectname = '/ESRCC/CST_ELMNT'
         iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
    result-%assoc-_CostElementsText = edit_flag.
  ENDMETHOD.
  METHOD ValidateData.
    READ ENTITIES OF /ESRCC/I_CostElements_S IN LOCAL MODE
        ENTITY CostElement
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'CostElementsAll' ) )
        source_entity_name = '/ESRCC/C_COSTELEMENTS'
      CHANGING
        reported_entity    = reported-costelement
        failed_entity      = failed-costelement ) ).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>) WHERE Sysid IS INITIAL
                                                         OR LegalEntity IS INITIAL
                                                         OR CompanyCode IS INITIAL
                                                         OR CostElement IS INITIAL.
      lo_validation->validate_cost_element(
        entity  = <entity>
        control = VALUE #( sysid         = if_abap_behv=>mk-on
                           legalentity   = if_abap_behv=>mk-on
                           companycode   = if_abap_behv=>mk-on
                           costelement   = if_abap_behv=>mk-on )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
        EXPORTING
          paths              = VALUE #( ( path = 'CostElementsAll' ) )
          source_entity_name = '/ESRCC/C_COSTELEMENTS'
        CHANGING
          reported_entity    = reported-costelement
          failed_entity      = failed-costelement ) ).

    LOOP AT entities INTO DATA(entity) WHERE %control-Sysid            = if_abap_behv=>mk-on
                                          OR %control-LegalEntity      = if_abap_behv=>mk-on
                                          OR %control-CompanyCode      = if_abap_behv=>mk-on
                                          OR %control-CostElement      = if_abap_behv=>mk-on.
      lo_validation->validate_cost_element(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( sysid         = entity-%control-Sysid
                           legalentity   = entity-%control-LegalEntity
                           companycode   = entity-%control-CompanyCode
                           costelement   = entity-%control-CostElement )
      ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
CLASS lhc_/esrcc/i_costelementstext DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR CostElementsText
        RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_costelementstext IMPLEMENTATION.
  METHOD get_global_features.
    DATA edit_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.
    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
         iv_objectname = '/ESRCC/CST_ELMTT'
         iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.
ENDCLASS.
