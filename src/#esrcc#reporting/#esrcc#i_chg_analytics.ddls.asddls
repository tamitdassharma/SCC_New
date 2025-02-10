@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Charge-Out Receiver'
@Analytics.dataCategory: #CUBE
define root view entity /ESRCC/I_CHG_ANALYTICS 
as select from /ESRCC/I_ReceiverChargeout as ReceiverChargeout
{

    key UUID,
    key ParentUUID,
    key RootUUID,
    key Currencytype,
    _ServiceCost._CostCenterCost.Fplv,
    _ServiceCost._CostCenterCost.Ryear,
    _ServiceCost._CostCenterCost.Poper,
    _ServiceCost._CostCenterCost.Sysid,
    _ServiceCost._CostCenterCost.Legalentity,
    _ServiceCost._CostCenterCost.Ccode,
    _ServiceCost._CostCenterCost.Costobject,
    _ServiceCost._CostCenterCost.Costcenter,
    _ServiceCost._CostCenterCost.ProcessType,
    _ServiceCost.Serviceproduct,
    ReceiverSysId,
    ReceiverCompanyCode,
    Receivingentity,
    ReceiverCostObject,
    ReceiverCostCenter,
    
    _ServiceCost._CostCenterCost.Billingfrequqncy,
    _ServiceCost._CostCenterCost.Billingperiod,
    _ServiceCost._CostCenterCost.Businessdivision,
    _ServiceCost._CostCenterCost.FunctionalArea,
    _ServiceCost._CostCenterCost.Profitcenter,
    _ServiceCost._CostCenterCost.Controllingarea,
    _ServiceCost.Servicetype,
    _ServiceCost.Transactiongroup,
    _ServiceCost.Chargeout,
    _ServiceCost.Uom,
    Currency,
    Reckpi,
    Reckpishare,
    TotalChargeout,
    TotalRecMarkup,
    RecValueaddMarkup,
    RecPassthroughMarkup,
    RecCostShare,
    RecValueadded,
    RecPassthrough,
    _ServiceCost._CostCenterCost.Stewardship,
    cast((RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) as abap.dec(23,2)) as RecIncludedCost,
    cast((RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) - RecCostShare as abap.dec(23,2)) as RecStewardship,
    
    case when _ServiceCost._CostCenterCost.Includetotalcost <> 0 then
    cast(( (RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) / _ServiceCost._CostCenterCost.Includetotalcost) * _ServiceCost._CostCenterCost.Excludedtotalcost as abap.dec(23,2))  
    else 0 end as RecExcludedCost,
    
    case when _ServiceCost._CostCenterCost.Includetotalcost <> 0 then
    cast((RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) +
    (( (RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) / _ServiceCost._CostCenterCost.Includetotalcost) * _ServiceCost._CostCenterCost.Excludedtotalcost ) as abap.dec(23,2)) 
    else 0 end as RecTotalCost,
    
    case when _ServiceCost._CostCenterCost.Includetotalcost <> 0 then
    cast((((RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) / _ServiceCost._CostCenterCost.Includetotalcost) * _ServiceCost._CostCenterCost.VirtualCost ) as abap.dec(23,2))  
    else 0 end as RecVirtualTotalCost,
    
    case when _ServiceCost._CostCenterCost.Includetotalcost <> 0 then
    cast((RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) +
    (( (RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) / _ServiceCost._CostCenterCost.Includetotalcost) * _ServiceCost._CostCenterCost.Excludedtotalcost ) as abap.dec(23,2)) 
    -
    cast((((RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) / _ServiceCost._CostCenterCost.Includetotalcost) * _ServiceCost._CostCenterCost.VirtualCost ) as abap.dec(23,2))  
    else 0 end as RecERPTotalCost,
     
    case when _ServiceCost._CostCenterCost.Includetotalcost <> 0 then
    cast((((RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) / _ServiceCost._CostCenterCost.Includetotalcost) * _ServiceCost._CostCenterCost.Origtotalcost ) as abap.dec(23,2))  
    else 0 end as RecOrigTotalCost, 
    
    case when _ServiceCost._CostCenterCost.Includetotalcost <> 0 then
    cast((((RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) / _ServiceCost._CostCenterCost.Includetotalcost) * _ServiceCost._CostCenterCost.Passtotalcost ) as abap.dec(23,2))  
    else 0 end as RecPassTotalCost, 
      
    Status,
    _ServiceCost.OECD,
    @Semantics.text: true
    _ServiceCost._CostCenterCost.legalentitydescription,
    @Semantics.text: true
    _ServiceCost._CostCenterCost.costobjectdescription,
    @Semantics.text: true
    _ServiceCost._CostCenterCost.costcenterdescription,
    @Semantics.text: true
    _ServiceCost.Serviceproductdescription,
    @Semantics.text: true
    _ServiceCost.Transactiongroupdescription,
    @Semantics.text: true
    _ServiceCost.Servicetypedescription,
    @Semantics.text: true
    _ServiceCost._CostCenterCost.ccodedescription,
    @Semantics.text: true
    _ServiceCost._CostCenterCost.functionalareadescription,
    @Semantics.text: true
    _ServiceCost._CostCenterCost.businessdescription,
    @Semantics.text: true
    _ServiceCost._CostCenterCost.profitcenterdescription,
    @Semantics.text: true
    _ServiceCost.oecdDescription,
    @Semantics.text: true
    _ServiceCost._CostCenterCost.costdatasetdescription,
    @Semantics.text: true
    ccodedescription as RecCcodedescription,
    @Semantics.text: true
    receivingentitydescription,
    @Semantics.text: true
    costcenterdescription as RecCostCenterdescription,
    @Semantics.text: true
    costobjectdescription as RecCostObjectdescription,
    @Semantics.text: true
    statusdescription,  
    @Semantics.text: true
    _ServiceCost._CostCenterCost.ProcessTypedescription, 
    _ServiceCost._CostCenterCost.Country as legalentitycountry,
    Country      as receivingentitycountry,
    _ServiceCost._CostCenterCost.LocalCurr        as legalentitycurrecy,
    ReceiverCurrency,
    _ServiceCost._CostCenterCost.Region          as legalentityregion,
    ReceiverRegion,
    //Associations
    _ServiceCost._CostCenterCost._legalCountryText,
    _ReceivingCountryText
} where Currencytype = 'G'
