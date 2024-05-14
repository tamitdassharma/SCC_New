@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Receiver Total Cost Union View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_RECCOST_UNION as select from /esrcc/rec_cost
{
    key fplv as Fplv,
    key ryear as Ryear,
    key poper as Poper,
    key sysid as Sysid,
    key legalentity as Legalentity,
    key ccode as Ccode,
    key costobject as Costobject,
    key costcenter as Costcenter,
//    key billfrequency as Billingfrequqncy,
    key serviceproduct as Serviceproduct,
    key receivingentity as Receivingentity,
    key 'L' as Currencytype,
    chargeout,
    receivergroup as Receivergroup,
    allockey as Allockey,
    alloctype as Alloctype,
    consumption_version as ConsumptionVersion,
    key_version as KeyVersion,
    reckpi as Reckpi,
    reckpishare as Reckpishare,
    reckpishareabsl as Reckpishareabs,
    recvalueaddmarkupabsl as Recvalueaddmarkupabs,
    recpassthrumarkupabsl as Recpassthrumarkupabs,
    recvalueaddmarkupabsl + recpassthrumarkupabsl as Rectotalmarkupabs,
    recvalueaddedl as Recvalueadded,
    recpassthroughl as Recpassthrough,
    recvalueaddedl + recpassthroughl as Reccostshare,
    recorigtotalcostl as Recorigtotalcost,
    recpasstotalcostl as Recpasstotalcost,
    recorigtotalcostl + recpasstotalcostl as Recincludedcost,
    recexcludedcostl as Recexcludedcost,
    rectotalcostl as Rectotalcost,
    uom as Uom,
    status as Status,
    workflowid as Workflowid,
    exchdate as Exchdate,
    created_by as CreatedBy,
    created_at as CreatedAt,
    last_changed_by as LastChangedBy,
    last_changed_at as LastChangedAt
}
union
select from /esrcc/rec_cost
{
    key fplv as Fplv,
    key ryear as Ryear,
    key poper as Poper,
    key sysid as Sysid,
    key legalentity as Legalentity,
    key ccode as Ccode,
    key costobject as Costobject,
    key costcenter as Costcenter,
//    key billfrequency as Billingfrequqncy,
    key serviceproduct as Serviceproduct,
    key receivingentity as Receivingentity,
    key 'G' as Currencytype,
    chargeout,
    receivergroup as Receivergroup,
    allockey as Allockey,
    alloctype as Alloctype,
    consumption_version as ConsumptionVersion,
    key_version as KeyVersion,
    reckpi as Reckpi,
    reckpishare as Reckpishare,
    reckpishareabsg as Reckpishareabs,
    recvalueaddmarkupabsg as Recvalueaddmarkupabs,
    recpassthrumarkupabsg as Recpassthrumarkupabs,
    recvalueaddmarkupabsg + recpassthrumarkupabsl as Rectotalmarkupabs,
    recvalueaddedg as Recvalueadded,
    recpassthroughg as Recpassthrough,
    recvalueaddedg + recpassthroughl as Reccostshare,
    recorigtotalcostg as Recorigtotalcost,
    recpasstotalcostg as Recpasstotalcost,
    recorigtotalcostg + recpasstotalcostl as Recincludedcost,
    recexcludedcostg as Recexcludedcost,
    rectotalcostg as Rectotalcost,
    uom as Uom,
    status as Status,
    workflowid as Workflowid,
    exchdate as Exchdate,
    created_by as CreatedBy,
    created_at as CreatedAt,
    last_changed_by as LastChangedBy,
    last_changed_at as LastChangedAt
}