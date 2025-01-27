@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Chargeout Details by Service Provider'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_ProviderChargeout 
as select from /ESRCC/I_CostBaseStewardship

{
    key UUID,
    key _ServiceMarkup._ReceiverCost.UUID as ReceiverUUID,
    key _ServiceMarkup.UUID as ServiceProductUUID,
    key Currencytype,
    Fplv,
    Ryear,
    Poper,
    Sysid,
    Legalentity,
    Ccode,
    Costobject,
    Costcenter,
    Billingfrequqncy,
    Businessdivision,
    FunctionalArea,
    Profitcenter,
    Controllingarea,
    Billingperiod,
    Currency,
    Totalcost,
    Excludedtotalcost,
    Includetotalcost,
    Origtotalcost,
    Passtotalcost,
    Stewardship,
    Remainingcostbase,
    Status,
    Workflowid,
//    CreatedBy,
//    CreatedAt,
//    LastChangedBy,
//    LastChangedAt,
//    ccodedescription,
//    legalentitydescription,
//    costobjectdescription,
//    costcenterdescription,
//    costdatasetdescription,
//    businessdescription,
//    functionalareadescription,
//    profitcenterdescription,
//    billingfrequencydescription,
//    billingperioddescription,
//    statusdescription,
//    Country,
//    _legalCountryText.CountryName as legalcountryname,
    
//    Service Product Details
    _ServiceMarkup.Serviceproduct,
    _ServiceMarkup.Serviceproductdescription,
    _ServiceMarkup.OECD,
    _ServiceMarkup.oecdDescription,
    _ServiceMarkup.Chargeout,
    _ServiceMarkup.chargeoutdescription,
     _ServiceMarkup.Uom,
    _ServiceMarkup.Planning,
     _ServiceMarkup.PlanningUom,
    _ServiceMarkup.CapacityVersion,
    _ServiceMarkup.Srvcostshare,
   

//Receiver Details    
    _ServiceMarkup._ReceiverCost.ReceiverSysId,
    _ServiceMarkup._ReceiverCost.ReceiverCompanyCode,
    _ServiceMarkup._ReceiverCost.Receivingentity,
    _ServiceMarkup._ReceiverCost.ReceiverCostObject,
    _ServiceMarkup._ReceiverCost.ReceiverCostCenter,
    _ServiceMarkup._ReceiverCost.RecCostShare
//    _ServiceMarkup._ReceiverCost.ccodedescription as RecCcodedescription,
//    _ServiceMarkup._ReceiverCost.receivingentitydescription,
//    _ServiceMarkup._ReceiverCost.costcenterdescription as RecCostCenterdescription,
//    _ServiceMarkup._ReceiverCost.costobjectdescription as RecCostObjectdescription,
//    _ServiceMarkup._ReceiverCost.Country as ReceiverCountry,
//    _ServiceMarkup._ReceiverCost._ReceivingCountryText.CountryName as ReceivingCountryName,
//    
//    _ServiceMarkup._ReceiverCost.TransferPrice
//    _ServiceMarkup._ReceiverCost.rec
//    /* Associations */
//    _legalCountryText,
//    _ServiceMarkup
}
