@EndUserText.label: 'Receivers Chargeout Cost'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity /ESRCC/C_RECEIVER_COST 
provider contract transactional_query
as projection on /ESRCC/I_RECEIVER_COST
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
    @ObjectModel.text.element: [ 'serviceproductdescription' ]
    key Serviceproduct,
    @ObjectModel.text.element: [ 'receivingentitydescription' ]
    key Receivingentity,
    @ObjectModel.text.element: [ 'currenytext' ]
    key Currencytype,
    @ObjectModel.text.element: [ 'billingfreqdescription' ]
    key Billingfrequqncy,
    @ObjectModel.text.element: [ 'billingperioddescription' ]
    Billingperiod,
    @ObjectModel.text.element: [ 'chargeoutdescription' ]
    Chargeout,
//    CapacityVersion,
//    ConsumptionVersion, 
////    @Semantics.quantity.unitOfMeasure: 'Uom'
//    consumption,
//    @ObjectModel.text.element: [ 'unitname' ]
//    Uom,   
    @ObjectModel.text.element: [ 'servicetypedescription' ]
    Servicetype,    
    @ObjectModel.text.element: [ 'transactiongroupdescription' ]
    Transactiongroup,
    @Semantics.amount.currencyCode: 'Currency'
    @ObjectModel.filter.enabled: false
    Transferprice,
    @Semantics.amount.currencyCode: 'Currency'
    @ObjectModel.filter.enabled: false
    totalmarkuptransferprice,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    totaludmarkupabs,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Totalcostbase,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Totalvalueaddabs,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Totalpassthruabs,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    chargeoutforservice,    
    Currency,    
    _legalentity.Description as legalentitydescription,    
    _ccode.ccodedescription,   
    _costdataset.text as costdatasetdescription,    
    _billingfreq.text as billingfreqdescription,    
    _billingperiod.text as billingperioddescription,    
    _serviceproduct.Description as serviceproductdescription,    
    _srvtyp.Description as servicetypedescription,    
    _srvtransactiongroup.Description as transactiongroupdescription,    
    _rcventity.Description as receivingentitydescription,    
    _chgout.text as chargeoutdescription, 
    _legalentity,
    _rcventity,
//    _UoM.UnitOfMeasureName as unitname,
    _CurrencyTypeText.text as currenytext,
    @ObjectModel.text.element: [ 'legalentitycountryname' ]
    LECountry,
    @ObjectModel.text.element: [ 'receivingcountryname' ]
    RecCountry, 
    _legalCountryText.CountryName as legalentitycountryname,
    _RecCountryText.CountryName as receivingcountryname,   
    hidedirect,    
    hideindirect,
    @ObjectModel.text.element: [ 'oecdDescription' ]
    OECD,
    @Semantics.text: true
    oecdDescription,
    /* Associations */
    _RecmkupCost : redirected to composition child /ESRCC/C_RECMKUP_COST,
    _IndRecmkupCost : redirected to composition child /ESRCC/C_INDRECMKUP_COST
}
