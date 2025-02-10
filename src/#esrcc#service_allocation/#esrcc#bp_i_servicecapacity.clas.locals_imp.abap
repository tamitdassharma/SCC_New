CLASS lhc_ServiceCapacity DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR ServiceCapacity RESULT result.
    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE ServiceCapacity.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE ServiceCapacity.

    METHODS precheck_delete FOR PRECHECK
      IMPORTING keys FOR DELETE ServiceCapacity.

ENDCLASS.

CLASS lhc_ServiceCapacity IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD precheck_create.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).
*Authorisation Check
      AUTHORITY-CHECK OBJECT '/ESRCC/LE'
              ID '/ESRCC/LE' FIELD <entity>-LegalEntity
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
                         ) TO reported-servicecapacity.
          APPEND VALUE #( %tky = <entity>-%key ) TO
                          failed-servicecapacity.
          EXIT.
        ENDIF.
      ELSE.
        APPEND VALUE #( %tky = <entity>-%key
                            %msg = new_message(
                                       id    = '/ESRCC/MESSAGES'
                                       number = '002'
                                       v1     = <entity>-legalentity
                                       severity  = if_abap_behv_message=>severity-error )
                           ) TO reported-servicecapacity.
        APPEND VALUE #( %tky = <entity>-%key ) TO
                        failed-servicecapacity.
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD precheck_update.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).
*Authorisation Check
      AUTHORITY-CHECK OBJECT '/ESRCC/LE'
              ID '/ESRCC/LE' FIELD <entity>-LegalEntity
              ID 'ACTVT'      FIELD '02'.
      IF sy-subrc = 0.
        AUTHORITY-CHECK OBJECT '/ESRCC/CO'
          ID '/ESRCC/OBJ' FIELD <entity>-costobject
          ID '/ESRCC/CN' FIELD <entity>-costcenter
          ID 'ACTVT'      FIELD '02'.
        IF sy-subrc <> 0.
          APPEND VALUE #( %tky = <entity>-%key
                          %msg = new_message(
                                     id    = '/ESRCC/MESSAGES'
                                     number = '005'
                                     v1     = <entity>-CostObject
                                     v2     = <entity>-CostCenter
                                     severity  = if_abap_behv_message=>severity-error )
                         ) TO reported-servicecapacity.
          APPEND VALUE #( %tky = <entity>-%key ) TO
                          failed-servicecapacity.
          EXIT.
        ENDIF.
      ELSE.
        APPEND VALUE #( %tky = <entity>-%key
                            %msg = new_message(
                                       id    = '/ESRCC/MESSAGES'
                                       number = '004'
                                       v1     = <entity>-legalentity
                                       severity  = if_abap_behv_message=>severity-error )
                           ) TO reported-servicecapacity.
        APPEND VALUE #( %tky = <entity>-%key ) TO
                        failed-servicecapacity.
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD precheck_delete.

    READ ENTITIES OF /ESRCC/I_ServiceCapacity IN LOCAL MODE
            ENTITY ServiceCapacity
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(entities).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).
*Authorisation Check
      AUTHORITY-CHECK OBJECT '/ESRCC/LE'
              ID '/ESRCC/LE' FIELD <entity>-LegalEntity
              ID 'ACTVT'      FIELD '06'.
      IF sy-subrc = 0.
        AUTHORITY-CHECK OBJECT '/ESRCC/CO'
          ID '/ESRCC/OBJ' FIELD <entity>-Costobject
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
                         ) TO reported-servicecapacity.
          APPEND VALUE #( %tky = <entity>-%key ) TO
                          failed-servicecapacity.
          EXIT.
        ENDIF.
      ELSE.
        APPEND VALUE #( %tky = <entity>-%key
                            %msg = new_message(
                                       id    = '/ESRCC/MESSAGES'
                                       number = '006'
                                       v1     = <entity>-legalentity
                                       severity  = if_abap_behv_message=>severity-error )
                           ) TO reported-servicecapacity.
        APPEND VALUE #( %tky = <entity>-%key ) TO
                        failed-servicecapacity.
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
