@EndUserText.label: 'Cost Element Text'
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_CostEleText
  as select from /esrcc/costelet
  association [1..1] to /ESRCC/I_CostEle_S      as _CostElementAll on  $projection.SingletonID = _CostElementAll.SingletonID
  association        to parent /ESRCC/I_CostEle as _CostElement    on  $projection.Sysid       = _CostElement.sysid
                                                                   and $projection.Costelement = _CostElement.Costelement
  association [0..*] to I_LanguageText          as _LanguageText   on  $projection.Spras = _LanguageText.LanguageCode
{
      @Semantics.language: true
  key spras                 as Spras,
  key sysid                 as Sysid,
  key costelement           as Costelement,
      @Semantics.text: true
      description           as Description,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      1                     as SingletonID,
      _CostElementAll,
      _CostElement,
      _LanguageText

}
