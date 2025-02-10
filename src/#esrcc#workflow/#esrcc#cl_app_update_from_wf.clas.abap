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
      !IV_USER type SYST-UNAME optional
      !IV_COMMENT type /ESRCC/COMMENT optional .
  class-methods UPDATE_CC_COST
    importing
      !IT_LEADING_DATA type /ESRCC/TT_WF_LEADINGOBJECT
      !IV_WI_ID type /ESRCC/WORKFLOWID
      !IV_STATUS type /ESRCC/STATUS_DE
      !IV_USER type SYST-UNAME optional
      !IV_COMMENT type /ESRCC/COMMENT optional .
  class-methods UPDATE_REC_COST
    importing
      !IT_LEADING_DATA type /ESRCC/TT_WF_LEADINGOBJECT
      !IV_WI_ID type /ESRCC/WORKFLOWID
      !IV_STATUS type /ESRCC/STATUS_DE
      !IV_USER type SYST-UNAME optional
      !IV_COMMENT type /ESRCC/COMMENT optional .
  class-methods UPDATE_SRV_COST
    importing
      !IT_LEADING_DATA type /ESRCC/TT_WF_LEADINGOBJECT
      !IV_WI_ID type /ESRCC/WORKFLOWID
      !IV_STATUS type /ESRCC/STATUS_DE
      !IV_USER type SYST-UNAME optional
      !IV_COMMENT type /ESRCC/COMMENT optional .
  class-methods UPDATE_STEWARDSHIP_CONFIG
    importing
      !IT_LEADING_DATA type /ESRCC/TT_WF_LEADINGOBJECT
      !IV_WI_ID type /ESRCC/WORKFLOWID
      !IV_STATUS type /ESRCC/STATUS_DE
      !IV_USER type SYST-UNAME optional
      !IV_COMMENT type /ESRCC/COMMENT optional .
  class-methods UPDATE_CO_RULE_CONFIG
    importing
      !IT_LEADING_DATA type /ESRCC/TT_WF_LEADINGOBJECT
      !IV_WI_ID type /ESRCC/WORKFLOWID
      !IV_STATUS type /ESRCC/STATUS_DE
      !IV_USER type SYST-UNAME optional
      !IV_COMMENT type /ESRCC/COMMENT optional .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /ESRCC/CL_APP_UPDATE_FROM_WF IMPLEMENTATION.


  METHOD update_cb_li.

    DATA ls_comment TYPE /esrcc/comments.

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
        IF iv_user IS SUPPLIED.
          <fs_cb_li>-last_changed_by = iv_user.
        ENDIF.
        <fs_cb_li>-workflowid = iv_wi_id.
      ENDLOOP.
      UPDATE /esrcc/cb_li FROM TABLE @lt_cb_li.

      IF iv_comment IS NOT INITIAL.
        ls_comment-worfklow_id = iv_wi_id.
        ls_comment-created_by = iv_user.
        ls_comment-last_changed_by = iv_user.
        ls_comment-status = iv_status.
        /esrcc/cl_comments_util=>modify_comments(
          comments    = ls_comment
          iv_comments = iv_comment
        ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD update_cc_cost.

    DATA ls_comment TYPE /esrcc/comments.

    SELECT * FROM /esrcc/cb_stw   FOR ALL ENTRIES IN @it_leading_data
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
        IF iv_user IS SUPPLIED.
          <fs_cc_cost>-last_changed_by = iv_user.
        ENDIF.
        <fs_cc_cost>-workflowid = iv_wi_id.
      ENDLOOP.
      UPDATE /esrcc/cb_stw FROM TABLE @lt_cc_cost.

      IF iv_comment IS NOT INITIAL.
        ls_comment-worfklow_id = iv_wi_id.
        ls_comment-created_by = iv_user.
        ls_comment-last_changed_by = iv_user.
        ls_comment-status = iv_status.
        /esrcc/cl_comments_util=>modify_comments(
          comments    = ls_comment
          iv_comments = iv_comment
        ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD update_rec_cost.

    DATA ls_comment TYPE /esrcc/comments.

    SELECT recchg~* FROM /esrcc/cb_stw as cb
             INNER JOIN /esrcc/srv_share as srvshare
               on cb~cc_uuid = srvshare~cc_uuid
             INNER JOIN /esrcc/rec_chg as recchg
               on cb~cc_uuid = recchg~cc_uuid
              and srvshare~srv_uuid = recchg~srv_uuid
                FOR ALL ENTRIES IN @it_leading_data
          WHERE
                fplv  = @it_leading_data-fplv AND
                ryear = @it_leading_data-ryear AND
                poper = @it_leading_data-poper AND
                sysid = @it_leading_data-sysid AND
                legalentity = @it_leading_data-legalentity AND
                ccode = @it_leading_data-ccode AND
                costobject = @it_leading_data-costobject  AND
                costcenter = @it_leading_data-costcenter AND
                serviceproduct = @it_leading_data-serviceproduct AND
                receivingentity = @it_leading_data-receivingentity
                INTO TABLE @DATA(lt_rec_cost).


    IF sy-subrc EQ 0.
      LOOP AT lt_rec_cost ASSIGNING FIELD-SYMBOL(<fs_rec_cost>).
        <fs_rec_cost>-status = iv_status.
        IF iv_user IS SUPPLIED.
          <fs_rec_cost>-last_changed_by = iv_user.
        ENDIF.
        <fs_rec_cost>-workflowid = iv_wi_id.
      ENDLOOP.
      UPDATE /esrcc/rec_chg FROM TABLE @lt_rec_cost.

      IF iv_comment IS NOT INITIAL.
        ls_comment-worfklow_id = iv_wi_id.
        ls_comment-created_by = iv_user.
        ls_comment-last_changed_by = iv_user.
        ls_comment-status = iv_status.
        /esrcc/cl_comments_util=>modify_comments(
          comments    = ls_comment
          iv_comments = iv_comment
        ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD update_srv_cost.

    DATA ls_comment TYPE /esrcc/comments.

    SELECT srvshare~* FROM /esrcc/cb_stw as cb
             INNER JOIN /esrcc/srv_share as srvshare
               on cb~cc_uuid = srvshare~cc_uuid FOR ALL ENTRIES IN @it_leading_data
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
        IF iv_user IS SUPPLIED.
          <fs_srv_cost>-last_changed_by = iv_user.
        ENDIF.
        <fs_srv_cost>-workflowid = iv_wi_id.
      ENDLOOP.
      UPDATE /esrcc/srv_share FROM TABLE @lt_srv_cost.

      IF iv_comment IS NOT INITIAL.
        ls_comment-worfklow_id = iv_wi_id.
        ls_comment-created_by = iv_user.
        ls_comment-last_changed_by = iv_user.
        ls_comment-status = iv_status.
        /esrcc/cl_comments_util=>modify_comments(
          comments    = ls_comment
          iv_comments = iv_comment
        ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


METHOD update_co_rule_config.
  DATA lr_rule_id TYPE RANGE OF /esrcc/chargeout_rule_id.

  CHECK it_leading_data IS NOT INITIAL.
  lr_rule_id = VALUE #( FOR rule IN it_leading_data ( sign = 'I' option = 'EQ' low = rule-rule_id ) ).

  UPDATE /esrcc/co_rule SET workflow_id     = @iv_wi_id,
                            workflow_status = @iv_status,
                            last_changed_by = @iv_user
*                            last_changed_at = @sy-timlo
    WHERE rule_id IN @lr_rule_id.

  IF sy-subrc = 0 AND iv_comment IS NOT INITIAL.
    /esrcc/cl_comments_util=>modify_comments(
      comments    = VALUE #( worfklow_id = iv_wi_id created_by = iv_user last_changed_by = iv_user status = iv_status )
      iv_comments = iv_comment
    ).
  ENDIF.
ENDMETHOD.


METHOD update_stewardship_config.
  DATA lr_stewardship_uuid TYPE RANGE OF sysuuid_x16.

  CHECK it_leading_data IS NOT INITIAL.
  lr_stewardship_uuid = VALUE #( FOR stw IN it_leading_data ( sign = 'I' option = 'EQ' low = stw-stewardship_uuid ) ).

  UPDATE /esrcc/stewrdshp SET workflow_id     = @iv_wi_id,
                              workflow_status = @iv_status,
                              last_changed_by = @iv_user
*                              last_changed_at = @sy-timlo
    WHERE stewardship_uuid IN @lr_stewardship_uuid.

  IF sy-subrc = 0 AND iv_comment IS NOT INITIAL.
    /esrcc/cl_comments_util=>modify_comments(
      comments    = VALUE #( worfklow_id = iv_wi_id created_by = iv_user last_changed_by = iv_user status = iv_status )
      iv_comments = iv_comment
    ).
  ENDIF.
ENDMETHOD.
ENDCLASS.
