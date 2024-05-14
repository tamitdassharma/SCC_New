@EndUserText.label: 'Cost Element Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_CostEle_S
  as select from I_Language
    left outer join /ESRCC/COSTELE on 0 = 0
  composition [0..*] of /ESRCC/I_CostEle as _CostElement
{
  key 1 as SingletonID,
  _CostElement,
  max( /ESRCC/COSTELE.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
