@EndUserText.label: 'Cost Center to LE Mapping'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_LeCctr
  as select from /esrcc/le_cctr
  association        to parent /ESRCC/I_LeCctr_S       as _LeToCostCenterAll    on  $projection.SingletonID = _LeToCostCenterAll.SingletonID
  association [0..1] to /ESRCC/I_SystemInformationText as _SysInfoText          on  _SysInfoText.SystemId = $projection.Sysid
                                                                                and _SysInfoText.Spras    = $session.system_language
  association [0..1] to /ESRCC/I_LEGALENTITY_F4        as _LeText               on  _LeText.Legalentity = $projection.Legalentity
  association [0..1] to /ESRCC/I_COMPANYCODES_F4       as _CcodeText            on  _CcodeText.Sysid = $projection.Sysid
                                                                                and _CcodeText.Ccode = $projection.Ccode
  association [0..1] to /ESRCC/I_COSTOBJECTS           as _CostObjText          on  _CostObjText.Costobject = $projection.Costobject
  association [0..1] to /ESRCC/I_COSCEN_F4             as _CosCenText           on  _CosCenText.Sysid      = $projection.Sysid
                                                                                and _CosCenText.Costcenter = $projection.Costcenter
                                                                                and _CosCenText.Costobject = $projection.Costobject
  association [0..1] to /ESRCC/I_PROFITCENTER_F4       as _ProfitCenterText     on  _ProfitCenterText.ProfitCenter = $projection.Profitcenter
  association [0..1] to /ESRCC/I_BUSINESSDIV_F4        as _BusinessDivisionText on  _BusinessDivisionText.BusinessDivision = $projection.Businessdivision

  composition [0..*] of /ESRCC/I_ServiceParameter      as _ServiceParameter
  composition [0..*] of /ESRCC/I_ServiceAllocReceiver  as _ServiceReceiver
{
  key legalentity           as Legalentity,
  key sysid                 as Sysid,
  key ccode                 as Ccode,
  key costobject            as Costobject,
  key costcenter            as Costcenter,
  key validfrom             as Validfrom,
      validto               as Validto,
      profitcenter          as Profitcenter,
      businessdivision      as Businessdivision,
      stewardship           as Stewardship,
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
      _LeToCostCenterAll,

      _SysInfoText,
      _LeText,
      _CcodeText,
      _CostObjText,
      _CosCenText,
      _ProfitCenterText,
      _BusinessDivisionText,
      _ServiceParameter,
      _ServiceReceiver
}
