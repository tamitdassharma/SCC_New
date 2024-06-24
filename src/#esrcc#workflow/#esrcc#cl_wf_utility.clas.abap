class /ESRCC/CL_WF_UTILITY definition
  public
  final
  create public .

public section.

  class-methods IS_WF_ON
    importing
      !IV_APPTYPE type /ESRCC/APPLICATION_TYPE_DE
    exporting
      !EV_WF_ACTIVE type /ESRCC/WORKFLOW_ON .
protected section.
private section.
ENDCLASS.



CLASS /ESRCC/CL_WF_UTILITY IMPLEMENTATION.


  METHOD is_wf_on.
    CLEAR ev_wf_active.
    SELECT SINGLE application , workflowactive FROM /esrcc/wf_switch  WHERE application = @iv_apptype INTO @DATA(ls_switch).
    IF sy-subrc EQ 0.
      ev_wf_active =  ls_switch-workflowactive.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
