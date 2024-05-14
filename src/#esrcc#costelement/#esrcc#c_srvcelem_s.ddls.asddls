@EndUserText.label: 'Mapping Cost Element Singleton - Maintai'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'SingletonID' ]
define root view entity /ESRCC/C_SrvCeleM_S
  provider contract transactional_query
  as projection on /ESRCC/I_SrvCeleM_S
{
  key SingletonID,
  LastChangedAtMax,
  TransportRequestID,
  HideTransport,
  _CostElementToLe : redirected to composition child /ESRCC/C_SrvCeleM
  
}
