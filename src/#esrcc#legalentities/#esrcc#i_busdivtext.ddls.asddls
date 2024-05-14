@EndUserText.label: 'Business Division Text'
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_BusDivText
  as select from /ESRCC/BUS_DIVT
  association [1..1] to /ESRCC/I_BusDiv_S as _BusinessDivisionAll on $projection.SingletonID = _BusinessDivisionAll.SingletonID
  association to parent /ESRCC/I_BusDiv as _BusinessDivision on $projection.BusinessDivision = _BusinessDivision.BusinessDivison
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key SPRAS as Spras,
  key BUSINESS_DIVISION as BusinessDivision,
  @Semantics.text: true
  DESCRIPTION as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  1 as SingletonID,
  _BusinessDivisionAll,
  _BusinessDivision,
  _LanguageText
  
}
