@EndUserText.label: 'Receivers Chargeout Cost'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity /ESRCC/C_RECEIVER_WORKFLOW 
provider contract transactional_query
as projection on /ESRCC/I_RECCOST_WORKFLOW
{   
    @ObjectModel.filter.enabled: false
    key Fplv,
    @ObjectModel.filter.enabled: false
    key Ryear,
    @ObjectModel.filter.enabled: false
    key Poper,
    @ObjectModel.filter.enabled: false
    key Sysid,
    @ObjectModel.filter.enabled: false
    @ObjectModel.text.element: [ 'legalentitydescription' ]
    key Legalentity,
    @ObjectModel.filter.enabled: false
    @ObjectModel.text.element: [ 'ccodedescription' ]
    key Ccode,
    @ObjectModel.filter.enabled: false
    @ObjectModel.text.element: [ 'costobjectdescription' ]
    key Costobject,
    @ObjectModel.filter.enabled: false
    @ObjectModel.text.element: [ 'costcenterdescription' ]
    key Costcenter,
    @ObjectModel.text.element: [ 'Serviceproductdescription' ]
    key Serviceproduct,
    @ObjectModel.filter.enabled: false
    @ObjectModel.text.element: [ 'receivingentitydescription' ]
    key Receivingentity,
    key Currencytype,
    @ObjectModel.filter.enabled: false
    key Billingfrequqncy,
    @ObjectModel.filter.enabled: false
    key Billingperiod,
    Reckpi,
    @ObjectModel.filter.enabled: false
    Currency,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    onvalueaddedmarkupabs,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    onvpassthrudmarkupabs,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    totaludmarkupabs,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    totalcostbaseabs,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    valuaddabs,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    passthruabs,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    chargeoutforservice,
    Workflowid,
    @ObjectModel.filter.enabled: false
    @ObjectModel.text.element: [ 'statusdescription' ]
    Status,
    @Semantics.text: true
    legalentitydescription,
    @Semantics.text: true
    ccodedescription,
    @Semantics.text: true
    costobjectdescription,
    @Semantics.text: true
    costcenterdescription,
    @Semantics.text: true
    Serviceproductdescription,
    @Semantics.text: true
    Servicetypedescription,
    @Semantics.text: true
    statusdescription,
    @Semantics.text: true
    receivingentitydescription,
    @ObjectModel.text.element: [ 'reccountryname' ]
    receivingentitycountry,
    @ObjectModel.text.element: [ 'legalcountryname' ]
    legalentitycountry,
    @Semantics.text: true
    _ReceivingCountryText.CountryName as reccountryname,
    @Semantics.text: true
    _legalCountryText.CountryName as legalcountryname
    
}
