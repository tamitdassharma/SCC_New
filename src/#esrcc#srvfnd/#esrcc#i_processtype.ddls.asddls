@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Charge-out Process Type'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

@Search.searchable: true
define view entity /ESRCC/I_PROCESSTYPE
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: '/ESRCC/PROCESSTYPE')
{
      @ObjectModel.text.element: ['text']
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
  key value_low as ProcessType,

      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      text
}
where
  language = $session.system_language
