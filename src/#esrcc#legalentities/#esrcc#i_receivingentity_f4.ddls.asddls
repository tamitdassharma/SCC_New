@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service Receiver'

@Search.searchable: true
define view entity /ESRCC/I_RECEIVINGENTITY_F4
  as select from /ESRCC/I_LegalEntityAll_F4
{
  key Legalentity as Receivingentity,
      Entitytype,
      Role,
      LocalCurr,
      Region,
      Country,

      Description,
      RegionDesc,
      RoleDesc,
      EntitytypeDesc,
      CountryName,
      CurrencyName,

      _CountryText,
      _CurrencyText
}
where
     Role = 'R2'
  or Role = 'R3'
  or Role = 'R4'
