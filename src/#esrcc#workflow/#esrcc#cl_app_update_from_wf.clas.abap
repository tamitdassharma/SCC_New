class /ESRCC/CL_APP_UPDATE_FROM_WF definition
  public
  final
  create public .

public section.

  class-methods UPDATE_CB_LI
    importing
      !IT_LEADING_DATA type /ESRCC/TT_WF_LEADINGOBJECT
      !IV_WI_ID type /ESRCC/WORKFLOWID
      !IV_STATUS type /ESRCC/STATUS_DE
      !IV_USER type SYST-UNAME .
  class-methods UPDATE_CC_COST
    importing
      !IT_LEADING_DATA type /ESRCC/TT_WF_LEADINGOBJECT
      !IV_WI_ID type /ESRCC/WORKFLOWID
      !IV_STATUS type /ESRCC/STATUS_DE
      !IV_USER type SYST-UNAME .
  class-methods UPDATE_REC_COST
    importing
      !IT_LEADING_DATA type /ESRCC/TT_WF_LEADINGOBJECT
      !IV_WI_ID type /ESRCC/WORKFLOWID
      !IV_STATUS type /ESRCC/STATUS_DE
      !IV_USER type SYST-UNAME .
  class-methods UPDATE_SRV_COST
    importing
      !IT_LEADING_DATA type /ESRCC/TT_WF_LEADINGOBJECT
      !IV_WI_ID type /ESRCC/WORKFLOWID
      !IV_STATUS type /ESRCC/STATUS_DE
      !IV_USER type SYST-UNAME .
protected section.
private section.
ENDCLASS.



CLASS /ESRCC/CL_APP_UPDATE_FROM_WF IMPLEMENTATION.


  METHOD update_cb_li.

    SELECT * FROM /esrcc/cb_li   FOR ALL ENTRIES IN @it_leading_data
          WHERE ryear = @it_leading_data-ryear AND
                poper = @it_leading_data-poper AND
                sysid = @it_leading_data-sysid AND
                legalentity = @it_leading_data-legalentity AND
                ccode = @it_leading_data-ccode AND
                belnr = @it_leading_data-belnr AND
                buzei = @it_leading_data-buzei AND
                costobject = @it_leading_data-costobject  AND
                costcenter = @it_leading_data-costcenter AND
                costelement  = @it_leading_data-costelement INTO TABLE @DATA(lt_cb_li).


    IF sy-subrc EQ 0.
      LOOP AT lt_cb_li ASSIGNING FIELD-SYMBOL(<fs_cb_li>).
        <fs_cb_li>-status = iv_status.
        <fs_cb_li>-last_changed_by = iv_user.
        <fs_cb_li>-workflowid = iv_wi_id.
      ENDLOOP.
      UPDATE /esrcc/cb_li FROM TABLE @lt_cb_li.
    ENDIF.

  ENDMETHOD.


  METHOD update_cc_cost.

    SELECT * FROM /esrcc/cc_cost   FOR ALL ENTRIES IN @it_leading_data
          WHERE
                fplv  = @it_leading_data-fplv AND
                ryear = @it_leading_data-ryear AND
                poper = @it_leading_data-poper AND
                sysid = @it_leading_data-sysid AND
                legalentity = @it_leading_data-legalentity AND
                ccode = @it_leading_data-ccode AND
                costobject = @it_leading_data-costobject  AND
                costcenter = @it_leading_data-costcenter
                INTO TABLE @DATA(lt_cc_cost).


    IF sy-subrc EQ 0.
      LOOP AT lt_cc_cost ASSIGNING FIELD-SYMBOL(<fs_cc_cost>).
        <fs_cc_cost>-status = iv_status.
        <fs_cc_cost>-last_changed_by = iv_user.
        <fs_cc_cost>-workflowid = iv_wi_id.
      ENDLOOP.
      UPDATE /esrcc/cc_cost FROM TABLE @lt_cc_cost.
    ENDIF.

  ENDMETHOD.


  METHOD update_rec_cost.

    SELECT * FROM /esrcc/rec_cost   FOR ALL ENTRIES IN @it_leading_data
          WHERE
                fplv  = @it_leading_data-fplv AND
                ryear = @it_leading_data-ryear AND
                poper = @it_leading_data-poper AND
                sysid = @it_leading_data-sysid AND
                legalentity = @it_leading_data-legalentity AND
                ccode = @it_leading_data-ccode AND
                costobject = @it_leading_data-costobject  AND
                costcenter = @it_leading_data-costcenter AND
                serviceproduct = @it_leading_data-serviceproduct and
                receivingentity = @it_leading_data-receivingentity
                INTO TABLE @DATA(lt_rec_cost).


    IF sy-subrc EQ 0.
      LOOP AT lt_rec_cost ASSIGNING FIELD-SYMBOL(<fs_rec_cost>).
        <fs_rec_cost>-status = iv_status.
 "       <fs_rec_cost>-last_changed_by = iv_user.
        <fs_rec_cost>-workflowid = iv_wi_id.
      ENDLOOP.
      UPDATE /esrcc/rec_cost FROM TABLE @lt_rec_cost.
    ENDIF.

  ENDMETHOD.


  METHOD UPDATE_SRV_COST.

    SELECT * FROM /esrcc/srv_cost   FOR ALL ENTRIES IN @it_leading_data
          WHERE
                fplv  = @it_leading_data-fplv AND
                ryear = @it_leading_data-ryear AND
                poper = @it_leading_data-poper AND
                sysid = @it_leading_data-sysid AND
                legalentity = @it_leading_data-legalentity AND
                ccode = @it_leading_data-ccode AND
                costobject = @it_leading_data-costobject  AND
                costcenter = @it_leading_data-costcenter AND
                serviceproduct = @it_leading_data-serviceproduct

                INTO TABLE @DATA(lt_srv_cost).


    IF sy-subrc EQ 0.
      LOOP AT lt_srv_cost ASSIGNING FIELD-SYMBOL(<fs_srv_cost>).
        <fs_srv_cost>-status = iv_status.
 "       <fs_srv_cost>-last_changed_by = iv_user.
        <fs_srv_cost>-workflowid = iv_wi_id.
      ENDLOOP.
      UPDATE /esrcc/srv_cost FROM TABLE @lt_srv_cost.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
