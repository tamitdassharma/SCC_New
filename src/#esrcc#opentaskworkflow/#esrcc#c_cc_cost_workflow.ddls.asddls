@EndUserText.label: 'Cost Center Chargeout'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity /ESRCC/C_CC_COST_WORKFLOW 
provider contract transactional_query
as projection on /ESRCC/I_CC_COST
{
    @ObjectModel.text.element: [ 'costdatasetdescription' ]
    
    key Fplv,
    
    key Ryear,
    
    key Poper,
    
    key Sysid,
    
    @ObjectModel.text.element: [ 'legalentitydescription' ]
    key Legalentity,
    
    @ObjectModel.text.element: [ 'ccodedescription' ]
    key Ccode,
    
    @ObjectModel.text.element: [ 'costobjectdescription' ]
    key Costobject,
    
    @ObjectModel.text.element: [ 'costcenterdescription' ]
    key Costcenter,
    key Currencytype,
    
    @ObjectModel.text.element: [ 'billingfrequencydescription' ]
    Billingfrequqncy,
    
    @ObjectModel.text.element: [ 'businessdescription' ]
    Businessdivision,
    
    @ObjectModel.text.element: [ 'profitcenterdescription' ]
    Profitcenter,
    
    Controllingarea, 
//       
    @ObjectModel.text.element: [ 'billingperioddescription' ]
    Billingperiod,
    
    Currency,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Totalcost,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Excludedtotalcost,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Includetotalcost,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Origtotalcost,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Passtotalcost,
    
//    @Semantics.amount.currencyCode: 'Currency'
    Stewardship,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Remainingcostbase,
    
    @ObjectModel.text.element: [ 'statusdescription' ]
    Status,
    Workflowid, 
    @Semantics.text: true  
    ccodedescription,
    @Semantics.text: true 
    legalentitydescription,
    @Semantics.text: true 
    costobjectdescription,
    @Semantics.text: true 
    costcenterdescription,
    @Semantics.text: true 
    costdatasetdescription,
    @Semantics.text: true 
    businessdescription,
    @Semantics.text: true 
    profitcenterdescription,
    @Semantics.text: true 
    billingfrequencydescription,
    @Semantics.text: true 
    billingperioddescription,
    @Semantics.text: true 
    statusdescription,
    @ObjectModel.text.element: [ 'countryname' ]
    Country,
//    statuscriticallity,
    
    CreatedBy,
    
    CreatedAt,
    
    LastChangedBy,
    
    LastChangedAt,
    @Semantics.text: true 
    _legalCountryText.CountryName as countryname
    
}
