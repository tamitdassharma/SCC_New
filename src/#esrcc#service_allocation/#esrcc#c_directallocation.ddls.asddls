@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for Direct Allocation'
//@ObjectModel.semanticKey: [ 'Serviceproduct', 'Ryear', 'Poper', 'Receivingentity', 'Fplv' ]
define root view entity /ESRCC/C_DIRECTALLOCATION
  provider contract transactional_query
  as projection on /ESRCC/I_DIRECTALLOCATION
{
      @ObjectModel.text.element: ['ServiceproductDescription']
  key Serviceproduct,
  key Ryear,
      @ObjectModel.text.element: [ 'PoperDescription' ]
  key Poper,
      @ObjectModel.text.element: ['ReceivingentityDescription']
  key Receivingentity,
      @ObjectModel.text.element: ['FplvDescription']
  key Fplv,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      Consumption,
      uom,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Semantics.text: true
      _ServiceProductText.Description as ServiceproductDescription,
      @Semantics.text: true
      _ReceiverText.Description       as ReceivingentityDescription,
      @Semantics.text: true
      _ConsumptionText.text           as FplvDescription,
      @Semantics.text: true
      _UoM.UnitOfMeasureLongName      as UomDescription,
      @Semantics.text: true
      _PoperText.text                 as PoperDescription
}
