@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cost Element'
@Metadata.ignorePropagatedAnnotations: true

@Search.searchable: true
define view entity /ESRCC/I_COSTELEMENT_F4
  as select from /esrcc/costele
  association [0..1] to /esrcc/costelet                as _CostelementText on  _CostelementText.sysid       = $projection.Sysid
                                                                           and _CostelementText.costelement = $projection.Costelement
                                                                           and _CostelementText.spras       = $session.system_language
  association [0..*] to /ESRCC/I_SystemInformationText as _SystemInfoText  on  _SystemInfoText.SystemId = $projection.Sysid
{
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.filter.hidden: true
      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text.association: '_SystemInfoText'
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_SystemInformation_F4', element: 'SystemId' } }]
  key sysid                        as Sysid,

      @ObjectModel.text.element: ['costelementdescription']
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
  key costelement                  as Costelement,

      @Semantics.text: true
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7 }
      @Consumption.filter.hidden: true
      _CostelementText.description as costelementdescription,

      _SystemInfoText
}
