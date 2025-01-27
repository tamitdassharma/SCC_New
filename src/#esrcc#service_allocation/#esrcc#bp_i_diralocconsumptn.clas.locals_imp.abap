CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_consumption TYPE STRUCTURE FOR READ RESULT /esrcc/i_diralocconsumptn\\DirectAllocationConsumption,

      BEGIN OF ts_control,
        sysid              TYPE if_abap_behv=>t_xflag,
        receivingentity    TYPE if_abap_behv=>t_xflag,
        receivingcompany   TYPE if_abap_behv=>t_xflag,
        costobject         TYPE if_abap_behv=>t_xflag,
        costcenter         TYPE if_abap_behv=>t_xflag,
        providersysid      TYPE if_abap_behv=>t_xflag,
        providerentity     TYPE if_abap_behv=>t_xflag,
        providercompany    TYPE if_abap_behv=>t_xflag,
        providercostobject TYPE if_abap_behv=>t_xflag,
        providercostcenter TYPE if_abap_behv=>t_xflag,
        ryear              TYPE if_abap_behv=>t_xflag,
        poper              TYPE if_abap_behv=>t_xflag,
        serviceproduct     TYPE if_abap_behv=>t_xflag,
        fplv               TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_consumption
        IMPORTING
          entity  TYPE ts_consumption
          control TYPE ts_control.

  PRIVATE SECTION.
    DATA: config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_consumption.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-sysid              = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'SYSID' ) TO fields. ENDIF.
    IF control-receivingentity    = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'RECEIVINGENTITY' ) TO fields. ENDIF.
    IF control-receivingcompany   = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'RECEIVINGCOMPANY' ) TO fields. ENDIF.
    IF control-costobject         = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'COSTOBJECT' ) TO fields. ENDIF.
    IF control-costcenter         = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'COSTCENTER' ) TO fields. ENDIF.
    IF control-providersysid      = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'PROVIDERSYSID' ) TO fields. ENDIF.
    IF control-providerentity     = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'PROVIDERENTITY' ) TO fields. ENDIF.
    IF control-providercompany    = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'PROVIDERCOMPANY' ) TO fields. ENDIF.
    IF control-providercostobject = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'PROVIDERCOSTOBJECT' ) TO fields. ENDIF.
    IF control-providercostcenter = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'PROVIDERCOSTCENTER' ) TO fields. ENDIF.
    IF control-ryear              = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'RYEAR' ) TO fields. ENDIF.
    IF control-poper              = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'POPER' ) TO fields. ENDIF.
    IF control-serviceproduct     = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'SERVICEPRODUCT' ) TO fields. ENDIF.
    IF control-fplv               = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'FPLV' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
  ENDMETHOD.
ENDCLASS.

CLASS lhc_DirectAllocationConsumptio DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR DirectAllocationConsumption RESULT result.
    METHODS ValidateData FOR VALIDATE ON SAVE
      IMPORTING keys FOR DirectAllocationConsumption~ValidateData.
    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE DirectAllocationConsumption.

ENDCLASS.

CLASS lhc_DirectAllocationConsumptio IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD ValidateData.
    READ ENTITIES OF /esrcc/i_diralocconsumptn IN LOCAL MODE
        ENTITY DirectAllocationConsumption
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
                                                                         EXPORTING
                                                                           paths              = VALUE #( ( path = 'DirectAllocationConsumption' ) )
                                                                           source_entity_name = '/ESRCC/C_DIRALOCCONSUMPTN'
                                                                         CHANGING
                                                                           reported_entity    = reported-directallocationconsumption
                                                                           failed_entity      = failed-directallocationconsumption
                                                                       ) ).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>) WHERE Sysid IS INITIAL
                                                         OR ReceivingEntity IS INITIAL
                                                         OR ReceivingCompany IS INITIAL
                                                         OR CostObject IS INITIAL
                                                         OR CostCenter IS INITIAL
                                                         OR ProviderSysid IS INITIAL
                                                         OR ProviderEntity IS INITIAL
                                                         OR ProviderCompany IS INITIAL
                                                         OR ProviderCostObject IS INITIAL
                                                         OR ProviderCostCenter IS INITIAL
                                                         OR Ryear IS INITIAL
                                                         OR Poper IS INITIAL
                                                         OR ServiceProduct IS INITIAL
                                                         OR Fplv IS INITIAL.
      lo_validation->validate_consumption(
        entity  = <entity>
        control = VALUE #( sysid              = if_abap_behv=>mk-on
                           receivingentity    = if_abap_behv=>mk-on
                           receivingcompany   = if_abap_behv=>mk-on
                           costobject         = if_abap_behv=>mk-on
                           costcenter         = if_abap_behv=>mk-on
                           providersysid      = if_abap_behv=>mk-on
                           providerentity     = if_abap_behv=>mk-on
                           providercompany    = if_abap_behv=>mk-on
                           providercostobject = if_abap_behv=>mk-on
                           providercostcenter = if_abap_behv=>mk-on
                           ryear              = if_abap_behv=>mk-on
                           poper              = if_abap_behv=>mk-on
                           serviceproduct     = if_abap_behv=>mk-on
                           fplv               = if_abap_behv=>mk-on )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
*    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
*                                                                         EXPORTING
*                                                                           paths              = VALUE #( ( path = 'DirectAllocationConsumption' ) )
*                                                                           source_entity_name = '/ESRCC/C_DIRALOCCONSUMPTN'
*                                                                         CHANGING
*                                                                           reported_entity    = reported-directallocationconsumption
*                                                                           failed_entity      = failed-directallocationconsumption
*                                                                       ) ).
*
*    LOOP AT entities INTO DATA(entity) WHERE %control-Sysid            = if_abap_behv=>mk-on
*                                          OR %control-ReceivingEntity  = if_abap_behv=>mk-on
*                                          OR %control-ReceivingCompany = if_abap_behv=>mk-on
*                                          OR %control-CostObject       = if_abap_behv=>mk-on
*                                          OR %control-CostCenter       = if_abap_behv=>mk-on
*                                          OR %control-Ryear            = if_abap_behv=>mk-on
*                                          OR %control-Poper            = if_abap_behv=>mk-on
*                                          OR %control-ServiceProduct   = if_abap_behv=>mk-on
*                                          OR %control-Fplv             = if_abap_behv=>mk-on.
*      lo_validation->validate_consumption(
*        entity  = CORRESPONDING #( entity )
*        control = VALUE #( sysid            = entity-%control-Sysid
*                           receivingentity  = entity-%control-ReceivingEntity
*                           receivingcompany = entity-%control-ReceivingCompany
*                           costobject       = entity-%control-CostObject
*                           costcenter       = entity-%control-CostCenter
*                           ryear            = entity-%control-Ryear
*                           poper            = entity-%control-Poper
*                           serviceproduct   = entity-%control-ServiceProduct
*                           fplv             = entity-%control-Fplv )
*      ).
*    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
