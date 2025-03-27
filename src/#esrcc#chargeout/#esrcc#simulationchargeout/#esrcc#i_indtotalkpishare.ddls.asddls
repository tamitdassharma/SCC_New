@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION, #GROUP_BY ]
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
    key Fplv,
    key Ryear,
    key Poper,
    key Sysid,
    key Ccode,
    key Legalentity,
    key Costobject,
    key Costcenter,
<<<<<<< HEAD
    key serviceproduct,
    key receivingentity,
=======
    key serviceproduct,    
    key ReceiverSysId,
    key ReceiverCompanyCode,
    key ReceivingEntity,
    key ReceiverCostObject,
    key ReceiverCostCenter,
>>>>>>> origin/main
    sum( reckpishare ) as totalreckpishare
}
group by
Fplv,
Ryear,
Poper,
Sysid,
Ccode,
Legalentity,
Costobject,
Costcenter,
serviceproduct,
receivingentity

