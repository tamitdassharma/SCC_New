@EndUserText.label: 'Mapping Cost Element'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_SrvCeleM
  as select from /esrcc/srvcelem
  association        to parent /ESRCC/I_SrvCeleM_S     as _CostElementToLeAll on  $projection.SingletonID = _CostElementToLeAll.SingletonID
  association [0..1] to /ESRCC/I_SystemInformationText as _SystemInfoText     on  _SystemInfoText.SystemId = $projection.Sysid
                                                                              and _SystemInfoText.Spras    = $session.system_language
  association [0..1] to /ESRCC/I_LEGALENTITY_F4        as _LeText             on  _LeText.Legalentity = $projection.Legalentity
  association [0..1] to /ESRCC/I_COMPANYCODES_F4       as _CcodeText          on  _CcodeText.Sysid = $projection.Sysid
                                                                              and _CcodeText.Ccode = $projection.Ccode
  association [0..1] to /ESRCC/I_COSTELEMENT_F4        as _CostElementText    on  _CostElementText.Sysid       = $projection.Sysid
                                                                              and _CostElementText.Costelement = $projection.Costelement
  association [0..1] to /ESRCC/I_COSTTYPE              as _CostTypeText       on  _CostTypeText.Costtype = $projection.Costtype
  association [0..1] to /ESRCC/I_POSTINGTYPE           as _PostingTypeText    on  _PostingTypeText.Postingtype = $projection.Postingtype
  association [0..1] to /ESRCC/I_COSTIND               as _CostIndText        on  _CostIndText.costind = $projection.Costind
  association [0..1] to /ESRCC/I_USAGECALCULATION      as _UsageTypeText      on  _UsageTypeText.usagecal = $projection.Usagetype
{
  key legalentity           as Legalentity,
  key sysid                 as Sysid,
  key ccode                 as Ccode,
  key costelement           as Costelement,
  key valid_from            as ValidFrom,
      costtype              as Costtype,
      postingtype           as Postingtype,
      costind               as Costind,
      usagetype             as Usagetype,
      valid_to              as ValidTo,
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

      _CostElementToLeAll,
      _SystemInfoText,
      _LeText,
      _CcodeText,
      _CostElementText,
      _CostTypeText,
      _PostingTypeText,
      _CostIndText,
      _UsageTypeText
}
