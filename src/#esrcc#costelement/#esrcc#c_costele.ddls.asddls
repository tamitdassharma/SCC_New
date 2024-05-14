@EndUserText.label: 'Cost Element - Maintain'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_CostEle
  as projection on /ESRCC/I_CostEle
{
      @ObjectModel.text.element: ['SysidDescription']
  key Sysid,
  key Costelement,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,
      _CostElementAll  : redirected to parent /ESRCC/C_CostEle_S,
      _CostElementText : redirected to composition child /ESRCC/C_CostEleText,
      _CostElementText.Description : localized,
      @Semantics.text: true
      _SystemInfoText.Description as SysidDescription

}
