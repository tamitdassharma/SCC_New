@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Charge-Out for Receivers'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_CHARGEOUT_RECEIVERS 
//as select from /ESRCC/I_CHARGEOUT_UNITCOST as chargeoutcost
as select from /esrcc/srv_cost as chargeoutcost

association [0..1] to /esrcc/cc_cost  as _CostCenterCost 
                   on  $projection.fplv        = _CostCenterCost.fplv
                   and $projection.ryear       = _CostCenterCost.ryear
                   and $projection.poper       = _CostCenterCost.poper
                   and $projection.sysid       = _CostCenterCost.sysid
                   and $projection.legalentity = _CostCenterCost.legalentity
                   and $projection.ccode       = _CostCenterCost.ccode
                   and $projection.costobject  = _CostCenterCost.costobject
                   and $projection.costcenter  = _CostCenterCost.costcenter 
                                                                                  
                   
association [0..*] to /ESRCC/I_ServiceAllocReceiver as srvallocreceivers  
                   on  srvallocreceivers.Sysid          = chargeoutcost.sysid
                   and srvallocreceivers.Ccode          = chargeoutcost.ccode
                   and srvallocreceivers.Legalentity    = chargeoutcost.legalentity
                   and srvallocreceivers.Costobject     = chargeoutcost.costobject
                   and srvallocreceivers.Costcenter     = chargeoutcost.costcenter                  
                   and srvallocreceivers.Serviceproduct = chargeoutcost.serviceproduct                   
                   and srvallocreceivers.Active = 'X'
                   and chargeoutcost.validon between srvallocreceivers.CcValidfrom and srvallocreceivers.CcValidto
{
    key ryear,
    key poper,
    key fplv,
    key sysid,
    key legalentity,
    key ccode,
    key costobject,
    key costcenter,
    key serviceproduct,
    key srvallocreceivers.Receivingentity as receivingentity,
// Additonal Characteristics
    _CostCenterCost.profitcenter,
    _CostCenterCost.businessdivision,
    _CostCenterCost.controllingarea,
    billfrequency,   
    servicetype,
    transactiongroup,   
    capacity_version,
    consumption_version,
    key_version,
    @Semantics.quantity.unitOfMeasure: 'uom'
    planning,
    uom,
    chargeout, 
    validon,
    _CostCenterCost.localcurr,
    _CostCenterCost.groupcurr,
    _CostCenterCost.stewardship,
    _CostCenterCost.totalcost_l,
    _CostCenterCost.excludedtotalcost_l,
    _CostCenterCost.totalcost_l - _CostCenterCost.excludedtotalcost_l as includetotalcost_l, 
    _CostCenterCost.origtotalcost_l,
    _CostCenterCost.passtotalcost_l,
    _CostCenterCost.totalcost_g,
    _CostCenterCost.excludedtotalcost_g,
    _CostCenterCost.totalcost_l - _CostCenterCost.excludedtotalcost_l as includetotalcost_g,    
    _CostCenterCost.origtotalcost_g,
    _CostCenterCost.passtotalcost_g,
//    _CostCenterCost.origtotalcost_l - ( ( _CostCenterCost.stewardship / 100 ) * _CostCenterCost.origtotalcost_l ) as remainingorigcostbase_l,
//    _CostCenterCost.passtotalcost_l - ( ( _CostCenterCost.stewardship / 100 ) * _CostCenterCost.passtotalcost_l ) as remainingpasscostbase_l,
//    _CostCenterCost.origtotalcost_g - ( ( _CostCenterCost.stewardship / 100 ) * _CostCenterCost.origtotalcost_g ) as remainingorigcostbase_g,
//    _CostCenterCost.passtotalcost_g - ( ( _CostCenterCost.stewardship / 100 ) * _CostCenterCost.passtotalcost_g ) as remainingpasscostbase_g,
    _CostCenterCost.origtotalcost_l - ( ( _CostCenterCost.stewardship / 100 ) * _CostCenterCost.origtotalcost_l ) +
    _CostCenterCost.passtotalcost_l - ( ( _CostCenterCost.stewardship / 100 ) * _CostCenterCost.passtotalcost_l ) as remainingcostbase_l,
    _CostCenterCost.origtotalcost_g - ( ( _CostCenterCost.stewardship / 100 ) * _CostCenterCost.origtotalcost_g ) +
    _CostCenterCost.passtotalcost_g - ( ( _CostCenterCost.stewardship / 100 ) * _CostCenterCost.passtotalcost_g ) as remainingcostbase_g,
    costshare,
    srvcostsharel,
    valueaddsharel,
    passthroughsharel,
    (valueaddmarkupabsl + passthrumarkupabsl ) as srvtotalmarkupabsL,
    cast((srvcostsharel + valueaddmarkupabsl + passthrumarkupabsl) as abap.dec(23,2)) as totalchargeoutamountL,       
    srvcostshareg,
    valueaddshareg,
    passthroughshareg,
    (valueaddmarkupabsg + passthrumarkupabsg ) as srvtotalmarkupabsG,
    cast((srvcostshareg + valueaddmarkupabsg + passthrumarkupabsg) as abap.dec(23,2)) as totalchargeoutamountG,
    servicecostperunitl,
    valueaddcostperunitl,
    passthrucostperunitl,
//    overallcostperunitG,
    servicecostperunitg,
    valueaddcostperunitg,
    passthrucostperunitg,
    tp_valueaddmarkupcostperunitl,
    tp_valueaddmarkupcostperunitg,
    tp_passthrumarkupcostperunitl,
    tp_passthrumarkupcostperunitg,
    valueaddmarkup,
    passthrumarkup,
    valueaddmarkupabsl,
    valueaddmarkupabsg,
    passthrumarkupabsl,
    passthrumarkupabsg,
    case when chargeout = 'D' then
    cast(( servicecostperunitl + tp_valueaddmarkupcostperunitl + tp_passthrumarkupcostperunitl ) as abap.dec(10,2))
    else 0 end as transferpriceL,
    case when chargeout = 'D' then
    cast(( servicecostperunitg + tp_valueaddmarkupcostperunitg + tp_passthrumarkupcostperunitg ) as abap.dec(10,2))
    else 0 end as transferpriceG
}
