@EndUserText.label: 'Service Product Allocation Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_SrvAloc_S
  as select from I_Language
    left outer join /ESRCC/SRVALOC on 0 = 0
  composition [0..*] of /ESRCC/I_SrvAloc as _ServiceAllocation
{
  key 1 as SingletonID,
  _ServiceAllocation,
  max( /ESRCC/SRVALOC.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
