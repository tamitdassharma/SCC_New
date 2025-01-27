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

    DATA lt_keys TYPE /esrcc/tt_keys.

    lt_keys = CORRESPONDING #( keys ).

    /esrcc/cl_calculate_chargeout=>finalize_chargeout( it_keys = lt_keys ).

*    DATA lt_procctrl TYPE STANDARD TABLE OF /esrcc/procctrl.
*    DATA ls_procctrl TYPE  /esrcc/procctrl.
*    DATA _poper TYPE RANGE OF poper.
*    DATA ls_cbli TYPE /esrcc/cb_li.
*    DATA lt_cbli TYPE TABLE OF /esrcc/cb_li.
*    DATA lv_valid_from TYPE /esrcc/validfrom.
*    DATA number TYPE /esrcc/doc_no.
**Derive poper from billing frequency customizing
*    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
*    IF sy-subrc = 0.
*      SELECT 'I'  AS sign,
*            'EQ'  AS option,
*            poper AS low
*            FROM /esrcc/billfreq
*            WHERE billingfreq = @<key>-billingfreq
*              AND billingvalue = @<key>-billingperiod
*            ORDER BY low ASCENDING
*            INTO CORRESPONDING FIELDS OF TABLE @_poper.
*    ENDIF.
*
*    LOOP AT keys ASSIGNING <key> WHERE costcenter IS NOT INITIAL AND serviceproduct IS NOT INITIAL.
*      ls_procctrl = CORRESPONDING #( <key> ).
*      ls_procctrl-process = 'CHR'.    "Charge-Out
*      ls_procctrl-status = '05'.     "Charge Out finalized
*
** Admin data
*      ls_procctrl-last_changed_by = sy-uname.
*      /esrcc/cl_utility_core=>get_utc_date_time_ts(
*        IMPORTING
*          time_stamp = ls_procctrl-last_changed_at
*      ).
*
*      APPEND ls_procctrl TO lt_procctrl.
*    ENDLOOP.
*
**Finalize calculated receiever
*    SELECT rec_chg~* FROM /esrcc/cb_stw AS cb_stw
*          INNER JOIN /esrcc/srv_share AS srv_share
*                  ON cb_stw~cc_uuid = srv_share~cc_uuid
*          INNER JOIN /esrcc/rec_chg AS rec_chg
*                  ON cb_stw~cc_uuid = rec_chg~cc_uuid
*                 AND srv_share~srv_uuid = rec_chg~srv_uuid
*          FOR ALL ENTRIES IN @keys
*                WHERE fplv = @keys-fplv
*                  AND ryear = @keys-ryear
*                  AND sysid = @keys-sysid
*                  AND poper IN @_poper
*                  AND legalentity = @keys-legalentity
*                  AND ccode = @keys-ccode
*                  AND costobject = @keys-costobject
*                  AND costcenter = @keys-costcenter
*                  AND serviceproduct = @keys-serviceproduct
*                  INTO TABLE @DATA(lt_recshare).
*
*    LOOP AT lt_recshare ASSIGNING FIELD-SYMBOL(<ls_recshare>).
*      <ls_recshare>-status = 'F'.
*      <ls_recshare>-invoicestatus = '01'.
*
** Admin data
*      <ls_recshare>-last_changed_by = sy-uname.
*      /esrcc/cl_utility_core=>get_utc_date_time_ts(
*        IMPORTING
*          time_stamp = <ls_recshare>-last_changed_at
*      ).
*
*    ENDLOOP.
*
*
**Handling of delta for Indirect Scenario
**If there is cost base which is not allocated 100% due to difference between consumption & planning
** for a period then allocate that cost base and remaining comsumption to a dummy receiver
**    SELECT srv_share~* FROM /esrcc/cb_stw AS cb_stw
**             INNER JOIN /esrcc/srv_share AS srv_share
**                     ON cb_stw~cc_uuid = srv_share~cc_uuid
**             FOR ALL ENTRIES IN @keys
**                   WHERE fplv = @keys-fplv
**                     AND ryear = @keys-ryear
**                     AND sysid = @keys-sysid
**                     AND poper IN @_poper
**                     AND legalentity = @keys-legalentity
**                     AND ccode = @keys-ccode
**                     AND costobject = @keys-costobject
**                     AND costcenter = @keys-costcenter
**                     AND serviceproduct = @keys-serviceproduct
**                     INTO TABLE @DATA(lt_srv_cost).
*
**    SELECT fplv,
**           ryear,
**           poper,
**           sysid,
**           legalentity,
**           ccode,
**           costobject,
**           costcenter,
**           serviceproduct,
**           SUM( reckpi ) AS totalreckpi,
**           SUM( reckpishareabsl ) AS totalchargeoutl,
**           SUM( reckpishareabsg ) AS totalchargeoutg
**           FROM @lt_rec_cost AS chg
**           WHERE chg~chargeout = 'D'
**           GROUP BY
**           fplv,
**           ryear,
**           poper,
**           sysid,
**           legalentity,
**           ccode,
**           costobject,
**           costcenter,
**           serviceproduct INTO TABLE @DATA(lt_diragg_chargeout).
**
**    LOOP AT lt_diragg_chargeout ASSIGNING FIELD-SYMBOL(<ls_diragg>).
**      READ TABLE lt_srv_cost ASSIGNING FIELD-SYMBOL(<ls_chargeout>) WITH KEY fplv = <ls_diragg>-fplv
**                                                                              ryear = <ls_diragg>-ryear
**                                                                              poper = <ls_diragg>-poper
**                                                                              sysid = <ls_diragg>-sysid
**                                                                              legalentity = <ls_diragg>-legalentity
**                                                                              ccode = <ls_diragg>-ccode
**                                                                              costobject = <ls_diragg>-costobject
**                                                                              costcenter = <ls_diragg>-costcenter
**                                                                              serviceproduct = <ls_diragg>-serviceproduct.
**
**      IF sy-subrc = 0 AND <ls_diragg>-totalreckpi <> <ls_chargeout>-planning.
**        READ TABLE lt_rec_cost INTO ls_chargeout WITH KEY fplv = <ls_diragg>-fplv
**                                                                              ryear = <ls_diragg>-ryear
**                                                                              poper = <ls_diragg>-poper
**                                                                              sysid = <ls_diragg>-sysid
**                                                                              legalentity = <ls_diragg>-legalentity
**                                                                              ccode = <ls_diragg>-ccode
**                                                                              costobject = <ls_diragg>-costobject
**                                                                              costcenter = <ls_diragg>-costcenter
**                                                                              serviceproduct = <ls_diragg>-serviceproduct.
*** add a dummy receiver
**        IF sy-subrc = 0.
**
**          ls_chargeout-receivingentity = 'REST'.
**          ls_chargeout-reckpishareabsl = ( <ls_chargeout>-srvcostsharel + <ls_chargeout>-valueaddmarkupabsl + <ls_chargeout>-passthrumarkupabsl ) - <ls_diragg>-totalchargeoutl.
**          ls_chargeout-reckpishareabsg = ( <ls_chargeout>-srvcostshareg + <ls_chargeout>-valueaddmarkupabsg + <ls_chargeout>-passthrumarkupabsg ) - <ls_diragg>-totalchargeoutg.
**          ls_chargeout-reckpi = <ls_chargeout>-planning - <ls_diragg>-totalreckpi.
**          ls_chargeout-recvalueaddmarkupabsl = ( ls_chargeout-recvalueaddmarkupabsl / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
**          ls_chargeout-recvalueaddmarkupabsg = ( ls_chargeout-recvalueaddmarkupabsg / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
**          ls_chargeout-recpassthrumarkupabsl = ( ls_chargeout-recpassthrumarkupabsl / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
**          ls_chargeout-recpassthrumarkupabsg = ( ls_chargeout-recpassthrumarkupabsg / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
**          ls_chargeout-recvalueaddedl = ( ls_chargeout-recvalueaddedl / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
**          ls_chargeout-recvalueaddedg = ( ls_chargeout-recvalueaddedg / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
**          ls_chargeout-recpassthroughl = ( ls_chargeout-recpassthroughl / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
**          ls_chargeout-recpassthroughg = ( ls_chargeout-recpassthroughg / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
**          ls_chargeout-recorigtotalcostl = ( ls_chargeout-recorigtotalcostl / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
**          ls_chargeout-recorigtotalcostg = ( ls_chargeout-recorigtotalcostg / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
**          ls_chargeout-recpasstotalcostl = ( ls_chargeout-recpasstotalcostl / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
**          ls_chargeout-recpasstotalcostg = ( ls_chargeout-recpasstotalcostg / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
**          ls_chargeout-recexcludedcostl = ( ls_chargeout-recexcludedcostl / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
**          ls_chargeout-recexcludedcostg = ( ls_chargeout-recexcludedcostg / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
**          ls_chargeout-rectotalcostl = ( ls_chargeout-rectotalcostl / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
**          ls_chargeout-rectotalcostg = ( ls_chargeout-rectotalcostg / <ls_chargeout>-planning ) * ls_chargeout-reckpi.
**          ls_chargeout-billingperiod = keys[ 1 ]-billingperiod.
**          APPEND ls_chargeout TO lt_rec_cost.
**        ENDIF.
**      ENDIF.
**
**    ENDLOOP.
*
*
**SCC Virtual posting
*    SELECT * FROM /ESRCC/I_ChargeoutReceived FOR ALL ENTRIES IN @keys
*                                             WHERE fplv = @keys-fplv
*                                               AND ryear = @keys-ryear
*                                               AND sysid = @keys-sysid
*                                               AND poper IN @_poper
*                                               AND legalentity = @keys-legalentity
*                                               AND ccode = @keys-ccode
*                                               AND costobject = @keys-costobject
*                                               AND costcenter = @keys-costcenter
*                                               AND serviceproduct = @keys-serviceproduct
*                                               AND Currencytype = 'G'
*                                               INTO TABLE @DATA(lt_receiverchargeout).
*
*    IF lt_receiverchargeout IS NOT INITIAL.
*
*      SELECT cel~sysid, cel~company_code, cel~legal_entity, cel~cost_element, costelem~*
*                 FROM /esrcc/cstelmtch AS costelem
*                 INNER JOIN /esrcc/cst_elmnt AS cel
*                 ON costelem~cost_element_uuid = cel~cost_element_uuid
*                 FOR ALL ENTRIES IN @lt_receiverchargeout
*               WHERE value_source = 'SCC'
*                 AND cel~legal_entity = @lt_receiverchargeout-receivingentity
*                 AND cel~company_code = @lt_receiverchargeout-receivercompanycode
*                 AND cel~sysid        = @lt_receiverchargeout-receiversysid
*               INTO TABLE @DATA(lt_costelement).
*
*
*      LOOP AT lt_receiverchargeout ASSIGNING FIELD-SYMBOL(<ls_receiverchargeout>).
*
*        CONCATENATE <ls_receiverchargeout>-ryear <ls_receiverchargeout>-poper+1(2) '01' INTO lv_valid_from.
*        READ TABLE lt_costelement ASSIGNING FIELD-SYMBOL(<ls_costlement>)
*                                  WITH KEY sysid = <ls_receiverchargeout>-ReceiverSysId
*                                           company_code = <ls_receiverchargeout>-ReceiverCompanyCode
*                                           legal_entity = <ls_receiverchargeout>-Receivingentity.
*
*        IF sy-subrc = 0 AND
*           <ls_costlement>-costelem-valid_from <= lv_valid_from AND
*           <ls_costlement>-costelem-valid_to >= lv_valid_from.
*
*          TRY.
*              CALL METHOD cl_numberrange_runtime=>number_get
*                EXPORTING
*                  nr_range_nr = '01'
*                  object      = '/ESRCC/VP'
*                IMPORTING
*                  number      = DATA(lv_number)
*                  returncode  = DATA(lv_rcode).
*            CATCH cx_nr_object_not_found
*                  cx_number_ranges INTO DATA(cx_numberrange).
*              DATA(error) = cx_numberrange->get_longtext(  ).
*          ENDTRY.
*          number = lv_number+10(10).
*          ls_cbli-fplv         = <ls_receiverchargeout>-fplv.
*          ls_cbli-ryear        = <ls_receiverchargeout>-ryear.
*          ls_cbli-poper        = <ls_receiverchargeout>-Poper.
*          ls_cbli-belnr        = number.
*          ls_cbli-sysid        = <ls_receiverchargeout>-ReceiverSysId.
*          ls_cbli-ccode        = <ls_receiverchargeout>-ReceiverCompanyCode.
*          ls_cbli-legalentity  = <ls_receiverchargeout>-Receivingentity.
*          ls_cbli-costobject   = <ls_receiverchargeout>-ReceiverCostObject.
*          ls_cbli-costcenter   = <ls_receiverchargeout>-ReceiverCostCenter.
*          ls_cbli-costelement  = <ls_costlement>-cost_element.
*          ls_cbli-costind      = <ls_costlement>-costelem-cost_indicator.
*          ls_cbli-costtype     = <ls_costlement>-costelem-cost_type.
*          ls_cbli-usagecal     = <ls_costlement>-costelem-usage_type.
*          ls_cbli-value_source = <ls_costlement>-costelem-value_source.
*          ls_cbli-reasonid     = <ls_costlement>-costelem-reason_id.
*          ls_cbli-postingtype  = <ls_costlement>-costelem-posting_type.
*          ls_cbli-localcurr    = <ls_receiverchargeout>-Currency.
*          ls_cbli-hsl          = <ls_receiverchargeout>-TotalChargeoutAmount.
*          ls_cbli-groupcurr    = <ls_receiverchargeout>-currency.
*          ls_cbli-ksl          = <ls_receiverchargeout>-TotalChargeoutAmount.
*          ls_cbli-vendor       = <ls_receiverchargeout>-Legalentity.
*          ls_cbli-status       = 'V'.   "Virtual Postings
*          ls_cbli-posting_sysid       = <ls_receiverchargeout>-Sysid.
*          ls_cbli-posting_ccode       = <ls_receiverchargeout>-ccode.
*          ls_cbli-posting_legalentity = <ls_receiverchargeout>-Legalentity.
*          ls_cbli-posting_costobject  = <ls_receiverchargeout>-Costobject.
*          ls_cbli-posting_costcenter  = <ls_receiverchargeout>-Costcenter.
*          APPEND ls_cbli TO lt_cbli.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.
*
*    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.
*    MODIFY /esrcc/rec_chg FROM TABLE @lt_recshare.
*    MODIFY /esrcc/cb_li FROM TABLE @lt_cbli.

  ENDMETHOD.

  METHOD finalizecostbase.

    DATA lt_keys TYPE /esrcc/tt_keys.

    lt_keys = CORRESPONDING #( keys ).

    /esrcc/cl_calculate_chargeout=>finalize_costbase( it_keys = lt_keys ).

*    DATA lt_procctrl TYPE STANDARD TABLE OF /esrcc/procctrl.
*    DATA ls_procctrl TYPE  /esrcc/procctrl.
*    DATA _poper TYPE RANGE OF poper.
*
**Derive poper from billing frequency customizing
*    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
*    IF sy-subrc = 0.
*      SELECT 'I'  AS sign,
*            'EQ'  AS option,
*            poper AS low
*            FROM /esrcc/billfreq
*            WHERE billingfreq = @<key>-billingfreq
*              AND billingvalue = @<key>-billingperiod
*            ORDER BY low ASCENDING
*            INTO CORRESPONDING FIELDS OF TABLE @_poper.
*    ENDIF.
*
**update execution process control
*    LOOP AT keys ASSIGNING <key> WHERE costcenter IS NOT INITIAL AND serviceproduct IS INITIAL.
*      ls_procctrl = CORRESPONDING #( <key> ).
*      ls_procctrl-process = 'CBS'.    "Costbase
*      ls_procctrl-status = '08'.     "Cost base finalized
*
** Admin data
*      ls_procctrl-last_changed_by = sy-uname.
*      /esrcc/cl_utility_core=>get_utc_date_time_ts(
*        IMPORTING
*          time_stamp = ls_procctrl-last_changed_at
*      ).
*
*      APPEND ls_procctrl TO lt_procctrl.
*    ENDLOOP.
*
**Finalize cost base line items.
*    SELECT * FROM /esrcc/cb_li FOR ALL ENTRIES IN @keys WHERE     fplv = @keys-fplv
*                                                             AND  ryear = @keys-ryear
*                                                             AND sysid = @keys-sysid
*                                                             AND  poper IN @_poper
*                                                             AND  legalentity = @keys-legalentity
*                                                             AND  ccode = @keys-ccode
*                                                             AND  costobject = @keys-costobject
*                                                             AND  costcenter = @keys-costcenter
*                                                             INTO TABLE @DATA(lt_cb_li).
*
*    LOOP AT lt_cb_li ASSIGNING FIELD-SYMBOL(<ls_cb_li>).
*      <ls_cb_li>-status = 'F'.
*
** Admin data
*      <ls_cb_li>-last_changed_by = sy-uname.
*      /esrcc/cl_utility_core=>get_utc_date_time_ts(
*        IMPORTING
*          time_stamp = <ls_cb_li>-last_changed_at
*      ).
*
*    ENDLOOP.
*
**Finalize calculated Cost base & Stewardship
*    SELECT * FROM /esrcc/cb_stw FOR ALL ENTRIES IN @keys WHERE fplv = @keys-fplv
*                                                             AND ryear = @keys-ryear
*                                                             AND sysid = @keys-sysid
*                                                             AND  poper IN @_poper
*                                                             AND  legalentity = @keys-legalentity
*                                                             AND  ccode = @keys-ccode
*                                                             AND  costobject = @keys-costobject
*                                                             AND  costcenter = @keys-costcenter
**                                                             AND  serviceproduct = @keys-serviceproduct
*                                  INTO TABLE @DATA(lt_cc_cost).
*
*    LOOP AT lt_cc_cost ASSIGNING FIELD-SYMBOL(<ls_cc_cost>).
*      <ls_cc_cost>-status = 'F'.
*
** Admin data
*      <ls_cc_cost>-last_changed_by = sy-uname.
*      /esrcc/cl_utility_core=>get_utc_date_time_ts(
*        IMPORTING
*          time_stamp = <ls_cc_cost>-last_changed_at
*      ).
*
*    ENDLOOP.
*
*
*
*
*    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.
*    MODIFY /esrcc/cb_li FROM TABLE @lt_cb_li.
*    MODIFY /esrcc/cb_stw FROM TABLE @lt_cc_cost.

  ENDMETHOD.

  METHOD finalizestewardship.

    DATA lt_keys TYPE /esrcc/tt_keys.

    lt_keys = CORRESPONDING #( keys ).

    /esrcc/cl_calculate_chargeout=>finalize_servicecostshare( it_keys = lt_keys ).

*    DATA lt_procctrl TYPE STANDARD TABLE OF /esrcc/procctrl.
*    DATA ls_procctrl TYPE  /esrcc/procctrl.
*    DATA _poper TYPE RANGE OF poper.
*
**Derive poper from billing frequency customizing
*    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
*    IF sy-subrc = 0.
*      SELECT 'I'  AS sign,
*            'EQ'  AS option,
*            poper AS low
*            FROM /esrcc/billfreq
*            WHERE billingfreq = @<key>-billingfreq
*              AND billingvalue = @<key>-billingperiod
*            ORDER BY low ASCENDING
*            INTO CORRESPONDING FIELDS OF TABLE @_poper.
*    ENDIF.
*
**  Finalize Process Control
*    LOOP AT keys ASSIGNING <key> WHERE costcenter IS NOT INITIAL AND serviceproduct IS NOT INITIAL.
*      ls_procctrl = CORRESPONDING #( <key> ).
*      ls_procctrl-process = 'SCM'.    "Stewardship
*      ls_procctrl-status = '05'.     "Stewardship Finalized
*
** Admin data
*      ls_procctrl-last_changed_by = sy-uname.
*      /esrcc/cl_utility_core=>get_utc_date_time_ts(
*        IMPORTING
*          time_stamp = ls_procctrl-last_changed_at
*      ).
*
*      APPEND ls_procctrl TO lt_procctrl.
*    ENDLOOP.
*
**Finalize calculated Cost base & Stewardship
*    SELECT srv_share~* FROM /esrcc/cb_stw AS cb_stw
*          INNER JOIN /esrcc/srv_share AS srv_share
*                  ON cb_stw~cc_uuid = srv_share~cc_uuid
*          FOR ALL ENTRIES IN @keys
*                WHERE fplv = @keys-fplv
*                  AND ryear = @keys-ryear
*                  AND sysid = @keys-sysid
*                  AND poper IN @_poper
*                  AND legalentity = @keys-legalentity
*                  AND ccode = @keys-ccode
*                  AND costobject = @keys-costobject
*                  AND costcenter = @keys-costcenter
*                  AND serviceproduct = @keys-serviceproduct
*                  INTO TABLE @DATA(lt_srvshare).
*
*
*    LOOP AT lt_srvshare ASSIGNING FIELD-SYMBOL(<ls_srvshare>).
*      <ls_srvshare>-status = 'F'.
*
** Admin data
*      <ls_srvshare>-last_changed_by = sy-uname.
*      /esrcc/cl_utility_core=>get_utc_date_time_ts(
*        IMPORTING
*          time_stamp = <ls_srvshare>-last_changed_at
*      ).
*
*    ENDLOOP.
*
*    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.
*    MODIFY /esrcc/srv_share FROM TABLE @lt_srvshare.
  ENDMETHOD.

  METHOD performchargeout.

    DATA lt_keys TYPE /esrcc/tt_keys.

    lt_keys = CORRESPONDING #( keys ).

    /esrcc/cl_calculate_chargeout=>calculate_chargeout( it_keys = lt_keys ).

*    DATA lt_rec_chg TYPE TABLE OF /esrcc/rec_chg.
*    DATA lt_rec_share TYPE TABLE OF /esrcc/alocshare.
*    DATA lt_srv_values TYPE TABLE OF /esrcc/alcvalues.
*    DATA lt_procctrl TYPE STANDARD TABLE OF /esrcc/procctrl.
*    DATA ls_procctrl TYPE  /esrcc/procctrl.
*    DATA _poper TYPE RANGE OF poper.
*    DATA ls_wf_leadobj TYPE /esrcc/s_wf_leadingobject.
*    DATA lt_wf_leadobj TYPE /esrcc/tt_wf_leadingobject.
*    DATA lv_valid_from TYPE /esrcc/validfrom.
*    DATA lt_recshare_del TYPE TABLE OF /esrcc/alocshare.
*
**Derive poper from billing frequency customizing
*    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
*    IF sy-subrc = 0.
*      SELECT 'I'  AS sign,
*            'EQ'  AS option,
*            poper AS low
*            FROM /esrcc/billfreq
*            WHERE billingfreq = @<key>-billingfreq
*              AND billingvalue = @<key>-billingperiod
*            ORDER BY low ASCENDING
*            INTO CORRESPONDING FIELDS OF TABLE @_poper.
*    ENDIF.
*
*    /esrcc/cl_wf_utility=>is_wf_on(
*      EXPORTING
*        iv_apptype   = 'CHR'
*      IMPORTING
*        ev_wf_active = DATA(wf_active)
*    ).
*
*
*    CLEAR: ls_wf_leadobj,lt_wf_leadobj.
*
**Receiver charge out and markup
*    SELECT * FROM /esrcc/i_chargeout_recshare FOR ALL ENTRIES IN @keys WHERE  fplv = @keys-fplv
*                                                                          AND ryear = @keys-ryear
*                                                                          AND sysid = @keys-sysid
*                                                                          AND  poper IN @_poper
*                                                                          AND  legalentity = @keys-legalentity
*                                                                          AND  ccode = @keys-ccode
*                                                                          AND  costobject = @keys-costobject
*                                                                          AND  costcenter = @keys-costcenter
*                                                                          AND  serviceproduct = @keys-serviceproduct
*                                                                          INTO TABLE @DATA(lt_rec_cost).
*
**Delete old allocation data in case user re-triggered chargeout without re-open
**  Delete receiver cost
*    SELECT rec_chg~* FROM /esrcc/cb_stw AS cb_stw
*          INNER JOIN /esrcc/srv_share AS srv_share
*                  ON cb_stw~cc_uuid = srv_share~cc_uuid
*          INNER JOIN /esrcc/rec_chg AS rec_chg
*                  ON cb_stw~cc_uuid = rec_chg~cc_uuid
*                 AND srv_share~srv_uuid = rec_chg~srv_uuid
*          FOR ALL ENTRIES IN @keys
*                WHERE fplv = @keys-fplv
*                  AND ryear = @keys-ryear
*                  AND sysid = @keys-sysid
*                  AND poper IN @_poper
*                  AND legalentity = @keys-legalentity
*                  AND ccode = @keys-ccode
*                  AND costobject = @keys-costobject
*                  AND costcenter = @keys-costcenter
*                  AND serviceproduct = @keys-serviceproduct
*                  INTO TABLE @DATA(lt_del_recshare).
*
*    SELECT AlocUUID AS uuid FROM /esrcc/i_allocationshare FOR ALL ENTRIES IN @keys WHERE  fplv = @keys-fplv
*                                                              AND ryear = @keys-ryear
*                                                              AND sysid = @keys-sysid
*                                                              AND  poper IN @_poper
*                                                              AND  legalentity = @keys-legalentity
*                                                              AND  ccode = @keys-ccode
*                                                              AND  costobject = @keys-costobject
*                                                              AND  costcenter = @keys-costcenter
*                                                              AND  serviceproduct = @keys-serviceproduct
*                                                              INTO CORRESPONDING FIELDS OF TABLE @lt_recshare_del.
*
*    SELECT * FROM /esrcc/alcvalues FOR ALL ENTRIES IN @lt_recshare_del
*                                   WHERE parentuuid = @lt_recshare_del-uuid
*                                     INTO TABLE @DATA(lt_srvvalues_del).
*
** Create New allocation data
*    SELECT * FROM /esrcc/i_chargeout_indkpishare FOR ALL ENTRIES IN @keys WHERE  fplv = @keys-fplv
*                                                                       AND ryear = @keys-ryear
*                                                                       AND sysid = @keys-sysid
*                                                                       AND  poper IN @_poper
*                                                                       AND  legalentity = @keys-legalentity
*                                                                       AND  ccode = @keys-ccode
*                                                                       AND  costobject = @keys-costobject
*                                                                       AND  costcenter = @keys-costcenter
*                                                                       AND  serviceproduct = @keys-serviceproduct
*                                                                       INTO TABLE @DATA(lt_allocation_share).
*
*    SELECT * FROM /esrcc/i_indallocvalues FOR ALL ENTRIES IN @keys WHERE  fplv = @keys-fplv
*                                                                       AND ryear = @keys-ryear
*                                                                       AND sysid = @keys-sysid
*                                                                       AND  poper IN @_poper
*                                                                       AND  legalentity = @keys-legalentity
*                                                                       AND  ccode = @keys-ccode
*                                                                       AND  costobject = @keys-costobject
*                                                                       AND  costcenter = @keys-costcenter
*                                                                       AND  serviceproduct = @keys-serviceproduct
*                                                                       INTO TABLE @DATA(lt_allocation_values).
*
*    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).
*
*    LOOP AT lt_rec_cost ASSIGNING FIELD-SYMBOL(<ls_rec_cost>).
*      APPEND INITIAL LINE TO lt_rec_chg ASSIGNING FIELD-SYMBOL(<ls_rec_chg>).
*      MOVE-CORRESPONDING <ls_rec_cost> TO <ls_rec_chg>.
*
*      IF wf_active EQ abap_true.
*        CLEAR ls_wf_leadobj.
*        MOVE-CORRESPONDING <ls_rec_cost> TO ls_wf_leadobj.
*        IF <key> IS ASSIGNED.
*          ls_wf_leadobj-billingperiod = <key>-billingperiod.
*        ENDIF.
*        APPEND ls_wf_leadobj TO lt_wf_leadobj.
**        <ls_rec_cost>-status = 'W'.   "In Approval
*      ELSE.
*        <ls_rec_chg>-status = 'A'.   "Approved
*      ENDIF.
*
**      <ls_rec_cost>-billingperiod = <key>-billingperiod.
*
** Admin data
*      <ls_rec_chg>-created_by = sy-uname.
*      /esrcc/cl_utility_core=>get_utc_date_time_ts(
*        IMPORTING
*          time_stamp = <ls_rec_chg>-created_at
*      ).
*      <ls_rec_chg>-last_changed_by = sy-uname.
*      /esrcc/cl_utility_core=>get_utc_date_time_ts(
*        IMPORTING
*          time_stamp = <ls_rec_chg>-last_changed_at
*      ).
*
** Assign the 16 digit unique identifier
*      IF lo_uuid IS BOUND.
*        TRY.
*            <ls_rec_chg>-rec_uuid = lo_uuid->create_uuid_x16( ).
*          CATCH cx_uuid_error.
*            "handle exception
*        ENDTRY.
*      ENDIF.
*
** valid from = first day of the month.
*      CONCATENATE <ls_rec_cost>-ryear <ls_rec_cost>-poper+1(2) '01' INTO lv_valid_from.
*
*      CALL FUNCTION '/ESRCC/FM_LAST_DAY_OF_MONTH'
*        EXPORTING
*          day_in       = lv_valid_from
*        IMPORTING
*          end_of_month = <ls_rec_chg>-exchdate.
*
** Assign the 16 digit unique identifier for allocation share
*      LOOP AT lt_allocation_share ASSIGNING FIELD-SYMBOL(<ls_allocation_share>)
*                                                 WHERE  fplv = <ls_rec_cost>-fplv
*                                                   AND ryear = <ls_rec_cost>-ryear
*                                                   AND sysid = <ls_rec_cost>-sysid
*                                                   AND poper = <ls_rec_cost>-poper
*                                                   AND legalentity = <ls_rec_cost>-legalentity
*                                                   AND ccode = <ls_rec_cost>-ccode
*                                                   AND costobject = <ls_rec_cost>-costobject
*                                                   AND costcenter = <ls_rec_cost>-costcenter
*                                                   AND serviceproduct = <ls_rec_cost>-serviceproduct
*                                                   AND ReceiverSysId = <ls_rec_cost>-receiversysid
*                                                   AND ReceiverCompanyCode = <ls_rec_cost>-receivercompanycode
*                                                   AND ReceivingEntity = <ls_rec_cost>-receivingentity
*                                                   AND ReceiverCostObject = <ls_rec_cost>-receivercostobject
*                                                   AND ReceiverCostCenter = <ls_rec_cost>-receivercostcenter.
*
*        APPEND INITIAL LINE TO lt_rec_share ASSIGNING FIELD-SYMBOL(<ls_rec_share>).
*        MOVE-CORRESPONDING <ls_allocation_share> TO <ls_rec_share>.
*        IF lo_uuid IS BOUND.
*          TRY.
*              <ls_rec_share>-uuid = lo_uuid->create_uuid_x16( ).
*            CATCH cx_uuid_error.
*              "handle exception
*          ENDTRY.
*          <ls_rec_share>-parentuuid = <ls_rec_chg>-rec_uuid.
*        ENDIF.
*
** Assign the 16 digit unique identifier for allocation values
*        LOOP AT lt_allocation_values ASSIGNING FIELD-SYMBOL(<ls_allocation_values>)
*                                                 WHERE  fplv = <ls_rec_cost>-fplv
*                                                   AND ryear = <ls_rec_cost>-ryear
*                                                   AND sysid = <ls_rec_cost>-sysid
*                                                   AND poper = <ls_rec_cost>-poper
*                                                   AND legalentity = <ls_rec_cost>-legalentity
*                                                   AND ccode = <ls_rec_cost>-ccode
*                                                   AND costobject = <ls_rec_cost>-costobject
*                                                   AND costcenter = <ls_rec_cost>-costcenter
*                                                   AND serviceproduct = <ls_rec_cost>-serviceproduct
*                                                   AND ReceiverSysId = <ls_rec_cost>-receiversysid
*                                                   AND ReceiverCompanyCode = <ls_rec_cost>-receivercompanycode
*                                                   AND ReceivingEntity = <ls_rec_cost>-receivingentity
*                                                   AND ReceiverCostObject = <ls_rec_cost>-receivercostobject
*                                                   AND ReceiverCostCenter = <ls_rec_cost>-receivercostcenter.
*
*          APPEND INITIAL LINE TO lt_srv_values ASSIGNING FIELD-SYMBOL(<ls_srv_values>).
*          MOVE-CORRESPONDING <ls_allocation_values> TO <ls_srv_values>.
*          IF lo_uuid IS BOUND.
*            TRY.
*                <ls_srv_values>-uuid = lo_uuid->create_uuid_x16( ).
*              CATCH cx_uuid_error.
*                "handle exception
*            ENDTRY.
*            <ls_srv_values>-parentuuid = <ls_rec_share>-uuid.
*          ENDIF.
*        ENDLOOP.
*      ENDLOOP.
*    ENDLOOP.
*
*
*
*    IF wf_active EQ abap_true.
*      CALL FUNCTION '/ESRCC/FM_WF_START'
*        EXPORTING
*          it_leading_object = lt_wf_leadobj
*          iv_apptype        = 'CHR'.
*    ENDIF.
*
*    LOOP AT keys ASSIGNING <key> WHERE costcenter IS NOT INITIAL AND serviceproduct IS NOT INITIAL.
*      ls_procctrl = CORRESPONDING #( <key> ).
*      ls_procctrl-process = 'CHR'.    "Charge-out
*      IF wf_active EQ abap_false.
*        ls_procctrl-status = '04'.     "Charge-out approved
*      ELSE.
*        ls_procctrl-status = '02'.     "Charge-out In Process
*      ENDIF.
*
** Admin data
*      ls_procctrl-created_by = sy-uname.
*      /esrcc/cl_utility_core=>get_utc_date_time_ts(
*        IMPORTING
*          time_stamp = ls_procctrl-created_at
*      ).
*      ls_procctrl-last_changed_by = sy-uname.
*      /esrcc/cl_utility_core=>get_utc_date_time_ts(
*        IMPORTING
*          time_stamp = ls_procctrl-last_changed_at
*      ).
*
*      APPEND ls_procctrl TO lt_procctrl.
*    ENDLOOP.
*
*    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.
*    DELETE /esrcc/rec_chg FROM TABLE @lt_del_recshare.
*    MODIFY /esrcc/rec_chg FROM TABLE @lt_rec_chg.
*    DELETE /esrcc/alocshare FROM TABLE @lt_recshare_del.
*    MODIFY /esrcc/alocshare FROM TABLE @lt_rec_share.
*    DELETE /esrcc/alcvalues FROM TABLE @lt_srvvalues_del.
*    MODIFY /esrcc/alcvalues FROM TABLE @lt_srv_values.

  ENDMETHOD.

  METHOD performstewardship.

    DATA lt_keys TYPE /esrcc/tt_keys.

    lt_keys = CORRESPONDING #( keys ).

    /esrcc/cl_calculate_chargeout=>calculate_servicecostshare( it_keys = lt_keys ).

*    DATA lt_srv_cost TYPE TABLE OF /esrcc/srv_share.
*    DATA lt_procctrl TYPE STANDARD TABLE OF /esrcc/procctrl.
*    DATA ls_procctrl TYPE  /esrcc/procctrl.
*    DATA _poper TYPE RANGE OF poper.
*    DATA ls_wf_leadobj TYPE /esrcc/s_wf_leadingobject.
*    DATA lt_wf_leadobj TYPE /esrcc/tt_wf_leadingobject.
*
**Derive poper from billing frequency customizing
*    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
*    IF sy-subrc = 0.
*      SELECT 'I'  AS sign,
*            'EQ'  AS option,
*            poper AS low
*            FROM /esrcc/billfreq
*            WHERE billingfreq = @<key>-billingfreq
*              AND billingvalue = @<key>-billingperiod
*            ORDER BY low ASCENDING
*            INTO CORRESPONDING FIELDS OF TABLE @_poper.
*    ENDIF.
*
*    SELECT * FROM /esrcc/i_chargeout_unitcost FOR ALL ENTRIES IN @keys WHERE
*                                                                      fplv = @keys-fplv
*                                                                  AND ryear = @keys-ryear
*                                                                  AND sysid = @keys-sysid
*                                                                  AND poper IN @_poper
*                                                                  AND legalentity = @keys-legalentity
*                                                                  AND ccode = @keys-ccode
*                                                                  AND costobject = @keys-costobject
*                                                                  AND costcenter = @keys-costcenter
*                                                                  AND serviceproduct = @keys-serviceproduct
*                                                                  INTO CORRESPONDING FIELDS OF TABLE @lt_srv_cost.
*
*
*    /esrcc/cl_wf_utility=>is_wf_on(
*      EXPORTING
*        iv_apptype   = 'SCM'
*      IMPORTING
*        ev_wf_active = DATA(wf_active)
*    ).
*
*
*    CLEAR: ls_wf_leadobj,lt_wf_leadobj.
*
*
*    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).
*
*    LOOP AT lt_srv_cost ASSIGNING FIELD-SYMBOL(<ls_srv_cost>).
*      IF wf_active EQ abap_true.
*        CLEAR ls_wf_leadobj.
*        MOVE-CORRESPONDING <ls_srv_cost> TO ls_wf_leadobj.
*        IF <key> IS ASSIGNED.
*          ls_wf_leadobj-billingperiod = <key>-billingperiod.
*        ENDIF.
*        APPEND ls_wf_leadobj TO lt_wf_leadobj.
**        <ls_srv_cost>-status = 'W'.   "In Approval
*      ELSE.
*        <ls_srv_cost>-status = 'A'.   "Approved
*      ENDIF.
*
** Admin data
*      <ls_srv_cost>-created_by = sy-uname.
*      /esrcc/cl_utility_core=>get_utc_date_time_ts(
*        IMPORTING
*          time_stamp = <ls_srv_cost>-created_at
*      ).
*      <ls_srv_cost>-last_changed_by = sy-uname.
*      /esrcc/cl_utility_core=>get_utc_date_time_ts(
*        IMPORTING
*          time_stamp = <ls_srv_cost>-last_changed_at
*      ).
*
** Assign the 16 digit unique identifier
*      IF lo_uuid IS BOUND.
*        TRY.
*            <ls_srv_cost>-srv_uuid = lo_uuid->create_uuid_x16( ).
*          CATCH cx_uuid_error.
*            "handle exception
*        ENDTRY.
*      ENDIF.
*
*    ENDLOOP.
*
*    IF wf_active EQ abap_true.
*      CALL FUNCTION '/ESRCC/FM_WF_START'
*        EXPORTING
*          it_leading_object = lt_wf_leadobj
*          iv_apptype        = 'SCM'.
*    ENDIF.
*
*
*
*    LOOP AT keys ASSIGNING <key> WHERE costcenter IS NOT INITIAL AND serviceproduct IS NOT INITIAL.
*      ls_procctrl = CORRESPONDING #( <key> ).
*      ls_procctrl-process = 'SCM'.    "Stewardship
*      IF wf_active =  abap_false.
*        ls_procctrl-status = '04'.     "Stewardship Approved
*      ELSE.
*        ls_procctrl-status = '02'.     "Stewardship In Process
*      ENDIF.
*
** Admin data
*      ls_procctrl-created_by = sy-uname.
*      /esrcc/cl_utility_core=>get_utc_date_time_ts(
*        IMPORTING
*          time_stamp = ls_procctrl-created_at
*      ).
*      ls_procctrl-last_changed_by = sy-uname.
*      /esrcc/cl_utility_core=>get_utc_date_time_ts(
*        IMPORTING
*          time_stamp = ls_procctrl-last_changed_at
*      ).
*
*      APPEND ls_procctrl TO lt_procctrl.
*    ENDLOOP.
*
**delete old service product share as user might re-trigger calculations again
**  Delete service cost
*    SELECT srv_share~* FROM /esrcc/cb_stw AS cb_stw
*          INNER JOIN /esrcc/srv_share AS srv_share
*                  ON cb_stw~cc_uuid = srv_share~cc_uuid
*          FOR ALL ENTRIES IN @keys
*                WHERE fplv = @keys-fplv
*                  AND ryear = @keys-ryear
*                  AND sysid = @keys-sysid
*                  AND poper IN @_poper
*                  AND legalentity = @keys-legalentity
*                  AND ccode = @keys-ccode
*                  AND costobject = @keys-costobject
*                  AND costcenter = @keys-costcenter
*                  AND serviceproduct = @keys-serviceproduct
*                  INTO TABLE @DATA(lt_del_srvshare).
*
*    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.
*    MODIFY /esrcc/srv_share FROM TABLE @lt_del_srvshare.
*    MODIFY /esrcc/srv_share FROM TABLE @lt_srv_cost.


  ENDMETHOD.

  METHOD reopenchargeout.

    DATA lt_keys TYPE /esrcc/tt_keys.

    lt_keys = CORRESPONDING #( keys ).

    /esrcc/cl_calculate_chargeout=>reopen_chargeout( it_keys = lt_keys ).

*    DATA lt_procctrl TYPE STANDARD TABLE OF /esrcc/procctrl.
*    DATA ls_procctrl TYPE  /esrcc/procctrl.
*    DATA lt_alocshare TYPE TABLE OF /esrcc/alocshare.
*    DATA lt_alocvalues TYPE TABLE OF /esrcc/alcvalues.
*    DATA _poper TYPE RANGE OF poper.
*
**Derive poper from billing frequency customizing
*    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
*    IF sy-subrc = 0.
*      SELECT 'I'  AS sign,
*            'EQ'  AS option,
*            poper AS low
*            FROM /esrcc/billfreq
*            WHERE billingfreq = @<key>-billingfreq
*              AND billingvalue = @<key>-billingperiod
*            ORDER BY low ASCENDING
*            INTO CORRESPONDING FIELDS OF TABLE @_poper.
*    ENDIF.
*
** Update status in execution cockpit process control
*    LOOP AT keys ASSIGNING <key> WHERE costcenter IS NOT INITIAL AND serviceproduct IS NOT INITIAL.
*      ls_procctrl = CORRESPONDING #( <key> ).
*      ls_procctrl-process = 'CHR'.    "Costbase
*      APPEND ls_procctrl TO lt_procctrl.
*    ENDLOOP.
*
**  Delete receiver cost
*    SELECT rec_chg~* FROM /esrcc/cb_stw AS cb_stw
*          INNER JOIN /esrcc/srv_share AS srv_share
*                  ON cb_stw~cc_uuid = srv_share~cc_uuid
*          INNER JOIN /esrcc/rec_chg AS rec_chg
*                  ON cb_stw~cc_uuid = rec_chg~cc_uuid
*                 AND srv_share~srv_uuid = rec_chg~srv_uuid
*          FOR ALL ENTRIES IN @keys
*                WHERE fplv = @keys-fplv
*                  AND ryear = @keys-ryear
*                  AND sysid = @keys-sysid
*                  AND poper IN @_poper
*                  AND legalentity = @keys-legalentity
*                  AND ccode = @keys-ccode
*                  AND costobject = @keys-costobject
*                  AND costcenter = @keys-costcenter
*                  AND serviceproduct = @keys-serviceproduct
*                  AND rec_chg~status NE 'W'
*                  INTO TABLE @DATA(lt_recshare).
*
**  Delete Service Allocation
*    SELECT * FROM /esrcc/alocshare FOR ALL ENTRIES IN @lt_recshare
*                                   WHERE  parentuuid = @lt_recshare-rec_uuid
*                                   INTO CORRESPONDING FIELDS OF TABLE @lt_alocshare.
*
*    SELECT * FROM /esrcc/alcvalues FOR ALL ENTRIES IN @lt_alocshare
*                                   WHERE parentuuid = @lt_alocshare-uuid
*                                     INTO CORRESPONDING FIELDS OF TABLE @lt_alocvalues.
*
*
*
*    DELETE /esrcc/procctrl FROM TABLE @lt_procctrl.
*    DELETE /esrcc/rec_chg FROM TABLE @lt_recshare.
*    DELETE /esrcc/alocshare FROM TABLE @lt_alocshare.
*    DELETE /esrcc/alcvalues FROM TABLE @lt_alocvalues.

  ENDMETHOD.

  METHOD reopencostbase.

    DATA lt_keys TYPE /esrcc/tt_keys.

    lt_keys = CORRESPONDING #( keys ).

    /esrcc/cl_calculate_chargeout=>reopen_costbase( it_keys = lt_keys ).

*    DATA lt_procctrl TYPE STANDARD TABLE OF /esrcc/procctrl.
*    DATA ls_procctrl TYPE  /esrcc/procctrl.
*    DATA lt_alocshare TYPE TABLE OF /esrcc/alocshare.
*    DATA lt_alocvalues TYPE TABLE OF /esrcc/alcvalues.
*    DATA _poper TYPE RANGE OF poper.
*
**Derive poper from billing frequency customizing
*    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
*    IF sy-subrc = 0.
*      SELECT 'I'  AS sign,
*            'EQ'  AS option,
*            poper AS low
*            FROM /esrcc/billfreq
*            WHERE billingfreq = @<key>-billingfreq
*              AND billingvalue = @<key>-billingperiod
*            ORDER BY low ASCENDING
*            INTO CORRESPONDING FIELDS OF TABLE @_poper.
*    ENDIF.
*
**Update execution cockpit process control
*    SELECT * FROM /esrcc/procctrl FOR ALL ENTRIES IN @keys WHERE fplv = @keys-fplv
*                                                             AND ryear = @keys-ryear
*                                                             AND sysid = @keys-sysid
*                                                             AND legalentity = @keys-legalentity
*                                                             AND ccode = @keys-ccode
*                                                             AND costobject = @keys-costobject
*                                                             AND costcenter = @keys-costcenter
*                                                             AND billingfreq = @keys-billingfreq
*                                                             AND billingperiod = @keys-billingperiod
*                                                             INTO TABLE @lt_procctrl.
*
**ReOpen cost base line items.
*    SELECT * FROM /esrcc/cb_li FOR ALL ENTRIES IN @keys WHERE    fplv = @keys-fplv
*                                                             AND ryear = @keys-ryear
*                                                             AND sysid = @keys-sysid
*                                                             AND  poper IN @_poper
*                                                             AND  legalentity = @keys-legalentity
*                                                             AND  ccode = @keys-ccode
*                                                             AND  costobject = @keys-costobject
*                                                             AND  costcenter = @keys-costcenter
*                                  INTO TABLE @DATA(lt_cb_li).
*
*    LOOP AT lt_cb_li ASSIGNING FIELD-SYMBOL(<ls_cb_li>).
*      <ls_cb_li>-status = 'A'.
*    ENDLOOP.
*
**  Delete cost center cost
*    SELECT * FROM /esrcc/cb_stw FOR ALL ENTRIES IN @keys WHERE  fplv = @keys-fplv
*                                                             AND ryear = @keys-ryear
*                                                             AND sysid = @keys-sysid
*                                                             AND  poper IN @_poper
*                                                             AND  legalentity = @keys-legalentity
*                                                             AND  ccode = @keys-ccode
*                                                             AND  costobject = @keys-costobject
*                                                             AND  costcenter = @keys-costcenter
*                                                             INTO TABLE @DATA(lt_cc_cost).
*
**  Delete service cost
*    SELECT srv_share~* FROM /esrcc/cb_stw AS cb_stw
*          INNER JOIN /esrcc/srv_share AS srv_share
*                  ON cb_stw~cc_uuid = srv_share~cc_uuid
*          FOR ALL ENTRIES IN @keys
*                WHERE fplv = @keys-fplv
*                  AND ryear = @keys-ryear
*                  AND sysid = @keys-sysid
*                  AND poper IN @_poper
*                  AND legalentity = @keys-legalentity
*                  AND ccode = @keys-ccode
*                  AND costobject = @keys-costobject
*                  AND costcenter = @keys-costcenter
*                  AND serviceproduct = @keys-serviceproduct
*                  INTO TABLE @DATA(lt_srvshare).
*
**  Delete receiver cost
*    SELECT rec_chg~* FROM /esrcc/cb_stw AS cb_stw
*          INNER JOIN /esrcc/srv_share AS srv_share
*                  ON cb_stw~cc_uuid = srv_share~cc_uuid
*          INNER JOIN /esrcc/rec_chg AS rec_chg
*                  ON cb_stw~cc_uuid = rec_chg~cc_uuid
*                 AND srv_share~srv_uuid = rec_chg~srv_uuid
*          FOR ALL ENTRIES IN @keys
*                WHERE fplv = @keys-fplv
*                  AND ryear = @keys-ryear
*                  AND sysid = @keys-sysid
*                  AND poper IN @_poper
*                  AND legalentity = @keys-legalentity
*                  AND ccode = @keys-ccode
*                  AND costobject = @keys-costobject
*                  AND costcenter = @keys-costcenter
*                  AND serviceproduct = @keys-serviceproduct
*                  AND rec_chg~status NE 'W'
*                  INTO TABLE @DATA(lt_recshare).
*
**  Delete Service Allocation
*    SELECT * FROM /esrcc/alocshare FOR ALL ENTRIES IN @lt_recshare
*                                   WHERE  parentuuid = @lt_recshare-rec_uuid
*                                   INTO CORRESPONDING FIELDS OF TABLE @lt_alocshare.
*
*    SELECT * FROM /esrcc/alcvalues FOR ALL ENTRIES IN @lt_alocshare
*                                   WHERE parentuuid = @lt_alocshare-uuid
*                                     INTO CORRESPONDING FIELDS OF TABLE @lt_alocvalues.
*
*    DELETE /esrcc/procctrl FROM TABLE @lt_procctrl.
*    DELETE /esrcc/cb_stw FROM TABLE @lt_cc_cost.
*    DELETE /esrcc/srv_share FROM TABLE @lt_srvshare.
*    DELETE /esrcc/rec_chg FROM TABLE @lt_recshare.
*    DELETE /esrcc/alocshare FROM TABLE @lt_alocshare.
*    DELETE /esrcc/alcvalues FROM TABLE @lt_alocvalues.
*    MODIFY /esrcc/cb_li FROM TABLE @lt_cb_li.

  ENDMETHOD.

  METHOD reopenstewardship.

    DATA lt_keys TYPE /esrcc/tt_keys.

    lt_keys = CORRESPONDING #( keys ).

    /esrcc/cl_calculate_chargeout=>reopen_serviceshare( it_keys = lt_keys ).

*    DATA lt_procctrl TYPE STANDARD TABLE OF /esrcc/procctrl.
*    DATA ls_procctrl TYPE  /esrcc/procctrl.
*    DATA lt_alocshare TYPE TABLE OF /esrcc/alocshare.
*    DATA lt_alocvalues TYPE TABLE OF /esrcc/alcvalues.
*    DATA _poper TYPE RANGE OF poper.
*
**Derive poper from billing frequency customizing
*    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
*    IF sy-subrc = 0.
*      SELECT 'I'  AS sign,
*            'EQ'  AS option,
*            poper AS low
*            FROM /esrcc/billfreq
*            WHERE billingfreq = @<key>-billingfreq
*              AND billingvalue = @<key>-billingperiod
*            ORDER BY low ASCENDING
*            INTO CORRESPONDING FIELDS OF TABLE @_poper.
*    ENDIF.
*
**Update execution cockpit process control
*    LOOP AT keys ASSIGNING <key> WHERE costcenter IS NOT INITIAL AND serviceproduct IS NOT INITIAL.
*
*      ls_procctrl = CORRESPONDING #( <key> ).
*      ls_procctrl-process = 'SCM'.    "Stewardship
*      APPEND ls_procctrl TO lt_procctrl.
*
*      ls_procctrl = CORRESPONDING #( <key> ).
*      ls_procctrl-process = 'CHR'.    "Chargeout
*      APPEND ls_procctrl TO lt_procctrl.
*    ENDLOOP.
*
**  Delete service cost
*    SELECT srv_share~* FROM /esrcc/cb_stw AS cb_stw
*          INNER JOIN /esrcc/srv_share AS srv_share
*                  ON cb_stw~cc_uuid = srv_share~cc_uuid
*          FOR ALL ENTRIES IN @keys
*                WHERE fplv = @keys-fplv
*                  AND ryear = @keys-ryear
*                  AND sysid = @keys-sysid
*                  AND poper IN @_poper
*                  AND legalentity = @keys-legalentity
*                  AND ccode = @keys-ccode
*                  AND costobject = @keys-costobject
*                  AND costcenter = @keys-costcenter
*                  AND serviceproduct = @keys-serviceproduct
*                  INTO TABLE @DATA(lt_srvshare).
*
**  Delete receiver cost
*    SELECT rec_chg~* FROM /esrcc/cb_stw AS cb_stw
*          INNER JOIN /esrcc/srv_share AS srv_share
*                  ON cb_stw~cc_uuid = srv_share~cc_uuid
*          INNER JOIN /esrcc/rec_chg AS rec_chg
*                  ON cb_stw~cc_uuid = rec_chg~cc_uuid
*                 AND srv_share~srv_uuid = rec_chg~srv_uuid
*          FOR ALL ENTRIES IN @keys
*                WHERE fplv = @keys-fplv
*                  AND ryear = @keys-ryear
*                  AND sysid = @keys-sysid
*                  AND poper IN @_poper
*                  AND legalentity = @keys-legalentity
*                  AND ccode = @keys-ccode
*                  AND costobject = @keys-costobject
*                  AND costcenter = @keys-costcenter
*                  AND serviceproduct = @keys-serviceproduct
*                  AND rec_chg~status NE 'W'
*                  INTO TABLE @DATA(lt_recshare).
*
**  Delete Service Allocation
*    SELECT * FROM /esrcc/alocshare FOR ALL ENTRIES IN @lt_recshare
*                                   WHERE  parentuuid = @lt_recshare-rec_uuid
*                                   INTO CORRESPONDING FIELDS OF TABLE @lt_alocshare.
*
*    SELECT * FROM /esrcc/alcvalues FOR ALL ENTRIES IN @lt_alocshare
*                                   WHERE parentuuid = @lt_alocshare-uuid
*                                     INTO CORRESPONDING FIELDS OF TABLE @lt_alocvalues.
*
*    DELETE /esrcc/procctrl FROM TABLE @lt_procctrl.
*    DELETE /esrcc/srv_share FROM TABLE @lt_srvshare.
*    DELETE /esrcc/rec_chg FROM TABLE @lt_recshare.
*    DELETE /esrcc/alocshare FROM TABLE @lt_alocshare.
*    DELETE /esrcc/alcvalues FROM TABLE @lt_alocvalues.

  ENDMETHOD.

  METHOD performcostbase.

    DATA lt_keys TYPE /esrcc/tt_keys.

    lt_keys = CORRESPONDING #( keys ).

    /esrcc/cl_calculate_chargeout=>calculate_costbase( it_keys = lt_keys ).

*    DATA lt_cc_cost  TYPE TABLE OF /esrcc/cb_stw.
*    DATA lt_procctrl TYPE STANDARD TABLE OF /esrcc/procctrl.
*    DATA ls_procctrl TYPE  /esrcc/procctrl.
*    DATA _poper TYPE RANGE OF poper.
*    DATA ls_wf_leadobj TYPE /esrcc/s_wf_leadingobject.
*    DATA lt_wf_leadobj TYPE /esrcc/tt_wf_leadingobject.
*
*
**Derive poper from billing frequency customizing
*    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
*    IF sy-subrc = 0.
*      SELECT 'I'  AS sign,
*            'EQ'  AS option,
*            poper AS low
*            FROM /esrcc/billfreq
*            WHERE billingfreq = @<key>-billingfreq
*              AND billingvalue = @<key>-billingperiod
*            ORDER BY low ASCENDING
*            INTO CORRESPONDING FIELDS OF TABLE @_poper.
*    ENDIF.
*
*
*    SELECT * FROM /esrcc/i_costbase_stewardship FOR ALL ENTRIES IN @keys WHERE  fplv = @keys-fplv
*                                                                  AND ryear = @keys-ryear
*                                                                  AND sysid = @keys-sysid
*                                                                  AND poper IN @_poper
*                                                                  AND legalentity = @keys-legalentity
*                                                                  AND ccode = @keys-ccode
*                                                                  AND costobject = @keys-costobject
*                                                                  AND costcenter = @keys-costcenter
*                                                                  INTO CORRESPONDING FIELDS OF TABLE @lt_cc_cost.
*
**
*    /esrcc/cl_wf_utility=>is_wf_on(
*      EXPORTING
*        iv_apptype   = 'CBS'
*      IMPORTING
*        ev_wf_active = DATA(wf_active)
*    ).
*
*
*    CLEAR: ls_wf_leadobj,lt_wf_leadobj.
*
*    DATA(lo_uuid) = cl_uuid_factory=>create_system_uuid( ).
*
*    LOOP AT lt_cc_cost ASSIGNING FIELD-SYMBOL(<ls_cc_cost>).
*
** Assign the 16 digit unique identifier
*      IF lo_uuid IS BOUND.
*        TRY.
*            <ls_cc_cost>-cc_uuid = lo_uuid->create_uuid_x16( ).
*          CATCH cx_uuid_error.
*            "handle exception
*        ENDTRY.
*      ENDIF.
*
*      <ls_cc_cost>-billingperiod = keys[ 1 ]-billingperiod.
** Admin data
*      <ls_cc_cost>-created_by = sy-uname.
*      /esrcc/cl_utility_core=>get_utc_date_time_ts(
*        IMPORTING
*          time_stamp = <ls_cc_cost>-created_at
*      ).
*      <ls_cc_cost>-last_changed_by = sy-uname.
*      /esrcc/cl_utility_core=>get_utc_date_time_ts(
*        IMPORTING
*          time_stamp = <ls_cc_cost>-last_changed_at
*      ).
*
*      IF wf_active EQ abap_true.
*        CLEAR ls_wf_leadobj.
*        MOVE-CORRESPONDING <ls_cc_cost> TO ls_wf_leadobj.
*        APPEND ls_wf_leadobj TO lt_wf_leadobj.
**        <ls_cc_cost>-status = 'W'.   "In Approval
*      ELSE.
*        <ls_cc_cost>-status = 'A'.   "Approval
*      ENDIF.
*    ENDLOOP.
*
*
*    IF wf_active EQ abap_true.
*      CALL FUNCTION '/ESRCC/FM_WF_START'
*        EXPORTING
*          it_leading_object = lt_wf_leadobj
*          iv_apptype        = 'CBS'.
*    ENDIF.
*
*
*    LOOP AT keys ASSIGNING <key> WHERE costcenter IS NOT INITIAL AND serviceproduct IS INITIAL.
*      ls_procctrl = CORRESPONDING #( <key> ).
*      ls_procctrl-process = 'CBS'.    "Cost Base
*      IF wf_active = abap_false.
*        ls_procctrl-status = '07'.     "Cost Base Approved
*      ELSE.
*        ls_procctrl-status = '05'.     "Cost Base In Process
*      ENDIF.
*
** Admin data
*      ls_procctrl-created_by = sy-uname.
*      /esrcc/cl_utility_core=>get_utc_date_time_ts(
*        IMPORTING
*          time_stamp = ls_procctrl-created_at
*      ).
*      ls_procctrl-last_changed_by = sy-uname.
*      /esrcc/cl_utility_core=>get_utc_date_time_ts(
*        IMPORTING
*          time_stamp = ls_procctrl-last_changed_at
*      ).
*
*      APPEND ls_procctrl TO lt_procctrl.
*    ENDLOOP.
*
**  Delete old as user might have re-triggered costbase & stewardship calculation
*    SELECT * FROM /esrcc/cb_stw FOR ALL ENTRIES IN @keys WHERE  fplv = @keys-fplv
*                                                             AND ryear = @keys-ryear
*                                                             AND sysid = @keys-sysid
*                                                             AND  poper IN @_poper
*                                                             AND  legalentity = @keys-legalentity
*                                                             AND  ccode = @keys-ccode
*                                                             AND  costobject = @keys-costobject
*                                                             AND  costcenter = @keys-costcenter
*                                                             INTO TABLE @DATA(lt_del_cc_cost).
*
*    MODIFY /esrcc/procctrl FROM TABLE @lt_procctrl.
*    DELETE /esrcc/cb_stw FROM TABLE @lt_del_cc_cost.
*    MODIFY /esrcc/cb_stw FROM TABLE @lt_cc_cost.


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
