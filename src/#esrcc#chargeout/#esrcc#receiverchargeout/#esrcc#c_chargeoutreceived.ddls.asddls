@EndUserText.label: 'Receivers Chargeout Cost'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity /ESRCC/C_ChargeOutReceived 
provider contract transactional_query
as projection on /ESRCC/I_ChargeoutReceived
{   
    key UUID,
    key ParentUUID,
    key RootUUID,
    @ObjectModel.text.element: [ 'currenytext' ]
    key Currencytype,
    @ObjectModel.text.element: [ 'costdatasetdescription' ]
    Fplv,
    Ryear,
    Poper,
    Sysid,
    @ObjectModel.text.element: [ 'legalentitydescription' ]
    Legalentity,
    @ObjectModel.text.element: [ 'ccodedescription' ]
    Ccode,
    @ObjectModel.text.element: [ 'costobjectdescription' ]
    Costobject,
    @ObjectModel.text.element: [ 'costcenterdescription' ]
    Costcenter,
    @ObjectModel.text.element: [ 'serviceproductdescription' ]
    Serviceproduct,
    ReceiverSysId,
    @ObjectModel.text.element: [ 'RecCcodedescription' ]
    ReceiverCompanyCode,
    @ObjectModel.text.element: [ 'receivingentitydescription' ]
    Receivingentity,
    @ObjectModel.text.element: [ 'RecCostObjectdescription' ]
    ReceiverCostObject,
    @ObjectModel.text.element: [ 'RecCostCenterdescription' ]
    ReceiverCostCenter,
//    @ObjectModel.text.element: [ 'currenytext' ]
//    Currencytype,
    @ObjectModel.text.element: [ 'billingfrequencydescription' ]
    Billingfrequqncy,
    @ObjectModel.text.element: [ 'billingperioddescription' ]
    Billingperiod,
    @ObjectModel.text.element: [ 'chargeoutdescription' ]
    Chargeout,
    @ObjectModel.text.element: [ 'servicetypedescription' ]
    Servicetype,    
    @ObjectModel.text.element: [ 'transactiongroupdescription' ]
    Transactiongroup,
//    @Semantics.amount.currencyCode: 'Currency'
//    @ObjectModel.filter.enabled: false
//    Transferprice,
//    @Semantics.amount.currencyCode: 'Currency'
//    @ObjectModel.filter.enabled: false
//    TotalMarkupperunit,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    TotalMarkup,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    TotalCostbase,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    TotalValueAdd,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    TotalPassthrough,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    TotalChargeoutAmount,    
    Currency,
    @ObjectModel.text.element: [ 'oecdDescription' ]
    OECD,    
    @Semantics.text: true
    billingfrequencydescription,
    @Semantics.text: true
    billingperioddescription,
    @Semantics.text: true
    legalentitydescription,
    @Semantics.text: true
    costobjectdescription,
    @Semantics.text: true
    costcenterdescription,
    @Semantics.text: true
    Serviceproductdescription,
    @Semantics.text: true
    Transactiongroupdescription,
    @Semantics.text: true
    Servicetypedescription,
    @Semantics.text: true
    ccodedescription,
    @Semantics.text: true
    oecdDescription,
    @Semantics.text: true
    costdatasetdescription, 
    @Semantics.text: true
    RecCcodedescription,
    @Semantics.text: true
    receivingentitydescription,
    @Semantics.text: true
    RecCostCenterdescription,
    @Semantics.text: true
    RecCostObjectdescription, 
    @Semantics.text: true
    chargeoutdescription, 
    
    _CurrencyTypeText.text as currenytext,
    @ObjectModel.text.element: [ 'legalentitycountryname' ]
    LECountry,
    @ObjectModel.text.element: [ 'receivingcountryname' ]
    RecCountry, 
    _legalCountryText.CountryName as legalentitycountryname,
    _ReceivingCountryText.CountryName as receivingcountryname,   
    hidedirect,    
    hideindirect
   
   
//    /* Associations */
//    _RecmkupCost : redirected to composition child /ESRCC/C_RECMKUP_COST,
//    _IndRecmkupCost : redirected to composition child /ESRCC/C_INDRECMKUP_COST
}
