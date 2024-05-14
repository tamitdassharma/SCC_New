@EndUserText.label: 'Mapping Cost Element Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_SrvCeleM_S
  as select from I_Language
    left outer join /ESRCC/SRVCELEM on 0 = 0
  composition [0..*] of /ESRCC/I_SrvCeleM as _CostElementToLe
{
  key 1 as SingletonID,
  _CostElementToLe,
  max( /ESRCC/SRVCELEM.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
