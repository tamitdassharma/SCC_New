@EndUserText.label: 'Charge out Rules Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_CoRule_S
  as select from I_Language
    left outer join /ESRCC/CO_RULE on 0 = 0
  composition [0..*] of /ESRCC/I_CoRule as _Rule
{
  key 1 as SingletonID,
  _Rule,
  max( /ESRCC/CO_RULE.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
