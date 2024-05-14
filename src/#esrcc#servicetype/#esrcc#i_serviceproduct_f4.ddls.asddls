@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service Product'
@Metadata.ignorePropagatedAnnotations: true

@Search.searchable: true
define view entity /ESRCC/I_SERVICEPRODUCT_F4
  as select from /esrcc/srvpro as srvpro
  association [0..1] to /esrcc/srvprot as srvprot on  srvpro.serviceproduct = srvprot.serviceproduct
                                                  and srvprot.spras         = $session.system_language
{
      @ObjectModel.text: { element: ['Description'] }
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @UI.textArrangement: #TEXT_LAST
  key serviceproduct      as ServiceProduct,

      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.filter.hidden: true
      srvprot.description as Description
}
