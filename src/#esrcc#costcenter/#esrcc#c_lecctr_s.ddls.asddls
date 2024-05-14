@EndUserText.label: 'Cost Center to LE Mapping Singleton - Ma'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_LeCctr_S
  provider contract transactional_query
  as projection on /ESRCC/I_LeCctr_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _LeToCostCenter : redirected to composition child /ESRCC/C_LeCctr
  
}
