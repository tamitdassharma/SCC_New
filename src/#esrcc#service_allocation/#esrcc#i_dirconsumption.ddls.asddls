@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Direct Consumption'

define view entity /ESRCC/I_DIRCONSUMPTION
  as select from /esrcc/consumptn as cons
   association [0..1] to /esrcc/cst_objct as cb
    on cb.cost_object_uuid = $projection.CostObjectUuid
{
  key cons.direct_allocation_uuid as DirectAllocationUuid,
  key cons.cost_object_uuid as CostObjectUuid,  
      cons.fplv as Fplv,
      cons.ryear as Ryear,
      cons.poper as Poper,
      cons.service_product as ServiceProduct,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      cons.consumption,
      cons.uom,
            
      cb.sysid as ReceiverSysId,
      cb.company_code as ReceiverCompanyCode,
      cb.legal_entity as ReceivingEntity,
      cb.cost_object as ReceiverCostObject,
      cb.cost_center as ReceiverCostCenter,
      cb.profit_center as ReceiverProfitCenter,
      cb.functional_area as ReceiverFunctionalArea,
      cb.business_division as ReceiverBusinessDivision,
      cb.billing_frequency as ReceiverBillingFrequency

}
