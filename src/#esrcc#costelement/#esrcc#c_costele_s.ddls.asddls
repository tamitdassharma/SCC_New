@EndUserText.label: 'Cost Element Singleton - Maintain'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_CostEle_S
  provider contract transactional_query
  as projection on /ESRCC/I_CostEle_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _CostElement : redirected to composition child /ESRCC/C_CostEle
  
}
