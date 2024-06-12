@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Allocation Weightage'
@Metadata.allowExtensions: true

define view entity /ESRCC/C_AllocationWeightage
  as projection on /ESRCC/I_AllocationWeightage
{
      @ObjectModel.text.element: ['ServiceProductDescription']
  key Serviceproduct,
      @ObjectModel.text.element: ['CostVersionDescription']
  key CostVersion,
  key ValidfromAlloc,
      @ObjectModel.text.element: ['AllocationKeyDescription']
  key Allockey,
//      @ObjectModel.text.element: ['AllocationTypeDescription']
//  key AllocType,
      @ObjectModel.text.element: ['AllocationPeriodDescription']
      AllocationPeriod,
      RefPeriod,
      Weightage,
      @Consumption.hidden: true
      ValidtoAlloc,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,
      @Semantics.text: true
      _ProductText.Description    as ServiceProductDescription,
      @Semantics.text: true
      _CostVersionText.text       as CostVersionDescription,
      @Semantics.text: true
      _AllocKeyText.AllocationKeyDescription,
//      @Semantics.text: true
//      _AllocTypeText.text         as AllocationTypeDescription,
      @Semantics.text: true
      _AllocPeriodText.text       as AllocationPeriodDescription,
      /* Associations */
      _ServiceAllocation    : redirected to parent /ESRCC/C_SrvAloc,
      _ServiceAllocationAll : redirected to /ESRCC/C_SrvAloc_S
}
