@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Stewardship Products for BC Config (Draft & Persisted)'
@Metadata.ignorePropagatedAnnotations: true

define view entity /ESRCC/I_StwshipPrd_PD
  as select distinct from /esrcc/stwd_sp
{
  key service_product  as ServiceProduct,
      stewardship_uuid as StewardshipUuid

}

union select distinct from /esrcc/d_stwd_sp
{
  key serviceproduct as ServiceProduct,
      stewardshipuuid as StewardshipUuid
}
