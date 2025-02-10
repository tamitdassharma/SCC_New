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
    METHODS automate_sequentialchargeout FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~automate_sequentialchargeout.
    METHODS reopen_sequentialchargeout FOR MODIFY
      IMPORTING keys FOR ACTION /esrcc/c_execution_cockpit~reopen_sequentialchargeout.

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

  ENDMETHOD.

  METHOD finalizecostbase.

    DATA lt_keys TYPE /esrcc/tt_keys.

    lt_keys = CORRESPONDING #( keys ).

    /esrcc/cl_calculate_chargeout=>finalize_costbase( it_keys = lt_keys ).

  ENDMETHOD.

  METHOD finalizestewardship.

    DATA lt_keys TYPE /esrcc/tt_keys.

    lt_keys = CORRESPONDING #( keys ).

    /esrcc/cl_calculate_chargeout=>finalize_servicecostshare( it_keys = lt_keys ).

  ENDMETHOD.

  METHOD performchargeout.

    DATA lt_keys TYPE /esrcc/tt_keys.

    lt_keys = CORRESPONDING #( keys ).

    /esrcc/cl_calculate_chargeout=>calculate_chargeout( it_keys = lt_keys ).

  ENDMETHOD.

  METHOD performstewardship.

    DATA lt_keys TYPE /esrcc/tt_keys.

    lt_keys = CORRESPONDING #( keys ).

    /esrcc/cl_calculate_chargeout=>calculate_servicecostshare( it_keys = lt_keys ).

  ENDMETHOD.

  METHOD reopenchargeout.

    DATA lt_keys TYPE /esrcc/tt_keys.

    lt_keys = CORRESPONDING #( keys ).

    /esrcc/cl_calculate_chargeout=>reopen_chargeout( it_keys = lt_keys ).

  ENDMETHOD.

  METHOD reopencostbase.

    DATA lt_keys TYPE /esrcc/tt_keys.

    lt_keys = CORRESPONDING #( keys ).

    /esrcc/cl_calculate_chargeout=>reopen_costbase( it_keys = lt_keys ).

  ENDMETHOD.

  METHOD reopenstewardship.

    DATA lt_keys TYPE /esrcc/tt_keys.

    lt_keys = CORRESPONDING #( keys ).

    /esrcc/cl_calculate_chargeout=>reopen_serviceshare( it_keys = lt_keys ).

  ENDMETHOD.

  METHOD performcostbase.

    DATA lt_keys TYPE /esrcc/tt_keys.

    lt_keys = CORRESPONDING #( keys ).

    /esrcc/cl_calculate_chargeout=>calculate_costbase( it_keys = lt_keys ).

  ENDMETHOD.

  METHOD automate_sequentialchargeout.

    DATA lt_keys TYPE /esrcc/tt_keys.

    lt_keys = CORRESPONDING #( keys ).

    /esrcc/cl_calculate_chargeout=>sequentialchargeout( it_keys = lt_keys ).

  ENDMETHOD.

  METHOD reopen_sequentialchargeout.

    DATA lt_keys TYPE /esrcc/tt_keys.

    lt_keys = CORRESPONDING #( keys ).

    /esrcc/cl_calculate_chargeout=>reopnesequentialchargeout( it_keys = lt_keys ).

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
