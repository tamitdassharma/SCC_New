@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED Direct Allocation'
define root view entity /ESRCC/I_DIRECTALLOCATION
  as select from /esrcc/diralloc as DirectAllocation

  association [0..1] to /ESRCC/I_SERVICEPRODUCT_F4   as _ServiceProductText on  $projection.Serviceproduct = _ServiceProductText.ServiceProduct
  association [0..1] to /ESRCC/I_LegalEntityAll_F4   as _ReceiverText       on  $projection.Receivingentity = _ReceiverText.Legalentity
  association [0..1] to /ESRCC/I_CONSUMPTION_VERSION as _ConsumptionText    on  $projection.Fplv = _ConsumptionText.ConsumptionVersion
  association        to I_UnitOfMeasureText          as _UoM                on  $projection.uom = _UoM.UnitOfMeasure_E
                                                                            and _UoM.Language   = $session.system_language
  association        to /ESRCC/I_POPER               as _PoperText          on  _PoperText.Poper = $projection.Poper
{
  key serviceproduct        as Serviceproduct,
  key ryear                 as Ryear,
  key poper                 as Poper,
  key receivingentity       as Receivingentity,
  key fplv                  as Fplv,
      consumption           as Consumption,
      uom,
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

      _ServiceProductText,
      _ReceiverText,
      _ConsumptionText,
      _UoM,
      _PoperText

}
