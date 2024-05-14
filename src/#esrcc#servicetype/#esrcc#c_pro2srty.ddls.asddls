@EndUserText.label: 'Service Product Mapping - Maintain'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_Pro2SrTy
  as projection on /ESRCC/I_Pro2SrTy as ServiceProductMapping
{
      @ObjectModel.text.element: ['ServiceProductDescription']
  key Serviceproduct,
      @ObjectModel.text.element: ['ServiceTypeDescription']
      Servicetype,
      @ObjectModel.text.element: ['TransGroupDescription']
      Transactiongroup,
      CreatedBy,
      CreatedAt,
      LastChangedBy,

      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,

      @Semantics.text: true
      ServiceProductMapping._ServiceProduct.Description   as ServiceProductDescription,
      @Semantics.text: true
      ServiceProductMapping._ServiceType.Description      as ServiceTypeDescription,
      @Semantics.text: true
      ServiceProductMapping._TransactionGroup.Description as TransGroupDescription,

      _ServiceProductAll : redirected to parent /ESRCC/C_Pro2SrTy_S
}
