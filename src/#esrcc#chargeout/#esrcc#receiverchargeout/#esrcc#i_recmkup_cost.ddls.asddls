@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Receivers Cost'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity /ESRCC/I_RECMKUP_COST
  as select from /ESRCC/I_REC_COST as reccost

  association        to parent /ESRCC/I_RECEIVER_COST as _ReceiverCost on  $projection.Fplv             = _ReceiverCost.Fplv
                                                                       and $projection.Ryear            = _ReceiverCost.Ryear
                                                                       and $projection.Poper            = _ReceiverCost.Poper
                                                                       and $projection.Sysid            = _ReceiverCost.Sysid
                                                                       and $projection.Legalentity      = _ReceiverCost.Legalentity
                                                                       and $projection.Ccode            = _ReceiverCost.Ccode
                                                                       and $projection.Serviceproduct   = _ReceiverCost.Serviceproduct
                                                                       and $projection.Receivingentity  = _ReceiverCost.Receivingentity
                                                                       and $projection.Billingfrequqncy = _ReceiverCost.Billingfrequqncy
                                                                       and $projection.Currencytype     = _ReceiverCost.Currencytype

  association [0..1] to /ESRCC/I_RECEIVINGENTITY_F4   as rcventity     on  rcventity.Receivingentity = $projection.Receivingentity
  
  association [0..1] to I_UnitOfMeasureText as _UoM
  on _UoM.UnitOfMeasure_E = reccost.Uom
  and _UoM.Language = $session.system_language 
{
  key Fplv                                                    as Fplv,
  key Ryear                                                   as Ryear,
  key Poper                                                   as Poper,
  key Sysid                                                   as Sysid,
  key reccost.Legalentity                                     as Legalentity,
  key Ccode                                                   as Ccode,
  key Costobject                                              as Costobject,
  key Costcenter                                              as Costcenter,
  key Serviceproduct                                          as Serviceproduct,
  key Receivingentity                                         as Receivingentity,
  key Currencytype,
  key Billingfrequqncy,
  key Billingperiod,
      Reckpi                                                  as Reckpi,
      Uom                                                     as UoM,
      Reckpishare                                             as Reckpishare,
      Chargeout                                               as Chargeout,
      //Direct Allocation
      @Semantics.amount.currencyCode: 'Currency'
      case when Currencytype = 'L' and Currency <> rcventity.LocalCurr then
      currency_conversion( 
                           client => $session.client,
                           amount => cast(transferprice as abap.curr(23,2)),
                           source_currency => Currency,
                           round => 'X',
                           target_currency => rcventity.LocalCurr,
                           exchange_rate_date => Exchdate,
                           error_handling => 'SET_TO_NULL' )
      else cast(transferprice as abap.curr(23,2)) end         as transferprice,

      @Semantics.amount.currencyCode: 'Currency'
      case when Currencytype = 'L' and Currency <> rcventity.LocalCurr then
      currency_conversion( 
                           client => $session.client,
                           amount => cast(Servicecostperunit as abap.curr(23,2)),
                           source_currency => Currency,
                           round => 'X',
                           target_currency => rcventity.LocalCurr,
                           exchange_rate_date => Exchdate,
                           error_handling => 'SET_TO_NULL' )
      else cast(Servicecostperunit as abap.curr(23,2)) end    as Servicecostperunit,
      
      @Semantics.amount.currencyCode: 'Currency'
      case when Currencytype = 'L' and Currency <> rcventity.LocalCurr then
      currency_conversion( 
                           client => $session.client,
                           amount => cast(Valueaddcostperunit as abap.curr(23,2)),
                           source_currency => Currency,
                           round => 'X',
                           target_currency => rcventity.LocalCurr,
                           exchange_rate_date => Exchdate,
                           error_handling => 'SET_TO_NULL' )
      else cast(Valueaddcostperunit as abap.curr(23,2)) end   as Valueaddcostperunit,
      
      @Semantics.amount.currencyCode: 'Currency'
      case when Currencytype = 'L' and Currency <> rcventity.LocalCurr then
      currency_conversion( 
                         client => $session.client,
                         amount => cast(Passthrucostperunit as abap.curr(23,2)),
                         source_currency => Currency,
                         round => 'X',
                         target_currency => rcventity.LocalCurr,
                         exchange_rate_date => Exchdate,
                         error_handling => 'SET_TO_NULL' )
      else cast(Passthrucostperunit as abap.curr(23,2)) end   as Passthrucostperunit,
      

      @Semantics.amount.currencyCode: 'Currency'
      case when Currencytype = 'L' and Currency <> rcventity.LocalCurr then
      currency_conversion( 
                         client => $session.client,
                         amount => cast(tp_totalsrvmarkupabs as abap.curr(23,2)),
                         source_currency => Currency,
                         round => 'X',
                         target_currency => rcventity.LocalCurr,
                         exchange_rate_date => Exchdate,
                         error_handling => 'SET_TO_NULL' )
      else cast(tp_totalsrvmarkupabs as abap.curr(23,2)) end  as tp_totalsrvmarkupabs,
      
      @Semantics.amount.currencyCode: 'Currency'
      case when Currencytype = 'L' and Currency <> rcventity.LocalCurr then
      currency_conversion( 
                         client => $session.client,
                         amount => cast(tp_valueaddmarkupabs as abap.curr(23,2)),
                         source_currency => Currency,
                         round => 'X',
                         target_currency => rcventity.LocalCurr,
                         exchange_rate_date => Exchdate,
                         error_handling => 'SET_TO_NULL' )
      else cast(tp_valueaddmarkupabs as abap.curr(23,2)) end  as tp_valueaddmarkupabs,
      
      @Semantics.amount.currencyCode: 'Currency'
      case when Currencytype = 'L' and Currency <> rcventity.LocalCurr then
      currency_conversion( 
                         client => $session.client,
                         amount => cast(tp_passthrumarkupabs as abap.curr(23,2)),
                         source_currency => Currency,
                         round => 'X',
                         target_currency => rcventity.LocalCurr,
                         exchange_rate_date => Exchdate,
                         error_handling => 'SET_TO_NULL' )
      else cast(tp_passthrumarkupabs as abap.curr(23,2)) end  as tp_passthrumarkupabs,
      


      //Markup
      @Semantics.amount.currencyCode: 'Currency'
      case when Currencytype = 'L' and Currency <> rcventity.LocalCurr then
      currency_conversion( 
                         client => $session.client,
                         amount => cast(onvalueaddedmarkupabs as abap.curr(23,2)),
                         source_currency => Currency,
                         round => 'X',
                         target_currency => rcventity.LocalCurr,
                         exchange_rate_date => Exchdate,
                         error_handling => 'SET_TO_NULL' )
      else cast(onvalueaddedmarkupabs as abap.curr(23,2)) end as onvalueaddedmarkupabs,
      
      @Semantics.amount.currencyCode: 'Currency'
      case when Currencytype = 'L' and Currency <> rcventity.LocalCurr then
      currency_conversion( 
                         client => $session.client,
                         amount => cast(onvpassthrudmarkupabs as abap.curr(23,2)),
                         source_currency => Currency,
                         round => 'X',
                         target_currency => rcventity.LocalCurr,
                         exchange_rate_date => Exchdate,
                         error_handling => 'SET_TO_NULL' )
      else cast(onvpassthrudmarkupabs as abap.curr(23,2)) end as onvpassthrudmarkupabs,
      
      @Semantics.amount.currencyCode: 'Currency'
      case when Currencytype = 'L' and Currency <> rcventity.LocalCurr then
      currency_conversion( 
                         client => $session.client,
                         amount => cast(totaludmarkupabs as abap.curr(23,2)),
                         source_currency => Currency,
                         round => 'X',
                         target_currency => rcventity.LocalCurr,
                         exchange_rate_date => Exchdate,
                         error_handling => 'SET_TO_NULL' )
      else cast(totaludmarkupabs as abap.curr(23,2)) end      as totaludmarkupabs,

      //    Indirect Allocation
      @Semantics.amount.currencyCode: 'Currency'
      case when Currencytype = 'L' and Currency <> rcventity.LocalCurr then
      currency_conversion( 
                         client => $session.client,
                         amount => cast(totalcostbaseabs as abap.curr(23,2)),
                         source_currency => Currency,
                         round => 'X',
                         target_currency => rcventity.LocalCurr,
                         exchange_rate_date => Exchdate,
                         error_handling => 'SET_TO_NULL' )
      else cast(totalcostbaseabs as abap.curr(23,2)) end      as totalcostbaseabs,
      
      @Semantics.amount.currencyCode: 'Currency'
      case when Currencytype = 'L' and Currency <> rcventity.LocalCurr then
      currency_conversion( 
                         client => $session.client,
                         amount => cast(valuaddabs as abap.curr(23,2)),
                         source_currency => Currency,
                         round => 'X',
                         target_currency => rcventity.LocalCurr,
                         exchange_rate_date => Exchdate,
                         error_handling => 'SET_TO_NULL' )
      else cast(valuaddabs as abap.curr(23,2)) end            as valuaddabs,
      
      @Semantics.amount.currencyCode: 'Currency'
      case when Currencytype = 'L' and Currency <> rcventity.LocalCurr then
      currency_conversion( 
                         client => $session.client,
                         amount => cast(passthruabs as abap.curr(23,2)),
                         source_currency => Currency,
                         round => 'X',
                         target_currency => rcventity.LocalCurr,
                         exchange_rate_date => Exchdate,
                         error_handling => 'SET_TO_NULL' )
      else cast(passthruabs as abap.curr(23,2)) end           as passthruabs,
      
      @Semantics.amount.currencyCode: 'Currency'
      case when Currencytype = 'L' and Currency <> rcventity.LocalCurr then
      currency_conversion( 
                         client => $session.client,
                         amount => cast(chargeoutforservice as abap.curr(23,2)),
                         source_currency => Currency,
                         round => 'X',
                         target_currency => rcventity.LocalCurr,
                         exchange_rate_date => Exchdate,
                         error_handling => 'SET_TO_NULL' )
      else cast(chargeoutforservice as abap.curr(23,2)) end   as chargeoutforservice,

      reccost.Status,
      reccost.Workflowid,

      case Currencytype
      when 'L' then
      rcventity.LocalCurr
      else
      Currency end as Currency,
      Costshare,
      Stewardship,
      legalentitydescription,
      ccodedescription,
      costobjectdescription,
      costcenterdescription,
      Serviceproductdescription,
      Servicetypedescription,
      rcventity.Description                                   as receivingentitydescription,
      //    association
      _UoM,
      _ReceiverCost
}
