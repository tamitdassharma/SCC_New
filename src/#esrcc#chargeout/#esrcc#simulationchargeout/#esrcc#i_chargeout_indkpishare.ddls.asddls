@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Indirect Allocation KPI Share'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_CHARGEOUT_INDKPISHARE 
as select from /ESRCC/I_CHARGEOUT_INDWGHT as weightage

association [0..1] to /ESRCC/I_CHARGEOUT_INDKPISUM as indkpisum
                  on weightage.fplv = indkpisum.Fplv
                 and weightage.ryear = indkpisum.Ryear 
                 and weightage.poper = indkpisum.Poper
                 and weightage.sysid = indkpisum.Sysid
                 and weightage.ccode = indkpisum.Ccode
                 and weightage.legalentity = indkpisum.Legalentity
                 and weightage.costobject = indkpisum.Costobject
                 and weightage.costcenter = indkpisum.Costcenter
                 and weightage.serviceproduct = indkpisum.serviceproduct
                 and weightage.KeyVersion = indkpisum.KeyVersion                             
                 and weightage.Allockey = indkpisum.Allockey
//                 and weightage.AllocType = indkpisum.AllocType
                 and weightage.AllocationPeriod = indkpisum.AllocationPeriod
                 and weightage.RefPeriod = indkpisum.RefPeriod
                 

association [0..*] to /ESRCC/I_INDALLOC as TOTALINDALLOC
                  on weightage.fplv = TOTALINDALLOC.fplv
                 and weightage.ryear = TOTALINDALLOC.ryear 
                 and weightage.poper = TOTALINDALLOC.poper
                 and weightage.sysid = TOTALINDALLOC.sysid
                 and weightage.ccode = TOTALINDALLOC.ccode
                 and weightage.legalentity = TOTALINDALLOC.legalentity
                 and weightage.costobject = TOTALINDALLOC.costobject
                 and weightage.costcenter = TOTALINDALLOC.costcenter
                 and weightage.serviceproduct = TOTALINDALLOC.serviceproduct
                 and weightage.receivingentity = TOTALINDALLOC.receivingentity
                 and weightage.KeyVersion = TOTALINDALLOC.KeyVersion                             
                 and weightage.Allockey = TOTALINDALLOC.Allockey
//                 and weightage.AllocType = TOTALINDALLOC.AllocType
                 and weightage.AllocationPeriod = TOTALINDALLOC.AllocationPeriod
                 and weightage.RefPeriod = TOTALINDALLOC.RefPeriod
                
                 
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
 key receivingentity,
 key KeyVersion,
 key Allockey,
// key AllocType,
 key AllocationPeriod,
 key RefPeriod,
 key weightage.Weightage,
 TOTALINDALLOC.reckpivalue,
 indkpisum.totalreckpi,
 cast(case when indkpisum.totalreckpi <> 0 then
 ( TOTALINDALLOC.reckpivalue / indkpisum.totalreckpi ) else 0 end as abap.dec(10,8))  as initialreckpishare ,
    
 cast(case when indkpisum.totalreckpi <> 0 then
 ( TOTALINDALLOC.reckpivalue / indkpisum.totalreckpi ) * ( weightage.Weightage / 100 ) else 0 end as abap.dec(10,8)) as reckpishare
    
}


