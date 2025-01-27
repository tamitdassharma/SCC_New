INTERFACE /esrcc/if_execcockpit
  PUBLIC .
  INTERFACES: if_badi_interface.

  METHODS calculate_costbase_stewardship
    CHANGING ct_cc_cost TYPE /esrcc/tt_cc_cost.
  METHODS calculate_serviceshare_markup
    CHANGING ct_srv_cost TYPE /esrcc/tt_srv_cost.
  METHODS calculate_chargeout
    CHANGING ct_rec_cost TYPE /esrcc/tt_rec_cost.
  METHODS calculate_allocation
    CHANGING ct_srv_alloc TYPE /esrcc/tt_srvalloc.
  METHODS finalize_costbase .
  METHODS finalize_servicecostshare .
  METHODS finalize_chargeout.
  METHODS reopen_costbase .
  METHODS reopen_serviceshare .
  METHODS reopen_chargeout .
  METHODS virtual_posting_recharge
    IMPORTING it_rec_chg TYPE /esrcc/tt_rec_cost.
ENDINTERFACE.
