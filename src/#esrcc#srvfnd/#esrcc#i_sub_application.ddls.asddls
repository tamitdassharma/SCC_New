@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sub Application Type'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

@Search.searchable: true
define view entity /ESRCC/I_SUB_APPLICATION
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: '/ESRCC/SUB_APPLICATION')
{
      @ObjectModel.text.element: ['text']
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
  key value_low as SubApplication,

      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      text
}
where
  language = $session.system_language
