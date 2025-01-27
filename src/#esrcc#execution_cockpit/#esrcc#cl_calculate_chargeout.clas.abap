CLASS /esrcc/cl_calculate_chargeout DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS: costbase               TYPE /esrcc/application_type_de VALUE 'CBS',
               serviceshare           TYPE /esrcc/application_type_de VALUE 'SCM',
               chargeout              TYPE /esrcc/application_type_de VALUE 'CHR',
               approved               TYPE /esrcc/chargeoutstatus     VALUE 'A',
               draft                  TYPE /esrcc/chargeoutstatus     VALUE 'D',
               finalized              TYPE /esrcc/chargeoutstatus     VALUE 'F',
               approval_pending       TYPE /esrcc/chargeoutstatus   VALUE 'W',
               rejected               TYPE /esrcc/chargeoutstatus   VALUE 'R',
               chargeout_approved     TYPE /esrcc/process_status_de VALUE '04',
               chargeout_inprocess    TYPE /esrcc/process_status_de VALUE '02',
               chargeout_finalized    TYPE /esrcc/process_status_de VALUE '05',
               costbase_approved      TYPE /esrcc/process_status_de VALUE '07',
               costbase_inprocess     TYPE /esrcc/process_status_de VALUE '05',
               costbase_finalized     TYPE /esrcc/process_status_de VALUE '08',
               serviceshare_approved  TYPE /esrcc/process_status_de VALUE '04',
               serviceshare_inprocess TYPE /esrcc/process_status_de VALUE '02',
               serviceshare_finalized TYPE /esrcc/process_status_de VALUE '05',
               scc_valuesource        TYPE /esrcc/ce_value_source   VALUE 'SCC'.

    CLASS-METHODS: calculate_costbase
      IMPORTING
        !it_keys TYPE /esrcc/tt_keys.

    CLASS-METHODS: calculate_servicecostshare
      IMPORTING
        !it_keys TYPE /esrcc/tt_keys.

    CLASS-METHODS: calculate_chargeout
      IMPORTING
        !it_keys TYPE /esrcc/tt_keys.

    CLASS-METHODS: finalize_costbase
      IMPORTING
        !it_keys TYPE /esrcc/tt_keys.
    CLASS-METHODS: finalize_servicecostshare
      IMPORTING
        !it_keys TYPE /esrcc/tt_keys.
    CLASS-METHODS: finalize_chargeout
      IMPORTING
        !it_keys TYPE /esrcc/tt_keys.
    CLASS-METHODS: reopen_costbase
      IMPORTING
        !it_keys TYPE /esrcc/tt_keys.

    CLASS-METHODS: reopen_serviceshare
      IMPORTING
        !it_keys           TYPE /esrcc/tt_keys
        !iv_costbasereopen TYPE abap_boolean OPTIONAL.

    CLASS-METHODS: reopen_chargeout
      IMPORTING
        !it_keys           TYPE /esrcc/tt_keys
        !iv_costbasereopen TYPE abap_boolean OPTIONAL.

    CLASS-METHODS: calculate_adhocchargeout
      IMPORTING
        !it_cbli       TYPE /esrcc/tt_cbli
        !is_parameters TYPE /esrcc/c_adhocchargeout
        !it_receivers  TYPE /esrcc/tt_receivers.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-METHODS: determine_delta_chargeout
      IMPORTING
        !it_keys  TYPE /esrcc/tt_keys
        !it_poper TYPE /esrcc/tt_poper_range.

    CLASS-METHODS: virtual_posting
      IMPORTING
        !it_keys  TYPE /esrcc/tt_keys
        !it_poper TYPE /esrcc/tt_poper_range.

    CLASS-METHODS: determine_last_day
      IMPORTING
        !iv_ryear    TYPE /esrcc/ryear
        !iv_poper    TYPE poper
      EXPORTING
        !ev_valid_on TYPE /esrcc/validfrom.

    CLASS-METHODS: delete_virtual_postings
      IMPORTING
        !it_keys  TYPE /esrcc/tt_keys
        !it_poper TYPE /esrcc/tt_poper_range.

    CLASS-METHODS: trigger_workflow
      IMPORTING
        !it_leading_object TYPE /esrcc/tt_wf_leadingobject
        !iv_application    TYPE /esrcc/application_type_de.

    CLASS-METHODS: delete_chargeout
      IMPORTING
        !it_keys           TYPE /esrcc/tt_keys
        !it_poper          TYPE /esrcc/tt_poper_range
        !iv_costbasereopen TYPE abap_boolean OPTIONAL.

    CLASS-METHODS: delete_servicecostshare
      IMPORTING
        !it_keys           TYPE /esrcc/tt_keys
        !it_poper          TYPE /esrcc/tt_poper_range
        !iv_costbasereopen TYPE abap_boolean OPTIONAL.

    CLASS-METHODS: delete_costbase
      IMPORTING
        !it_keys  TYPE /esrcc/tt_keys
        !it_poper TYPE /esrcc/tt_poper_range.

    CLASS-METHODS: derive_poper
      IMPORTING
        !it_keys  TYPE /esrcc/tt_keys
      EXPORTING
        !et_poper TYPE /esrcc/tt_poper_range.

ENDCLASS.



CLASS /esrcc/cl_calculate_chargeout IMPLEMENTATION.


  METHOD calculate_adhocchargeout.

    DATA lt_cb_stw   TYPE TABLE OF /esrcc/cb_stw.
    DATA lt_srvshare TYPE TABLE OF /esrcc/srv_share.
    DATA lt_recchg   TYPE TABLE OF /esrcc/rec_chg.

    SELECT fplv,
           ryear,
           poper,
           sysid,
           legalentity,
           ccode,
           costobject,
           costcenter,
           businessdivision,
           profitcenter,
           localcurr,
           groupcurr,
           SUM( hsl ) AS totalcost_l,
           SUM( ksl ) AS totalcost_g
           FROM @it_cbli AS cbli
           GROUP BY
           fplv,
           ryear,
           poper,
           sysid,
           legalentity,
           ccode,
           costobject,
           costcenter,
           businessdivision,
           profitcenter,
           localcurr,
           groupcurr
           INTO CORRESPONDING FIELDS OF TABLE @lt_cb_stw.

    SELECT fplv,
           ryear,
           poper,
           sysid,
           legalentity,
           ccode,
           costobject,
           costcenter,
           businessdivision,
           profitcenter,
           localcurr,
           groupcurr,
           SUM( hsl ) AS origtotalcost_l,
           SUM( ksl ) AS origtotalcost_g
           FROM @it_cbli AS cbli
           WHERE costind = 'ORIG'
           GROUP BY
           fplv,
           ryear,
           poper,
           sysid,
           legalentity,
           ccode,
           costobject,
           costcenter,
           businessdivision,
           profitcenter,
           localcurr,
           groupcurr
           INTO TABLE @DATA(lt_cb_stw_orig).

    SELECT fplv,
          ryear,
          poper,
          sysid,
          legalentity,
          ccode,
          costobject,
          costcenter,
          businessdivision,
          profitcenter,
          localcurr,
          groupcurr,
          SUM( hsl ) AS passtotalcost_l,
          SUM( ksl ) AS passtotalcost_g
          FROM @it_cbli AS cbli
          WHERE costind = 'PASS'
          GROUP BY
          fplv,
          ryear,
          poper,
          sysid,
          legalentity,
          ccode,
          costobject,
          costcenter,
          businessdivision,
          profitcenter,
          localcurr,
          groupcurr
          INTO TABLE @DATA(lt_cb_stw_pass).

    SELECT SINGLE * FROM /esrcc/srvpro WHERE serviceproduct = @is_parameters-Serviceproduct
                                INTO @DATA(ls_serviceproduct).

    SELECT SINGLE * FROM /esrcc/co_rule WHERE rule_id = @is_parameters-rule_id
                                INTO @DATA(ls_rule).

    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).

    LOOP AT lt_cb_stw ASSIGNING FIELD-SYMBOL(<ls_cbstw>).

      READ TABLE lt_cb_stw_orig ASSIGNING FIELD-SYMBOL(<ls_cb_stw_orig>)
                                    WITH KEY fplv         = <ls_cbstw>-fplv
                                              ryear       = <ls_cbstw>-ryear
                                              poper       = <ls_cbstw>-poper
                                              sysid       = <ls_cbstw>-sysid
                                              legalentity = <ls_cbstw>-legalentity
                                              ccode       = <ls_cbstw>-ccode
                                              costobject  = <ls_cbstw>-costobject
                                              costcenter  = <ls_cbstw>-costcenter.
      IF sy-subrc = 0.
        <ls_cbstw>-origtotalcost_l = <ls_cb_stw_orig>-origtotalcost_l.
        <ls_cbstw>-origtotalcost_g = <ls_cb_stw_orig>-origtotalcost_g.
      ENDIF.

      READ TABLE lt_cb_stw_pass ASSIGNING FIELD-SYMBOL(<ls_cb_stw_pass>)
                                    WITH KEY fplv         = <ls_cbstw>-fplv
                                              ryear       = <ls_cbstw>-ryear
                                              poper       = <ls_cbstw>-poper
                                              sysid       = <ls_cbstw>-sysid
                                              legalentity = <ls_cbstw>-legalentity
                                              ccode       = <ls_cbstw>-ccode
                                              costobject  = <ls_cbstw>-costobject
                                              costcenter  = <ls_cbstw>-costcenter.
      IF sy-subrc = 0.
        <ls_cbstw>-passtotalcost_l = <ls_cb_stw_pass>-passtotalcost_l.
        <ls_cbstw>-passtotalcost_g = <ls_cb_stw_pass>-passtotalcost_g.
      ENDIF.
      <ls_cbstw>-billfrequency = 'M'.
* Assign the 16 digit unique identifier
      IF lo_uuid IS BOUND.
        TRY.
            <ls_cbstw>-cc_uuid = lo_uuid->create_uuid_x16( ).
            DATA(lv_ccuuid) = <ls_cbstw>-cc_uuid.
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY.
      ENDIF.
      DATA(localcurr) = <ls_cbstw>-localcurr.
      DATA(groupcurr) = <ls_cbstw>-groupcurr.
      <ls_cbstw>-status = finalized.
      determine_last_day(
       EXPORTING
         iv_ryear    = <ls_cbstw>-ryear
         iv_poper    = <ls_cbstw>-poper
       IMPORTING
         ev_valid_on = DATA(exchdate)
     ).
* Admin data
      <ls_cbstw>-created_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_cbstw>-created_at
      ).
      <ls_cbstw>-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_cbstw>-last_changed_at
      ).
**************************************************************************
*Determine Service Cost Share
**************************************************************************
      APPEND INITIAL LINE TO lt_srvshare ASSIGNING FIELD-SYMBOL(<ls_srvshare>).

      <ls_srvshare>-serviceproduct = is_parameters-Serviceproduct.
      <ls_srvshare>-servicetype = ls_serviceproduct-servicetype.
      <ls_srvshare>-transactiongroup = ls_serviceproduct-transactiongroup.
      <ls_srvshare>-costshare = 100.
      <ls_srvshare>-chargeout = ls_rule-chargeout_method.
      <ls_srvshare>-key_version = ls_rule-key_version.
      <ls_srvshare>-consumption_version = ls_rule-consumption_version.
      <ls_srvshare>-capacity_version = ls_rule-capacity_version.
      <ls_srvshare>-uom = ls_rule-uom.
      <ls_srvshare>-cc_uuid = lv_ccuuid.
      <ls_srvshare>-status = finalized.
* Assign the 16 digit unique identifier
      IF lo_uuid IS BOUND.
        TRY.
            <ls_srvshare>-srv_uuid = lo_uuid->create_uuid_x16( ).
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY.
      ENDIF.
      DATA(lv_srvuuid) = <ls_srvshare>-srv_uuid.
* Admin data
      <ls_srvshare>-created_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_srvshare>-created_at
      ).
      <ls_srvshare>-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_srvshare>-last_changed_at
      ).
**************************************************************************
*Determine Receiver Charge out
**************************************************************************
      LOOP AT it_receivers ASSIGNING FIELD-SYMBOL(<ls_receivers>).

        APPEND INITIAL LINE TO lt_recchg ASSIGNING FIELD-SYMBOL(<ls_recchg>).
* Assign the 16 digit unique identifier
        IF lo_uuid IS BOUND.
          <ls_recchg>-cc_uuid  = lv_ccuuid.
          <ls_recchg>-srv_uuid = lv_srvuuid.
          TRY.
              <ls_recchg>-rec_uuid = lo_uuid->create_uuid_x16( ).
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.
        ENDIF.
        <ls_recchg>-receiversysid       = <ls_receivers>-sysid.
        <ls_recchg>-receivercompanycode = <ls_receivers>-ccode.
        <ls_recchg>-receivingentity     = <ls_receivers>-legalentity.
        <ls_recchg>-receivercostobject  = <ls_receivers>-costobject.
        <ls_recchg>-receivercostcenter  = <ls_receivers>-costcenter.
        <ls_recchg>-reckpishare         = <ls_receivers>-sharepercent.
        IF <ls_cbstw>-legalentity <> <ls_receivers>-legalentity.
          <ls_recchg>-valueaddmarkup      = is_parameters-intervalueaddmarkup.
          <ls_recchg>-passthrumarkup      = is_parameters-interpassthroughmarkup.
        ELSE.
          <ls_recchg>-valueaddmarkup      = is_parameters-intravalueaddmarkup.
          <ls_recchg>-passthrumarkup      = is_parameters-intrapassthroughmarkup.
        ENDIF.
        <ls_recchg>-exchdate            = exchdate.
        <ls_recchg>-status              = finalized.
* Admin data
        <ls_recchg>-created_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = <ls_recchg>-created_at
        ).
        <ls_srvshare>-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = <ls_recchg>-last_changed_at
        ).
      ENDLOOP.
    ENDLOOP.

    DATA(lt_cbli) = it_cbli.
    LOOP AT lt_cbli ASSIGNING FIELD-SYMBOL(<ls_cbli>).
      <ls_cbli>-usagecal = 'E'.
      <ls_cbli>-status = finalized.
      <ls_cbli>-reasonid = 7.
* Admin data
      <ls_cbli>-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_cbli>-last_changed_at
      ).
    ENDLOOP.

    MODIFY /esrcc/cb_stw    FROM TABLE @lt_cb_stw.
    MODIFY /esrcc/srv_share FROM TABLE @lt_srvshare.
    MODIFY /esrcc/rec_chg   FROM TABLE @lt_recchg.
    MODIFY /esrcc/cb_li     FROM TABLE @lt_cbli.

  ENDMETHOD.


  METHOD calculate_chargeout.

    DATA lt_rec_chg    TYPE TABLE OF /esrcc/rec_chg.
    DATA lt_rec_share  TYPE TABLE OF /esrcc/alocshare.
    DATA lt_srv_values TYPE TABLE OF /esrcc/alcvalues.
    DATA lt_procctrl   TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl   TYPE  /esrcc/procctrl.
    DATA ls_wf_leadobj TYPE /esrcc/s_wf_leadingobject.
    DATA lt_wf_leadobj TYPE /esrcc/tt_wf_leadingobject.
    DATA lv_valid_from TYPE /esrcc/validfrom.


*Derive poper from billing frequency customizing
    derive_poper(
      EXPORTING
        it_keys  = it_keys
      IMPORTING
        et_poper = DATA(_poper)
    ).

    DATA(lt_keys) = it_keys.
    DELETE lt_keys WHERE serviceproduct IS INITIAL.

    READ TABLE lt_keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    /esrcc/cl_wf_utility=>is_wf_on(
      EXPORTING
        iv_apptype   = chargeout
      IMPORTING
        ev_wf_active = DATA(wf_active)
    ).


    CLEAR: ls_wf_leadobj,lt_wf_leadobj.

*Receiver charge out and markup
    SELECT * FROM /esrcc/i_chargeout_recshare FOR ALL ENTRIES IN @lt_keys
                                              WHERE  fplv          = @lt_keys-fplv
                                                AND ryear          = @lt_keys-ryear
                                                AND sysid          = @lt_keys-sysid
                                                AND poper         IN @_poper
                                                AND legalentity    = @lt_keys-legalentity
                                                AND ccode          = @lt_keys-ccode
                                                AND costobject     = @lt_keys-costobject
                                                AND costcenter     = @lt_keys-costcenter
                                                AND serviceproduct = @lt_keys-serviceproduct
                                                INTO TABLE @DATA(lt_rec_cost).

*Delete old allocation data in case user re-triggered chargeout without re-open
*  Delete receiver cost
    delete_chargeout(
      it_keys  = it_keys
      it_poper = _poper
    ).

* Create New allocation data
    SELECT * FROM /esrcc/i_chargeout_indkpishare FOR ALL ENTRIES IN @lt_keys
                                                 WHERE  fplv        = @lt_keys-fplv
                                                   AND ryear        = @lt_keys-ryear
                                                   AND sysid        = @lt_keys-sysid
                                                   AND poper        IN @_poper
                                                   AND legalentity  = @lt_keys-legalentity
                                                   AND  ccode       = @lt_keys-ccode
                                                   AND  costobject  = @lt_keys-costobject
                                                   AND  costcenter  = @lt_keys-costcenter
                                                   AND  serviceproduct = @lt_keys-serviceproduct
                                                   INTO TABLE @DATA(lt_allocation_share).

    SELECT * FROM /esrcc/i_indallocvalues FOR ALL ENTRIES IN @lt_keys
                                          WHERE  fplv       = @lt_keys-fplv
                                            AND ryear       = @lt_keys-ryear
                                            AND sysid       = @lt_keys-sysid
                                            AND  poper      IN @_poper
                                            AND  legalentity = @lt_keys-legalentity
                                            AND  ccode       = @lt_keys-ccode
                                            AND  costobject  = @lt_keys-costobject
                                            AND  costcenter  = @lt_keys-costcenter
                                            AND  serviceproduct = @lt_keys-serviceproduct
                                            INTO TABLE @DATA(lt_allocation_values).

    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).

    LOOP AT lt_rec_cost ASSIGNING FIELD-SYMBOL(<ls_rec_cost>).
      APPEND INITIAL LINE TO lt_rec_chg ASSIGNING FIELD-SYMBOL(<ls_rec_chg>).
      MOVE-CORRESPONDING <ls_rec_cost> TO <ls_rec_chg>.

      IF wf_active EQ abap_true.
        CLEAR ls_wf_leadobj.
        MOVE-CORRESPONDING <ls_rec_cost> TO ls_wf_leadobj.
        IF <key> IS ASSIGNED.
          ls_wf_leadobj-billfrequency = <key>-billingfreq.
          ls_wf_leadobj-billingperiod = <key>-billingperiod.
        ENDIF.
        APPEND ls_wf_leadobj TO lt_wf_leadobj.
      ELSE.
        <ls_rec_chg>-status = approved.   "Approved
      ENDIF.

* Admin data
      <ls_rec_chg>-created_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_rec_chg>-created_at
      ).
      <ls_rec_chg>-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_rec_chg>-last_changed_at
      ).

* Assign the 16 digit unique identifier
      IF lo_uuid IS BOUND.
        TRY.
            <ls_rec_chg>-rec_uuid = lo_uuid->create_uuid_x16( ).
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY.
      ENDIF.

* get exchange rate day
      determine_last_day(
        EXPORTING
          iv_ryear    = <ls_rec_cost>-ryear
          iv_poper    = <ls_rec_cost>-poper
        IMPORTING
          ev_valid_on = <ls_rec_chg>-exchdate
      ).

* Assign the 16 digit unique identifier for allocation share
      LOOP AT lt_allocation_share ASSIGNING FIELD-SYMBOL(<ls_allocation_share>)
                                  WHERE  fplv           = <ls_rec_cost>-fplv
                                    AND ryear           = <ls_rec_cost>-ryear
                                    AND sysid           = <ls_rec_cost>-sysid
                                    AND poper           = <ls_rec_cost>-poper
                                    AND legalentity     = <ls_rec_cost>-legalentity
                                    AND ccode           = <ls_rec_cost>-ccode
                                    AND costobject      = <ls_rec_cost>-costobject
                                    AND costcenter      = <ls_rec_cost>-costcenter
                                    AND serviceproduct  = <ls_rec_cost>-serviceproduct
                                    AND ReceiverSysId   = <ls_rec_cost>-receiversysid
                                    AND ReceiverCompanyCode = <ls_rec_cost>-receivercompanycode
                                    AND ReceivingEntity = <ls_rec_cost>-receivingentity
                                    AND ReceiverCostObject = <ls_rec_cost>-receivercostobject
                                    AND ReceiverCostCenter = <ls_rec_cost>-receivercostcenter.

        APPEND INITIAL LINE TO lt_rec_share ASSIGNING FIELD-SYMBOL(<ls_rec_share>).
        MOVE-CORRESPONDING <ls_allocation_share> TO <ls_rec_share>.
        IF lo_uuid IS BOUND.
          TRY.
              <ls_rec_share>-uuid = lo_uuid->create_uuid_x16( ).
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.
          <ls_rec_share>-parentuuid = <ls_rec_chg>-rec_uuid.
        ENDIF.

* Assign the 16 digit unique identifier for allocation values
        LOOP AT lt_allocation_values ASSIGNING FIELD-SYMBOL(<ls_allocation_values>)
                                     WHERE  fplv            = <ls_rec_cost>-fplv
                                       AND ryear            = <ls_rec_cost>-ryear
                                       AND sysid            = <ls_rec_cost>-sysid
                                       AND poper            = <ls_rec_cost>-poper
                                       AND legalentity      = <ls_rec_cost>-legalentity
                                       AND ccode            = <ls_rec_cost>-ccode
                                       AND costobject       = <ls_rec_cost>-costobject
                                       AND costcenter       = <ls_rec_cost>-costcenter
                                       AND serviceproduct   = <ls_rec_cost>-serviceproduct
                                       AND ReceiverSysId    = <ls_rec_cost>-receiversysid
                                       AND ReceiverCompanyCode = <ls_rec_cost>-receivercompanycode
                                       AND ReceivingEntity  = <ls_rec_cost>-receivingentity
                                       AND ReceiverCostObject = <ls_rec_cost>-receivercostobject
                                       AND ReceiverCostCenter = <ls_rec_cost>-receivercostcenter.

          APPEND INITIAL LINE TO lt_srv_values ASSIGNING FIELD-SYMBOL(<ls_srv_values>).
          MOVE-CORRESPONDING <ls_allocation_values> TO <ls_srv_values>.
          IF lo_uuid IS BOUND.
            TRY.
                <ls_srv_values>-uuid = lo_uuid->create_uuid_x16( ).
              CATCH cx_uuid_error.
                "handle exception
            ENDTRY.
            <ls_srv_values>-parentuuid = <ls_rec_share>-uuid.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    IF wf_active EQ abap_true.
      trigger_workflow(
        it_leading_object = lt_wf_leadobj
        iv_application    = chargeout
      ).
    ENDIF.

    LOOP AT lt_keys ASSIGNING <key> WHERE costcenter IS NOT INITIAL
                                    AND serviceproduct IS NOT INITIAL.
      ls_procctrl = CORRESPONDING #( <key> ).
      ls_procctrl-process = chargeout.    "Charge-out
      IF wf_active EQ abap_false.
        ls_procctrl-status = chargeout_approved.     "Charge-out approved
      ELSE.
        ls_procctrl-status = chargeout_inprocess.     "Charge-out In Process
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

    MODIFY /esrcc/procctrl  FROM TABLE @lt_procctrl.
    MODIFY /esrcc/rec_chg   FROM TABLE @lt_rec_chg.
    MODIFY /esrcc/alocshare FROM TABLE @lt_rec_share.
    MODIFY /esrcc/alcvalues FROM TABLE @lt_srv_values.

  ENDMETHOD.


  METHOD calculate_costbase.

    DATA lt_cc_cost    TYPE TABLE OF /esrcc/cb_stw.
    DATA lt_procctrl   TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl   TYPE  /esrcc/procctrl.
    DATA ls_wf_leadobj TYPE /esrcc/s_wf_leadingobject.
    DATA lt_wf_leadobj TYPE /esrcc/tt_wf_leadingobject.


*Derive poper from billing frequency customizing
    derive_poper(
      EXPORTING
        it_keys  = it_keys
      IMPORTING
        et_poper = DATA(_poper)
    ).


    SELECT * FROM /esrcc/i_costbase_stewardship FOR ALL ENTRIES IN @it_keys
                                                WHERE  fplv      = @it_keys-fplv
                                                  AND ryear      = @it_keys-ryear
                                                  AND sysid      = @it_keys-sysid
                                                  AND poper     IN @_poper
                                                  AND legalentity = @it_keys-legalentity
                                                  AND ccode      = @it_keys-ccode
                                                  AND costobject = @it_keys-costobject
                                                  AND costcenter = @it_keys-costcenter
                                         INTO CORRESPONDING FIELDS OF TABLE @lt_cc_cost.

*
    /esrcc/cl_wf_utility=>is_wf_on(
      EXPORTING
        iv_apptype   = costbase
      IMPORTING
        ev_wf_active = DATA(wf_active)
    ).


    CLEAR: ls_wf_leadobj,lt_wf_leadobj.

    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).

    LOOP AT lt_cc_cost ASSIGNING FIELD-SYMBOL(<ls_cc_cost>).

* Assign the 16 digit unique identifier
      IF lo_uuid IS BOUND.
        TRY.
            <ls_cc_cost>-cc_uuid = lo_uuid->create_uuid_x16( ).
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY.
      ENDIF.

      <ls_cc_cost>-billingperiod = it_keys[ 1 ]-billingperiod.
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
      ELSE.
        <ls_cc_cost>-status = approved.   "Approval
      ENDIF.
    ENDLOOP.


    IF wf_active EQ abap_true.
      trigger_workflow(
        it_leading_object = lt_wf_leadobj
        iv_application    = costbase
      ).
    ENDIF.


    LOOP AT it_keys ASSIGNING FIELD-SYMBOL(<key>) WHERE costcenter IS NOT INITIAL
                                    AND serviceproduct IS INITIAL.
      ls_procctrl = CORRESPONDING #( <key> ).
      ls_procctrl-process = costbase.    "Cost Base
      IF wf_active = abap_false.
        ls_procctrl-status = costbase_approved.     "Cost Base Approved
      ELSE.
        ls_procctrl-status = costbase_inprocess.     "Cost Base In Process
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

*  Delete old as user might have re-triggered costbase & stewardship calculation
    delete_costbase(
      it_keys  = it_keys
      it_poper = _poper
    ).

    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.
    MODIFY /esrcc/cb_stw FROM TABLE @lt_cc_cost.

  ENDMETHOD.


  METHOD calculate_servicecostshare.

    DATA lt_srvshare   TYPE TABLE OF /esrcc/srv_share.
    DATA lt_procctrl   TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl   TYPE  /esrcc/procctrl.
    DATA ls_wf_leadobj TYPE /esrcc/s_wf_leadingobject.
    DATA lt_wf_leadobj TYPE /esrcc/tt_wf_leadingobject.

*Derive poper from billing frequency customizing
    derive_poper(
      EXPORTING
        it_keys  = it_keys
      IMPORTING
        et_poper = DATA(_poper)
    ).

    DATA(lt_keys) = it_keys.
    DELETE lt_keys WHERE serviceproduct IS INITIAL.

    READ TABLE lt_keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    SELECT * FROM /esrcc/i_chargeout_unitcost FOR ALL ENTRIES IN @lt_keys
                                              WHERE fplv         = @lt_keys-fplv
                                                AND ryear        = @lt_keys-ryear
                                                AND sysid        = @lt_keys-sysid
                                                AND poper       IN @_poper
                                                AND legalentity  = @lt_keys-legalentity
                                                AND ccode        = @lt_keys-ccode
                                                AND costobject   = @lt_keys-costobject
                                                AND costcenter   = @lt_keys-costcenter
                                                AND serviceproduct = @lt_keys-serviceproduct
                                                AND ServiceProduct IS NOT INITIAL
                                       INTO TABLE @DATA(lt_srv_cost).


    /esrcc/cl_wf_utility=>is_wf_on(
      EXPORTING
        iv_apptype   = serviceshare
      IMPORTING
        ev_wf_active = DATA(wf_active)
    ).


    CLEAR: ls_wf_leadobj,lt_wf_leadobj.


    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).

    LOOP AT lt_srv_cost ASSIGNING FIELD-SYMBOL(<ls_srv_cost>)
                        WHERE ServiceProduct IS NOT INITIAL.
      APPEND INITIAL LINE TO lt_srvshare ASSIGNING FIELD-SYMBOL(<ls_srvshare>).

      MOVE-CORRESPONDING <ls_srv_cost> TO <ls_srvshare>.
      IF wf_active EQ abap_true.
        CLEAR ls_wf_leadobj.
        MOVE-CORRESPONDING <ls_srv_cost> TO ls_wf_leadobj.
        IF <key> IS ASSIGNED.
          ls_wf_leadobj-billfrequency = <key>-billingfreq.
          ls_wf_leadobj-billingperiod = <key>-billingperiod.
        ENDIF.
        APPEND ls_wf_leadobj TO lt_wf_leadobj.
      ELSE.
        <ls_srvshare>-status = approved.   "Approved
      ENDIF.

* Admin data
      <ls_srvshare>-created_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_srvshare>-created_at
      ).
      <ls_srvshare>-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_srvshare>-last_changed_at
      ).

* Assign the 16 digit unique identifier
      IF lo_uuid IS BOUND.
        TRY.
            <ls_srvshare>-srv_uuid = lo_uuid->create_uuid_x16( ).
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY.
      ENDIF.

    ENDLOOP.

    IF wf_active EQ abap_true.
      trigger_workflow(
        it_leading_object = lt_wf_leadobj
        iv_application    = serviceshare
      ).
    ENDIF.



    LOOP AT lt_keys ASSIGNING <key> WHERE costcenter IS NOT INITIAL AND serviceproduct IS NOT INITIAL.
      ls_procctrl = CORRESPONDING #( <key> ).
      ls_procctrl-process = serviceshare.
      IF wf_active =  abap_false.
        ls_procctrl-status = serviceshare_approved.     "Stewardship Approved
      ELSE.
        ls_procctrl-status = serviceshare_inprocess.     "Stewardship In Process
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

*delete old service product share as user might re-trigger calculations again
*  Delete service cost
    delete_servicecostshare(
      it_keys  = it_keys
      it_poper = _poper
    ).

    MODIFY /esrcc/procctrl  FROM TABLE @lt_procctrl.
    MODIFY /esrcc/srv_share FROM TABLE @lt_srvshare.

  ENDMETHOD.


  METHOD delete_virtual_postings.

*    DATA ls_cbli TYPE /esrcc/cb_li.
*    DATA lt_cbli TYPE TABLE OF /esrcc/cb_li.
*    DATA lv_valid_from TYPE /esrcc/validfrom.
*    DATA number TYPE /esrcc/doc_no.

    SELECT * FROM /esrcc/cb_li FOR ALL ENTRIES IN @it_keys
                                             WHERE fplv                 = @it_keys-fplv
                                               AND ryear                = @it_keys-ryear
                                               AND posting_sysid        = @it_keys-sysid
                                               AND poper               IN @it_poper
                                               AND posting_legalentity  = @it_keys-legalentity
                                               AND posting_ccode        = @it_keys-ccode
                                               AND posting_costobject   = @it_keys-costobject
                                               AND posting_costcenter   = @it_keys-costcenter
                                               AND value_source = 'SCC'
                                               INTO TABLE @DATA(lt_costbase).

    DELETE /esrcc/cb_li FROM TABLE @lt_costbase.

  ENDMETHOD.


  METHOD determine_delta_chargeout.

*Handling of delta for Indirect Scenario
*If there is cost base which is not allocated 100% due to difference between consumption & planning
* for a period then allocate that cost base and remaining comsumption to a dummy receiver
    SELECT rec_chg~* FROM /esrcc/cb_stw AS cb_stw
          INNER JOIN /esrcc/srv_share AS srv_share
                  ON cb_stw~cc_uuid = srv_share~cc_uuid
                 AND srv_share~chargeout = 'D'
          INNER JOIN /esrcc/rec_chg AS rec_chg
                  ON cb_stw~cc_uuid = rec_chg~cc_uuid
                 AND srv_share~srv_uuid = rec_chg~srv_uuid
          FOR ALL ENTRIES IN @it_keys
                WHERE fplv          = @it_keys-fplv
                  AND ryear         = @it_keys-ryear
                  AND sysid         = @it_keys-sysid
                  AND poper        IN @it_poper
                  AND legalentity   = @it_keys-legalentity
                  AND ccode         = @it_keys-ccode
                  AND costobject    = @it_keys-costobject
                  AND costcenter    = @it_keys-costcenter
                  AND serviceproduct = @it_keys-serviceproduct
                  INTO TABLE @DATA(lt_recshare).

    SELECT ryear,poper,srv_share~* FROM /esrcc/cb_stw AS cb_stw
         INNER JOIN /esrcc/srv_share AS srv_share
                 ON cb_stw~cc_uuid = srv_share~cc_uuid
                AND srv_share~chargeout = 'D'
         FOR ALL ENTRIES IN @it_keys
               WHERE fplv          = @it_keys-fplv
                 AND ryear         = @it_keys-ryear
                 AND sysid         = @it_keys-sysid
                 AND poper        IN @it_poper
                 AND legalentity   = @it_keys-legalentity
                 AND ccode         = @it_keys-ccode
                 AND costobject    = @it_keys-costobject
                 AND costcenter    = @it_keys-costcenter
                 AND serviceproduct = @it_keys-serviceproduct
                 INTO TABLE @DATA(lt_srvshare).

    SELECT cc_uuid,
           srv_uuid,
           SUM( reckpi ) AS totalconsumption
           FROM @lt_recshare AS recshare
           GROUP BY
           cc_uuid,
           srv_uuid
           INTO TABLE @DATA(lt_totalconsumption).
    CLEAR lt_recshare.
    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).
    LOOP AT lt_srvshare ASSIGNING FIELD-SYMBOL(<ls_srvshare>).
      READ TABLE lt_totalconsumption ASSIGNING FIELD-SYMBOL(<totalconsumption>)
                                     WITH KEY cc_uuid = <ls_srvshare>-srv_share-cc_uuid
                                              srv_uuid = <ls_srvshare>-srv_share-srv_uuid.

      IF sy-subrc = 0 AND <ls_srvshare>-srv_share-planning > <totalconsumption>-totalconsumption.
** add a dummy receiver
        APPEND INITIAL LINE TO lt_recshare ASSIGNING FIELD-SYMBOL(<recshare>).
        <recshare>-cc_uuid = <ls_srvshare>-srv_share-cc_uuid.
        <recshare>-srv_uuid = <ls_srvshare>-srv_share-srv_uuid.
* Assign the 16 digit unique identifier
        IF lo_uuid IS BOUND.
          TRY.
              <recshare>-rec_uuid = lo_uuid->create_uuid_x16( ).
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.
        ENDIF.
        <recshare>-receivingentity = 'REST'.
        <recshare>-reckpi = <ls_srvshare>-srv_share-planning - <totalconsumption>-totalconsumption.
        <recshare>-consumptionuom = <ls_srvshare>-srv_share-planninguom.
        <recshare>-uom = <recshare>-consumptionuom.
        <recshare>-status = chargeout_finalized.
        determine_last_day(
          EXPORTING
            iv_ryear    = <ls_srvshare>-ryear
            iv_poper    = <ls_srvshare>-poper
          IMPORTING
            ev_valid_on = <recshare>-exchdate
        ).
* Admin data
        <recshare>-created_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = <recshare>-created_at
        ).
        <recshare>-last_changed_by = sy-uname.
        /esrcc/cl_utility_core=>get_utc_date_time_ts(
          IMPORTING
            time_stamp = <recshare>-last_changed_at
        ).

      ENDIF.
    ENDLOOP.

    MODIFY /esrcc/rec_chg FROM TABLE @lt_recshare.

  ENDMETHOD.


  METHOD determine_last_day.

    DATA lv_valid_from TYPE /esrcc/validfrom.

    CONCATENATE iv_ryear iv_poper+1(2) '01' INTO lv_valid_from.

    CALL FUNCTION '/ESRCC/FM_LAST_DAY_OF_MONTH'
      EXPORTING
        day_in       = lv_valid_from
      IMPORTING
        end_of_month = ev_valid_on.

  ENDMETHOD.


  METHOD finalize_chargeout.

    DATA lt_procctrl   TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl   TYPE  /esrcc/procctrl.
    DATA _poper        TYPE RANGE OF poper.
    DATA ls_cbli       TYPE /esrcc/cb_li.
    DATA lt_cbli       TYPE TABLE OF /esrcc/cb_li.
    DATA lv_valid_from TYPE /esrcc/validfrom.
    DATA number        TYPE /esrcc/doc_no.

*Derive poper from billing frequency customizing
    READ TABLE it_keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
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

    LOOP AT it_keys ASSIGNING <key> WHERE costcenter IS NOT INITIAL
                                      AND serviceproduct IS NOT INITIAL.
      ls_procctrl = CORRESPONDING #( <key> ).
      ls_procctrl-process = chargeout.    "Charge-Out
      ls_procctrl-status = chargeout_finalized.     "Charge Out finalized

* Admin data
      ls_procctrl-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = ls_procctrl-last_changed_at
      ).

      APPEND ls_procctrl TO lt_procctrl.
    ENDLOOP.

*Finalize calculated receiever
    SELECT rec_chg~* FROM /esrcc/cb_stw AS cb_stw
          INNER JOIN /esrcc/srv_share AS srv_share
                  ON cb_stw~cc_uuid = srv_share~cc_uuid
          INNER JOIN /esrcc/rec_chg AS rec_chg
                  ON cb_stw~cc_uuid = rec_chg~cc_uuid
                 AND srv_share~srv_uuid = rec_chg~srv_uuid
          FOR ALL ENTRIES IN @it_keys
                WHERE fplv          = @it_keys-fplv
                  AND ryear         = @it_keys-ryear
                  AND sysid         = @it_keys-sysid
                  AND poper        IN @_poper
                  AND legalentity   = @it_keys-legalentity
                  AND ccode         = @it_keys-ccode
                  AND costobject    = @it_keys-costobject
                  AND costcenter    = @it_keys-costcenter
                  AND serviceproduct = @it_keys-serviceproduct
                  INTO TABLE @DATA(lt_recshare).

    LOOP AT lt_recshare ASSIGNING FIELD-SYMBOL(<ls_recshare>).
      <ls_recshare>-status = finalized.
      <ls_recshare>-invoicestatus = '01'.

* Admin data
      <ls_recshare>-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_recshare>-last_changed_at
      ).

    ENDLOOP.

*Handling of delta for direct chargeout Scenario
    determine_delta_chargeout(
      it_keys  = it_keys
      it_poper = _poper
    ).

*SCC Virtual posting
    virtual_posting(
      it_keys  = it_keys
      it_poper = _poper
    ).


    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.
    MODIFY /esrcc/rec_chg FROM TABLE @lt_recshare.


  ENDMETHOD.


  METHOD finalize_costbase.

    DATA lt_procctrl TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl TYPE  /esrcc/procctrl.
    DATA _poper TYPE RANGE OF poper.

*Derive poper from billing frequency customizing
    READ TABLE it_keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
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
    LOOP AT it_keys ASSIGNING <key> WHERE costcenter IS NOT INITIAL AND serviceproduct IS INITIAL.
      ls_procctrl = CORRESPONDING #( <key> ).
      ls_procctrl-process = costbase.    "Costbase
      ls_procctrl-status = costbase_finalized.     "Cost base finalized

* Admin data
      ls_procctrl-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = ls_procctrl-last_changed_at
      ).

      APPEND ls_procctrl TO lt_procctrl.
    ENDLOOP.

*Finalize cost base line items.
    SELECT * FROM /esrcc/cb_li FOR ALL ENTRIES IN @it_keys
                               WHERE fplv       = @it_keys-fplv
                                 AND ryear      = @it_keys-ryear
                                 AND sysid      = @it_keys-sysid
                                 AND poper     IN @_poper
                                 AND legalentity = @it_keys-legalentity
                                 AND ccode      = @it_keys-ccode
                                 AND costobject = @it_keys-costobject
                                 AND costcenter = @it_keys-costcenter
                                 INTO TABLE @DATA(lt_cb_li).

    LOOP AT lt_cb_li ASSIGNING FIELD-SYMBOL(<ls_cb_li>).
      <ls_cb_li>-status = finalized.

* Admin data
      <ls_cb_li>-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_cb_li>-last_changed_at
      ).

    ENDLOOP.

*Finalize calculated Cost base & Stewardship
    SELECT * FROM /esrcc/cb_stw FOR ALL ENTRIES IN @it_keys
                                WHERE fplv        = @it_keys-fplv
                                  AND ryear       = @it_keys-ryear
                                  AND sysid       = @it_keys-sysid
                                  AND poper      IN @_poper
                                  AND legalentity = @it_keys-legalentity
                                  AND ccode       = @it_keys-ccode
                                  AND costobject  = @it_keys-costobject
                                  AND costcenter  = @it_keys-costcenter
*                                  AND  serviceproduct = @keys-serviceproduct
                                  INTO TABLE @DATA(lt_cc_cost).

    LOOP AT lt_cc_cost ASSIGNING FIELD-SYMBOL(<ls_cc_cost>).
      <ls_cc_cost>-status = finalized.

* Admin data
      <ls_cc_cost>-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_cc_cost>-last_changed_at
      ).

    ENDLOOP.

    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.
    MODIFY /esrcc/cb_li    FROM TABLE @lt_cb_li.
    MODIFY /esrcc/cb_stw   FROM TABLE @lt_cc_cost.


  ENDMETHOD.


  METHOD finalize_servicecostshare.

    DATA lt_procctrl TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl TYPE  /esrcc/procctrl.
    DATA _poper TYPE RANGE OF poper.

*Derive poper from billing frequency customizing
    READ TABLE it_keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
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
    LOOP AT it_keys ASSIGNING <key> WHERE costcenter IS NOT INITIAL
                                      AND serviceproduct IS NOT INITIAL.
      ls_procctrl = CORRESPONDING #( <key> ).
      ls_procctrl-process = serviceshare.    "Stewardship
      ls_procctrl-status = serviceshare_finalized.     "Stewardship Finalized

* Admin data
      ls_procctrl-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = ls_procctrl-last_changed_at
      ).

      APPEND ls_procctrl TO lt_procctrl.
    ENDLOOP.

*Finalize calculated Cost base & Stewardship
    SELECT srv_share~* FROM /esrcc/cb_stw AS cb_stw
          INNER JOIN /esrcc/srv_share AS srv_share
                  ON cb_stw~cc_uuid = srv_share~cc_uuid
          FOR ALL ENTRIES IN @it_keys
                WHERE fplv          = @it_keys-fplv
                  AND ryear         = @it_keys-ryear
                  AND sysid         = @it_keys-sysid
                  AND poper        IN @_poper
                  AND legalentity   = @it_keys-legalentity
                  AND ccode         = @it_keys-ccode
                  AND costobject    = @it_keys-costobject
                  AND costcenter    = @it_keys-costcenter
                  AND serviceproduct = @it_keys-serviceproduct
                  INTO TABLE @DATA(lt_srvshare).


    LOOP AT lt_srvshare ASSIGNING FIELD-SYMBOL(<ls_srvshare>).
      <ls_srvshare>-status = finalized.

* Admin data
      <ls_srvshare>-last_changed_by = sy-uname.
      /esrcc/cl_utility_core=>get_utc_date_time_ts(
        IMPORTING
          time_stamp = <ls_srvshare>-last_changed_at
      ).

    ENDLOOP.

    MODIFY /esrcc/procctrl  FROM TABLE @lt_procctrl.
    MODIFY /esrcc/srv_share FROM TABLE @lt_srvshare.

  ENDMETHOD.


  METHOD reopen_chargeout.


    DATA lt_procctrl   TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl   TYPE  /esrcc/procctrl.
    DATA lt_alocshare  TYPE TABLE OF /esrcc/alocshare.
    DATA lt_alocvalues TYPE TABLE OF /esrcc/alcvalues.
    DATA _poper TYPE RANGE OF poper.

*Derive poper from billing frequency customizing
    READ TABLE it_keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
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
    LOOP AT it_keys ASSIGNING <key> WHERE costcenter IS NOT INITIAL
                                 AND serviceproduct IS NOT INITIAL.
      ls_procctrl = CORRESPONDING #( <key> ).
      ls_procctrl-process = chargeout.    "Costbase
      APPEND ls_procctrl TO lt_procctrl.
    ENDLOOP.

* Delete receiver cost
**Reopen Virtual posting in case done during finalizing chargeouts.
    delete_virtual_postings(
      it_keys  = it_keys
      it_poper = _poper
    ).

    delete_chargeout(
      it_keys  = it_keys
      it_poper = _poper
      iv_costbasereopen = iv_costbasereopen
    ).

    DELETE /esrcc/procctrl  FROM TABLE @lt_procctrl.

  ENDMETHOD.


  METHOD reopen_costbase.

    DATA lt_procctrl   TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl   TYPE  /esrcc/procctrl.
    DATA lt_alocshare  TYPE TABLE OF /esrcc/alocshare.
    DATA lt_alocvalues TYPE TABLE OF /esrcc/alcvalues.
    DATA _poper TYPE RANGE OF poper.

*Derive poper from billing frequency customizing
    READ TABLE it_keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
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
    SELECT * FROM /esrcc/procctrl FOR ALL ENTRIES IN @it_keys
                                  WHERE fplv          = @it_keys-fplv
                                    AND ryear         = @it_keys-ryear
                                    AND sysid         = @it_keys-sysid
                                    AND legalentity   = @it_keys-legalentity
                                    AND ccode         = @it_keys-ccode
                                    AND costobject    = @it_keys-costobject
                                    AND costcenter    = @it_keys-costcenter
                                    AND billingfreq   = @it_keys-billingfreq
                                    AND billingperiod = @it_keys-billingperiod
                                    INTO TABLE @lt_procctrl.

*ReOpen cost base line items.
    SELECT * FROM /esrcc/cb_li FOR ALL ENTRIES IN @it_keys
                               WHERE fplv        = @it_keys-fplv
                                 AND ryear       = @it_keys-ryear
                                 AND sysid       = @it_keys-sysid
                                 AND poper       IN @_poper
                                 AND legalentity = @it_keys-legalentity
                                 AND ccode       = @it_keys-ccode
                                 AND costobject  = @it_keys-costobject
                                 AND costcenter  = @it_keys-costcenter
                                 AND value_source = 'ERP'
                                 INTO TABLE @DATA(lt_cb_li).

    LOOP AT lt_cb_li ASSIGNING FIELD-SYMBOL(<ls_cb_li>).
      <ls_cb_li>-status = approved.
    ENDLOOP.

*  reopen service cost share
    /esrcc/cl_calculate_chargeout=>reopen_serviceshare( it_keys = it_keys
                                                        iv_costbasereopen = abap_true ).

*  Delete cost center cost
    delete_costbase(
      it_keys  = it_keys
      it_poper = _poper
    ).

    DELETE /esrcc/procctrl FROM TABLE @lt_procctrl.
    MODIFY /esrcc/cb_li    FROM TABLE @lt_cb_li.

  ENDMETHOD.


  METHOD reopen_serviceshare.


    DATA lt_procctrl TYPE STANDARD TABLE OF /esrcc/procctrl.
    DATA ls_procctrl TYPE  /esrcc/procctrl.
    DATA lt_alocshare TYPE TABLE OF /esrcc/alocshare.
    DATA lt_alocvalues TYPE TABLE OF /esrcc/alcvalues.
    DATA _poper TYPE RANGE OF poper.

*Derive poper from billing frequency customizing
    READ TABLE it_keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
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
    LOOP AT it_keys ASSIGNING <key> WHERE costcenter IS NOT INITIAL
                                    AND serviceproduct IS NOT INITIAL.

      ls_procctrl = CORRESPONDING #( <key> ).
      ls_procctrl-process = serviceshare.
      APPEND ls_procctrl TO lt_procctrl.

      ls_procctrl = CORRESPONDING #( <key> ).
      ls_procctrl-process = chargeout.
      APPEND ls_procctrl TO lt_procctrl.
    ENDLOOP.

*  Reopen chargeout
    /esrcc/cl_calculate_chargeout=>reopen_chargeout( it_keys = it_keys
                                                     iv_costbasereopen = iv_costbasereopen ).

*  Delete service cost
    delete_servicecostshare(
      it_keys  = it_keys
      it_poper = _poper
      iv_costbasereopen = iv_costbasereopen
    ).

    DELETE /esrcc/procctrl FROM TABLE @lt_procctrl.

  ENDMETHOD.


  METHOD trigger_workflow.

    CALL FUNCTION '/ESRCC/FM_WF_START'
      EXPORTING
        it_leading_object = it_leading_object
        iv_apptype        = iv_application.

  ENDMETHOD.


  METHOD virtual_posting.

    DATA ls_cbli TYPE /esrcc/cb_li.
    DATA lt_cbli TYPE TABLE OF /esrcc/cb_li.
    DATA lv_valid_from TYPE /esrcc/validfrom.
    DATA number TYPE /esrcc/doc_no.


*SCC Virtual posting
    SELECT * FROM /ESRCC/I_ChargeoutReceived FOR ALL ENTRIES IN @it_keys
                                             WHERE fplv         = @it_keys-fplv
                                               AND ryear        = @it_keys-ryear
                                               AND sysid        = @it_keys-sysid
                                               AND poper       IN @it_poper
                                               AND legalentity  = @it_keys-legalentity
                                               AND ccode        = @it_keys-ccode
                                               AND costobject   = @it_keys-costobject
                                               AND costcenter   = @it_keys-costcenter
                                               AND serviceproduct = @it_keys-serviceproduct
                                               AND Currencytype = 'G'
                                               AND Receivingentity IS NOT INITIAL
                                               INTO TABLE @DATA(lt_receiverchargeout).

    SELECT * FROM /ESRCC/I_ChargeoutReceived FOR ALL ENTRIES IN @it_keys
                                             WHERE fplv         = @it_keys-fplv
                                               AND ryear        = @it_keys-ryear
                                               AND sysid        = @it_keys-sysid
                                               AND poper       IN @it_poper
                                               AND legalentity  = @it_keys-legalentity
                                               AND ccode        = @it_keys-ccode
                                               AND costobject   = @it_keys-costobject
                                               AND costcenter   = @it_keys-costcenter
                                               AND serviceproduct = @it_keys-serviceproduct
                                               AND Currencytype = 'L'
                                               AND Receivingentity IS NOT INITIAL
                                               INTO TABLE @DATA(lt_chargeoutlocalcurr).

    IF lt_receiverchargeout IS NOT INITIAL.

      SELECT cel~sysid, cel~company_code, cel~legal_entity, cel~cost_element, costelem~*
                 FROM /esrcc/cstelmtch AS costelem
                 INNER JOIN /esrcc/cst_elmnt AS cel
                 ON costelem~cost_element_uuid = cel~cost_element_uuid
                 FOR ALL ENTRIES IN @lt_receiverchargeout
               WHERE value_source     = @scc_valuesource
                 AND cel~legal_entity = @lt_receiverchargeout-receivingentity
                 AND cel~company_code = @lt_receiverchargeout-receivercompanycode
                 AND cel~sysid        = @lt_receiverchargeout-receiversysid
               INTO TABLE @DATA(lt_costelement).


      LOOP AT lt_receiverchargeout ASSIGNING FIELD-SYMBOL(<ls_receiverchargeout>).

        CONCATENATE <ls_receiverchargeout>-ryear <ls_receiverchargeout>-poper+1(2) '01' INTO lv_valid_from.
        READ TABLE lt_costelement ASSIGNING FIELD-SYMBOL(<ls_costlement>)
                                  WITH KEY sysid = <ls_receiverchargeout>-ReceiverSysId
                                           company_code = <ls_receiverchargeout>-ReceiverCompanyCode
                                           legal_entity = <ls_receiverchargeout>-Receivingentity.

        IF sy-subrc = 0 AND
           <ls_costlement>-costelem-valid_from <= lv_valid_from AND
           <ls_costlement>-costelem-valid_to >= lv_valid_from.

          TRY.
              CALL METHOD cl_numberrange_runtime=>number_get
                EXPORTING
                  nr_range_nr = '01'
                  object      = '/ESRCC/VP'
                IMPORTING
                  number      = DATA(lv_number)
                  returncode  = DATA(lv_rcode).
            CATCH cx_nr_object_not_found
                  cx_number_ranges INTO DATA(cx_numberrange).
              DATA(error) = cx_numberrange->get_longtext(  ).
          ENDTRY.
          number = lv_number+10(10).
          ls_cbli-fplv         = <ls_receiverchargeout>-fplv.
          ls_cbli-ryear        = <ls_receiverchargeout>-ryear.
          ls_cbli-poper        = <ls_receiverchargeout>-Poper.
          ls_cbli-belnr        = number.
          ls_cbli-sysid        = <ls_receiverchargeout>-ReceiverSysId.
          ls_cbli-ccode        = <ls_receiverchargeout>-ReceiverCompanyCode.
          ls_cbli-legalentity  = <ls_receiverchargeout>-Receivingentity.
          ls_cbli-costobject   = <ls_receiverchargeout>-ReceiverCostObject.
          ls_cbli-costcenter   = <ls_receiverchargeout>-ReceiverCostCenter.
          ls_cbli-costelement  = <ls_costlement>-cost_element.
          ls_cbli-costind      = <ls_costlement>-costelem-cost_indicator.
          ls_cbli-costtype     = <ls_costlement>-costelem-cost_type.
          ls_cbli-usagecal     = <ls_costlement>-costelem-usage_type.
          ls_cbli-value_source = <ls_costlement>-costelem-value_source.
          ls_cbli-reasonid     = <ls_costlement>-costelem-reason_id.
          ls_cbli-postingtype  = <ls_costlement>-costelem-posting_type.

          READ TABLE lt_chargeoutlocalcurr ASSIGNING FIELD-SYMBOL(<chargeoutlocalcurr>)
                                          WITH KEY uuid         = <ls_receiverchargeout>-uuid.
          IF sy-subrc = 0.
            ls_cbli-localcurr    = <chargeoutlocalcurr>-Currency.
            ls_cbli-hsl          = <chargeoutlocalcurr>-TotalChargeoutAmount.
          ENDIF.
          ls_cbli-groupcurr           = <ls_receiverchargeout>-currency.
          ls_cbli-ksl                 = <ls_receiverchargeout>-TotalChargeoutAmount.
          ls_cbli-vendor              = <ls_receiverchargeout>-Legalentity.
          ls_cbli-status              = 'V'.   "Virtual Postings
          ls_cbli-posting_sysid       = <ls_receiverchargeout>-Sysid.
          ls_cbli-posting_ccode       = <ls_receiverchargeout>-ccode.
          ls_cbli-posting_legalentity = <ls_receiverchargeout>-Legalentity.
          ls_cbli-posting_costobject  = <ls_receiverchargeout>-Costobject.
          ls_cbli-posting_costcenter  = <ls_receiverchargeout>-Costcenter.
* Admin data
          ls_cbli-created_by = sy-uname.
          /esrcc/cl_utility_core=>get_utc_date_time_ts(
            IMPORTING
              time_stamp = ls_cbli-created_at
          ).
          ls_cbli-last_changed_by = sy-uname.
          /esrcc/cl_utility_core=>get_utc_date_time_ts(
            IMPORTING
              time_stamp = ls_cbli-last_changed_at
          ).
          APPEND ls_cbli TO lt_cbli.
          CLEAR ls_cbli.
        ENDIF.
      ENDLOOP.
    ENDIF.

    MODIFY /esrcc/cb_li FROM TABLE @lt_cbli.

  ENDMETHOD.


  METHOD delete_chargeout.

    IF iv_costbasereopen = abap_true.
      SELECT rec_chg~* FROM /esrcc/cb_stw AS cb_stw
            INNER JOIN /esrcc/srv_share AS srv_share
                    ON srv_share~cc_uuid = cb_stw~cc_uuid
            INNER JOIN /esrcc/rec_chg AS rec_chg
                    ON rec_chg~cc_uuid = cb_stw~cc_uuid
                   AND rec_chg~srv_uuid = srv_share~srv_uuid
                   AND rec_chg~status  NE @approval_pending
            FOR ALL ENTRIES IN @it_keys
                  WHERE cb_stw~fplv                = @it_keys-fplv
                    AND cb_stw~ryear               = @it_keys-ryear
                    AND cb_stw~sysid               = @it_keys-sysid
                    AND cb_stw~poper              IN @it_poper
                    AND cb_stw~legalentity         = @it_keys-legalentity
                    AND cb_stw~ccode               = @it_keys-ccode
                    AND cb_stw~costobject          = @it_keys-costobject
                    AND cb_stw~costcenter          = @it_keys-costcenter
*                  AND srv_share~serviceproduct   = @it_keys-serviceproduct
                    INTO TABLE @DATA(lt_recshare).
    ELSE.
      SELECT rec_chg~* FROM /esrcc/cb_stw AS cb_stw
           INNER JOIN /esrcc/srv_share AS srv_share
                   ON srv_share~cc_uuid = cb_stw~cc_uuid
           INNER JOIN /esrcc/rec_chg AS rec_chg
                   ON rec_chg~cc_uuid = cb_stw~cc_uuid
                  AND rec_chg~srv_uuid = srv_share~srv_uuid
                  AND rec_chg~status  NE @approval_pending
           FOR ALL ENTRIES IN @it_keys
                 WHERE cb_stw~fplv                = @it_keys-fplv
                   AND cb_stw~ryear               = @it_keys-ryear
                   AND cb_stw~sysid               = @it_keys-sysid
                   AND cb_stw~poper              IN @it_poper
                   AND cb_stw~legalentity         = @it_keys-legalentity
                   AND cb_stw~ccode               = @it_keys-ccode
                   AND cb_stw~costobject          = @it_keys-costobject
                   AND cb_stw~costcenter          = @it_keys-costcenter
                   AND srv_share~serviceproduct   = @it_keys-serviceproduct
                   INTO TABLE @lt_recshare.
    ENDIF.

    IF lt_recshare IS NOT INITIAL.
*  Delete Service Allocation
      SELECT * FROM /esrcc/alocshare FOR ALL ENTRIES IN @lt_recshare
                                     WHERE  parentuuid = @lt_recshare-rec_uuid
                                     INTO TABLE @DATA(lt_alocshare).
      IF lt_alocshare IS NOT INITIAL.
        SELECT * FROM /esrcc/alcvalues FOR ALL ENTRIES IN @lt_alocshare
                                       WHERE parentuuid = @lt_alocshare-uuid
                                         INTO TABLE @DATA(lt_alocvalues).
      ENDIF.


      DELETE /esrcc/rec_chg   FROM TABLE @lt_recshare.
      DELETE /esrcc/alocshare FROM TABLE @lt_alocshare.
      DELETE /esrcc/alcvalues FROM TABLE @lt_alocvalues.
    ENDIF.
  ENDMETHOD.


  METHOD delete_costbase.

    SELECT * FROM /esrcc/cb_stw FOR ALL ENTRIES IN @it_keys
                               WHERE  fplv       = @it_keys-fplv
                                 AND ryear       = @it_keys-ryear
                                 AND sysid       = @it_keys-sysid
                                 AND poper      IN @it_poper
                                 AND legalentity = @it_keys-legalentity
                                 AND ccode       = @it_keys-ccode
                                 AND costobject  = @it_keys-costobject
                                 AND costcenter  = @it_keys-costcenter
                                 INTO TABLE @DATA(lt_cc_cost).

    DELETE /esrcc/cb_stw   FROM TABLE @lt_cc_cost.

  ENDMETHOD.


  METHOD delete_servicecostshare.
    IF iv_costbasereopen = abap_true.
      SELECT srv_share~* FROM /esrcc/cb_stw AS cb_stw
          INNER JOIN /esrcc/srv_share AS srv_share
                  ON cb_stw~cc_uuid = srv_share~cc_uuid
          FOR ALL ENTRIES IN @it_keys
                WHERE fplv           = @it_keys-fplv
                  AND ryear          = @it_keys-ryear
                  AND sysid          = @it_keys-sysid
                  AND poper         IN @it_poper
                  AND legalentity    = @it_keys-legalentity
                  AND ccode          = @it_keys-ccode
                  AND costobject     = @it_keys-costobject
                  AND costcenter     = @it_keys-costcenter
*                AND serviceproduct = @it_keys-serviceproduct
                  INTO TABLE @DATA(lt_srvshare).
    ELSE.
      SELECT srv_share~* FROM /esrcc/cb_stw AS cb_stw
          INNER JOIN /esrcc/srv_share AS srv_share
                  ON cb_stw~cc_uuid = srv_share~cc_uuid
          FOR ALL ENTRIES IN @it_keys
                WHERE fplv           = @it_keys-fplv
                  AND ryear          = @it_keys-ryear
                  AND sysid          = @it_keys-sysid
                  AND poper         IN @it_poper
                  AND legalentity    = @it_keys-legalentity
                  AND ccode          = @it_keys-ccode
                  AND costobject     = @it_keys-costobject
                  AND costcenter     = @it_keys-costcenter
                  AND serviceproduct = @it_keys-serviceproduct
                  INTO TABLE @lt_srvshare.
    ENDIF.

    DELETE /esrcc/srv_share FROM TABLE @lt_srvshare.

  ENDMETHOD.


  METHOD derive_poper.

*Derive poper from billing frequency customizing
    READ TABLE it_keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      SELECT 'I'  AS sign,
            'EQ'  AS option,
            poper AS low
            FROM /esrcc/billfreq
            WHERE billingfreq = @<key>-billingfreq
              AND billingvalue = @<key>-billingperiod
            ORDER BY low ASCENDING
            INTO CORRESPONDING FIELDS OF TABLE @et_poper.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
