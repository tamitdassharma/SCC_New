@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Chargout to Receivers KPI Sum'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_CHARGEOUT_INDWGHT
  as select from /ESRCC/I_CHARGEOUT_RECEIVERS as chargeoutreceivers

  association [0..*] to /ESRCC/I_AllocationWeightage as weightage on  weightage.Serviceproduct   =       chargeoutreceivers.serviceproduct
                                                                  and weightage.CostVersion      =       chargeoutreceivers.fplv
                                                                  and chargeoutreceivers.validon between weightage.ValidfromAlloc and weightage.ValidtoAlloc


{
  key fplv,
  key ryear,
  key poper,
  key chargeoutreceivers.sysid,
  key ccode,
  key legalentity,
  key costobject,
  key costcenter,
  key serviceproduct,
  key receivingentity,
  key key_version                              as KeyVersion,
  key weightage.Allockey,
//  key weightage.AllocType,
  key weightage.AllocationPeriod,
  key weightage.RefPeriod,
      cast(case weightage.AllocationPeriod
      when '04' then
      case when cast(poper as abap.dec(3,0)) - cast(weightage.RefPeriod as abap.dec(3,0)) < 0 then
      concat('000',cast(cast(poper as abap.dec(3,0)) - cast(weightage.RefPeriod as abap.dec(3,0)) as abap.char( 256 )))
      else
      case when cast(poper as abap.dec(3,0)) - cast(weightage.RefPeriod as abap.dec(3,0)) <= 9 then
      concat('00',cast(cast(poper as abap.dec(3,0)) - cast(weightage.RefPeriod as abap.dec(3,0)) as abap.char( 256 )))
      else
      concat('0',cast(cast(poper as abap.dec(3,0)) - cast(weightage.RefPeriod as abap.dec(3,0)) as abap.char( 256 ))) end end
      when '05' then
      case when cast(poper as abap.dec(3,0)) - 1 < 0 then
      concat('000',cast(cast(poper as abap.dec(3,0)) as abap.char( 256 )))
      else
      case when cast(poper as abap.dec(3,0)) - 1 > 9 then
      concat('0',cast(cast(poper as abap.dec(3,0)) - cast(1 as abap.dec(3,0)) as abap.char( 256 )))
      else
      concat('00',cast(cast(poper as abap.dec(3,0)) - cast(1 as abap.dec(3,0)) as abap.char( 256 )))
      end end
      else
      weightage.RefPeriod end as abap.numc(3)) as fromRefperiod,
      weightage.Weightage
}
where
  chargeout = 'I'
