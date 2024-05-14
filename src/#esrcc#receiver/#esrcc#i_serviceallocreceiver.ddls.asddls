@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service Allocation Receivers'

define view entity /ESRCC/I_ServiceAllocReceiver
  as select from /esrcc/srv_pr_le
  association [1..1] to /ESRCC/I_LeCctr_S              as _LeToCostCenterAll on  $projection.SingletonID = _LeToCostCenterAll.SingletonID
  association        to parent /ESRCC/I_LeCctr         as _LeToCostCenter    on  _LeToCostCenter.Sysid       = $projection.Sysid
                                                                             and _LeToCostCenter.Ccode       = $projection.Ccode
                                                                             and _LeToCostCenter.Legalentity = $projection.Legalentity
                                                                             and _LeToCostCenter.Costobject  = $projection.Costobject
                                                                             and _LeToCostCenter.Costcenter  = $projection.Costcenter
                                                                             and _LeToCostCenter.Validfrom   = $projection.CcValidfrom
  association [0..1] to /ESRCC/I_SystemInformationText as _SystemInfoText    on  _SystemInfoText.SystemId = $projection.Sysid
                                                                             and _SystemInfoText.Spras    = $session.system_language
  association [0..1] to /ESRCC/I_SERVICEPRODUCT_F4     as _ProductText       on  _ProductText.ServiceProduct = $projection.Serviceproduct
  association [0..1] to /ESRCC/I_LegalEntityAll_F4     as _LeText            on  _LeText.Legalentity = $projection.Legalentity
  association [0..1] to /ESRCC/I_RECEIVINGENTITY_F4    as _ReceiverText      on  _ReceiverText.Receivingentity = $projection.Receivingentity
{
  key sysid                   as Sysid,
  key ccode                   as Ccode,
  key legalentity             as Legalentity,
  key costobject              as Costobject,
  key costcenter              as Costcenter,
  key serviceproduct          as Serviceproduct,
  key cc_validfrom            as CcValidfrom,
  key receivingentity         as Receivingentity,

      active                  as Active,
      _LeToCostCenter.Validto as CcValidto,
      @Semantics.user.createdBy: true
      created_by              as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at              as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by         as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at         as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at   as LocalLastChangedAt,
      1                       as SingletonID,
      _LeToCostCenterAll,
      _LeToCostCenter,
      _SystemInfoText,
      _ProductText,
      _LeText,
      _ReceiverText
}
