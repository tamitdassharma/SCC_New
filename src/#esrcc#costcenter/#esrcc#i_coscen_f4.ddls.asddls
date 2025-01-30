@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Source Cost Object and Number'
@Metadata.ignorePropagatedAnnotations: true

@Search.searchable: true
define view entity /ESRCC/I_COSCEN_F4
  as select from /esrcc/coscen
  association [0..1] to /esrcc/coscent                 as _Text            on  _Text.sysid      = $projection.Sysid
                                                                           and _Text.costcenter = $projection.Costcenter
                                                                           and _Text.costobject = $projection.Costobject
                                                                           and _Text.spras      = $session.system_language
  association [0..1] to /ESRCC/I_COSTOBJECTS           as _CostObjText     on  _CostObjText.Costobject = $projection.Costobject
  association [0..1] to /ESRCC/I_BILLINGFREQ           as _BillingFreqText on  _BillingFreqText.Billingfreq = $projection.Billfrequency
  association [0..*] to /ESRCC/I_SystemInformationText as _SystemInfoText  on  _SystemInfoText.SystemId = $projection.Sysid

{

      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @UI.lineItem: [{ position: 1 }]
      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text.association: '_SystemInfoText'
      @Consumption.filter.hidden: true
  key sysid                 as Sysid,

      @ObjectModel.text.element: [ 'CostObjectDescription' ]
      @UI.lineItem: [{ position: 2 }]
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTOBJECTS', element: 'Costobject' }}]
  key costobject            as Costobject,

      @ObjectModel.text.element: [ 'Description' ]
      @UI.lineItem: [{ position: 3 }]
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
  key costcenter            as Costcenter,

      @ObjectModel.text.element: [ 'BillfrequencyDescription' ]
      @UI.lineItem: [{ position: 4 }]
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_BILLINGFREQ', element: 'Billingfreq' }}]
      billfrequency         as Billfrequency,

      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.filter.hidden: true
      _Text.description     as Description,

      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.filter.hidden: true
      _CostObjText.text     as CostobjectDescription,

      @Semantics.text: true
      @Consumption.filter.hidden: true
      _BillingFreqText.text as BillfrequencyDescription,

      _SystemInfoText
}
