@EndUserText.label: 'Service Markup - Maintain'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_SrvMkp
  as projection on /ESRCC/I_SrvMkp
{
      @ObjectModel.text.element: ['ProductDescription']
  key Serviceproduct,
  key Validfrom,
      Origcost,
      Passcost,
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
      _ProductText.Description    as ProductDescription,
      _ServiceMarkupAll : redirected to parent /ESRCC/C_SrvMkp_S
}
