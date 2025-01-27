CLASS /esrcc/cl_badi_execcockpit DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES /esrcc/if_execcockpit .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /ESRCC/CL_BADI_EXECCOCKPIT IMPLEMENTATION.


  METHOD /esrcc/if_execcockpit~calculate_allocation.
  ENDMETHOD.


  METHOD /esrcc/if_execcockpit~calculate_chargeout.
  ENDMETHOD.


  METHOD /esrcc/if_execcockpit~calculate_costbase_stewardship.
  ENDMETHOD.


  METHOD /esrcc/if_execcockpit~calculate_serviceshare_markup.
  ENDMETHOD.


  METHOD /esrcc/if_execcockpit~finalize_chargeout.
  ENDMETHOD.


  METHOD /esrcc/if_execcockpit~finalize_costbase.
  ENDMETHOD.


  METHOD /esrcc/if_execcockpit~finalize_servicecostshare.
  ENDMETHOD.


  METHOD /esrcc/if_execcockpit~reopen_chargeout.
  ENDMETHOD.


  METHOD /esrcc/if_execcockpit~reopen_costbase.
  ENDMETHOD.


  METHOD /esrcc/if_execcockpit~reopen_serviceshare.
  ENDMETHOD.


  METHOD /esrcc/if_execcockpit~virtual_posting_recharge.

*    IF
  ENDMETHOD.
ENDCLASS.
