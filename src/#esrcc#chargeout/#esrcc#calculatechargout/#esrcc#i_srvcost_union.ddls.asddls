@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service Cost Share Union View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_SRVCOST_UNION 
as select from /esrcc/srv_cost
{
    key fplv as Fplv,
    key ryear as Ryear,
    key poper as Poper,
    key sysid as Sysid,
    key legalentity as Legalentity,
    key ccode as Ccode,
    key costobject as Costobject,
    key costcenter as Costcenter,
//    key billfrequency as Billfrequency,
    key serviceproduct as Serviceproduct,
    key 'L' as Currencytype,
    servicetype as Servicetype,
    transactiongroup as Transactiongroup,
    chargeout as Chargeout,
    costshare as Costshare,
    srvcostsharel as Srvcostshare,
    valueaddsharel as Valueaddshare,
    passthroughsharel as Passthroughshare,
    servicecostperunitl as Servicecostperunit,
    valueaddcostperunitl as Valueaddcostperunit,
    passthrucostperunitl as Passthrucostperunit,    
    valueaddmarkup as Valueaddmarkup,
    passthrumarkup as Passthrumarkup,
    tp_valueaddmarkupcostperunitl as Tp_valueaddmarkupcostperunit,
    tp_passthrumarkupcostperunitl as Tp_passthrumarkupcostperunit,
    valueaddmarkupabsl as Valueaddmarkupabs,
    passthrumarkupabsl as Passthrumarkupabs,
    capacity_version as CapacityVersion,
    consumption_version as ConsumptionVersion,
    planning as Planning,
    uom as Uom,
    status as Status,
    workflowid as Workflowid,
    
    created_by as CreatedBy,
    created_at as CreatedAt,
    last_changed_by as LastChangedBy,
    last_changed_at as LastChangedAt
}
union
select from /esrcc/srv_cost
{
    key fplv as Fplv,
    key ryear as Ryear,
    key poper as Poper,
    key sysid as Sysid,
    key legalentity as Legalentity,
    key ccode as Ccode,
    key costobject as Costobject,
    key costcenter as Costcenter,
//    key billfrequency as Billfrequency,
    key serviceproduct as Serviceproduct,
    key 'G' as Currencytype,
    servicetype as Servicetype,
    transactiongroup as Transactiongroup,
    chargeout as Chargeout,
    costshare as Costshare,
    srvcostshareg as Srvcostshare,
    valueaddshareg as Valueaddshare,
    passthroughshareg as Passthroughshare,
    servicecostperunitg as Servicecostperunit,
    valueaddcostperunitg as Valueaddcostperunit,
    passthrucostperunitg as Passthrucostperunit,  
    valueaddmarkup as Valueaddmarkup,
    passthrumarkup as Passthrumarkup,
    tp_valueaddmarkupcostperunitg as Tp_valueaddmarkupcostperunit,
    tp_passthrumarkupcostperunitg as Tp_passthrumarkupcostperunit,
    valueaddmarkupabsg as Valueaddmarkupabs,
    passthrumarkupabsg as Passthrumarkupabs,
    capacity_version as CapacityVersion,
    consumption_version as ConsumptionVersion,
    planning as Planning,
//    receivergroup as Receivergroup,
//    allockey as Allockey,
    uom as Uom,
    status as Status,
    workflowid as Workflowid,
    created_by as CreatedBy,
    created_at as CreatedAt,
    last_changed_by as LastChangedBy,
    last_changed_at as LastChangedAt
}
