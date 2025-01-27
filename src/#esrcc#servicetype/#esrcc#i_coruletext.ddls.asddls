@EndUserText.label: 'Charge out Rules Text'
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_CoRuleText
  as select from /ESRCC/CO_RULET
  association [1..1] to /ESRCC/I_CoRule_S as _RuleAll on $projection.SingletonID = _RuleAll.SingletonID
  association to parent /ESRCC/I_CoRule as _Rule on $projection.RuleId = _Rule.RuleId
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key SPRAS as Spras,
  key RULE_ID as RuleId,
  @Semantics.text: true
  DESCRIPTION as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  1 as SingletonID,
  _RuleAll,
  _Rule,
  _LanguageText
  
}
