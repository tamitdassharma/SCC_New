CLASS lhc_c_execution_cockpit DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR /esrcc/c_execution_cockpit RESULT result.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE /esrcc/c_execution_cockpit.

    METHODS read FOR READ
      IMPORTING keys FOR READ /esrcc/c_execution_cockpit RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK /esrcc/c_execution_cockpit.

    METHODS finalizechargeout FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~finalizechargeout.

    METHODS finalizecostbase FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~finalizecostbase.

    METHODS finalizestewardship FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~finalizestewardship.

    METHODS performcostbase FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~performcostbase.

    METHODS performchargeout FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~performchargeout.

    METHODS performstewardship FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~performstewardship.

    METHODS reopenchargeout FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~reopenchargeout.

    METHODS reopencostbase FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~reopencostbase.

    METHODS reopenstewardship FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~reopenstewardship.

ENDCLASS.

CLASS lhc_c_execution_cockpit IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD finalizechargeout.

    DATA lt_procctrl TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl TYPE  /esrcc/procctrl.
    DATA lt_chargeout TYPE TABLE OF /esrcc/rec_cost.
    DATA ls_chargeout TYPE /esrcc/rec_cost.
    DATA _poper TYPE RANGE OF poper.

*Derive poper from billing frequency customizing
    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      SELECT 'I'  AS sign,
            'EQ'  AS option,
            poper AS low
            FROM /esrcc/billfreq
            WHERE billingfreq = @<key>-billingfreq
              AND billingvalue = @<key>-billingperiod
            ORDER BY low ASCENDING
            INTO CORRESPONDING FIELDS OF TABLE @_poper.
    ENDIF.

    LOOP AT keys ASSIGNING <key> WHERE costcenter IS NOT INITIAL AND serviceproduct IS NOT INITIAL.
      ls_procctrl = CORRESPONDING #( <key> ).
      ls_procctrl-process = 'CHR'.    "Charge-Out
      ls_procctrl-status = '05'.     "Charge Out finalized

* Admin data
      ls_procctrl-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = ls_procctrl-last_changed_at
      ).

      APPEND ls_procctrl TO lt_procctrl.
    ENDLOOP.

*Finalize calculated receiever
    SELECT * FROM /esrcc/srv_cost FOR ALL ENTRIES IN @keys WHERE fplv = @keys-fplv
                                                             AND ryear = @keys-ryear
                                                             AND sysid = @keys-sysid
                                                             AND  poper IN @_poper
                                                             AND  legalentity = @keys-legalentity
                                                             AND  ccode = @keys-ccode
                                                             AND  costobject = @keys-costobject
                                                             AND  costcenter = @keys-costcenter
                                                             AND  serviceproduct = @keys-serviceproduct
                                  INTO TABLE @DATA(lt_srv_cost).

    SELECT * FROM /esrcc/rec_cost FOR ALL ENTRIES IN @keys WHERE fplv = @keys-fplv
                                                             AND ryear = @keys-ryear
                                                             AND sysid = @keys-sysid
                                                             AND  poper IN @_poper
                                                             AND  legalentity = @keys-legalentity
                                                             AND  ccode = @keys-ccode
                                                             AND  costobject = @keys-costobject
                                                             AND  costcenter = @keys-costcenter
                                                             AND  serviceproduct = @keys-serviceproduct
                                  INTO TABLE @DATA(lt_rec_cost).

    LOOP AT lt_rec_cost ASSIGNING FIELD-SYMBOL(<ls_rec_cost>).
      <ls_rec_cost>-status = 'F'.

* Admin data
      <ls_rec_cost>-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_rec_cost>-last_changed_at
      ).

    ENDLOOP.


*Handling of delta for Indirect Scenario
*If there is cost base which is not allocation 100% due to consumption for a period then allocate that cost base and comsumption to a dummy receiver
    SELECT fplv,
           ryear,
           poper,
           sysid,
           legalentity,
           ccode,
           costobject,
           costcenter,
           serviceproduct,
           SUM( reckpi ) AS totalreckpi,
           SUM( reckpishareabsl ) AS totalchargeoutl,
           SUM( reckpishareabsg ) AS totalchargeoutg
           FROM @lt_rec_cost AS chg
           WHERE chg~chargeout = 'D'
           GROUP BY
           fplv,
           ryear,
           poper,
           sysid,
           legalentity,
           ccode,
           costobject,
           costcenter,
           serviceproduct INTO TABLE @DATA(lt_diragg_chargeout).

    LOOP AT lt_diragg_chargeout ASSIGNING FIELD-SYMBOL(<ls_diragg>).
      READ TABLE lt_srv_cost ASSIGNING FIELD-SYMBOL(<ls_chargeout>) WITH KEY fplv = <ls_diragg>-fplv
                                                                              ryear = <ls_diragg>-ryear
                                                                              poper = <ls_diragg>-poper
                                                                              sysid = <ls_diragg>-sysid
                                                                              legalentity = <ls_diragg>-legalentity
                                                                              ccode = <ls_diragg>-ccode
                                                                              costobject = <ls_diragg>-costobject
                                                                              costcenter = <ls_diragg>-costcenter
                                                                              serviceproduct = <ls_diragg>-serviceproduct.

      IF sy-subrc = 0 AND <ls_diragg>-totalreckpi <> <ls_chargeout>-planning.
        READ TABLE lt_rec_cost INTO ls_chargeout WITH KEY fplv = <ls_diragg>-fplv
                                                                              ryear = <ls_diragg>-ryear
                                                                              poper = <ls_diragg>-poper
                                                                              sysid = <ls_diragg>-sysid
                                                                              legalentity = <ls_diragg>-legalentity
                                                                              ccode = <ls_diragg>-ccode
                                                                              costobject = <ls_diragg>-costobject
                                                                              costcenter = <ls_diragg>-costcenter
                                                                              serviceproduct = <ls_diragg>-serviceproduct.
* add a dummy receiver
        IF sy-subrc = 0.

          ls_chargeout-receivingentity = 'REST'.
          ls_chargeout-reckpishareabsl = ( <ls_chargeout>-srvcostsharel + <ls_chargeout>-valueaddmarkupabsl + <ls_chargeout>-passthrumarkupabsl ) - <ls_diragg>-totalchargeoutl.
          ls_chargeout-reckpishareabsg = ( <ls_chargeout>-srvcostshareg + <ls_chargeout>-valueaddmarkupabsg + <ls_chargeout>-passthrumarkupabsg ) - <ls_diragg>-totalchargeoutg.
          ls_chargeout-reckpi = <ls_chargeout>-planning - <ls_diragg>-totalreckpi.
          ls_chargeout-recvalueaddmarkupabsl = ( ls_chargeout-recvalueaddmarkupabsl / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
          ls_chargeout-recvalueaddmarkupabsg = ( ls_chargeout-recvalueaddmarkupabsg / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
          ls_chargeout-recpassthrumarkupabsl = ( ls_chargeout-recpassthrumarkupabsl / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
          ls_chargeout-recpassthrumarkupabsg = ( ls_chargeout-recpassthrumarkupabsg / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
          ls_chargeout-recvalueaddedl = ( ls_chargeout-recvalueaddedl / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
          ls_chargeout-recvalueaddedg = ( ls_chargeout-recvalueaddedg / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
          ls_chargeout-recpassthroughl = ( ls_chargeout-recpassthroughl / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
          ls_chargeout-recpassthroughg = ( ls_chargeout-recpassthroughg / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
          ls_chargeout-recorigtotalcostl = ( ls_chargeout-recorigtotalcostl / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
          ls_chargeout-recorigtotalcostg = ( ls_chargeout-recorigtotalcostg / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
          ls_chargeout-recpasstotalcostl = ( ls_chargeout-recpasstotalcostl / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
          ls_chargeout-recpasstotalcostg = ( ls_chargeout-recpasstotalcostg / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
          ls_chargeout-recexcludedcostl = ( ls_chargeout-recexcludedcostl / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
          ls_chargeout-recexcludedcostg = ( ls_chargeout-recexcludedcostg / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
          ls_chargeout-rectotalcostl = ( ls_chargeout-rectotalcostl / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
          ls_chargeout-rectotalcostg = ( ls_chargeout-rectotalcostg / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
          ls_chargeout-billingperiod = keys[ 1 ]-billingperiod.
          APPEND ls_chargeout TO lt_rec_cost.
        ENDIF.
      ENDIF.

    ENDLOOP.

    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.
    MODIFY /esrcc/rec_cost FROM TABLE @lt_rec_cost.

  ENDMETHOD.

  METHOD finalizecostbase.

    DATA lt_procctrl TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl TYPE  /esrcc/procctrl.
    DATA _poper TYPE RANGE OF poper.

*Derive poper from billing frequency customizing
    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      SELECT 'I'  AS sign,
            'EQ'  AS option,
            poper AS low
            FROM /esrcc/billfreq
            WHERE billingfreq = @<key>-billingfreq
              AND billingvalue = @<key>-billingperiod
            ORDER BY low ASCENDING
            INTO CORRESPONDING FIELDS OF TABLE @_poper.
    ENDIF.

*update execution process control
    LOOP AT keys ASSIGNING <key> WHERE costcenter IS NOT INITIAL AND serviceproduct IS INITIAL.
      ls_procctrl = CORRESPONDING #( <key> ).
      ls_procctrl-process = 'CBS'.    "Costbase
      ls_procctrl-status = '08'.     "Cost base finalized

* Admin data
      ls_procctrl-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = ls_procctrl-last_changed_at
      ).

      APPEND ls_procctrl TO lt_procctrl.
    ENDLOOP.

*Finalize cost base line items.
    SELECT * FROM /esrcc/cb_li FOR ALL ENTRIES IN @keys WHERE     fplv = @keys-fplv
                                                             AND  ryear = @keys-ryear
                                                             AND sysid = @keys-sysid
                                                             AND  poper IN @_poper
                                                             AND  legalentity = @keys-legalentity
                                                             AND  ccode = @keys-ccode
                                                             AND  costobject = @keys-costobject
                                                             AND  costcenter = @keys-costcenter
                                                             INTO TABLE @DATA(lt_cb_li).

    LOOP AT lt_cb_li ASSIGNING FIELD-SYMBOL(<ls_cb_li>).
      <ls_cb_li>-status = 'F'.

* Admin data
      <ls_cb_li>-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_cb_li>-last_changed_at
      ).

    ENDLOOP.

*Finalize calculated Cost base & Stewardship
    SELECT * FROM /esrcc/cc_cost FOR ALL ENTRIES IN @keys WHERE fplv = @keys-fplv
                                                             AND ryear = @keys-ryear
                                                             AND sysid = @keys-sysid
                                                             AND  poper IN @_poper
                                                             AND  legalentity = @keys-legalentity
                                                             AND  ccode = @keys-ccode
                                                             AND  costobject = @keys-costobject
                                                             AND  costcenter = @keys-costcenter
*                                                             AND  serviceproduct = @keys-serviceproduct
                                  INTO TABLE @DATA(lt_cc_cost).

    LOOP AT lt_cc_cost ASSIGNING FIELD-SYMBOL(<ls_cc_cost>).
      <ls_cc_cost>-status = 'F'.

* Admin data
      <ls_cc_cost>-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_cc_cost>-last_changed_at
      ).

    ENDLOOP.




    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.
    MODIFY /esrcc/cb_li FROM TABLE @lt_cb_li.
    MODIFY /esrcc/cc_cost FROM TABLE @lt_cc_cost.

  ENDMETHOD.

  METHOD finalizestewardship.

    DATA lt_procctrl TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl TYPE  /esrcc/procctrl.
    DATA _poper TYPE RANGE OF poper.

*Derive poper from billing frequency customizing
    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      SELECT 'I'  AS sign,
            'EQ'  AS option,
            poper AS low
            FROM /esrcc/billfreq
            WHERE billingfreq = @<key>-billingfreq
              AND billingvalue = @<key>-billingperiod
            ORDER BY low ASCENDING
            INTO CORRESPONDING FIELDS OF TABLE @_poper.
    ENDIF.

*  Finalize Process Control
    LOOP AT keys ASSIGNING <key> WHERE costcenter IS NOT INITIAL AND serviceproduct IS NOT INITIAL.
      ls_procctrl = CORRESPONDING #( <key> ).
      ls_procctrl-process = 'SCM'.    "Stewardship
      ls_procctrl-status = '05'.     "Stewardship Finalized

* Admin data
      ls_procctrl-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = ls_procctrl-last_changed_at
      ).

      APPEND ls_procctrl TO lt_procctrl.
    ENDLOOP.

*Finalize calculated Cost base & Stewardship
    SELECT * FROM /esrcc/srv_cost FOR ALL ENTRIES IN @keys WHERE fplv = @keys-fplv
                                                             AND ryear = @keys-ryear
                                                             AND sysid = @keys-sysid
                                                             AND  poper IN @_poper
                                                             AND  legalentity = @keys-legalentity
                                                             AND  ccode = @keys-ccode
                                                             AND  costobject = @keys-costobject
                                                             AND  costcenter = @keys-costcenter
                                                             AND  serviceproduct = @keys-serviceproduct
                                  INTO TABLE @DATA(lt_srv_cost).

    LOOP AT lt_srv_cost ASSIGNING FIELD-SYMBOL(<ls_srv_cost>).
      <ls_srv_cost>-status = 'F'.

* Admin data
      <ls_srv_cost>-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_srv_cost>-last_changed_at
      ).

    ENDLOOP.

    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.
    MODIFY /esrcc/srv_cost FROM TABLE @lt_srv_cost.
  ENDMETHOD.

  METHOD performchargeout.

    DATA lt_rec_cost TYPE TABLE OF /esrcc/rec_cost.
    DATA lt_rec_share TYPE TABLE OF /esrcc/recshare.
    DATA lt_srv_values TYPE TABLE OF /esrcc/srvvalues.
    DATA lt_procctrl TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl TYPE  /esrcc/procctrl.
    DATA _poper TYPE RANGE OF poper.
    DATA ls_wf_leadobj TYPE /esrcc/s_wf_leadingobject.
    DATA lt_wf_leadobj TYPE /esrcc/tt_wf_leadingobject.
    DATA lv_valid_from TYPE /esrcc/validfrom.

*Derive poper from billing frequency customizing
    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      SELECT 'I'  AS sign,
            'EQ'  AS option,
            poper AS low
            FROM /esrcc/billfreq
            WHERE billingfreq = @<key>-billingfreq
              AND billingvalue = @<key>-billingperiod
            ORDER BY low ASCENDING
            INTO CORRESPONDING FIELDS OF TABLE @_poper.
    ENDIF.

    /esrcc/cl_wf_utility=>is_wf_on(
      EXPORTING
        iv_apptype   = 'CHR'
      IMPORTING
        ev_wf_active = DATA(wf_active)
    ).


    CLEAR: ls_wf_leadobj,lt_wf_leadobj.

*Receiver allocation
    SELECT * FROM /esrcc/i_chargeout_recshare FOR ALL ENTRIES IN @keys WHERE  fplv = @keys-fplv
                                                                          AND ryear = @keys-ryear
                                                                          AND sysid = @keys-sysid
                                                                          AND  poper IN @_poper
                                                                          AND  legalentity = @keys-legalentity
                                                                          AND  ccode = @keys-ccode
                                                                          AND  costobject = @keys-costobject
                                                                          AND  costcenter = @keys-costcenter
                                                                          AND  serviceproduct = @keys-serviceproduct
                                                                          INTO CORRESPONDING FIELDS OF TABLE @lt_rec_cost.
*Service Allocation
    SELECT * FROM /esrcc/recshare FOR ALL ENTRIES IN @keys WHERE  fplv = @keys-fplv
                                                              AND ryear = @keys-ryear
                                                              AND sysid = @keys-sysid
                                                              AND  poper IN @_poper
                                                              AND  legalentity = @keys-legalentity
                                                              AND  ccode = @keys-ccode
                                                              AND  costobject = @keys-costobject
                                                              AND  costcenter = @keys-costcenter
                                                              AND  serviceproduct = @keys-serviceproduct
                                                              INTO TABLE @DATA(lt_recshare_del).

    SELECT * FROM /esrcc/i_chargeout_indkpishare FOR ALL ENTRIES IN @keys WHERE  fplv = @keys-fplv
                                                                       AND ryear = @keys-ryear
                                                                       AND sysid = @keys-sysid
                                                                       AND  poper IN @_poper
                                                                       AND  legalentity = @keys-legalentity
                                                                       AND  ccode = @keys-ccode
                                                                       AND  costobject = @keys-costobject
                                                                       AND  costcenter = @keys-costcenter
                                                                       AND  serviceproduct = @keys-serviceproduct
                                                                       INTO CORRESPONDING FIELDS OF TABLE @lt_rec_share.

    SELECT * FROM /esrcc/srvvalues FOR ALL ENTRIES IN @keys WHERE  fplv = @keys-fplv
                                                               AND ryear = @keys-ryear
                                                               AND sysid = @keys-sysid
                                                               AND  poper IN @_poper
                                                               AND  legalentity = @keys-legalentity
                                                               AND  ccode = @keys-ccode
                                                               AND  costobject = @keys-costobject
                                                               AND  costcenter = @keys-costcenter
                                                               AND  serviceproduct = @keys-serviceproduct
                                                               INTO TABLE @DATA(lt_srvvalues_del).

    SELECT * FROM /esrcc/i_indallocvalues FOR ALL ENTRIES IN @keys WHERE  fplv = @keys-fplv
                                                                       AND ryear = @keys-ryear
                                                                       AND sysid = @keys-sysid
                                                                       AND  poper IN @_poper
                                                                       AND  legalentity = @keys-legalentity
                                                                       AND  ccode = @keys-ccode
                                                                       AND  costobject = @keys-costobject
                                                                       AND  costcenter = @keys-costcenter
                                                                       AND  serviceproduct = @keys-serviceproduct
                                                                       INTO CORRESPONDING FIELDS OF TABLE @lt_srv_values.






    LOOP AT lt_rec_cost ASSIGNING FIELD-SYMBOL(<ls_rec_cost>).

      IF wf_active EQ abap_true.
        CLEAR ls_wf_leadobj.
        MOVE-CORRESPONDING <ls_rec_cost> TO ls_wf_leadobj.
        IF <key> IS ASSIGNED.
          ls_wf_leadobj-billingperiod = <key>-billingperiod.
        ENDIF.
        APPEND ls_wf_leadobj TO lt_wf_leadobj.
*        <ls_rec_cost>-status = 'W'.   "In Approval
      ELSE.
        <ls_rec_cost>-status = 'A'.   "Approved
      ENDIF.

* Admin data
      <ls_rec_cost>-created_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_rec_cost>-created_at
      ).
      <ls_rec_cost>-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_rec_cost>-last_changed_at
      ).

* valid from = first day of the month.
      CONCATENATE <ls_rec_cost>-ryear <ls_rec_cost>-poper+1(2) '01' INTO lv_valid_from.

      CALL FUNCTION '/ESRCC/FM_LAST_DAY_OF_MONTH'
        EXPORTING
          day_in       = lv_valid_from
        IMPORTING
          end_of_month = <ls_rec_cost>-exchdate.

    ENDLOOP.

    IF wf_active EQ abap_true.
      CALL FUNCTION '/ESRCC/FM_WF_START'
        EXPORTING
          it_leading_object = lt_wf_leadobj
          iv_apptype        = 'CHR'.
    ENDIF.

    LOOP AT keys ASSIGNING <key> WHERE costcenter IS NOT INITIAL AND serviceproduct IS NOT INITIAL.
      ls_procctrl = CORRESPONDING #( <key> ).
      ls_procctrl-process = 'CHR'.    "Charge-out
      IF wf_active EQ abap_false.
        ls_procctrl-status = '04'.     "Charge-out approved
      ELSE.
        ls_procctrl-status = '02'.     "Charge-out In Process
      ENDIF.

* Admin data
      ls_procctrl-created_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = ls_procctrl-created_at
      ).
      ls_procctrl-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = ls_procctrl-last_changed_at
      ).

      APPEND ls_procctrl TO lt_procctrl.
    ENDLOOP.

    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.
    MODIFY /esrcc/rec_cost FROM TABLE @lt_rec_cost.
    DELETE /esrcc/recshare FROM TABLE @lt_recshare_del.
    MODIFY /esrcc/recshare FROM TABLE @lt_rec_share.
    DELETE /esrcc/srvvalues FROM TABLE @lt_srvvalues_del.
    MODIFY /esrcc/srvvalues FROM TABLE @lt_srv_values.

  ENDMETHOD.

  METHOD performstewardship.

    DATA lt_cc_cost  TYPE TABLE OF /esrcc/cc_cost.
    DATA lt_srv_cost TYPE TABLE OF /esrcc/srv_cost.
    DATA lt_procctrl TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl TYPE  /esrcc/procctrl.
    DATA _poper TYPE RANGE OF poper.
    DATA ls_wf_leadobj TYPE /esrcc/s_wf_leadingobject.
    DATA lt_wf_leadobj TYPE /esrcc/tt_wf_leadingobject.

*Derive poper from billing frequency customizing
    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      SELECT 'I'  AS sign,
            'EQ'  AS option,
            poper AS low
            FROM /esrcc/billfreq
            WHERE billingfreq = @<key>-billingfreq
              AND billingvalue = @<key>-billingperiod
            ORDER BY low ASCENDING
            INTO CORRESPONDING FIELDS OF TABLE @_poper.
    ENDIF.

    SELECT * FROM /esrcc/i_chargeout_unitcost FOR ALL ENTRIES IN @keys WHERE
                                                                      fplv = @keys-fplv
                                                                  AND ryear = @keys-ryear
                                                                  AND sysid = @keys-sysid
                                                                  AND  poper IN @_poper
                                                                  AND  legalentity = @keys-legalentity
                                                                  AND  ccode = @keys-ccode
                                                                  AND  costobject = @keys-costobject
                                                                  AND  costcenter = @keys-costcenter
                                                                  AND  serviceproduct = @keys-serviceproduct
                                                                  INTO CORRESPONDING FIELDS OF TABLE @lt_srv_cost.


    /esrcc/cl_wf_utility=>is_wf_on(
      EXPORTING
        iv_apptype   = 'SCM'
      IMPORTING
        ev_wf_active = DATA(wf_active)
    ).


    CLEAR: ls_wf_leadobj,lt_wf_leadobj.



    LOOP AT lt_srv_cost ASSIGNING FIELD-SYMBOL(<ls_srv_cost>).
      IF wf_active EQ abap_true.
        CLEAR ls_wf_leadobj.
        MOVE-CORRESPONDING <ls_srv_cost> TO ls_wf_leadobj.
        IF <key> IS ASSIGNED.
          ls_wf_leadobj-billingperiod = <key>-billingperiod.
        ENDIF.
        APPEND ls_wf_leadobj TO lt_wf_leadobj.
*        <ls_srv_cost>-status = 'W'.   "In Approval
      ELSE.
        <ls_srv_cost>-status = 'A'.   "Approved
      ENDIF.

* Admin data
      <ls_srv_cost>-created_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_srv_cost>-created_at
      ).
      <ls_srv_cost>-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_srv_cost>-last_changed_at
      ).

    ENDLOOP.

    IF wf_active EQ abap_true.
      CALL FUNCTION '/ESRCC/FM_WF_START'
        EXPORTING
          it_leading_object = lt_wf_leadobj
          iv_apptype        = 'SCM'.
    ENDIF.



    LOOP AT keys ASSIGNING <key> WHERE costcenter IS NOT INITIAL AND serviceproduct IS NOT INITIAL.
      ls_procctrl = CORRESPONDING #( <key> ).
      ls_procctrl-process = 'SCM'.    "Stewardship
      IF wf_active =  abap_false.
        ls_procctrl-status = '04'.     "Stewardship Approved
      ELSE.
        ls_procctrl-status = '02'.     "Stewardship In Process
      ENDIF.

* Admin data
      ls_procctrl-created_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = ls_procctrl-created_at
      ).
      ls_procctrl-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = ls_procctrl-last_changed_at
      ).

      APPEND ls_procctrl TO lt_procctrl.
    ENDLOOP.

    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.
    MODIFY /esrcc/srv_cost FROM TABLE @lt_srv_cost.


  ENDMETHOD.

  METHOD reopenchargeout.

    DATA lt_procctrl TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl TYPE  /esrcc/procctrl.
    DATA _poper TYPE RANGE OF poper.

*Derive poper from billing frequency customizing
    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      SELECT 'I'  AS sign,
            'EQ'  AS option,
            poper AS low
            FROM /esrcc/billfreq
            WHERE billingfreq = @<key>-billingfreq
              AND billingvalue = @<key>-billingperiod
            ORDER BY low ASCENDING
            INTO CORRESPONDING FIELDS OF TABLE @_poper.
    ENDIF.

* Update status in execution cockpit process control
    LOOP AT keys ASSIGNING <key> WHERE costcenter IS NOT INITIAL AND serviceproduct IS NOT INITIAL.
      ls_procctrl = CORRESPONDING #( <key> ).
      ls_procctrl-process = 'CHR'.    "Costbase
      APPEND ls_procctrl TO lt_procctrl.
    ENDLOOP.

*  Delete receiver cost
    SELECT * FROM /esrcc/rec_cost FOR ALL ENTRIES IN @keys WHERE fplv = @keys-fplv
                                                             AND ryear = @keys-ryear
                                                             AND sysid = @keys-sysid
                                                             AND  poper IN @_poper
                                                             AND  legalentity = @keys-legalentity
                                                             AND  ccode = @keys-ccode
                                                             AND  costobject = @keys-costobject
                                                             AND  costcenter = @keys-costcenter
                                                             AND  serviceproduct = @keys-serviceproduct
                                                             AND status NE 'W'
                                  INTO TABLE @DATA(lt_rec_cost).

*  Delete Service Allocation
    SELECT * FROM /esrcc/recshare FOR ALL ENTRIES IN @keys WHERE fplv = @keys-fplv
                                                             AND ryear = @keys-ryear
                                                             AND sysid = @keys-sysid
                                                             AND  poper IN @_poper
                                                             AND  legalentity = @keys-legalentity
                                                             AND  ccode = @keys-ccode
                                                             AND  costobject = @keys-costobject
                                                             AND  costcenter = @keys-costcenter
                                                             AND  serviceproduct = @keys-serviceproduct
                                  INTO TABLE @DATA(lt_rec_share).

    SELECT * FROM /esrcc/srvvalues FOR ALL ENTRIES IN @keys WHERE fplv = @keys-fplv
                                                             AND ryear = @keys-ryear
                                                             AND sysid = @keys-sysid
                                                             AND  poper IN @_poper
                                                             AND  legalentity = @keys-legalentity
                                                             AND  ccode = @keys-ccode
                                                             AND  costobject = @keys-costobject
                                                             AND  costcenter = @keys-costcenter
                                                             AND  serviceproduct = @keys-serviceproduct
                                  INTO TABLE @DATA(lt_srvvalues).


    DELETE /esrcc/procctrl FROM TABLE @lt_procctrl.
    DELETE /esrcc/rec_cost FROM TABLE @lt_rec_cost.
    DELETE /esrcc/recshare FROM TABLE @lt_rec_share.
    DELETE /esrcc/srvvalues FROM TABLE @lt_srvvalues.

  ENDMETHOD.

  METHOD reopencostbase.

    DATA lt_procctrl TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl TYPE  /esrcc/procctrl.
    DATA _poper TYPE RANGE OF poper.

*Derive poper from billing frequency customizing
    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      SELECT 'I'  AS sign,
            'EQ'  AS option,
            poper AS low
            FROM /esrcc/billfreq
            WHERE billingfreq = @<key>-billingfreq
              AND billingvalue = @<key>-billingperiod
            ORDER BY low ASCENDING
            INTO CORRESPONDING FIELDS OF TABLE @_poper.
    ENDIF.

*Update execution cockpit process control
    SELECT * FROM /esrcc/procctrl FOR ALL ENTRIES IN @keys WHERE fplv = @keys-fplv
                                                             AND ryear = @keys-ryear
                                                             AND sysid = @keys-sysid
                                                             AND legalentity = @keys-legalentity
                                                             AND ccode = @keys-ccode
                                                             AND costobject = @keys-costobject
                                                             AND costcenter = @keys-costcenter
                                                             AND billingfreq = @keys-billingfreq
                                                             AND billingperiod = @keys-billingperiod
                                                             INTO TABLE @lt_procctrl.

*ReOpen cost base line items.
    SELECT * FROM /esrcc/cb_li FOR ALL ENTRIES IN @keys WHERE    fplv = @keys-fplv
                                                             AND ryear = @keys-ryear
                                                             AND sysid = @keys-sysid
                                                             AND  poper IN @_poper
                                                             AND  legalentity = @keys-legalentity
                                                             AND  ccode = @keys-ccode
                                                             AND  costobject = @keys-costobject
                                                             AND  costcenter = @keys-costcenter
                                  INTO TABLE @DATA(lt_cb_li).

    LOOP AT lt_cb_li ASSIGNING FIELD-SYMBOL(<ls_cb_li>).
      <ls_cb_li>-status = 'A'.
    ENDLOOP.

*  Delete cost center cost
    SELECT * FROM /esrcc/cc_cost FOR ALL ENTRIES IN @keys WHERE  fplv = @keys-fplv
                                                             AND ryear = @keys-ryear
                                                             AND sysid = @keys-sysid
                                                             AND  poper IN @_poper
                                                             AND  legalentity = @keys-legalentity
                                                             AND  ccode = @keys-ccode
                                                             AND  costobject = @keys-costobject
                                                             AND  costcenter = @keys-costcenter
                                                             INTO TABLE @DATA(lt_cc_cost).

*  Delete service cost
    SELECT * FROM /esrcc/srv_cost FOR ALL ENTRIES IN @keys WHERE  fplv = @keys-fplv
                                                             AND ryear = @keys-ryear
                                                             AND sysid = @keys-sysid
                                                             AND  poper IN @_poper
                                                             AND  legalentity = @keys-legalentity
                                                             AND  ccode = @keys-ccode
                                                             AND  costobject = @keys-costobject
                                                             AND  costcenter = @keys-costcenter
                                                             INTO TABLE @DATA(lt_srv_cost).

*  Delete receiver cost
    SELECT * FROM /esrcc/rec_cost FOR ALL ENTRIES IN @keys WHERE fplv = @keys-fplv
                                                             AND ryear = @keys-ryear
                                                             AND sysid = @keys-sysid
                                                             AND  poper IN @_poper
                                                             AND  legalentity = @keys-legalentity
                                                             AND  ccode = @keys-ccode
                                                             AND  costobject = @keys-costobject
                                                             AND  costcenter = @keys-costcenter
                                                             INTO TABLE @DATA(lt_rec_cost).

*  Delete Service Allocation
    SELECT * FROM /esrcc/recshare FOR ALL ENTRIES IN @keys WHERE fplv = @keys-fplv
                                                             AND ryear = @keys-ryear
                                                             AND sysid = @keys-sysid
                                                             AND  poper IN @_poper
                                                             AND  legalentity = @keys-legalentity
                                                             AND  ccode = @keys-ccode
                                                             AND  costobject = @keys-costobject
                                                             AND  costcenter = @keys-costcenter
                                                             INTO TABLE @DATA(lt_rec_share).

    SELECT * FROM /esrcc/srvvalues FOR ALL ENTRIES IN @keys WHERE fplv = @keys-fplv
                                                             AND ryear = @keys-ryear
                                                             AND sysid = @keys-sysid
                                                             AND  poper IN @_poper
                                                             AND  legalentity = @keys-legalentity
                                                             AND  ccode = @keys-ccode
                                                             AND  costobject = @keys-costobject
                                                             AND  costcenter = @keys-costcenter
                                                             INTO TABLE @DATA(lt_srvvalues).



    DELETE /esrcc/procctrl FROM TABLE @lt_procctrl.
    DELETE /esrcc/cc_cost FROM TABLE @lt_cc_cost.
    DELETE /esrcc/srv_cost FROM TABLE @lt_srv_cost.
    DELETE /esrcc/rec_cost FROM TABLE @lt_rec_cost.
    DELETE /esrcc/recshare FROM TABLE @lt_rec_share.
    DELETE /esrcc/srvvalues FROM TABLE @lt_srvvalues.
    MODIFY /esrcc/cb_li FROM TABLE @lt_cb_li.

  ENDMETHOD.

  METHOD reopenstewardship.

    DATA lt_procctrl TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl TYPE  /esrcc/procctrl.
    DATA _poper TYPE RANGE OF poper.

*Derive poper from billing frequency customizing
    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      SELECT 'I'  AS sign,
            'EQ'  AS option,
            poper AS low
            FROM /esrcc/billfreq
            WHERE billingfreq = @<key>-billingfreq
              AND billingvalue = @<key>-billingperiod
            ORDER BY low ASCENDING
            INTO CORRESPONDING FIELDS OF TABLE @_poper.
    ENDIF.

*Update execution cockpit process control
    LOOP AT keys ASSIGNING <key> WHERE costcenter IS NOT INITIAL AND serviceproduct IS NOT INITIAL.

      ls_procctrl = CORRESPONDING #( <key> ).
      ls_procctrl-process = 'SCM'.    "Stewardship
      APPEND ls_procctrl TO lt_procctrl.

      ls_procctrl = CORRESPONDING #( <key> ).
      ls_procctrl-process = 'CHR'.    "Chargeout
      APPEND ls_procctrl TO lt_procctrl.
    ENDLOOP.

*  Delete service cost
    SELECT * FROM /esrcc/srv_cost FOR ALL ENTRIES IN @keys WHERE  fplv = @keys-fplv
                                                             AND ryear = @keys-ryear
                                                             AND sysid = @keys-sysid
                                                             AND  poper IN @_poper
                                                             AND  legalentity = @keys-legalentity
                                                             AND  ccode = @keys-ccode
                                                             AND  costobject = @keys-costobject
                                                             AND  costcenter = @keys-costcenter
                                                             AND  serviceproduct = @keys-serviceproduct
                                                             INTO TABLE @DATA(lt_srv_cost).

*  Delete receiver cost
    SELECT * FROM /esrcc/rec_cost FOR ALL ENTRIES IN @keys WHERE  fplv = @keys-fplv
                                                             AND ryear = @keys-ryear
                                                             AND sysid = @keys-sysid
                                                             AND  poper IN @_poper
                                                             AND  legalentity = @keys-legalentity
                                                             AND  ccode = @keys-ccode
                                                             AND  costobject = @keys-costobject
                                                             AND  costcenter = @keys-costcenter
                                                             AND  serviceproduct = @keys-serviceproduct
                                                             INTO TABLE @DATA(lt_rec_cost).

*  Delete Service Allocation
    SELECT * FROM /esrcc/recshare FOR ALL ENTRIES IN @keys WHERE fplv = @keys-fplv
                                                             AND ryear = @keys-ryear
                                                             AND sysid = @keys-sysid
                                                             AND  poper IN @_poper
                                                             AND  legalentity = @keys-legalentity
                                                             AND  ccode = @keys-ccode
                                                             AND  costobject = @keys-costobject
                                                             AND  costcenter = @keys-costcenter
                                                             INTO TABLE @DATA(lt_rec_share).

    SELECT * FROM /esrcc/srvvalues FOR ALL ENTRIES IN @keys WHERE fplv = @keys-fplv
                                                             AND ryear = @keys-ryear
                                                             AND sysid = @keys-sysid
                                                             AND  poper IN @_poper
                                                             AND  legalentity = @keys-legalentity
                                                             AND  ccode = @keys-ccode
                                                             AND  costobject = @keys-costobject
                                                             AND  costcenter = @keys-costcenter
                                                             INTO TABLE @DATA(lt_srvvalues).

    DELETE /esrcc/procctrl FROM TABLE @lt_procctrl.
    DELETE /esrcc/srv_cost FROM TABLE @lt_srv_cost.
    DELETE /esrcc/rec_cost FROM TABLE @lt_rec_cost.
    DELETE /esrcc/recshare FROM TABLE @lt_rec_share.
    DELETE /esrcc/srvvalues FROM TABLE @lt_srvvalues.

  ENDMETHOD.

  METHOD performcostbase.

    DATA lt_cc_cost  TYPE TABLE OF /esrcc/cc_cost.
    DATA lt_srv_cost TYPE TABLE OF /esrcc/srv_cost.
    DATA lt_procctrl TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl TYPE  /esrcc/procctrl.
    DATA _poper TYPE RANGE OF poper.
    DATA ls_wf_leadobj TYPE /esrcc/s_wf_leadingobject.
    DATA lt_wf_leadobj TYPE /esrcc/tt_wf_leadingobject.


*Derive poper from billing frequency customizing
    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      SELECT 'I'  AS sign,
            'EQ'  AS option,
            poper AS low
            FROM /esrcc/billfreq
            WHERE billingfreq = @<key>-billingfreq
              AND billingvalue = @<key>-billingperiod
            ORDER BY low ASCENDING
            INTO CORRESPONDING FIELDS OF TABLE @_poper.
    ENDIF.


    SELECT * FROM /esrcc/i_costbase_stewardship FOR ALL ENTRIES IN @keys WHERE  fplv = @keys-fplv
                                                                  AND ryear = @keys-ryear
                                                                  AND sysid = @keys-sysid
                                                                  AND  poper IN @_poper
                                                                  AND  legalentity = @keys-legalentity
                                                                  AND  ccode = @keys-ccode
                                                                  AND  costobject = @keys-costobject
                                                                  AND  costcenter = @keys-costcenter
                                                                  INTO CORRESPONDING FIELDS OF TABLE @lt_cc_cost.

*
    /esrcc/cl_wf_utility=>is_wf_on(
      EXPORTING
        iv_apptype   = 'CBS'
      IMPORTING
        ev_wf_active = DATA(wf_active)
    ).


    CLEAR: ls_wf_leadobj,lt_wf_leadobj.

    LOOP AT lt_cc_cost ASSIGNING FIELD-SYMBOL(<ls_cc_cost>).
      <ls_cc_cost>-billingperiod = keys[ 1 ]-billingperiod.
* Admin data
      <ls_cc_cost>-created_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_cc_cost>-created_at
      ).
      <ls_cc_cost>-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_cc_cost>-last_changed_at
      ).

      IF wf_active EQ abap_true.
        CLEAR ls_wf_leadobj.
        MOVE-CORRESPONDING <ls_cc_cost> TO ls_wf_leadobj.
        APPEND ls_wf_leadobj TO lt_wf_leadobj.
*        <ls_cc_cost>-status = 'W'.   "In Approval
      ELSE.
        <ls_cc_cost>-status = 'A'.   "Approval
      ENDIF.
    ENDLOOP.


    IF wf_active EQ abap_true.
      CALL FUNCTION '/ESRCC/FM_WF_START'
        EXPORTING
          it_leading_object = lt_wf_leadobj
          iv_apptype        = 'CBS'.
    ENDIF.


    LOOP AT keys ASSIGNING <key> WHERE costcenter IS NOT INITIAL AND serviceproduct IS INITIAL.
      ls_procctrl = CORRESPONDING #( <key> ).
      ls_procctrl-process = 'CBS'.    "Cost Base
      IF wf_active = abap_false.
        ls_procctrl-status = '07'.     "Cost Base Approved
      ELSE.
        ls_procctrl-status = '05'.     "Cost Base In Process
      ENDIF.

* Admin data
      ls_procctrl-created_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = ls_procctrl-created_at
      ).
      ls_procctrl-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = ls_procctrl-last_changed_at
      ).

      APPEND ls_procctrl TO lt_procctrl.
    ENDLOOP.

    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.
    MODIFY /esrcc/cc_cost FROM TABLE @lt_cc_cost.


  ENDMETHOD.

ENDCLASS.

CLASS lsc_c_execution_cockpit DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_c_execution_cockpit IMPLEMENTATION.

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
