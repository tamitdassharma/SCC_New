@EndUserText.label: 'Service Product Mapping'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_Pro2SrTy
  as select from /esrcc/pro2srty
  association to parent /ESRCC/I_Pro2SrTy_S   as _ServiceProductAll on $projection.SingletonID = _ServiceProductAll.SingletonID
  association to /ESRCC/I_SERVICETYPE_F4      as _ServiceType       on $projection.Servicetype = _ServiceType.ServiceType
  association to /ESRCC/I_SERVICEPRODUCT_F4   as _ServiceProduct    on $projection.Serviceproduct = _ServiceProduct.ServiceProduct
  association to /ESRCC/I_TRANSACTIONGROUP_F4 as _TransactionGroup  on $projection.Transactiongroup = _TransactionGroup.Transactiongroup
{
  key serviceproduct        as Serviceproduct,
      servicetype           as Servicetype,
      transactiongroup      as Transactiongroup,
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
      _ServiceProduct,
      _ServiceType,
      _TransactionGroup

}
