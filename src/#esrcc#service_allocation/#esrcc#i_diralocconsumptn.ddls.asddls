@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED Direct alloc service consumptn'
define root view entity /ESRCC/I_DIRALOCCONSUMPTN
  as select from /esrcc/consumptn as DirectAllocationConsumption
  association [1..1] to /ESRCC/I_COSCEN_F4           as _CostCenter         on  $projection.CostObjectUuid = _CostCenter.CostObjectUuid
  association [1..1] to /ESRCC/I_COSCEN_F4           as _ProviderCostCenter on  $projection.ProviderCostObjectUuid = _ProviderCostCenter.CostObjectUuid
  association [0..1] to /ESRCC/I_SERVICEPRODUCT_F4   as _ServiceProductText on  $projection.ServiceProduct = _ServiceProductText.ServiceProduct
  association [0..1] to /ESRCC/I_CONSUMPTION_VERSION as _ConsumptionText    on  $projection.Fplv = _ConsumptionText.ConsumptionVersion
  association        to I_UnitOfMeasureText          as _UoM                on  $projection.Uom = _UoM.UnitOfMeasure_E
                                                                            and _UoM.Language   = $session.system_language
  association        to /ESRCC/I_POPER               as _PoperText          on  _PoperText.Poper = $projection.Poper
{
  key direct_allocation_uuid          as DirectAllocationUuid,
      service_product                 as ServiceProduct,
      cost_object_uuid                as CostObjectUuid,
      provider_cost_object_uuid       as ProviderCostObjectUuid,
      ryear                           as Ryear,
      poper                           as Poper,
      fplv                            as Fplv,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      consumption                     as Consumption,
      uom                             as Uom,
      _CostCenter.Sysid,
      _CostCenter.LegalEntity         as ReceivingEntity,
      _CostCenter.CompanyCode         as ReceivingCompany,
      _CostCenter.Costobject,
      _CostCenter.Costcenter,

      _ProviderCostCenter.Sysid       as ProviderSysid,
      _ProviderCostCenter.LegalEntity as ProviderEntity,
      _ProviderCostCenter.CompanyCode as ProviderCompany,
      _ProviderCostCenter.Costobject  as ProviderCostobject,
      _ProviderCostCenter.Costcenter  as ProviderCostcenter,

      @Semantics.user.createdBy: true
      created_by                      as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                      as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by                 as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                 as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at           as LocalLastChangedAt,

      _CostCenter,
      _ProviderCostCenter,
      _ServiceProductText,
      _ConsumptionText,
      _UoM,
      _PoperText
}
