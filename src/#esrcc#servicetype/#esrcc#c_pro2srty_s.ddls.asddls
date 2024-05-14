@EndUserText.label: 'Service Product Mapping Singleton - Main'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_Pro2SrTy_S
  provider contract transactional_query
  as projection on /ESRCC/I_Pro2SrTy_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _ServiceProduct : redirected to composition child /ESRCC/C_Pro2SrTy
  
}
