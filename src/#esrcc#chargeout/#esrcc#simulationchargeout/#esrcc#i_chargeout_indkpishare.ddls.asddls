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
                  on weightage.Fplv = indkpisum.Fplv
                 and weightage.Ryear = indkpisum.Ryear 
                 and weightage.Poper = indkpisum.Poper
                 and weightage.Sysid = indkpisum.Sysid
                 and weightage.Ccode = indkpisum.Ccode
                 and weightage.Legalentity = indkpisum.Legalentity
                 and weightage.Costobject = indkpisum.Costobject
                 and weightage.Costcenter = indkpisum.Costcenter
                 and weightage.serviceproduct = indkpisum.serviceproduct
                 and weightage.KeyVersion = indkpisum.KeyVersion                             
                 and weightage.Allockey = indkpisum.Allockey
                 and weightage.AllocType = indkpisum.AllocType
                 and weightage.AllocationPeriod = indkpisum.AllocationPeriod
                 and weightage.RefPeriod = indkpisum.RefPeriod
                 

association [0..*] to /ESRCC/I_INDALLOC as TOTALINDALLOC
                  on weightage.Fplv = TOTALINDALLOC.Fplv
                 and weightage.Ryear = TOTALINDALLOC.Ryear 
                 and weightage.Poper = TOTALINDALLOC.Poper
                 and weightage.Sysid = TOTALINDALLOC.Sysid
                 and weightage.Ccode = TOTALINDALLOC.Ccode
                 and weightage.Legalentity = TOTALINDALLOC.Legalentity
                 and weightage.Costobject = TOTALINDALLOC.Costobject
                 and weightage.Costcenter = TOTALINDALLOC.Costcenter
                 and weightage.serviceproduct = TOTALINDALLOC.serviceproduct
                 and weightage.receivingentity = TOTALINDALLOC.receivingentity
                 and weightage.KeyVersion = TOTALINDALLOC.KeyVersion                             
                 and weightage.Allockey = TOTALINDALLOC.Allockey
                 and weightage.AllocType = TOTALINDALLOC.AllocType
                 and weightage.AllocationPeriod = TOTALINDALLOC.AllocationPeriod
                 and weightage.RefPeriod = TOTALINDALLOC.RefPeriod
                
                 
{
 key Fplv,
 key Ryear,
 key Poper,
 key Sysid,
 key Ccode,
 key Legalentity,
 key Costobject,
 key Costcenter,
 key serviceproduct,
 key receivingentity,
 key KeyVersion,
 key Allockey,
 key AllocType,
 key AllocationPeriod,
 key RefPeriod,
 key weightage.Weightage,
 TOTALINDALLOC.reckpivalue,
 indkpisum.totalreckpi,
 cast(case when indkpisum.totalreckpi <> 0 then
 ( TOTALINDALLOC.reckpivalue / indkpisum.totalreckpi ) else 0 end as abap.dec(10,5))  as initialreckpishare ,
    
 cast(case when indkpisum.totalreckpi <> 0 then
 ( TOTALINDALLOC.reckpivalue / indkpisum.totalreckpi ) * ( weightage.Weightage / 100 ) else 0 end as abap.dec(10,5)) as reckpishare
    
}


