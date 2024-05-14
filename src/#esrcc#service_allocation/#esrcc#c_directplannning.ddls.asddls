@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for planning'
//@ObjectModel.semanticKey: [ 'Serviceproduct', 'Ryear', 'Poper', 'Fplv' ]
define root view entity /ESRCC/C_DIRECTPLANNNING
  provider contract transactional_query
  as projection on /ESRCC/I_DIRECTPLANNING
{
      @ObjectModel.text.element: [ 'serviceproductdescription' ]
  key Serviceproduct,
  key Ryear,
      @ObjectModel.text.element: [ 'PoperDescription' ]
  key Poper,
      @ObjectModel.text.element: [ 'capacitydescription' ]
  key Fplv,
      @ObjectModel.text.element: [ 'UnitOfMeasureName' ]
      Uom,
      Planning,
      CreatedAt,
      CreatedBy,
      LastChangedAt,
      LastChangedBy,
      LocalLastChangedAt,
      @Semantics.text: true
      _serviceproduct.Description as serviceproductdescription,
      @Semantics.text: true
      _capacityversion.text       as capacitydescription,
      @Semantics.text: true
      _UoM.UnitOfMeasureName,
      @Semantics.text: true
      _PoperText.text             as PoperDescription
}
