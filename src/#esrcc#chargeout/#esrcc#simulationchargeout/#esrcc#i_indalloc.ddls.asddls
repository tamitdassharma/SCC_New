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
                                                          and indwght.Ryear           = periodindalloc.ryear
                                                          and indwght.Allockey        = periodindalloc.allocationkey
                                                          and indwght.KeyVersion      = periodindalloc.fplv
                                                          and indwght.Poper           >= periodindalloc.poper

                                                                                         

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
      case AllocType
        when 'A' then   /*average*/ 
         case when cast(Poper as abap.int1) > 0 then
         sum(cast( periodindalloc.value / cast(Poper as abap.int1) as abap.dec(23,5))) else 0 end
        when 'C' then   /*cumulative*/
        sum(periodindalloc.value)
        else 0 end as reckpivalue

} where AllocationPeriod = '01'  /*YTD*/
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
receivingentity,
KeyVersion,
Allockey,
AllocType,
AllocationPeriod,
RefPeriod
  
union

select from /ESRCC/I_CHARGEOUT_INDWGHT as indwght

  association [0..*] to /esrcc/indalloc as periodindalloc on  indwght.receivingentity = periodindalloc.receivingentity
                                                          and indwght.Ryear           = periodindalloc.ryear
                                                          and indwght.Allockey        = periodindalloc.allocationkey
                                                          and indwght.KeyVersion      = periodindalloc.fplv
                                                          and indwght.Poper           = periodindalloc.poper
                                                          
                                                                                         

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
      sum(periodindalloc.value) as reckpivalue

} where AllocationPeriod = '02'   /*Recent Month*/
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
receivingentity,
KeyVersion,
Allockey,
AllocType,
AllocationPeriod,
RefPeriod

union

select from /ESRCC/I_CHARGEOUT_INDWGHT as indwght

  association [0..*] to /esrcc/indalloc as periodindalloc on  indwght.receivingentity = periodindalloc.receivingentity
                                                          and indwght.Ryear           = periodindalloc.ryear
                                                          and indwght.Allockey        = periodindalloc.allocationkey
                                                          and indwght.KeyVersion      = periodindalloc.fplv                                                          
                                                          and indwght.RefPeriod      >= periodindalloc.poper
                                                                                         

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
       case AllocType
        when 'A' then   /*average*/ 
         case when cast(RefPeriod as abap.int1) <> 0 then
         sum(cast( periodindalloc.value / cast(RefPeriod as abap.int1) as abap.dec(23,5)))  else 0  end
        when 'C' then   /*cumulative*/
        sum(periodindalloc.value)
        else 0 end as reckpivalue

} where AllocationPeriod = '03'  /*No. Of months*/
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
receivingentity,
KeyVersion,
Allockey,
AllocType,
AllocationPeriod,
RefPeriod

union 

select from /ESRCC/I_CHARGEOUT_INDWGHT as indwght

  association [0..*] to /esrcc/indalloc as periodindalloc on  indwght.receivingentity = periodindalloc.receivingentity
                                                          and indwght.Ryear           = periodindalloc.ryear
                                                          and indwght.Allockey        = periodindalloc.allocationkey
                                                          and indwght.KeyVersion      = periodindalloc.fplv                                                                                                                                                                   
                                                          and indwght.Poper          >= periodindalloc.poper  
                                                          and periodindalloc.poper    > indwght.fromRefperiod                           
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
       case AllocType
        when 'A' then   /*average*/ 
         case when cast(Poper as abap.int1) - cast(RefPeriod as abap.int1) > 0   then  
         sum(cast( periodindalloc.value / cast(RefPeriod as abap.int1) as abap.dec(23,5))) else 0 end
        when 'C' then   /*cumulative*/
        case when cast(Poper as abap.int1) - cast(RefPeriod as abap.int1) > 0   then
        sum(periodindalloc.value) else 0 end
        else 0 end as reckpivalue

} where AllocationPeriod = '04' /*Last months*/
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
receivingentity,
KeyVersion,
Allockey,
AllocType,
AllocationPeriod,
RefPeriod

