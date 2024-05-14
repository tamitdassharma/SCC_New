@EndUserText.label: 'Service Product Mapping Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_Pro2SrTy_S
  as select from I_Language
    left outer join /ESRCC/PRO2SRTY on 0 = 0
  composition [0..*] of /ESRCC/I_Pro2SrTy as _ServiceProduct
{
  key 1 as SingletonID,
  _ServiceProduct,
  max( /ESRCC/PRO2SRTY.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
