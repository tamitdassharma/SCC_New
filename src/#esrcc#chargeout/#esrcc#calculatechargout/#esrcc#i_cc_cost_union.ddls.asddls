@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cost Center ChargeOut Union View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_CC_COST_UNION 
as select from /esrcc/cc_cost
{
    key fplv as Fplv,
    key ryear as Ryear,
    key poper as Poper,
    key sysid as Sysid,
    key legalentity as Legalentity,
    key ccode as Ccode,
    key costobject as Costobject,
    key costcenter as Costcenter,
    key 'L' as Currencytype,
    billfrequency as Billfrequency,
    businessdivision as Businessdivision,
    '' as FunctionalArea,
    profitcenter as Profitcenter,
    controllingarea as Controllingarea,    
    billingperiod as Billingperiod,
    localcurr as Currency,
    totalcost_l as Totalcost,
    excludedtotalcost_l as Excludedtotalcost,
    origtotalcost_l as Origtotalcost,
    passtotalcost_l as Passtotalcost,
    stewardship as Stewardship,
    status as Status,
    workflowid as Workflowid,
    created_by as CreatedBy,
    created_at as CreatedAt,
    last_changed_by as LastChangedBy,
    last_changed_at as LastChangedAt
    
}
union
select from /esrcc/cc_cost
{
    key fplv as Fplv,
    key ryear as Ryear,
    key poper as Poper,
    key sysid as Sysid,
    key legalentity as Legalentity,
    key ccode as Ccode,
    key costobject as Costobject,
    key costcenter as Costcenter,
    key 'G' as Currencytype,
    billfrequency as Billfrequency,
    businessdivision as Businessdivision,
    '' as FunctionalArea,
    profitcenter as Profitcenter,
    controllingarea as Controllingarea,    
    billingperiod as Billingperiod,
    groupcurr as Currency,
    totalcost_g as Totalcost,
    excludedtotalcost_g as Excludedtotalcost,
    origtotalcost_g as Origtotalcost,
    passtotalcost_g as Passtotalcost,
    stewardship as Stewardship,
    status as Status,
    workflowid as Workflowid,
    created_by as CreatedBy,
    created_at as CreatedAt,
    last_changed_by as LastChangedBy,
    last_changed_at as LastChangedAt    
}
