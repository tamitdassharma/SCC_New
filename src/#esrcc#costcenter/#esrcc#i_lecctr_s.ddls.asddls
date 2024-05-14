@EndUserText.label: 'Cost Center to LE Mapping Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity /ESRCC/I_LeCctr_S
  as select from I_Language
    left outer join /ESRCC/LE_CCTR on 0 = 0
  composition [0..*] of /ESRCC/I_LeCctr as _LeToCostCenter
{
  key 1 as SingletonID,
  _LeToCostCenter,
  max( /ESRCC/LE_CCTR.LAST_CHANGED_AT ) as LastChangedAtMax,
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
