@EndUserText.label: 'Cost Center'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_CosCen
  as select from /esrcc/coscen
  association        to parent /ESRCC/I_CosCen_S       as _CostCenterAll   on  $projection.SingletonID = _CostCenterAll.SingletonID
  composition [0..*] of /ESRCC/I_CosCenText            as _CostCenterText
  association [0..1] to /ESRCC/I_SystemInformationText as _SystemInfoText  on  _SystemInfoText.SystemId = $projection.Sysid
                                                                           and _SystemInfoText.Spras    = $session.system_language
  association [0..1] to /ESRCC/I_COSTOBJECTS           as _CostObjText     on  _CostObjText.Costobject = $projection.Costobject
  association [0..1] to /ESRCC/I_BILLINGFREQ           as _BillingFreqText on  _BillingFreqText.Billingfreq = $projection.Billfrequency
{
  key sysid                 as Sysid,
  key costcenter            as Costcenter,
  key costobject            as Costobject,
      billfrequency         as Billfrequency,
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
      _CostCenterAll,
      _CostCenterText,
      _SystemInfoText,
      _CostObjText,
      _BillingFreqText
}
