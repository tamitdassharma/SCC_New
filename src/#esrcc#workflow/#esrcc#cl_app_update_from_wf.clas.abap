CLASS /esrcc/cl_app_update_from_wf DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS update_cb_li
      IMPORTING
        !it_leading_data TYPE /esrcc/tt_wf_leadingobject
        !iv_wi_id        TYPE /esrcc/workflowid
        !iv_status       TYPE /esrcc/status_de
        !iv_user         TYPE syst-uname OPTIONAL
        !iv_comment      TYPE /esrcc/comment OPTIONAL .
    CLASS-METHODS update_cc_cost
      IMPORTING
        !it_leading_data TYPE /esrcc/tt_wf_leadingobject
        !iv_wi_id        TYPE /esrcc/workflowid
        !iv_status       TYPE /esrcc/status_de
        !iv_user         TYPE syst-uname OPTIONAL
        !iv_comment      TYPE /esrcc/comment OPTIONAL .
    CLASS-METHODS update_rec_cost
      IMPORTING
        !it_leading_data TYPE /esrcc/tt_wf_leadingobject
        !iv_wi_id        TYPE /esrcc/workflowid
        !iv_status       TYPE /esrcc/status_de
        !iv_user         TYPE syst-uname OPTIONAL
        !iv_comment      TYPE /esrcc/comment OPTIONAL .
    CLASS-METHODS update_srv_cost
      IMPORTING
        !it_leading_data TYPE /esrcc/tt_wf_leadingobject
        !iv_wi_id        TYPE /esrcc/workflowid
        !iv_status       TYPE /esrcc/status_de
        !iv_user         TYPE syst-uname OPTIONAL
        !iv_comment      TYPE /esrcc/comment OPTIONAL .
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
        IF iv_user IS SUPPLIED.
          <fs_cc_cost>-last_changed_by = iv_user.
        ENDIF.
        <fs_cc_cost>-workflowid = iv_wi_id.
      ENDLOOP.
      UPDATE /esrcc/cc_cost FROM TABLE @lt_cc_cost.

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
      UPDATE /esrcc/rec_cost FROM TABLE @lt_rec_cost.

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
        IF iv_user IS SUPPLIED.
          <fs_srv_cost>-last_changed_by = iv_user.
        ENDIF.
        <fs_srv_cost>-workflowid = iv_wi_id.
      ENDLOOP.
      UPDATE /esrcc/srv_cost FROM TABLE @lt_srv_cost.

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
ENDCLASS.
