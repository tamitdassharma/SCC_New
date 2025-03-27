@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION, #GROUP_BY ]
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

<<<<<<< HEAD
  association [0..*] to /esrcc/indalloc as periodindalloc on  indwght.receivingentity = periodindalloc.receivingentity
                                                          and indwght.ryear           = periodindalloc.ryear
                                                          and indwght.Allockey        = periodindalloc.allocationkey
                                                          and indwght.KeyVersion      = periodindalloc.fplv
                                                          and indwght.poper           >= periodindalloc.poper
=======
  association [0..*] to /ESRCC/I_INDKEYBASEVALUES as periodindalloc 
            on indwght.ReceiverSysId = periodindalloc.ReceiverSysId
           and indwght.ReceiverCompanyCode = periodindalloc.ReceiverCompanyCode           
           and indwght.ReceivingEntity = periodindalloc.ReceivingEntity
           and indwght.ReceiverCostObject = periodindalloc.ReceiverCostObject
           and indwght.ReceiverCostCenter = periodindalloc.ReceiverCostCenter
           and indwght.Ryear           = periodindalloc.Ryear
           and indwght.Allockey        = periodindalloc.AllocationKey
           and indwght.KeyVersion      = periodindalloc.Fplv
           and indwght.Poper           >= periodindalloc.Poper
>>>>>>> origin/main

                                                                                         

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
//AllocType,
AllocationPeriod,
RefPeriod
  
union

select from /ESRCC/I_CHARGEOUT_INDWGHT as indwght

<<<<<<< HEAD
  association [0..*] to /esrcc/indalloc as periodindalloc on  indwght.receivingentity = periodindalloc.receivingentity
                                                          and indwght.ryear           = periodindalloc.ryear
                                                          and indwght.Allockey        = periodindalloc.allocationkey
                                                          and indwght.KeyVersion      = periodindalloc.fplv
                                                          and indwght.poper           = periodindalloc.poper
=======
  association [0..*] to /ESRCC/I_INDKEYBASEVALUES as periodindalloc 
        on indwght.ReceiverSysId       = periodindalloc.ReceiverSysId
       and indwght.ReceiverCompanyCode = periodindalloc.ReceiverCompanyCode           
       and indwght.ReceivingEntity     = periodindalloc.ReceivingEntity
       and indwght.ReceiverCostObject  = periodindalloc.ReceiverCostObject
       and indwght.ReceiverCostCenter  = periodindalloc.ReceiverCostCenter
       and indwght.Ryear               = periodindalloc.Ryear
       and indwght.Allockey            = periodindalloc.AllocationKey
       and indwght.KeyVersion          = periodindalloc.Fplv
       and indwght.Poper               = periodindalloc.Poper
>>>>>>> origin/main
                                                         
                                                          
                                                                                         

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

<<<<<<< HEAD
  association [0..*] to /esrcc/indalloc as periodindalloc on  indwght.receivingentity = periodindalloc.receivingentity
                                                          and indwght.ryear           = periodindalloc.ryear
                                                          and indwght.Allockey        = periodindalloc.allocationkey
                                                          and indwght.KeyVersion      = periodindalloc.fplv                                                          
                                                          and indwght.RefPeriod      >= periodindalloc.poper
=======
  association [0..*] to /ESRCC/I_INDKEYBASEVALUES as periodindalloc 
               on indwght.ReceiverSysId        = periodindalloc.ReceiverSysId
               and indwght.ReceiverCompanyCode = periodindalloc.ReceiverCompanyCode           
               and indwght.ReceivingEntity     = periodindalloc.ReceivingEntity
               and indwght.ReceiverCostObject  = periodindalloc.ReceiverCostObject
               and indwght.ReceiverCostCenter  = periodindalloc.ReceiverCostCenter
               and indwght.Ryear               = periodindalloc.Ryear
               and indwght.Allockey            = periodindalloc.AllocationKey
               and indwght.KeyVersion          = periodindalloc.Fplv                                                          
               and indwght.RefPeriod          >= periodindalloc.Poper
>>>>>>> origin/main
                                                                                         

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
//AllocType,
AllocationPeriod,
RefPeriod

union 

select from /ESRCC/I_CHARGEOUT_INDWGHT as indwght

<<<<<<< HEAD
  association [0..*] to /esrcc/indalloc as periodindalloc on  indwght.receivingentity = periodindalloc.receivingentity
                                                          and indwght.ryear           = periodindalloc.ryear
                                                          and indwght.Allockey        = periodindalloc.allocationkey
                                                          and indwght.KeyVersion      = periodindalloc.fplv                                                                                                                                                                   
                                                          and indwght.poper          >= periodindalloc.poper  
                                                          and periodindalloc.poper    > indwght.fromRefperiod                           
=======
  association [0..*] to /ESRCC/I_INDKEYBASEVALUES as periodindalloc 
            on indwght.ReceiverSysId       = periodindalloc.ReceiverSysId
           and indwght.ReceiverCompanyCode = periodindalloc.ReceiverCompanyCode           
           and indwght.ReceivingEntity     = periodindalloc.ReceivingEntity
           and indwght.ReceiverCostObject  = periodindalloc.ReceiverCostObject
           and indwght.ReceiverCostCenter  = periodindalloc.ReceiverCostCenter
           and indwght.Ryear               = periodindalloc.Ryear
           and indwght.Allockey            = periodindalloc.AllocationKey
           and indwght.KeyVersion          = periodindalloc.Fplv                                                                                                                                                                   
           and indwght.Poper              >= periodindalloc.Poper  
           and periodindalloc.Poper        > indwght.fromRefperiod                           
>>>>>>> origin/main
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
//AllocType,
AllocationPeriod,
RefPeriod

union

select from /ESRCC/I_CHARGEOUT_INDWGHT as indwght

<<<<<<< HEAD
  association [0..*] to /esrcc/indalloc as periodindalloc on  indwght.receivingentity = periodindalloc.receivingentity
                                                          and indwght.ryear           = periodindalloc.ryear
                                                          and indwght.Allockey        = periodindalloc.allocationkey
                                                          and indwght.KeyVersion      = periodindalloc.fplv
                                                          and indwght.poper           > periodindalloc.poper  
                                                          and periodindalloc.poper    >= indwght.fromRefperiod    
=======
  association [0..*] to /ESRCC/I_INDKEYBASEVALUES as periodindalloc 
                on indwght.ReceiverSysId       = periodindalloc.ReceiverSysId
               and indwght.ReceiverCompanyCode = periodindalloc.ReceiverCompanyCode           
               and indwght.ReceivingEntity     = periodindalloc.ReceivingEntity
               and indwght.ReceiverCostObject  = periodindalloc.ReceiverCostObject
               and indwght.ReceiverCostCenter  = periodindalloc.ReceiverCostCenter
               and indwght.Ryear               = periodindalloc.Ryear
               and indwght.Allockey            = periodindalloc.AllocationKey
               and indwght.KeyVersion          = periodindalloc.Fplv
               and indwght.Poper               > periodindalloc.Poper  
               and periodindalloc.Poper       >= indwght.fromRefperiod    
>>>>>>> origin/main
                                                          
                                                                                         

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

<<<<<<< HEAD
  association [0..*] to /esrcc/indalloc as periodindalloc on  indwght.receivingentity = periodindalloc.receivingentity
                                                          and indwght.ryear           = periodindalloc.ryear
                                                          and indwght.Allockey        = periodindalloc.allocationkey
                                                          and indwght.KeyVersion      = periodindalloc.fplv
                                                          and indwght.RefPeriod       = periodindalloc.poper
=======
  association [0..*] to /ESRCC/I_INDKEYBASEVALUES as periodindalloc 
               on indwght.ReceiverSysId        = periodindalloc.ReceiverSysId
               and indwght.ReceiverCompanyCode = periodindalloc.ReceiverCompanyCode           
               and indwght.ReceivingEntity     = periodindalloc.ReceivingEntity
               and indwght.ReceiverCostObject  = periodindalloc.ReceiverCostObject
               and indwght.ReceiverCostCenter  = periodindalloc.ReceiverCostCenter
               and indwght.Ryear               = periodindalloc.Ryear
               and indwght.Allockey            = periodindalloc.AllocationKey
               and indwght.KeyVersion          = periodindalloc.Fplv
               and indwght.RefPeriod           = periodindalloc.Poper
>>>>>>> origin/main
                                                          
                                                                                         

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



