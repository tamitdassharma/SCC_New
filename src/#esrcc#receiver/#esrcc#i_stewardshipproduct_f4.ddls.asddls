@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Stewardship Products'
@Metadata.ignorePropagatedAnnotations: true

@Search.searchable: true
define view entity /ESRCC/I_StewardshipProduct_F4
  as select distinct from /ESRCC/I_StwshipPrd_PD
  association [0..1] to /esrcc/srvprot as srvprot on  $projection.ServiceProduct = srvprot.serviceproduct
                                                  and srvprot.spras              = $session.system_language
{
      @ObjectModel.text: { element: ['Description'] }
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @UI.textArrangement: #TEXT_LAST
  key ServiceProduct,

      @UI.hidden: true
      StewardshipUuid,

      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.filter.hidden: true
      srvprot.description as Description
}
