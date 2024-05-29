CLASS lhc_managecostbase DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR managecostbase RESULT result.

    METHODS changeitems FOR MODIFY
      IMPORTING keys FOR ACTION managecostbase~changeitems RESULT result.

    METHODS changevalueadd FOR MODIFY
      IMPORTING keys FOR ACTION managecostbase~changevalueadd RESULT result.

    METHODS discardall FOR MODIFY
      IMPORTING keys FOR ACTION managecostbase~discardall RESULT result.

    METHODS submit FOR MODIFY
      IMPORTING keys FOR ACTION managecostbase~submit RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR managecostbase RESULT result.

    METHODS precheck_changevalueadd FOR PRECHECK
      IMPORTING keys FOR ACTION managecostbase~changevalueadd.
    METHODS precheck_changeitems FOR PRECHECK
      IMPORTING keys FOR ACTION managecostbase~changeitems.

    METHODS precheck_discardall FOR PRECHECK
      IMPORTING keys FOR ACTION managecostbase~discardall.

    METHODS precheck_submit FOR PRECHECK
      IMPORTING keys FOR ACTION managecostbase~submit.


ENDCLASS.

CLASS lhc_managecostbase IMPLEMENTATION.

  METHOD get_instance_authorizations.

    " Return result to UI
    READ ENTITIES OF /esrcc/i_managecostbase IN LOCAL MODE
        ENTITY managecostbase
        ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(costbases).

    CHECK costbases IS NOT INITIAL.

    LOOP AT costbases ASSIGNING FIELD-SYMBOL(<costbase>).

      IF requested_authorizations-%update = if_abap_behv=>mk-on.

        AUTHORITY-CHECK OBJECT '/ESRCC/LE'
            ID '/ESRCC/LE' FIELD <costbase>-legalentity
            ID 'ACTVT'      FIELD '02'.
        IF sy-subrc = 0.
          AUTHORITY-CHECK OBJECT '/ESRCC/CO'
            ID '/ESRCC/OBJ' FIELD <costbase>-costobject
            ID '/ESRCC/CN' FIELD <costbase>-costcenter
            ID 'ACTVT'      FIELD '02'.
          IF sy-subrc <> 0.
            APPEND VALUE #( %tky = <costbase>-%tky
                            %msg = new_message(
                                       id    = '/ESRCC/MANAGECOSTBAS'
                                       number = '000'
                                       v1     = <costbase>-legalentity
                                       severity  = if_abap_behv_message=>severity-error )
                           ) TO reported-managecostbase.
            APPEND VALUE #( %tky = <costbase>-%tky ) TO
                            failed-managecostbase.
          ENDIF.
        ELSE.
          APPEND VALUE #( %tky = <costbase>-%tky
                              %msg = new_message(
                                         id    = '/ESRCC/MANAGECOSTBAS'
                                         number = '000'
                                         v1     = <costbase>-legalentity
                                         severity  = if_abap_behv_message=>severity-error )
                             ) TO reported-managecostbase.
          APPEND VALUE #( %tky = <costbase>-%tky ) TO
                          failed-managecostbase.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD changeitems.

    DATA ls_param   TYPE /esrcc/c_usagecalculation.
    DATA lt_costbase TYPE TABLE OF /esrcc/cb_li.

    " Return result to UI
    READ ENTITIES OF /esrcc/i_managecostbase IN LOCAL MODE
        ENTITY managecostbase
        ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(costbases).

    ls_param = CORRESPONDING #( keys[ 1 ]-%param ).

    MODIFY ENTITIES OF /esrcc/i_managecostbase  IN LOCAL MODE
        ENTITY managecostbase
         UPDATE FIELDS ( oldusagecal usagecal status )
              WITH VALUE #( FOR costbase IN costbases WHERE ( status <> 'F' AND status <> 'W' )
                              (
                                 %key = costbase-%key
                                 oldusagecal = costbase-usagecal
                                 usagecal = ls_param-usagecal
                                 status = 'D'
                               ) )
                              FAILED   FINAL(fail_mod)
                              REPORTED FINAL(rep_mod)
                              MAPPED FINAL(map_mod).

    result = VALUE #( FOR costbase IN costbases
            ( %tky   = costbase-%tky
              %param = costbase ) ).

  ENDMETHOD.

  METHOD changevalueadd.

    DATA ls_param   TYPE /esrcc/c_costind.
    DATA lt_costbase TYPE TABLE OF /esrcc/cb_li.

    " Return result to UI
    READ ENTITIES OF /esrcc/i_managecostbase IN LOCAL MODE
        ENTITY managecostbase
        ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(costbases).

    ls_param = CORRESPONDING #( keys[ 1 ]-%param ).

    MODIFY ENTITIES OF /esrcc/i_managecostbase  IN LOCAL MODE
        ENTITY managecostbase
         UPDATE FIELDS ( oldcostind costind status )
              WITH VALUE #( FOR costbase IN costbases WHERE ( status <> 'F' AND status <> 'W' )
                              (
                                 %key = costbase-%key
                                 oldcostind = costbase-costind
                                 costind = ls_param-costind
                                 status = 'D'
                               ) )
                              FAILED   FINAL(fail_mod)
                              REPORTED FINAL(rep_mod)
                              MAPPED FINAL(map_mod).

    result = VALUE #( FOR costbase IN costbases
            ( %tky   = costbase-%tky
              %param = costbase ) ).

  ENDMETHOD.

  METHOD discardall.

    " Return result to UI
    READ ENTITIES OF /esrcc/i_managecostbase IN LOCAL MODE
        ENTITY managecostbase
        ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(costbases).

    MODIFY ENTITIES OF /esrcc/i_managecostbase  IN LOCAL MODE
        ENTITY managecostbase
         UPDATE FIELDS ( oldcostind oldcostdataset oldusagecal costind usagecal status )
              WITH VALUE #( FOR costbase IN costbases WHERE ( status = 'D' )
                              (
                                 %key = costbase-%key
                                 costind = COND #( when costbase-oldcostind is INITIAL then costbase-costind else costbase-oldcostind )
                                 usagecal = COND #( when costbase-oldusagecal is INITIAL then costbase-usagecal else costbase-oldusagecal )
                                 status = 'U'
                                 oldcostind = ''
                                 oldcostdataset = ''
                                 oldusagecal = ''

                               ) )
                              FAILED   FINAL(fail_mod)
                              REPORTED FINAL(rep_mod)
                              MAPPED FINAL(map_mod).

    result = VALUE #( FOR costbase IN costbases
            ( %tky   = costbase-%tky
              %param = costbase ) ).

  ENDMETHOD.

  METHOD submit.

    DATA lt_leading_object TYPE /esrcc/tt_wf_leadingobject.

    " Return result to UI
    READ ENTITIES OF /esrcc/i_managecostbase IN LOCAL MODE
        ENTITY managecostbase
        ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(costbases).

    DATA(lv_param) = keys[ 1 ]-%param.

    lt_leading_object = CORRESPONDING #( costbases ).

    /esrcc/cl_wf_utility=>is_wf_on(
      EXPORTING
        iv_apptype   = 'CBL'
      IMPORTING
        ev_wf_active = DATA(wf_active)
    ).

* check if workflow is on or not
    IF wf_active = abap_true.

      MODIFY ENTITIES OF /esrcc/i_managecostbase  IN LOCAL MODE
       ENTITY managecostbase
        UPDATE FIELDS ( comments oldcostind oldcostdataset oldusagecal costind usagecal status )
             WITH VALUE #( FOR costbase IN costbases WHERE ( status = 'D' )
                             (
                                %key = costbase-%key
                                oldcostind = ''
                                oldcostdataset = ''
                                oldusagecal = ''
                                costind = costbase-costind
                                usagecal = costbase-usagecal
                                status = 'W'
                                comments = lv_param
                              ) )
                             FAILED failed
                             REPORTED reported
                             MAPPED mapped.

    ELSE.

      MODIFY ENTITIES OF /esrcc/i_managecostbase  IN LOCAL MODE
       ENTITY managecostbase
        UPDATE FIELDS ( comments oldcostind oldcostdataset oldusagecal costind usagecal status )
             WITH VALUE #( FOR costbase IN costbases WHERE ( status = 'D' )
                             (
                                %key = costbase-%key
                                oldcostind = ''
                                oldcostdataset = ''
                                oldusagecal = ''
                                costind = costbase-costind
                                usagecal = costbase-usagecal
                                status = 'A'
                                comments = lv_param
                              ) )
                             FAILED failed
                             REPORTED reported
                             MAPPED mapped.

    ENDIF.

    IF failed IS INITIAL AND wf_active = abap_true.
      CALL FUNCTION '/ESRCC/FM_WF_START'
        EXPORTING
          it_leading_object = lt_leading_object
          iv_apptype        = 'CBL'.
    ENDIF.

    result = VALUE #( FOR costbase IN costbases
             ( %tky   = costbase-%tky
               %param = costbase ) ).

  ENDMETHOD.

  METHOD get_instance_features.

  ENDMETHOD.

  METHOD precheck_changevalueadd.

    " Return result to UI
    READ ENTITIES OF /esrcc/i_managecostbase IN LOCAL MODE
        ENTITY managecostbase
        ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(costbases).

    LOOP AT costbases ASSIGNING FIELD-SYMBOL(<costbase>).

      IF <costbase>-status = 'F'.
        APPEND VALUE #( %tky = <costbase>-%tky
                        %msg = new_message(
                        id   = '/ESRCC/MANAGECOSTBAS'
                        number = '001'
                        v1   = <costbase>-belnr
                        severity  = if_abap_behv_message=>severity-error )
                       ) TO reported-managecostbase.
        APPEND VALUE #( %tky = <costbase>-%tky ) TO
                        failed-managecostbase.
      ENDIF.

      IF <costbase>-status = 'W'.
        APPEND VALUE #( %tky = <costbase>-%tky
                        %msg = new_message(
                        id   = '/ESRCC/MANAGECOSTBAS'
                        number = '002'
                        v1   = <costbase>-belnr
                        severity  = if_abap_behv_message=>severity-error )
                       ) TO reported-managecostbase.
        APPEND VALUE #( %tky = <costbase>-%tky ) TO
                        failed-managecostbase.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD precheck_changeitems.

    " Return result to UI
    READ ENTITIES OF /esrcc/i_managecostbase IN LOCAL MODE
        ENTITY managecostbase
        ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(costbases).

    LOOP AT costbases ASSIGNING FIELD-SYMBOL(<costbase>).

      IF <costbase>-status = 'F'.
        APPEND VALUE #( %tky = <costbase>-%tky
                        %msg = new_message(
                        id   = '/ESRCC/MANAGECOSTBAS'
                        number = '001'
                        v1   = <costbase>-belnr
                        severity  = if_abap_behv_message=>severity-error )
                       ) TO reported-managecostbase.
        APPEND VALUE #( %tky = <costbase>-%tky ) TO
                        failed-managecostbase.
      ENDIF.

      IF <costbase>-status = 'W'.
        APPEND VALUE #( %tky = <costbase>-%tky
                        %msg = new_message(
                        id   = '/ESRCC/MANAGECOSTBAS'
                        number = '002'
                        v1   = <costbase>-belnr
                        severity  = if_abap_behv_message=>severity-error )
                       ) TO reported-managecostbase.
        APPEND VALUE #( %tky = <costbase>-%tky ) TO
                        failed-managecostbase.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD precheck_discardall.

    " Return result to UI
    READ ENTITIES OF /esrcc/i_managecostbase IN LOCAL MODE
        ENTITY managecostbase
        ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(costbases).

    LOOP AT costbases ASSIGNING FIELD-SYMBOL(<costbase>) where Status <> 'D'.

*      IF <costbase>-status IS INITIAL.
        APPEND VALUE #( %tky = <costbase>-%tky
                        %msg = new_message(
                        id   = '/ESRCC/MANAGECOSTBAS'
                        number = '004'
                        v1   = <costbase>-belnr
                        severity  = if_abap_behv_message=>severity-error )
                       ) TO reported-managecostbase.
        APPEND VALUE #( %tky = <costbase>-%tky ) TO
                        failed-managecostbase.
*      ENDIF.
*
*      IF <costbase>-status = 'F'.
*        APPEND VALUE #( %tky = <costbase>-%tky
*                        %msg = new_message(
*                        id   = '/ESRCC/MANAGECOSTBAS'
*                        number = '001'
*                        v1   = <costbase>-belnr
*                        severity  = if_abap_behv_message=>severity-error )
*                       ) TO reported-managecostbase.
*        APPEND VALUE #( %tky = <costbase>-%tky ) TO
*                        failed-managecostbase.
*      ENDIF.
*
*
*      IF <costbase>-status = 'W'.
*        APPEND VALUE #( %tky = <costbase>-%tky
*                        %msg = new_message(
*                        id   = '/ESRCC/MANAGECOSTBAS'
*                        number = '002'
*                        v1   = <costbase>-belnr
*                        severity  = if_abap_behv_message=>severity-error )
*                       ) TO reported-managecostbase.
*        APPEND VALUE #( %tky = <costbase>-%tky ) TO
*                        failed-managecostbase.
*      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD precheck_submit.

    " Return result to UI
    READ ENTITIES OF /esrcc/i_managecostbase IN LOCAL MODE
        ENTITY managecostbase
        ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(costbases).

    LOOP AT costbases ASSIGNING FIELD-SYMBOL(<costbase>) where status <> 'D'.

*      IF <costbase>-status IS INITIAL.
        APPEND VALUE #( %tky = <costbase>-%tky
                        %msg = new_message(
                        id   = '/ESRCC/MANAGECOSTBAS'
                        number = '003'
                        v1   = <costbase>-belnr
                        severity  = if_abap_behv_message=>severity-error )
                       ) TO reported-managecostbase.
        APPEND VALUE #( %tky = <costbase>-%tky ) TO
                        failed-managecostbase.
*      ENDIF.
*
*      IF <costbase>-status = 'F'.
*        APPEND VALUE #( %tky = <costbase>-%tky
*                        %msg = new_message(
*                        id   = '/ESRCC/MANAGECOSTBAS'
*                        number = '001'
*                        v1   = <costbase>-belnr
*                        severity  = if_abap_behv_message=>severity-error )
*                       ) TO reported-managecostbase.
*        APPEND VALUE #( %tky = <costbase>-%tky ) TO
*                        failed-managecostbase.
*      ENDIF.
*
*
*      IF <costbase>-status = 'W'.
*        APPEND VALUE #( %tky = <costbase>-%tky
*                        %msg = new_message(
*                        id   = '/ESRCC/MANAGECOSTBAS'
*                        number = '002'
*                        v1   = <costbase>-belnr
*                        severity  = if_abap_behv_message=>severity-error )
*                       ) TO reported-managecostbase.
*        APPEND VALUE #( %tky = <costbase>-%tky ) TO
*                        failed-managecostbase.
*      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
