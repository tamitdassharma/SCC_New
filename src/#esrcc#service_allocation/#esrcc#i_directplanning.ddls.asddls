@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED Direct Capacity Planning'
define root view entity /ESRCC/I_DIRECTPLANNING
  as select from /esrcc/dirplan as DirectPlanning

  association [0..1] to /ESRCC/I_SERVICEPRODUCT_F4 as _serviceproduct  on  _serviceproduct.ServiceProduct = DirectPlanning.serviceproduct

  association [0..1] to /ESRCC/I_CAPACITY_VERSION  as _capacityversion on  _capacityversion.CapacityVersion = DirectPlanning.fplv

  association        to I_UnitOfMeasureText        as _UoM             on  $projection.Uom = _UoM.UnitOfMeasure_E
                                                                       and _UoM.Language   = $session.system_language
  association        to /ESRCC/I_POPER             as _PoperText       on  _PoperText.Poper = $projection.Poper

{
  key DirectPlanning.serviceproduct as Serviceproduct,
  key ryear                         as Ryear,
  key poper                         as Poper,
  key fplv                          as Fplv,
      uom                           as Uom,
      planning                      as Planning,
      @Semantics.user.createdBy: true
      created_by                    as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                    as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by               as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at               as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at         as LocalLastChangedAt,

      //  Associations
      _serviceproduct,
      _capacityversion,
      _UoM,
      _PoperText

}
