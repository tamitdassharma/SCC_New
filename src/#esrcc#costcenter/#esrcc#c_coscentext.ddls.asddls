@EndUserText.label: 'Cost Center Text - Maintain'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_CosCenText
  as projection on /ESRCC/I_CosCenText
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
  key Costcenter,
  key Costobject,
      Description,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,
      _LanguageText.LanguageName : localized,
      _CostCenter    : redirected to parent /ESRCC/C_CosCen,
      _CostCenterAll : redirected to /ESRCC/C_CosCen_S

}
