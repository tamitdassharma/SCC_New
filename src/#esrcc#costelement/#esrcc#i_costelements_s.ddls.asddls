@EndUserText.label: 'Cost elements Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_CostElements_S
  as select from I_Language
    left outer join /ESRCC/CST_ELMNT on 0 = 0
  composition [0..*] of /ESRCC/I_CostElements as _CostElements
{
  key 1 as SingletonID,
  _CostElements,
  max( /ESRCC/CST_ELMNT.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
