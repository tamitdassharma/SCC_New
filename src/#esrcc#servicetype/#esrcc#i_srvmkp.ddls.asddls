@EndUserText.label: 'Service Markup'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_SrvMkp
  as select from /esrcc/srvmkp
  association        to parent /ESRCC/I_SrvMkp_S       as _ServiceMarkupAll on  $projection.SingletonID = _ServiceMarkupAll.SingletonID
  association [1..1] to /ESRCC/I_SERVICEPRODUCT_F4     as _ProductText      on  _ProductText.ServiceProduct = $projection.Serviceproduct
{
  key serviceproduct        as Serviceproduct,
  key validfrom             as Validfrom,
      origcost              as Origcost,
      passcost              as Passcost,
      validto               as Validto,
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
      _ServiceMarkupAll,
      _ProductText
}
