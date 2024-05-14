@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Cost Center'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

@Search.searchable: true
define view entity /ESRCC/I_COSNUMBER_F4
  as select from /esrcc/coscen as coscen
  association [0..1] to /esrcc/coscent                 as _Text            on  _Text.sysid      = coscen.sysid
                                                                           and _Text.costcenter = coscen.costcenter
                                                                           and _Text.costobject = coscen.costobject
                                                                           and _Text.spras      = $session.system_language
  

{
      @ObjectModel.text.element: [ 'Description' ]
      @UI.lineItem: [{ position: 3 }]
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
  key costcenter            as Costcenter,
  
      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.filter.hidden: true
      _Text.description     as Description
}
