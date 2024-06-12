@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Allocation Weightage'

define view entity /ESRCC/I_AllocationWeightage
  as select from /esrcc/alloc_wgt
  association [1..1] to /ESRCC/I_SrvAloc_S         as _ServiceAllocationAll on  $projection.SingletonID = _ServiceAllocationAll.SingletonID
  association        to parent /ESRCC/I_SrvAloc    as _ServiceAllocation    on  $projection.Serviceproduct = _ServiceAllocation.Serviceproduct
                                                                            and $projection.CostVersion    = _ServiceAllocation.CostVersion
                                                                            and $projection.ValidfromAlloc = _ServiceAllocation.Validfrom
  association [0..1] to /ESRCC/I_SERVICEPRODUCT_F4 as _ProductText          on  _ProductText.ServiceProduct = $projection.Serviceproduct
  association [0..1] to /ESRCC/I_COST_VERSION      as _CostVersionText      on  _CostVersionText.CostVersion = $projection.CostVersion
  association [0..1] to /ESRCC/I_ALLOCATION_KEY_F4 as _AllocKeyText         on  _AllocKeyText.Allocationkey = $projection.Allockey
//  association [0..1] to /ESRCC/I_ALLOCATIONTYPE    as _AllocTypeText        on  _AllocTypeText.AllocType = $projection.alloctype
  association [0..1] to /ESRCC/I_ALLOCATIONPERIOD  as _AllocPeriodText      on  _AllocPeriodText.AllocationPeriod = $projection.AllocationPeriod

{
  key serviceproduct             as Serviceproduct,
  key cost_version               as CostVersion,
  key validfrom_alloc            as ValidfromAlloc,
  key allockey                   as Allockey,
//  key allockeytype               as AllocType,
      allocation_period          as AllocationPeriod,
      ref_period                 as RefPeriod,
      weightage                  as Weightage,
      _ServiceAllocation.Validto as ValidtoAlloc,
      @Semantics.user.createdBy: true
      created_by                 as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                 as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by            as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at            as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at      as LocalLastChangedAt,
      1                          as SingletonID,
      _ServiceAllocationAll,
      _ServiceAllocation,
      _ProductText,
      _CostVersionText,
      _AllocKeyText,
//      _AllocTypeText,
      _AllocPeriodText
}
