@EndUserText.label: 'Cost Element'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_CostEle
  as select from /esrcc/costele
  association        to parent /ESRCC/I_CostEle_S      as _CostElementAll on  $projection.SingletonID = _CostElementAll.SingletonID
  composition [0..*] of /ESRCC/I_CostEleText           as _CostElementText
  association [0..1] to /ESRCC/I_SystemInformationText as _SystemInfoText on  _SystemInfoText.SystemId = $projection.Sysid
                                                                          and _SystemInfoText.Spras    = $session.system_language
{
  key sysid                 as Sysid,
  key costelement           as Costelement,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      1                     as SingletonID,
      _CostElementAll,
      _CostElementText,
      _SystemInfoText
}
