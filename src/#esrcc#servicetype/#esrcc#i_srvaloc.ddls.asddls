@EndUserText.label: 'Service Product Allocation'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_SrvAloc
  as select from /esrcc/srvaloc
  association        to parent /ESRCC/I_SrvAloc_S    as _ServiceAllocatioAll    on  $projection.SingletonID = _ServiceAllocatioAll.SingletonID
  association [0..1] to /ESRCC/I_SERVICEPRODUCT_F4   as _ProductText            on  _ProductText.ServiceProduct = $projection.Serviceproduct
  association        to /ESRCC/I_CHGOUT              as _ChargeOut              on  _ChargeOut.Chargeout = $projection.Chargeout
  association        to I_UnitOfMeasureText          as _UoM                    on  _UoM.UnitOfMeasure_E = $projection.Uom
                                                                                and _UoM.Language        = $session.system_language
  association [0..1] to /ESRCC/I_CAPACITY_VERSION    as _CapacityVersionText    on  _CapacityVersionText.CapacityVersion = $projection.CapacityVersion
  association [0..1] to /ESRCC/I_COST_VERSION        as _CostVersionText        on  _CostVersionText.CostVersion = $projection.CostVersion
  association [0..1] to /ESRCC/I_CONSUMPTION_VERSION as _ConsumptionVersionText on  _ConsumptionVersionText.ConsumptionVersion = $projection.ConsumptionVersion
  association [0..1] to /ESRCC/I_KEY_VERSION         as _KeyVersionText         on  _KeyVersionText.KeyVersion = $projection.KeyVersion

  composition [0..*] of /ESRCC/I_AllocationWeightage as _Weightage
{
  key serviceproduct                             as Serviceproduct,
  key cost_version                               as CostVersion,
  key validfrom                                  as Validfrom,
      chargeout                                  as Chargeout,
      uom                                        as Uom,
      capacity_version                           as CapacityVersion,
      consumption_version                        as ConsumptionVersion,
      key_version                                as KeyVersion,
      validto                                    as Validto,
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
      cast( '' as abap_boolean preserving type ) as HideVersion,
      cast( '' as abap_boolean preserving type ) as HideWeightage,
      _ServiceAllocatioAll,
      _ProductText,
      _ChargeOut,
      _UoM,
      _CapacityVersionText,
      _CostVersionText,
      _ConsumptionVersionText,
      _KeyVersionText,
      _Weightage
}
