@EndUserText.label: 'Cost Center Text'
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.dataCategory: #TEXT
define view entity /ESRCC/I_CosCenText
  as select from /esrcc/coscent
  association [1..1] to /ESRCC/I_CosCen_S      as _CostCenterAll on  $projection.SingletonID = _CostCenterAll.SingletonID
  association        to parent /ESRCC/I_CosCen as _CostCenter    on  $projection.Sysid      = _CostCenter.Sysid
                                                                 and $projection.Costcenter = _CostCenter.Costcenter
                                                                 and $projection.Costobject = _CostCenter.Costobject
  association [0..*] to I_LanguageText         as _LanguageText  on  $projection.Spras = _LanguageText.LanguageCode
{
      @Semantics.language: true
  key spras                 as Spras,
  key sysid                 as Sysid,
  key costcenter            as Costcenter,
  key costobject            as Costobject,
      @Semantics.text: true
      description           as Description,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      1                     as SingletonID,
      _CostCenterAll,
      _CostCenter,
      _LanguageText

}
