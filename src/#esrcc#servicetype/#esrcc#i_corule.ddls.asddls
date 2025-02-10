@EndUserText.label: 'Charge out Rules'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_CoRule
  as select from /esrcc/co_rule
  association        to parent /ESRCC/I_CoRule_S     as _RuleAll                on  $projection.SingletonID = _RuleAll.SingletonID
  association        to /ESRCC/I_CHGOUT              as _ChargeOut              on  _ChargeOut.Chargeout = $projection.ChargeoutMethod
  association        to I_UnitOfMeasureText          as _UoM                    on  _UoM.UnitOfMeasure_E = $projection.Uom
                                                                                and _UoM.Language        = $session.system_language
  association [0..1] to /ESRCC/I_CAPACITY_VERSION    as _CapacityVersionText    on  _CapacityVersionText.CapacityVersion = $projection.CapacityVersion
  association [0..1] to /ESRCC/I_COST_VERSION        as _CostVersionText        on  _CostVersionText.CostVersion = $projection.CostVersion
  association [0..1] to /ESRCC/I_CONSUMPTION_VERSION as _ConsumptionVersionText on  _ConsumptionVersionText.ConsumptionVersion = $projection.ConsumptionVersion
  association [0..1] to /ESRCC/I_KEY_VERSION         as _KeyVersionText         on  _KeyVersionText.KeyVersion = $projection.KeyVersion
  association [0..1] to /ESRCC/I_ALLOCATION_KEY_F4   as _AllocationKeyText      on  _AllocationKeyText.Allocationkey = $projection.AdhocAllocationKey
  association [1..1] to /ESRCC/I_STATUS              as _WorkflowStatusText     on  _WorkflowStatusText.Status = $projection.WorkflowStatus

  composition [0..*] of /ESRCC/I_CoRuleText          as _RuleText
  composition [0..*] of /ESRCC/I_AllocWeightage      as _Weightage
{
  key rule_id                                    as RuleId,
      cost_version                               as CostVersion,
      chargeout_method                           as ChargeoutMethod,
      capacity_version                           as CapacityVersion,
      consumption_version                        as ConsumptionVersion,
      key_version                                as KeyVersion,
      uom                                        as Uom,
      adhoc_allocation_key                       as AdhocAllocationKey,
      workflow_id                                as WorkflowId,
      workflow_status                            as WorkflowStatus,
      comments                                   as Comments,
      @Semantics.user.createdBy: true
      created_by                                 as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                                 as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by                            as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                            as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at                      as LocalLastChangedAt,
      1                                          as SingletonID,

      case workflow_status
        when 'D' then 2
        when 'P' then 2
        when 'W' then 2
        when 'U' then 3
        when 'E' then 3
        when 'A' then 3
        when 'F' then 3
        when 'R' then 1
        when 'C' then 1
        else 0
      end                                        as WorkflowStatusCriticality,
      cast('' as abap_boolean)                   as TriggerWorkflow,

      cast( '' as abap_boolean preserving type ) as HideCostVersion,
      cast( '' as abap_boolean preserving type ) as HideCapacityVersion,
      cast( '' as abap_boolean preserving type ) as HideConsumptionVersion,
      cast( '' as abap_boolean preserving type ) as HideKeyVersion,
      cast( '' as abap_boolean preserving type ) as HideUom,
      cast( '' as abap_boolean preserving type ) as HideAdhocAllocationKey,
      cast( '' as abap_boolean preserving type ) as HideWeightageTab,

      _RuleAll,
      _RuleText,
      _ChargeOut,
      _UoM,
      _CapacityVersionText,
      _CostVersionText,
      _ConsumptionVersionText,
      _KeyVersionText,
      _Weightage,
      _AllocationKeyText,
      _WorkflowStatusText

}
