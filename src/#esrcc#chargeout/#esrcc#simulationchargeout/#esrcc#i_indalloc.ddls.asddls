@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Indirect Allocation'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define view entity /ESRCC/I_INDALLOC
as select from /ESRCC/I_CHARGEOUT_INDWGHT as indwght

  association [0..*] to /esrcc/indalloc as periodindalloc on  indwght.receivingentity = periodindalloc.receivingentity
                                                          and indwght.ryear           = periodindalloc.ryear
                                                          and indwght.Allockey        = periodindalloc.allocationkey
                                                          and indwght.KeyVersion      = periodindalloc.fplv
                                                          and indwght.poper           >= periodindalloc.poper

                                                                                         

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
//  key AllocType,
  key AllocationPeriod,
  key RefPeriod,
      sum(periodindalloc.value) as reckpivalue
//      case AllocType
//        when 'A' then   /*average*/ 
//         case when cast(Poper as abap.int1) > 0 then
//         sum(cast( periodindalloc.value / cast(Poper as abap.int1) as abap.dec(23,5))) else 0 end
//        when 'C' then   /*cumulative*/
//        sum(periodindalloc.value)
//        else 0 end as reckpivalue

} where AllocationPeriod = '01'  /*YTD*/
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
receivingentity,
KeyVersion,
Allockey,
//AllocType,
AllocationPeriod,
RefPeriod
  
union

select from /ESRCC/I_CHARGEOUT_INDWGHT as indwght

  association [0..*] to /esrcc/indalloc as periodindalloc on  indwght.receivingentity = periodindalloc.receivingentity
                                                          and indwght.ryear           = periodindalloc.ryear
                                                          and indwght.Allockey        = periodindalloc.allocationkey
                                                          and indwght.KeyVersion      = periodindalloc.fplv
                                                          and indwght.poper           = periodindalloc.poper
                                                         
                                                          
                                                                                         

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
//  key AllocType,
  key AllocationPeriod,
  key RefPeriod,
      periodindalloc.value as reckpivalue

} where AllocationPeriod = '02'   /*current Month*/
//group by
//fplv,
//ryear,
//poper,
//sysid,
//ccode,
//legalentity,
//costobject,
//costcenter,
//serviceproduct,
//receivingentity,
//KeyVersion,
//Allockey,
////AllocType,
//AllocationPeriod,
//RefPeriod

union

select from /ESRCC/I_CHARGEOUT_INDWGHT as indwght

  association [0..*] to /esrcc/indalloc as periodindalloc on  indwght.receivingentity = periodindalloc.receivingentity
                                                          and indwght.ryear           = periodindalloc.ryear
                                                          and indwght.Allockey        = periodindalloc.allocationkey
                                                          and indwght.KeyVersion      = periodindalloc.fplv                                                          
                                                          and indwght.RefPeriod      >= periodindalloc.poper
                                                                                         

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
//  key AllocType,
  key AllocationPeriod,
  key RefPeriod,
      sum(periodindalloc.value) as reckpivalue
//       case AllocType
//        when 'A' then   /*average*/ 
//         case when cast(RefPeriod as abap.int1) <> 0 then
//         sum(cast( periodindalloc.value / cast(RefPeriod as abap.int1) as abap.dec(23,5)))  else 0  end
//        when 'C' then   /*cumulative*/
//        sum(periodindalloc.value)
//        else 0 end as reckpivalue

} where AllocationPeriod = '03'  /*No. Of months*/
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
receivingentity,
KeyVersion,
Allockey,
//AllocType,
AllocationPeriod,
RefPeriod

union 

select from /ESRCC/I_CHARGEOUT_INDWGHT as indwght

  association [0..*] to /esrcc/indalloc as periodindalloc on  indwght.receivingentity = periodindalloc.receivingentity
                                                          and indwght.ryear           = periodindalloc.ryear
                                                          and indwght.Allockey        = periodindalloc.allocationkey
                                                          and indwght.KeyVersion      = periodindalloc.fplv                                                                                                                                                                   
                                                          and indwght.poper          >= periodindalloc.poper  
                                                          and periodindalloc.poper    > indwght.fromRefperiod                           
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
//  key AllocType,
  key AllocationPeriod,
  key RefPeriod,
      sum(periodindalloc.value) as reckpivalue
//       case AllocType
//        when 'A' then   /*average*/ 
//         case when cast(Poper as abap.int1) - cast(RefPeriod as abap.int1) > 0   then  
//         sum(cast( periodindalloc.value / cast(RefPeriod as abap.int1) as abap.dec(23,5))) else 0 end
//        when 'C' then   /*cumulative*/
//        case when cast(Poper as abap.int1) - cast(RefPeriod as abap.int1) > 0   then
//        sum(periodindalloc.value) else 0 end
//        else 0 end as reckpivalue

} where AllocationPeriod = '04' /*Last months*/
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
receivingentity,
KeyVersion,
Allockey,
//AllocType,
AllocationPeriod,
RefPeriod

union

select from /ESRCC/I_CHARGEOUT_INDWGHT as indwght

  association [0..*] to /esrcc/indalloc as periodindalloc on  indwght.receivingentity = periodindalloc.receivingentity
                                                          and indwght.ryear           = periodindalloc.ryear
                                                          and indwght.Allockey        = periodindalloc.allocationkey
                                                          and indwght.KeyVersion      = periodindalloc.fplv
                                                          and indwght.poper           > periodindalloc.poper  
                                                          and periodindalloc.poper    >= indwght.fromRefperiod    
                                                          
                                                                                         

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
//  key AllocType,
  key AllocationPeriod,
  key RefPeriod,
      periodindalloc.value as reckpivalue

} where AllocationPeriod = '05'   /*previous Month*/
//group by
//fplv,
//ryear,
//poper,
//sysid,
//ccode,
//legalentity,
//costobject,
//costcenter,
//serviceproduct,
//receivingentity,
//KeyVersion,
//Allockey,
////AllocType,
//AllocationPeriod,
//RefPeriod 

union

select from /ESRCC/I_CHARGEOUT_INDWGHT as indwght

  association [0..*] to /esrcc/indalloc as periodindalloc on  indwght.receivingentity = periodindalloc.receivingentity
                                                          and indwght.ryear           = periodindalloc.ryear
                                                          and indwght.Allockey        = periodindalloc.allocationkey
                                                          and indwght.KeyVersion      = periodindalloc.fplv
                                                          and indwght.RefPeriod       = periodindalloc.poper
                                                          
                                                                                         

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
//  key AllocType,
  key AllocationPeriod,
  key RefPeriod,
      periodindalloc.value as reckpivalue

} where AllocationPeriod = '06'   /*Reference Month*/
//group by
//fplv,
//ryear,
//poper,
//sysid,
//ccode,
//legalentity,
//costobject,
//costcenter,
//serviceproduct,
//receivingentity,
//KeyVersion,
//Allockey,
////AllocType,
//AllocationPeriod,
//RefPeriod



