interface /ESRCC/IF_EXECCOCKPIT
  public .
  INTERFACES: IF_BADI_INTERFACE.

  methods CALCULATE_COSTBASE_STEWARDSHIP
    CHANGING ct_cc_cost TYPE /esrcc/tt_cc_cost.
  methods CALCULATE_SERVICESHARE_MARKUP
    CHANGING ct_srv_cost TYPE /esrcc/tt_srv_cost.
  methods CALCULATE_CHARGEOUT
    CHANGING ct_rec_cost TYPE /esrcc/tt_rec_cost.
  methods CALCULATE_ALLOCATION
    CHANGING ct_srv_alloc TYPE /esrcc/tt_srvalloc.
  methods FINALIZE_COSTBASE .
  methods FINALIZE_SERVICECOSTSHARE .
  methods FINALIZE_CHARGEOUT.
  methods REOPEN_COSTBASE .
  methods REOPEN_SERVICESHARE .
  methods REOPEN_CHARGEOUT .
endinterface.
