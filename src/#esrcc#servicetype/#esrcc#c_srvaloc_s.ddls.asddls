@EndUserText.label: 'Service Product Allocation Singleton - M'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_SrvAloc_S
  provider contract transactional_query
  as projection on /ESRCC/I_SrvAloc_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _ServiceAllocation : redirected to composition child /ESRCC/C_SrvAloc
  
}
