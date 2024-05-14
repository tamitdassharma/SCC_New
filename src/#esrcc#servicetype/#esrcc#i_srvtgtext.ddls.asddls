@EndUserText.label: 'Service Transaction group Text'
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_SrvTgText
  as select from /ESRCC/TGT
  association [1..1] to /ESRCC/I_SrvTg_S as _TransactionGrpAll on $projection.SingletonID = _TransactionGrpAll.SingletonID
  association to parent /ESRCC/I_SrvTg as _TransactionGrp on $projection.Transactiongroup = _TransactionGrp.Transactiongroup
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key SPRAS as Spras,
  key TRANSACTIONGROUP as Transactiongroup,
  @Semantics.text: true
  DESCRIPTION as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  1 as SingletonID,
  _TransactionGrpAll,
  _TransactionGrp,
  _LanguageText
  
}
