@EndUserText.label: 'Service Product - Maintain'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_SrvPro
  as projection on /ESRCC/I_SrvPro
{
  key Serviceproduct,
      @ObjectModel.text.element: [ 'oecddescription' ]
      OecdTpg,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,
      _OECD.text as oecddescription,
      _ServiceProductAll  : redirected to parent /ESRCC/C_SrvPro_S,
      _ServiceProductText : redirected to composition child /ESRCC/C_SrvProText,
      _ServiceProductText.Description : localized
}
