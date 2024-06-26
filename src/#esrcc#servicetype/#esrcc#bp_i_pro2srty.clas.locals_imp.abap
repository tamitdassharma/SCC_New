CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_product TYPE STRUCTURE FOR READ RESULT /esrcc/i_pro2srty_s\\serviceproduct,
      BEGIN OF ts_control,
        servicetype TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_service_product
        IMPORTING
          entity  TYPE ts_product
          control TYPE ts_control.

  PRIVATE SECTION.
    DATA: config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_service_product.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-servicetype = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'SERVICETYPE' ) TO fields. ENDIF.

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
                                         ( entity = 'ServiceProduct' table = '/ESRCC/PRO2SRTY' )
                                       ) ).
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_pro2srty_s DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR serviceproductall
        RESULT    result,
*      selectcustomizingtransptreq FOR MODIFY
*        IMPORTING
*                  keys   FOR ACTION serviceproductall~selectcustomizingtransptreq
*        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR serviceproductall
        RESULT result,
      precheck_cba_serviceproduct FOR PRECHECK
        IMPORTING entities FOR CREATE serviceproductall\_serviceproduct.
ENDCLASS.

CLASS lhc_/esrcc/i_pro2srty_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA: selecttransport_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled,
          edit_flag            TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.

    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
        iv_objectname = '/ESRCC/PRO2SRTY'
        iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    DATA(transport_service) = cl_bcfg_cd_reuse_api_factory=>get_transport_service_instance(
      iv_objectname = '/ESRCC/PRO2SRTY'
      iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table ).
    IF transport_service->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /esrcc/i_pro2srty_s IN LOCAL MODE
    ENTITY serviceproductall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(all).
    IF all[ 1 ]-%is_draft = if_abap_behv=>mk-off.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result = VALUE #( (
               %tky = all[ 1 ]-%tky
               %action-edit = edit_flag
               %assoc-_serviceproduct = edit_flag ) ).
*               %action-selectcustomizingtransptreq = selecttransport_flag ) ).
  ENDMETHOD.
*  METHOD selectcustomizingtransptreq.
*    MODIFY ENTITIES OF /esrcc/i_pro2srty_s IN LOCAL MODE
*      ENTITY serviceproductall
*        UPDATE FIELDS ( transportrequestid hidetransport )
*        WITH VALUE #( FOR key IN keys
*                        ( %tky               = key-%tky
*                          transportrequestid = key-%param-transportrequestid
*                          hidetransport      = abap_false ) ).
*
*    READ ENTITIES OF /esrcc/i_pro2srty_s IN LOCAL MODE
*      ENTITY serviceproductall
*        ALL FIELDS WITH CORRESPONDING #( keys )
*        RESULT DATA(entities).
*    result = VALUE #( FOR entity IN entities
*                        ( %tky   = entity-%tky
*                          %param = entity ) ).
*  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_PRO2SRTY' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
*    result-%action-selectcustomizingtransptreq = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_serviceproduct.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'ServiceProductAll' ) )
        source_entity_name = '/ESRCC/C_PRO2SRTY'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported-serviceproduct
        failed_entity      = failed-serviceproduct ) ).

    LOOP AT entities[ 1 ]-%target INTO DATA(entity).
      lo_validation->validate_service_product(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( servicetype = if_abap_behv=>mk-on )
      ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_pro2srty_s DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_pro2srty_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-serviceproductall INDEX 1 INTO DATA(all).
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
CLASS lhc_/esrcc/i_pro2srty DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    DATA:
      go_service_product TYPE REF TO /esrcc/cl_config_util,
      gs_service_product TYPE STRUCTURE FOR READ RESULT /esrcc/i_pro2srty_s\\serviceproduct.

    METHODS:
*      validaterecordchanges FOR VALIDATE ON SAVE
*        IMPORTING
*          keys FOR serviceproduct~validaterecordchanges,
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR serviceproduct
        RESULT result,
      validatedata FOR VALIDATE ON SAVE
        IMPORTING keys FOR serviceproduct~validatedata,
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE serviceproduct.
ENDCLASS.

CLASS lhc_/esrcc/i_pro2srty IMPLEMENTATION.
*  METHOD validaterecordchanges.
*    DATA change TYPE REQUEST FOR CHANGE /ESRCC/I_Pro2SrTy_S.
*    SELECT SINGLE TransportRequestID FROM /ESRCC/D_PRO2S_S INTO @DATA(TransportRequestID). "#EC CI_NOORDER
*    lhc_rap_tdat_cts=>get( )->validate_changes(
*                                transport_request = TransportRequestID
*                                table             = '/ESRCC/PRO2SRTY'
*                                keys              = REF #( keys )
*                                reported          = REF #( reported )
*                                failed            = REF #( failed )
*                                change            = REF #( change-ServiceProduct ) ).
*  ENDMETHOD.
  METHOD get_global_features.
    DATA edit_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.
    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
         iv_objectname = '/ESRCC/PRO2SRTY'
         iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
    result-%delete = edit_flag.
  ENDMETHOD.

  METHOD validatedata.
    READ ENTITIES OF /esrcc/i_pro2srty_s IN LOCAL MODE
         ENTITY serviceproduct
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

    DELETE entities WHERE servicetype IS NOT INITIAL.
    IF entities IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'ServiceProductAll' ) )
        source_entity_name = '/ESRCC/C_PRO2SRTY'
      CHANGING
        reported_entity    = reported-serviceproduct
        failed_entity      = failed-serviceproduct ) ).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_service_product(
        entity  = entity
        control = VALUE #( servicetype = if_abap_behv=>mk-on )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'ServiceProductAll' ) )
        source_entity_name = '/ESRCC/C_PRO2SRTY'
      CHANGING
        reported_entity    = reported-serviceproduct
        failed_entity      = failed-serviceproduct ) ).

    LOOP AT entities INTO DATA(entity) WHERE %control-servicetype = if_abap_behv=>mk-on.
      lo_validation->validate_service_product(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( servicetype = entity-%control-servicetype )
      ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
