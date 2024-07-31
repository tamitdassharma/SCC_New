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
    METHODS triggerworkflow FOR DETERMINE ON SAVE
      IMPORTING keys FOR managecostbase~triggerworkflow.


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
         UPDATE FIELDS ( oldusagecal usagecal status ReasonId )
              WITH VALUE #( FOR costbase IN costbases WHERE ( status <> 'F' AND status <> 'W' )
                              (
                                 %key = costbase-%key
                                 oldusagecal = costbase-usagecal
                                 usagecal = ls_param-usagecal
                                 ReasonId = ls_param-reasonid
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
        UPDATE FIELDS ( comments oldcostind oldcostdataset oldusagecal costind usagecal status WorkflowId )
             WITH VALUE #( FOR costbase IN costbases WHERE ( status = 'D' )
                             (
                                %key = costbase-%key
                                oldcostind = ''
                                oldcostdataset = ''
                                oldusagecal = ''
                                costind = costbase-costind
                                usagecal = costbase-usagecal
                                status = 'P'
                                WorkflowId = ''
                              ) )
                             FAILED failed
                             REPORTED reported
                             MAPPED mapped.

    ELSE.

      MODIFY ENTITIES OF /esrcc/i_managecostbase  IN LOCAL MODE
       ENTITY managecostbase
        UPDATE FIELDS ( comments oldcostind oldcostdataset oldusagecal costind usagecal status WorkflowId )
             WITH VALUE #( FOR costbase IN costbases WHERE ( status = 'D' )
                             (
                                %key = costbase-%key
                                oldcostind = ''
                                oldcostdataset = ''
                                oldusagecal = ''
                                costind = costbase-costind
                                usagecal = costbase-usagecal
                                status = 'A'
                                WorkflowId = ''
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

        APPEND VALUE #( %tky = <costbase>-%tky
                        %msg = new_message(
                        id   = '/ESRCC/MANAGECOSTBAS'
                        number = '004'
                        v1   = <costbase>-belnr
                        severity  = if_abap_behv_message=>severity-error )
                       ) TO reported-managecostbase.
        APPEND VALUE #( %tky = <costbase>-%tky ) TO
                        failed-managecostbase.

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

        APPEND VALUE #( %tky = <costbase>-%tky
                        %msg = new_message(
                        id   = '/ESRCC/MANAGECOSTBAS'
                        number = '003'
                        v1   = <costbase>-belnr
                        severity  = if_abap_behv_message=>severity-error )
                       ) TO reported-managecostbase.
        APPEND VALUE #( %tky = <costbase>-%tky ) TO
                        failed-managecostbase.

    ENDLOOP.

  ENDMETHOD.

  METHOD triggerWorkflow.

*  DATA: CpWfHandle TYPE /esrcc/sww_wiid.
*    DATA: costbase_tmp TYPE /esrcc/i_managecostbase.
*    DATA: costbases_tmp TYPE TABLE OF /esrcc/i_managecostbase.
*
*    " Return result to UI
*    READ ENTITIES OF /esrcc/i_managecostbase IN LOCAL MODE
*        ENTITY managecostbase
*        ALL FIELDS
*        WITH CORRESPONDING #( keys )
*        RESULT DATA(costbases).
*
*    LOOP AT costbases ASSIGNING FIELD-SYMBOL(<costbase>) WHERE status = 'P'
*                                                           AND WorkflowId IS INITIAL.
*
*
*
*
*
*
*
*      READ TABLE costbases_tmp ASSIGNING FIELD-SYMBOL(<costbases_tmp>) WITH KEY fplv = <costbase>-fplv
*                                                                               ryear = <costbase>-ryear
*                                                                               Legalentity = <costbase>-Legalentity
*                                                                               ccode = <costbase>-ccode
*                                                                               sysid = <costbase>-sysid
*                                                                               costobject = <costbase>-costobject
*                                                                               Costcenter = <costbase>-costcenter.
*      IF sy-subrc <> 0.
*
*        TRY.
*          CALL METHOD cl_numberrange_runtime=>number_get
*            EXPORTING
*              nr_range_nr = '01'
*              object      = '/ESRCC/WF'
*            IMPORTING
*              number      = DATA(number)
*              returncode  = DATA(lv_rcode).
*        CATCH cx_number_ranges         .
*      ENDTRY.
*
*       <costbase>-WorkflowId = number.
*
*        DATA(wf_context) = VALUE /esrcc/s_wf_bpa_object(
*               fplv = <costbase>-fplv
*               ryear = <costbase>-ryear
*               sysid = <costbase>-sysid
*               legalentity = <costbase>-legalentity
*               ccode = <costbase>-ccode
*               costobject = <costbase>-costobject
*               costnumber = <costbase>-costcenter
*               application = 'CBL'
*               workflowid = <costbase>-WorkflowId
*             ).
*
*        MODIFY ENTITIES OF i_cpwf_inst
*             ENTITY CPWFInstance
*             EXECUTE registerWorkflowStart
*             FROM VALUE #( (
*                             %key-CpWfHandle = <costbase>-WorkflowId
*                             %param-RetentionTime = '30'
*                             %param-PaWfDefId = 'eu10.dev-abap-cloud.sccworkflow1.SCCWorkflow'
*                             %param-CallbackClass = '/ESRCC/CL_SWF_CPWF_CALLBACK'
*                             %param-Consumer = 'DEFAULT' ) ).
*
*        TRY.
*            DATA(cpwf_api_instance) = cl_swf_cpwf_api_factory_a4c=>get_api_instance( ).
*          CATCH cx_swf_cpwf_api.
*        ENDTRY.
*
*        DATA(lo_json) = cpwf_api_instance->get_json_converter(
**                              it_name_mapping              =
*                                    iv_camel_case                = abap_false
*                                    iv_capital_letter            = abap_false
**                              it_uppercase_word            =
*                                    iv_suppress_empty_components = abap_true
*                                    iv_uppercase                 = abap_false
*                                  ).
*
*        DATA(wf_context_json) = lo_json->serialize( wf_context ).
*
*
*        MODIFY ENTITIES OF i_cpwf_inst
*             ENTITY CPWFInstance
*             EXECUTE setPayload
*             FROM VALUE #( ( %key-CpWfHandle = <costbase>-WorkflowId
*                             %param-context = wf_context_json ) ).
*
*        costbase_tmp = CORRESPONDING #( <costbase> ).
*        APPEND costbase_tmp TO costbases_tmp.
*
*      ELSE.
*        <costbase>-WorkflowId = <costbases_tmp>-WorkflowId.
*      ENDIF.
*
*    ENDLOOP.
*
*    MODIFY ENTITIES OF /esrcc/i_managecostbase  IN LOCAL MODE
*       ENTITY managecostbase
*        UPDATE FIELDS ( WorkflowId Status )
*             WITH VALUE #( FOR costbase IN costbases WHERE ( status = 'P' )
*                             (
*                                %key = costbase-%key
*                                WorkflowId = costbase-WorkflowId
*                                status = 'W'
*                              ) )
*                             FAILED   FINAL(fail_mod)
*                              REPORTED FINAL(rep_mod)
*                              MAPPED FINAL(map_mod).


  ENDMETHOD.

ENDCLASS.
