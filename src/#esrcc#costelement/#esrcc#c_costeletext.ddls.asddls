@EndUserText.label: 'Cost Element Text - Maintain'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_CostEleText
  as projection on /ESRCC/I_CostEleText
{
  @ObjectModel.text.element: [ 'LanguageName' ]
  @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_Language', 
      element: 'Language'
    }
  } ]
  key Spras,
  key Sysid,
  key Costelement,
  Description,
  @Consumption.hidden: true
  LocalLastChangedAt,
  @Consumption.hidden: true
  SingletonID,
  _LanguageText.LanguageName : localized,
  _CostElement : redirected to parent /ESRCC/C_CostEle,
  _CostElementAll : redirected to /ESRCC/C_CostEle_S
  
}
