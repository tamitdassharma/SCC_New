@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Legal Entity'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true

define view entity /ESRCC/I_LegalEntityAll_F4
  as select from /esrcc/le
  association [0..1] to /esrcc/le_t         as _Text         on  _Text.legalentity = $projection.Legalentity
                                                             and _Text.spras       = $session.system_language
  association [0..1] to /ESRCC/I_REGION     as _Region       on  _Region.Region = $projection.Region
  association [0..1] to /ESRCC/I_ROLE       as _Role         on  _Role.Role = $projection.Role
  association [0..1] to /ESRCC/I_ENTITYTYPE as _EntityType   on  _EntityType.Entitytype = $projection.Entitytype
  association [0..*] to I_CurrencyText      as _CurrencyText on  _CurrencyText.Currency = $projection.LocalCurr
  association [0..*] to I_CountryText       as _CountryText  on  _CountryText.Country = $projection.Country
{
      @ObjectModel.text.element: ['Description']
      @UI.textArrangement: #TEXT_LAST
      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7, ranking: #HIGH }
  key legalentity       as Legalentity,

      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_ENTITYTYPE', element: 'Entitytype' } }]
      @ObjectModel.text.element: ['EntitytypeDesc']
      @UI.textArrangement: #TEXT_LAST
      entitytype        as Entitytype,

      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_Role', element: 'Role' } }]
      @ObjectModel.text.element: ['RoleDesc']
      @UI.textArrangement: #TEXT_LAST
      role              as Role,

      @ObjectModel.text.association: '_CurrencyText'
      @Consumption.filter.hidden: true
      @UI.textArrangement: #TEXT_LAST
      local_curr        as LocalCurr,

      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_REGION', element: 'Region' } }]
      @ObjectModel.text.element: ['RegionDesc']
      @UI.textArrangement: #TEXT_LAST
      region            as Region,
      
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_Country', element: 'Country' }, useForValidation: true } ]
      @ObjectModel.text.association: '_CountryText'
      @EndUserText.label: 'Country'
      @UI.textArrangement: #TEXT_LAST
      country           as Country,

      @Search: { defaultSearchElement: true, fuzzinessThreshold: 0.7, ranking: #MEDIUM }
      @Semantics.text: true
      @Consumption.filter.hidden: true
      _Text.description as Description,
      @Semantics.text: true
      @Consumption.filter.hidden: true
      _Region.text      as RegionDesc,
      @Semantics.text: true
      @Consumption.filter.hidden: true
      _Role.text        as RoleDesc,
      @Semantics.text: true
      @Consumption.filter.hidden: true
      _EntityType.text  as EntitytypeDesc,

      _CountryText,
      _CurrencyText
}
