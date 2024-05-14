@EndUserText.label: 'Cost Center - Maintain'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_CosCen
  as projection on /ESRCC/I_CosCen
{
      @ObjectModel.text.element: ['SysidDescription']
  key Sysid,
  key Costcenter,
      @ObjectModel.text.element: ['CostobjectDescription']
  key Costobject,
      @ObjectModel.text.element: ['BillfrequencyDesc']
      Billfrequency,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,
      @Semantics.text: true
      _CostObjText.text           as CostobjectDescription,
      _SystemInfoText.Description as SysidDescription,
      _CostCenterAll  : redirected to parent /ESRCC/C_CosCen_S,
      _CostCenterText : redirected to composition child /ESRCC/C_CosCenText,
      _CostCenterText.Description : localized,
      @Semantics.text: true
      _BillingFreqText.text       as BillfrequencyDesc
}
