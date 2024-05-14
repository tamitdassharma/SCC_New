@EndUserText.label: 'Cost Center Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_CosCen_S
  as select from I_Language
    left outer join /ESRCC/COSCEN on 0 = 0
  composition [0..*] of /ESRCC/I_CosCen as _CostCenter
{
  key 1 as SingletonID,
  _CostCenter,
  max( /ESRCC/COSCEN.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
