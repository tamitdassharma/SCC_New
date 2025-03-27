interface /ESRCC/IF_EXECCOCKPIT
  public .
<<<<<<< HEAD
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
=======


  interfaces IF_BADI_INTERFACE .

  class-methods CALCULATE_COSTBASE
    importing
      !IT_KEYS type /ESRCC/TT_KEYS
      !IT_POPER type /ESRCC/TT_POPER_RANGE optional
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods CALCULATE_SERVICECOSTSHARE
    importing
      !IT_KEYS type /ESRCC/TT_KEYS
      !IT_POPER type /ESRCC/TT_POPER_RANGE optional
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods CALCULATE_CHARGEOUT
    importing
      !IT_KEYS type /ESRCC/TT_KEYS
      !IT_POPER type /ESRCC/TT_POPER_RANGE optional
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods FINALIZE_COSTBASE
    importing
      !IT_KEYS type /ESRCC/TT_KEYS
      !IT_POPER type /ESRCC/TT_POPER_RANGE optional
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods FINALIZE_SERVICECOSTSHARE
    importing
      !IT_KEYS type /ESRCC/TT_KEYS
      !IT_POPER type /ESRCC/TT_POPER_RANGE optional
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods FINALIZE_CHARGEOUT
    importing
      !IT_KEYS type /ESRCC/TT_KEYS
      !IT_POPER type /ESRCC/TT_POPER_RANGE optional
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods REOPEN_COSTBASE
    importing
      !IT_KEYS type /ESRCC/TT_KEYS
      !IT_POPER type /ESRCC/TT_POPER_RANGE optional
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods REOPEN_SERVICESHARE
    importing
      !IT_KEYS type /ESRCC/TT_KEYS
      !IV_COSTBASEREOPEN type ABAP_BOOLEAN optional
      !IT_POPER type /ESRCC/TT_POPER_RANGE optional
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods REOPEN_CHARGEOUT
    importing
      !IT_KEYS type /ESRCC/TT_KEYS
      !IV_COSTBASEREOPEN type ABAP_BOOLEAN optional
      !IT_POPER type /ESRCC/TT_POPER_RANGE optional
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods CALCULATE_ADHOCCHARGEOUT
    importing
      !IT_CBLI type /ESRCC/TT_CBLI
      !IS_PARAMETERS type /ESRCC/C_ADHOCCHARGEOUT
      !IT_RECEIVERS type /ESRCC/TT_RECEIVERS
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods SEQUENTIALCHARGEOUT
    importing
      !IT_KEYS type /ESRCC/TT_KEYS
      !IV_COSTBASEREOPEN type ABAP_BOOLEAN optional
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods REOPNESEQUENTIALCHARGEOUT
    importing
      !IT_KEYS type /ESRCC/TT_KEYS
      !IV_COSTBASEREOPEN type ABAP_BOOLEAN optional
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods VIRTUAL_POSTING
    importing
      !IT_KEYS type /ESRCC/TT_KEYS
      !IT_POPER type /ESRCC/TT_POPER_RANGE
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
  class-methods DELETE_ADHOC_CHARGEOUT
    importing
      !ID type SYSUUID_X16
    exporting
      !EV_FAILED type ABAP_BOOLEAN .
>>>>>>> origin/main
endinterface.
