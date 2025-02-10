CLASS lhc_CostbaseChargeout DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR CostbaseChargeout RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ CostbaseChargeout RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK CostbaseChargeout.

    METHODS deleteadhochargeout FOR MODIFY
      IMPORTING keys FOR ACTION CostbaseChargeout~deleteadhochargeout.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR CostbaseChargeout RESULT result.

    METHODS precheck_deleteadhochargeout FOR PRECHECK
      IMPORTING keys FOR ACTION CostbaseChargeout~deleteadhochargeout.

ENDCLASS.

CLASS lhc_CostbaseChargeout IMPLEMENTATION.

  METHOD get_instance_authorizations.
    IF keys IS NOT INITIAL.
    ENDIF.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD deleteadhochargeout.
    DATA lt_proctrl TYPE TABLE OF /esrcc/procctrl.

    IF keys IS NOT INITIAL.
      SELECT * FROM /esrcc/cb_li FOR ALL ENTRIES IN @keys WHERE cc_guid = @keys-CcUuid
                                                          INTO TABLE @DATA(lt_cbli).
      LOOP AT lt_cbli ASSIGNING FIELD-SYMBOL(<ls_cbli>).

        CLEAR <ls_cbli>-cc_guid.
        <ls_cbli>-status = 'A'.   "Approved
* Admin data
        <ls_cbli>-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = <ls_cbli>-last_changed_at
        ).
      ENDLOOP.
      IF lt_cbli IS NOT INITIAL.

*Create process log entry
        CLEAR lt_proctrl.
        APPEND INITIAL LINE TO lt_proctrl ASSIGNING FIELD-SYMBOL(<ls_proctrl>).
        MOVE-CORRESPONDING <ls_cbli> TO <ls_proctrl>.
        <ls_proctrl>-process = 'ADH'.  "Adhoc
        /esrcc/cl_calculate_chargeout=>create_processlogs(
          iv_action = '13'
          it_keys   = lt_proctrl
        ).

        DATA(lv_ccuuid) = keys[ 1 ]-CcUuid.
        IF keys IS NOT INITIAL.
          SELECT * FROM /esrcc/rec_chg FOR ALL ENTRIES IN @keys WHERE cc_uuid = @keys-CcUuid INTO TABLE @DATA(lt_receievers).

          IF lt_receievers IS NOT INITIAL.
            SELECT * FROM /esrcc/alocshare FOR ALL ENTRIES IN @lt_receievers WHERE parentuuid = @lt_receievers-rec_uuid INTO TABLE @DATA(lt_alocshare).
            IF lt_alocshare IS NOT INITIAL.
              SELECT * FROM /esrcc/alcvalues FOR ALL ENTRIES IN @lt_alocshare WHERE parentuuid = @lt_alocshare-uuid INTO TABLE @DATA(lt_alcvalues).
            ENDIF.
          ENDIF.
        ENDIF.
        DELETE /esrcc/alocshare FROM TABLE @lt_alocshare.
        DELETE /esrcc/alcvalues FROM TABLE @lt_alcvalues.
        DELETE FROM /esrcc/rec_chg WHERE cc_uuid = @lv_ccuuid.
        DELETE FROM /esrcc/srv_share WHERE cc_uuid = @lv_ccuuid.
        DELETE FROM /esrcc/cb_stw WHERE cc_uuid = @lv_ccuuid.

      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD precheck_deleteadhochargeout.

    " Return result to UI
    READ ENTITIES OF /esrcc/i_costbase_chargeout IN LOCAL MODE
        ENTITY CostbaseChargeout
        ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(costbases).

    LOOP AT costbases ASSIGNING FIELD-SYMBOL(<costbase>).
*Authorisation Check
      AUTHORITY-CHECK OBJECT '/ESRCC/LE'
              ID '/ESRCC/LE' FIELD <costbase>-legalentity
              ID 'ACTVT'      FIELD '06'.
      IF sy-subrc = 0.
        AUTHORITY-CHECK OBJECT '/ESRCC/CO'
          ID '/ESRCC/OBJ' FIELD <costbase>-costobject
          ID '/ESRCC/CN' FIELD <costbase>-costcenter
          ID 'ACTVT'      FIELD '06'.
        IF sy-subrc <> 0.
          APPEND VALUE #( %tky = <costbase>-%tky
                          %msg = new_message(
                                     id    = '/ESRCC/MESSAGES'
                                     number = '001'
                                     v1     = <costbase>-Costobject
                                     v2     = <costbase>-Costcenter
                                     severity  = if_abap_behv_message=>severity-error )
                         ) TO reported-costbasechargeout.
          APPEND VALUE #( %tky = <costbase>-%tky ) TO
                          failed-costbasechargeout.
          EXIT.
        ENDIF.
      ELSE.
        APPEND VALUE #( %tky = <costbase>-%tky
                            %msg = new_message(
                                       id    = '/ESRCC/MESSAGES'
                                       number = '000'
                                       v1     = <costbase>-legalentity
                                       severity  = if_abap_behv_message=>severity-error )
                           ) TO reported-costbasechargeout.
        APPEND VALUE #( %tky = <costbase>-%tky ) TO
                        failed-costbasechargeout.
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_I_COSTBASE_CHARGEOUT DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_I_COSTBASE_CHARGEOUT IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
