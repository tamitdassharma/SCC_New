@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Service Parameter'

define view entity /ESRCC/I_ServiceParameter
  as select from /esrcc/srvprrec

  association [1..1] to /ESRCC/I_LeCctr_S              as _LeToCostcenterAll on  $projection.SingletonID = _LeToCostcenterAll.SingletonID
  association        to parent /ESRCC/I_LeCctr         as _LeToCostcenter    on  $projection.Legalentity  = _LeToCostcenter.Legalentity
                                                                             and $projection.Sysid        = _LeToCostcenter.Sysid
                                                                             and $projection.Ccode        = _LeToCostcenter.Ccode
                                                                             and $projection.Costobject   = _LeToCostcenter.Costobject
                                                                             and $projection.Costcenter   = _LeToCostcenter.Costcenter
                                                                             and $projection.CostcenterVf = _LeToCostcenter.Validfrom

  association [0..1] to /ESRCC/I_SystemInformationText as _SystemInfoText    on  _SystemInfoText.SystemId = $projection.Sysid
                                                                             and _SystemInfoText.Spras    = $session.system_language
  association        to /ESRCC/C_SrvPro                as _Product           on  _Product.Serviceproduct = $projection.Serviceproduct
  association [0..1] to /ESRCC/I_LEGALENTITY_F4        as _LeText            on  _LeText.Legalentity = $projection.Legalentity
  association [0..1] to /ESRCC/I_COMPANYCODES_F4       as _CcodeText         on  _CcodeText.Sysid = $projection.Sysid
                                                                             and _CcodeText.Ccode = $projection.Ccode
  association [0..1] to /ESRCC/I_COSTOBJECTS           as _CostObjText       on  _CostObjText.Costobject = $projection.Costobject
  association [0..1] to /ESRCC/I_COSCEN_F4             as _CostCenterText    on  _CostCenterText.Sysid      = $projection.Sysid
                                                                             and _CostCenterText.Costcenter = $projection.Costcenter
                                                                             and _CostCenterText.Costobject = $projection.Costobject
  association [0..1] to /ESRCC/I_SERVICEPRODUCT_F4     as _ServProdText      on  _ServProdText.ServiceProduct = $projection.Serviceproduct
{
  key legalentity           as Legalentity,
  key sysid                 as Sysid,
  key ccode                 as Ccode,
  key costobject            as Costobject,
  key costcenter            as Costcenter,
  key serviceproduct        as Serviceproduct,
  key costcenter_vf         as CostcenterVf,
  key validfrom             as Validfrom,
      validto               as Validto,
      costshare             as Costshare,
      erpsalesorder         as Erpsalesorder,
      contractid            as Contractid,
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
      _SystemInfoText,
      _LeText,
      _CcodeText,
      _CostObjText,
      _CostCenterText,
      _ServProdText,
      _LeToCostcenterAll,
      _LeToCostcenter,
      _Product
}
