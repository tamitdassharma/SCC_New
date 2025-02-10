@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cost Center ChargeOut Union View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_CostBaseData 
as select from /esrcc/cb_stw
{
    key cc_uuid as UUID,
    key 'L' as Currencytype,
    fplv as Fplv,
    ryear as Ryear,
    poper as Poper,
    sysid as Sysid,
    legalentity as Legalentity,
    ccode as Ccode,
    costobject as Costobject,
    costcenter as Costcenter,    
    billfrequency as Billfrequency,
    businessdivision as Businessdivision,
    functionalarea as FunctionalArea,
    profitcenter as Profitcenter,
    controllingarea as Controllingarea,    
    billingperiod as Billingperiod,
    localcurr as Currency,
    virtualtotalcost_l as VirtualCost,
    erptotalcost_l as ERPCost,
    totalcost_l as Totalcost,
    excludedtotalcost_l as Excludedtotalcost,
    origtotalcost_l as Origtotalcost,
    passtotalcost_l as Passtotalcost,
    stewardship as Stewardship,
    status as Status,
    workflowid as Workflowid,
    processtype as ProcessType,
    created_by as CreatedBy,
    created_at as CreatedAt,
    last_changed_by as LastChangedBy,
    last_changed_at as LastChangedAt
    
}
union
select from /esrcc/cb_stw
{
    key cc_uuid as UUID,
    key 'I' as Currencytype,
    fplv as Fplv,
    ryear as Ryear,
    poper as Poper,
    sysid as Sysid,
    legalentity as Legalentity,
    ccode as Ccode,
    costobject as Costobject,
    costcenter as Costcenter,    
    billfrequency as Billfrequency,
    businessdivision as Businessdivision,
    functionalarea as FunctionalArea,
    profitcenter as Profitcenter,
    controllingarea as Controllingarea,    
    billingperiod as Billingperiod,
    localcurr as Currency,
    virtualtotalcost_l as VirtualCost,
    erptotalcost_l as ERPCost,
    totalcost_l as Totalcost,
    excludedtotalcost_l as Excludedtotalcost,
    origtotalcost_l as Origtotalcost,
    passtotalcost_l as Passtotalcost,
    stewardship as Stewardship,
    status as Status,
    workflowid as Workflowid,
    processtype as ProcessType,
    created_by as CreatedBy,
    created_at as CreatedAt,
    last_changed_by as LastChangedBy,
    last_changed_at as LastChangedAt
    
}
union
select from /esrcc/cb_stw
{
    key cc_uuid as UUID,
    key 'G' as Currencytype,
    fplv as Fplv,
    ryear as Ryear,
    poper as Poper,
    sysid as Sysid,
    legalentity as Legalentity,
    ccode as Ccode,
    costobject as Costobject,
    costcenter as Costcenter,    
    billfrequency as Billfrequency,    
    businessdivision as Businessdivision,
    functionalarea as FunctionalArea,
    profitcenter as Profitcenter,
    controllingarea as Controllingarea,    
    billingperiod as Billingperiod,
    groupcurr as Currency,
    virtualtotalcost_g as VirtualCost,
    erptotalcost_g as ERPCost,
    totalcost_g as Totalcost,
    excludedtotalcost_g as Excludedtotalcost,
    origtotalcost_g as Origtotalcost,
    passtotalcost_g as Passtotalcost,
    stewardship as Stewardship,
    status as Status,
    workflowid as Workflowid,
    processtype as ProcessType,
    created_by as CreatedBy,
    created_at as CreatedAt,
    last_changed_by as LastChangedBy,
    last_changed_at as LastChangedAt    
}
