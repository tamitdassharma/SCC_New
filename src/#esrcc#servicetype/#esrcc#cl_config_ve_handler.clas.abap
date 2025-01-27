CLASS /esrcc/cl_config_ve_handler DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:
      tt_srvaloc TYPE STANDARD TABLE OF /esrcc/c_srvaloc WITH EMPTY KEY,
      tt_co_rule TYPE STANDARD TABLE OF /esrcc/c_corule WITH EMPTY KEY.

    DATA:
      gv_entity TYPE string.

    METHODS: calculate_srvaloc
      CHANGING ct_srvaloc TYPE tt_srvaloc.
    METHODS: calculate_co_rule
      CHANGING ct_co_rule TYPE tt_co_rule.
ENDCLASS.



CLASS /ESRCC/CL_CONFIG_VE_HANDLER IMPLEMENTATION.


  METHOD calculate_srvaloc.
    SELECT
        aloc~serviceproduct,
        aloc~costversion,
        aloc~validfrom,

        CASE
          WHEN draft~chargeout = 'D' THEN @abap_true ELSE CASE WHEN draft~chargeout IS NULL AND db~chargeout = 'D' THEN @abap_true ELSE @abap_false END
        END AS hideweightage,
        CASE
          WHEN draft~chargeout = 'I' THEN @abap_true ELSE CASE WHEN draft~chargeout IS NULL AND db~chargeout = 'I' THEN @abap_true ELSE @abap_false END
        END AS hideversion

      FROM @ct_srvaloc AS aloc
      LEFT OUTER JOIN /esrcc/d_srvaloc AS draft
         ON draft~serviceproduct = aloc~serviceproduct
        AND draft~costversion    = aloc~costversion
        AND draft~validfrom      = aloc~validfrom
        AND draft~draftentityoperationcode NOT IN ( 'D', 'L' )
      LEFT OUTER JOIN /esrcc/srvaloc AS db
         ON db~serviceproduct = aloc~serviceproduct
        AND db~cost_version   = aloc~costversion
        AND db~validfrom      = aloc~validfrom
      INTO TABLE @DATA(lt_srvaloc).

    ct_srvaloc = CORRESPONDING #( lt_srvaloc ).
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~calculate.
    CASE gv_entity.
      WHEN '/ESRCC/C_SRVALOC'.
        DATA(lt_srvaloc) = CORRESPONDING tt_srvaloc( it_original_data ).

        calculate_srvaloc(
          CHANGING
            ct_srvaloc = lt_srvaloc
        ).

        ct_calculated_data = CORRESPONDING #( lt_srvaloc ).

      WHEN '/ESRCC/C_CORULE'.
        DATA(lt_co_rule) = CORRESPONDING tt_co_rule( it_original_data ).

        calculate_co_rule(
          CHANGING
            ct_co_rule = lt_co_rule
        ).

        ct_calculated_data = CORRESPONDING #( lt_co_rule ).
    ENDCASE.
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    gv_entity = iv_entity.
  ENDMETHOD.


  METHOD calculate_co_rule.
    DATA(lt_co_rule_relevance) = /esrcc/cl_config_util=>get_co_rule_config( ).

    SELECT rule~ruleid, coalesce( draft~chargeoutmethod, db~chargeout_method, rule~chargeoutmethod ) AS chargeoutmethod
        FROM @ct_co_rule AS rule
        LEFT OUTER JOIN /esrcc/d_co_rule AS draft
            ON draft~ruleid = rule~RuleId
           AND draft~draftentityoperationcode NOT IN ( 'D', 'L' )
        LEFT OUTER JOIN /esrcc/co_rule AS db
            ON db~rule_id = rule~ruleid
        INTO CORRESPONDING FIELDS OF TABLE @ct_co_rule.

    LOOP AT ct_co_rule ASSIGNING FIELD-SYMBOL(<fs_co_rule>).
      DATA(ls_relevance) = VALUE #( lt_co_rule_relevance[ chargeout_method = <fs_co_rule>-ChargeoutMethod ] OPTIONAL ).

      <fs_co_rule>-HideCostVersion        = COND #( WHEN ls_relevance-cost_version         = abap_true THEN abap_false ELSE abap_true ).
      <fs_co_rule>-HideCapacityVersion    = COND #( WHEN ls_relevance-capacity_version     = abap_true THEN abap_false ELSE abap_true ).
      <fs_co_rule>-HideConsumptionVersion = COND #( WHEN ls_relevance-consumption_version  = abap_true THEN abap_false ELSE abap_true ).
      <fs_co_rule>-HideKeyVersion         = COND #( WHEN ls_relevance-key_version          = abap_true THEN abap_false ELSE abap_true ).
      <fs_co_rule>-HideUom                = COND #( WHEN ls_relevance-uom                  = abap_true THEN abap_false ELSE abap_true ).
      <fs_co_rule>-HideAdhocAllocationKey = COND #( WHEN ls_relevance-adhoc_allocation_key = abap_true THEN abap_false ELSE abap_true ).
      <fs_co_rule>-HideWeightageTab       = COND #( WHEN ls_relevance-weightage_tab        = abap_true THEN abap_false ELSE abap_true ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
