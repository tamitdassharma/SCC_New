@EndUserText.label: 'Service Product'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_SrvPro
  as select from /esrcc/srvpro
  association        to parent /ESRCC/I_SrvPro_S       as _ServiceProductAll on  $projection.SingletonID = _ServiceProductAll.SingletonID
  composition [0..*] of /ESRCC/I_SrvProText            as _ServiceProductText
{
  key serviceproduct        as Serviceproduct,
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
      _ServiceProductAll,
      _ServiceProductText
}
