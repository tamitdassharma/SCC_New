@EndUserText.label: 'Cost Object Text'
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_CstObjctText
  as select from /ESRCC/CST_OBJTT
  association [1..1] to /ESRCC/I_CstObjct_S as _CostObjectAll on $projection.SingletonID = _CostObjectAll.SingletonID
  association to parent /ESRCC/I_CstObjct as _CostObject on $projection.CostObjectUuid = _CostObject.CostObjectUuid
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key SPRAS as Spras,
  key COST_OBJECT_UUID as CostObjectUuid,
  @Semantics.text: true
  DESCRIPTION as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  1 as SingletonID,
  _CostObjectAll,
  _CostObject,
  _LanguageText
  
}
