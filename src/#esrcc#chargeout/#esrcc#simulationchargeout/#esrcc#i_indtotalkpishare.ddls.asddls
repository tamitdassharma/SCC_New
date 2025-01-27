@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Indirect Allocation Total KPI Share'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_INDTOTALKPISHARE 
as select from /ESRCC/I_CHARGEOUT_INDKPISHARE 

{
    key fplv,
    key ryear,
    key poper,
    key sysid,
    key ccode,
    key legalentity,
    key costobject,
    key costcenter,
    key serviceproduct,    
    key ReceiverSysId,
    key ReceiverCompanyCode,
    key ReceivingEntity,
    key ReceiverCostObject,
    key ReceiverCostCenter,
    sum( reckpishare ) as totalreckpishare
}
group by
fplv,
ryear,
poper,
sysid,
ccode,
legalentity,
costobject,
costcenter,
serviceproduct,
ReceiverSysId,
ReceiverCompanyCode,
ReceivingEntity,
ReceiverCostObject,
ReceiverCostCenter

