@EndUserText.label: 'Service Product Allocation - Maintain'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_SrvAloc
  as projection on /ESRCC/I_SrvAloc
{
      @ObjectModel.text.element: ['ServiceProductDescription']
  key Serviceproduct,
      @ObjectModel.text.element: ['CostVersionDescription']
  key CostVersion,
  key Validfrom,
      @ObjectModel.text.element: ['ChargeoutDescription']
      Chargeout,
      @ObjectModel.text.element: ['UomDescription']
      Uom,
      @ObjectModel.text.element: ['CapacityVersionDescription']
      CapacityVersion,
      @ObjectModel.text.element: ['ConsumptionVersionDescription']
      ConsumptionVersion,
      @ObjectModel.text.element: ['KeyVersionDescription']
      KeyVersion,
      Validto,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,
      @Semantics.text: true
      _ProductText.Description     as ServiceProductDescription,
      @Semantics.text: true
      _ChargeOut.text              as ChargeoutDescription,
      @Semantics.text: true
      _UoM.UnitOfMeasureLongName   as UomDescription,
      @Semantics.text: true
      _CapacityVersionText.text    as CapacityVersionDescription,
      @Semantics.text: true
      _ConsumptionVersionText.text as ConsumptionVersionDescription,
      @Semantics.text: true
      _CostVersionText.text        as CostVersionDescription,
      @Semantics.text: true
      _KeyVersionText.text         as KeyVersionDescription,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:/ESRCC/CL_CONFIG_VE_HANDLER'
      HideVersion,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:/ESRCC/CL_CONFIG_VE_HANDLER'
      HideWeightage,
      _ServiceAllocatioAll : redirected to parent /ESRCC/C_SrvAloc_S,
      _Weightage           : redirected to composition child /ESRCC/C_AllocationWeightage
}
