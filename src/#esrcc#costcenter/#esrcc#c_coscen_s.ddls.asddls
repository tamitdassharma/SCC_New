@EndUserText.label: 'Cost Center Singleton - Maintain'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_CosCen_S
  provider contract transactional_query
  as projection on /ESRCC/I_CosCen_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _CostCenter : redirected to composition child /ESRCC/C_CosCen
  
}
