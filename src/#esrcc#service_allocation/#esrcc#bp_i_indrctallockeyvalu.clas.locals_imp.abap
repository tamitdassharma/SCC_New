CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_allocvalue TYPE STRUCTURE FOR READ RESULT /esrcc/i_indirectallockeyvalue\\IndirectAllocationKeyValues,

      BEGIN OF ts_control,
        sysid         TYPE if_abap_behv=>t_xflag,
        legalentity   TYPE if_abap_behv=>t_xflag,
        companycode   TYPE if_abap_behv=>t_xflag,
        costobject    TYPE if_abap_behv=>t_xflag,
        costcenter    TYPE if_abap_behv=>t_xflag,
        ryear         TYPE if_abap_behv=>t_xflag,
        poper         TYPE if_abap_behv=>t_xflag,
        allocationkey TYPE if_abap_behv=>t_xflag,
        fplv          TYPE if_abap_behv=>t_xflag,
      END OF ts_control.

    METHODS:
      constructor IMPORTING config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_allocvalue
        IMPORTING
          entity  TYPE ts_allocvalue
          control TYPE ts_control.

  PRIVATE SECTION.
    DATA: config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_allocvalue.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-sysid         = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'SYSID' ) TO fields. ENDIF.
    IF control-legalentity   = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'LEGALENTITY' ) TO fields. ENDIF.
    IF control-companycode   = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'COMPANYCODE' ) TO fields. ENDIF.
    IF control-costobject    = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'COSTOBJECT' ) TO fields. ENDIF.
    IF control-costcenter    = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'COSTCENTER' ) TO fields. ENDIF.
    IF control-ryear         = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'RYEAR' ) TO fields. ENDIF.
    IF control-poper         = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'POPER' ) TO fields. ENDIF.
    IF control-allocationkey = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'ALLOCATIONKEY' ) TO fields. ENDIF.
    IF control-fplv          = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'FPLV' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).
  ENDMETHOD.
ENDCLASS.

CLASS lhc_IndirectAllocationKeyValue DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR IndirectAllocationKeyValues RESULT result.
    METHODS ValidateData FOR VALIDATE ON SAVE
      IMPORTING keys FOR IndirectAllocationKeyValues~ValidateData.
    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE IndirectAllocationKeyValues.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE IndirectAllocationKeyValues.

    METHODS precheck_delete FOR PRECHECK
      IMPORTING keys FOR DELETE IndirectAllocationKeyValues.

ENDCLASS.

CLASS lhc_IndirectAllocationKeyValue IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD ValidateData.
    READ ENTITIES OF /esrcc/i_indirectallockeyvalue IN LOCAL MODE
          ENTITY IndirectAllocationKeyValues
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(entities).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
                                                                         EXPORTING
                                                                           paths              = VALUE #( ( path = 'IndirectAllocationKeyValues' ) )
                                                                           source_entity_name = '/ESRCC/C_INDIRECTALLOCKEYVALUE'
                                                                         CHANGING
                                                                           reported_entity    = reported-indirectallocationkeyvalues
                                                                           failed_entity      = failed-indirectallocationkeyvalues
                                                                       ) ).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>) WHERE Sysid IS INITIAL
                                                         OR LegalEntity IS INITIAL
                                                         OR CompanyCode IS INITIAL
                                                         OR CostObject IS INITIAL
                                                         OR CostCenter IS INITIAL
                                                         OR Ryear IS INITIAL
                                                         OR Poper IS INITIAL
                                                         OR AllocationKey IS INITIAL
                                                         OR Fplv IS INITIAL.
      lo_validation->validate_allocvalue(
        entity  = <entity>
        control = VALUE #( sysid         = if_abap_behv=>mk-on
                           legalentity   = if_abap_behv=>mk-on
                           companycode   = if_abap_behv=>mk-on
                           costobject    = if_abap_behv=>mk-on
                           costcenter    = if_abap_behv=>mk-on
                           ryear         = if_abap_behv=>mk-on
                           poper         = if_abap_behv=>mk-on
                           allocationkey = if_abap_behv=>mk-on
                           fplv          = if_abap_behv=>mk-on )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_create.

   LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).
*Authorisation Check
      AUTHORITY-CHECK OBJECT '/ESRCC/LE'
              ID '/ESRCC/LE' FIELD <entity>-legalentity
              ID 'ACTVT'      FIELD '01'.
      IF sy-subrc = 0.
        AUTHORITY-CHECK OBJECT '/ESRCC/CO'
          ID '/ESRCC/OBJ' FIELD <entity>-costobject
          ID '/ESRCC/CN' FIELD <entity>-costcenter
          ID 'ACTVT'      FIELD '01'.
        IF sy-subrc <> 0.
          APPEND VALUE #( %tky = <entity>-%key
                          %msg = new_message(
                                     id    = '/ESRCC/MESSAGES'
                                     number = '003'
                                     v1     = <entity>-CostObject
                                     v2     = <entity>-CostCenter
                                     severity  = if_abap_behv_message=>severity-error )
                         ) TO reported-indirectallocationkeyvalues.
          APPEND VALUE #( %tky = <entity>-%key ) TO
                          failed-indirectallocationkeyvalues.
          EXIT.
        ENDIF.
      ELSE.
        APPEND VALUE #( %tky = <entity>-%key
                            %msg = new_message(
                                       id    = '/ESRCC/MESSAGES'
                                       number = '002'
                                       v1     = <entity>-legalentity
                                       severity  = if_abap_behv_message=>severity-error )
                           ) TO reported-indirectallocationkeyvalues.
        APPEND VALUE #( %tky = <entity>-%key ) TO
                        failed-indirectallocationkeyvalues.
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD precheck_update.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).
*Authorisation Check
      AUTHORITY-CHECK OBJECT '/ESRCC/LE'
              ID '/ESRCC/LE' FIELD <entity>-legalentity
              ID 'ACTVT'      FIELD '02'.
      IF sy-subrc = 0.
        AUTHORITY-CHECK OBJECT '/ESRCC/CO'
          ID '/ESRCC/OBJ' FIELD <entity>-costobject
          ID '/ESRCC/CN' FIELD <entity>-costcenter
          ID 'ACTVT'      FIELD '02'.
        IF sy-subrc <> 0.
          APPEND VALUE #( %tky = <entity>-%tky
                          %msg = new_message(
                                     id    = '/ESRCC/MESSAGES'
                                     number = '005'
                                     v1     = <entity>-CostObject
                                     v2     = <entity>-CostCenter
                                     severity  = if_abap_behv_message=>severity-error )
                         ) TO reported-indirectallocationkeyvalues.
          APPEND VALUE #( %tky = <entity>-%tky ) TO
                          failed-indirectallocationkeyvalues.
          EXIT.
        ENDIF.
      ELSE.
        APPEND VALUE #( %tky = <entity>-%tky
                            %msg = new_message(
                                       id    = '/ESRCC/MESSAGES'
                                       number = '004'
                                       v1     = <entity>-legalentity
                                       severity  = if_abap_behv_message=>severity-error )
                           ) TO reported-indirectallocationkeyvalues.
        APPEND VALUE #( %tky = <entity>-%tky ) TO
                        failed-indirectallocationkeyvalues.
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD precheck_delete.

    READ ENTITIES OF /esrcc/i_indirectallockeyvalue IN LOCAL MODE
          ENTITY IndirectAllocationKeyValues
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(entities).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).
*Authorisation Check
      AUTHORITY-CHECK OBJECT '/ESRCC/LE'
              ID '/ESRCC/LE' FIELD <entity>-legalentity
              ID 'ACTVT'      FIELD '06'.
      IF sy-subrc = 0.
        AUTHORITY-CHECK OBJECT '/ESRCC/CO'
          ID '/ESRCC/OBJ' FIELD <entity>-costobject
          ID '/ESRCC/CN' FIELD <entity>-costcenter
          ID 'ACTVT'      FIELD '06'.
        IF sy-subrc <> 0.
          APPEND VALUE #( %tky = <entity>-%key
                          %msg = new_message(
                                     id    = '/ESRCC/MESSAGES'
                                     number = '007'
                                     v1     = <entity>-CostObject
                                     v2     = <entity>-CostCenter
                                     severity  = if_abap_behv_message=>severity-error )
                         ) TO reported-indirectallocationkeyvalues.
          APPEND VALUE #( %tky = <entity>-%key ) TO
                          failed-indirectallocationkeyvalues.
          EXIT.
        ENDIF.
      ELSE.
        APPEND VALUE #( %tky = <entity>-%key
                            %msg = new_message(
                                       id    = '/ESRCC/MESSAGES'
                                       number = '006'
                                       v1     = <entity>-legalentity
                                       severity  = if_abap_behv_message=>severity-error )
                           ) TO reported-indirectallocationkeyvalues.
        APPEND VALUE #( %tky = <entity>-%key ) TO
                        failed-indirectallocationkeyvalues.
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
