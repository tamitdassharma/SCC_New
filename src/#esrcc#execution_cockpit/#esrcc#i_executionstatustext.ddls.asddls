@EndUserText.label: 'Execution Cockpit Status Text'
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_ExecutionStatusText
  as select from /ESRCC/EXECST_T
  association [1..1] to /ESRCC/I_ExecutionStatus_S as _ExecutionStatusAll on $projection.SingletonID = _ExecutionStatusAll.SingletonID
  association to parent /ESRCC/I_ExecutionStatus as _ExecutionStatus on $projection.Application = _ExecutionStatus.Application and $projection.Status = _ExecutionStatus.Status
  association [0..*] to I_LanguageText as _LanguageText on $projection.Spras = _LanguageText.LanguageCode
{
  @Semantics.language: true
  key SPRAS as Spras,
  key APPLICATION as Application,
  key STATUS as Status,
  @Semantics.text: true
  DESCRIPTION as Description,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  1 as SingletonID,
  _ExecutionStatusAll,
  _ExecutionStatus,
  _LanguageText
  
}
