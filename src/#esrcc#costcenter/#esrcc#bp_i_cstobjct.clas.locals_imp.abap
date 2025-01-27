CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_cost_object TYPE STRUCTURE FOR READ RESULT /ESRCC/I_CstObjct_S\\CostObject,

      BEGIN OF ts_control,
        sysid         TYPE if_abap_behv=>t_xflag,
        legalentity   TYPE if_abap_behv=>t_xflag,
        companycode   TYPE if_abap_behv=>t_xflag,
        costobject    TYPE if_abap_behv=>t_xflag,
        costcenter    TYPE if_abap_behv=>t_xflag,
        billfrequency TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_cost_object
        IMPORTING
          entity  TYPE ts_cost_object
          control TYPE ts_control.

  PRIVATE SECTION.
    DATA: config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_cost_object.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-sysid         = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'SYSID' ) TO fields. ENDIF.
    IF control-legalentity   = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'LEGALENTITY' ) TO fields. ENDIF.
    IF control-companycode   = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'COMPANYCODE' ) TO fields. ENDIF.
    IF control-costobject    = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'COSTOBJECT' ) TO fields. ENDIF.
    IF control-costcenter    = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'COSTCENTER' ) TO fields. ENDIF.
    IF control-billfrequency = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'BILLINGFREQUENCY' ) TO fields. ENDIF.

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
                                         ( entity = 'CostObject' table = '/ESRCC/CST_OBJCT' )
                                         ( entity = 'CostObjectText' table = '/ESRCC/CST_OBJTT' )
                                       ) ).
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_cstobjct_s DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR CostObjectAll
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR CostObjectAll
        RESULT result,
      edit FOR MODIFY
        IMPORTING keys FOR ACTION CostObjectAll~edit,
      precheck_cba_Costobject FOR PRECHECK
        IMPORTING entities FOR CREATE CostObjectAll\_Costobject.
ENDCLASS.

CLASS lhc_/esrcc/i_cstobjct_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA: selecttransport_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled,
          edit_flag            TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.

    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
        iv_objectname = '/ESRCC/CST_OBJCT'
        iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    DATA(transport_service) = cl_bcfg_cd_reuse_api_factory=>get_transport_service_instance(
                                iv_objectname = '/ESRCC/CST_OBJCT'
                                iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table ).
    IF transport_service->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /ESRCC/I_CstObjct_S IN LOCAL MODE
    ENTITY CostObjectAll
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(all).
    IF all[ 1 ]-%is_draft = if_abap_behv=>mk-off.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result = VALUE #( (
               %tky = all[ 1 ]-%tky
               %action-edit = edit_flag
               %assoc-_CostObject = edit_flag ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_CSTOBJCT' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%update      = is_authorized.
    result-%action-Edit = is_authorized.
  ENDMETHOD.

  METHOD edit.
    DATA(lo_util) = /esrcc/cl_config_util=>create_for_authorization( ).
    SELECT DISTINCT LegalEntity, costobject FROM /ESRCC/I_CstObjct INTO TABLE @DATA(cost_objects). "#EC CI_NOWHERE

    LOOP AT cost_objects INTO DATA(cost_object).
      DATA(is_unauthorized) = lo_util->is_unauthorized(
        EXPORTING
          legal_entity = cost_object-LegalEntity
          cost_object  = cost_object-CostObject
          create       = abap_true
          update       = abap_true
          delete       = abap_true
      ).

      IF is_unauthorized = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF is_unauthorized = abap_true.
      reported-costobjectall = VALUE #( ( %msg = new_message( id       = /esrcc/cl_config_util=>c_config_msg
                                                              number   = '019'
                                                              severity = if_abap_behv_message=>severity-success ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD precheck_cba_Costobject.
    TYPES ts_cost_object TYPE STRUCTURE FOR READ RESULT /ESRCC/I_CstObjct_S\\CostObject.

    DATA(lo_cost_object) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'CostObjectAll' ) )
        source_entity_name = '/ESRCC/C_CSTOBJCT'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported-costobject
        failed_entity      = failed-costobject
    ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_cost_object ).

    LOOP AT entities[ 1 ]-%target INTO DATA(entity).
*      lo_cost_center->check_authorization(
*        EXPORTING
*          entity      = CORRESPONDING ts_cost_center( entity )
*          cost_object = entity-costobject
*          activity    = /esrcc/cl_config_util=>c_authorization_activity-create
*      ).

      lo_validation->validate_cost_object(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( sysid         = if_abap_behv=>mk-on
                           legalentity   = if_abap_behv=>mk-on
                           companycode   = if_abap_behv=>mk-on
                           costobject    = if_abap_behv=>mk-on
                           costcenter    = if_abap_behv=>mk-on
                           billfrequency = if_abap_behv=>mk-on )
      ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_cstobjct_s DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_cstobjct_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-CostObjectAll INDEX 1 INTO DATA(all).
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
CLASS lhc_/esrcc/i_cstobjct DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE CostObject,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR CostObject RESULT result.
    METHODS ValidateData FOR VALIDATE ON SAVE
      IMPORTING keys FOR CostObject~ValidateData.
    METHODS precheck_delete FOR PRECHECK
      IMPORTING keys FOR DELETE CostObject.
ENDCLASS.

CLASS lhc_/esrcc/i_cstobjct IMPLEMENTATION.
  METHOD precheck_update.
    DATA(lo_cost_object) = /esrcc/cl_config_util=>create(
        EXPORTING
          paths              = VALUE #( ( path = 'CostObjectAll' ) )
          source_entity_name = '/ESRCC/C_CSTOBJCT'
        CHANGING
          reported_entity    = reported-costobject
          failed_entity      = failed-costobject ).

    IF lo_cost_object->foreign_check_cost_object(
      EXPORTING
        entities          = entities
        uuid_fieldname    = 'COSTOBJECTUUID'
        cost_object_uuids = CORRESPONDING #( entities MAPPING uuid = CostObjectUuid )
        operation         = VALUE #( update = abap_true )
        foreign_check     = VALUE #( serv_consumption = abap_true alloc_key = abap_true )
    ) = abap_true.
      RETURN.
    ENDIF.

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_cost_object ).

    LOOP AT entities INTO DATA(entity) WHERE %control-Sysid            = if_abap_behv=>mk-on
                                          OR %control-LegalEntity      = if_abap_behv=>mk-on
                                          OR %control-CompanyCode      = if_abap_behv=>mk-on
                                          OR %control-CostObject       = if_abap_behv=>mk-on
                                          OR %control-CostCenter       = if_abap_behv=>mk-on
                                          OR %control-BillingFrequency = if_abap_behv=>mk-on.
      lo_validation->validate_cost_object(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( sysid         = entity-%control-Sysid
                           legalentity   = entity-%control-LegalEntity
                           companycode   = entity-%control-CompanyCode
                           costobject    = entity-%control-CostObject
                           costcenter    = entity-%control-CostCenter
                           billfrequency = entity-%control-BillingFrequency )
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
          field_mapping   = VALUE #( legal_entity = 'LEGALENTITY' cost_object = 'COSTOBJECT' )
          assoc_path      = VALUE #( ( path = '_CostObjectText' ) )
        CHANGING
          result          = result
      ).
    ENDIF.
  ENDMETHOD.

  METHOD ValidateData.
    READ ENTITIES OF /esrcc/i_cstobjct_s IN LOCAL MODE
        ENTITY CostObject
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(lo_cost_object) = /esrcc/cl_config_util=>create(
                             EXPORTING
                               paths              = VALUE #( ( path = 'CostObjectAll' ) )
                               source_entity_name = '/ESRCC/C_CSTOBJCT'
                             CHANGING
                               reported_entity    = reported-costobject
                               failed_entity      = failed-costobject
                           ).

    lo_cost_object->foreign_check_cost_object(
      EXPORTING
        entities          = entities
        uuid_fieldname    = 'COSTOBJECTUUID'
        cost_object_uuids = CORRESPONDING #( entities MAPPING uuid = CostObjectUuid )
        operation         = VALUE #( delete = abap_true )
        foreign_check     = VALUE #( serv_consumption = abap_true alloc_key = abap_true )
    ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_cost_object ).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>) WHERE Sysid IS INITIAL
                                                         OR LegalEntity IS INITIAL
                                                         OR CompanyCode IS INITIAL
                                                         OR CostObject IS INITIAL
                                                         OR CostCenter IS INITIAL
                                                         OR BillingFrequency IS INITIAL.
      lo_validation->validate_cost_object(
        entity  = <entity>
        control = VALUE #( sysid         = if_abap_behv=>mk-on
                           legalentity   = if_abap_behv=>mk-on
                           companycode   = if_abap_behv=>mk-on
                           costobject    = if_abap_behv=>mk-on
                           costcenter    = if_abap_behv=>mk-on
                           billfrequency = if_abap_behv=>mk-on )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_delete.
    READ ENTITIES OF /ESRCC/I_CstObjct_S IN LOCAL MODE
        ENTITY CostObject
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(lo_cost_object) = /esrcc/cl_config_util=>create(
                         EXPORTING
                           paths              = VALUE #( ( path = 'CostObjectAll' )
                                                         ( path = 'CostObject' ) )
                           source_entity_name = '/ESRCC/C_CSTOBJCT'
                         CHANGING
                           reported_entity    = reported-costobject
                           failed_entity      = failed-costobject
                       ).

    lo_cost_object->foreign_check_cost_object(
      EXPORTING
        entities          = entities
        uuid_fieldname    = 'COSTOBJECTUUID'
        cost_object_uuids = CORRESPONDING #( entities MAPPING uuid = CostObjectUuid )
        operation         = VALUE #( delete = abap_true )
        foreign_check     = VALUE #( serv_consumption = abap_true alloc_key = abap_true )
    ).
  ENDMETHOD.

ENDCLASS.
CLASS lhc_/esrcc/i_cstobjcttext DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR CostObjectText RESULT result.
ENDCLASS.

CLASS lhc_/esrcc/i_cstobjcttext IMPLEMENTATION.
  METHOD get_instance_features.
    IF keys[ 1 ]-%is_draft = if_abap_behv=>mk-on.
      /esrcc/cl_config_util=>create_for_authorization( )->set_instance_authorization(
          EXPORTING
            keys            = keys
            update          = abap_true
            delete          = abap_true
            field_mapping   = VALUE #( legal_entity = 'LEGALENTITY' cost_object = 'COSTOBJECT' )
          CHANGING
            result          = result
        ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
