@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Receiver Total Cost'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_TOTALREC_COST
  as select from /ESRCC/I_REC_COST as reccost
{
  key Fplv,
  key Ryear,
  key Poper,
  key Sysid,
  key Legalentity,
  key Ccode,
  key Serviceproduct,
  key Receivingentity,
  key Currencytype,
      Billingfrequqncy,
      Billingperiod,
      Chargeout,
//      CapacityVersion,
//      ConsumptionVersion,
      Servicetype,
      Transactiongroup,
      Exchdate,
//      sum(Reckpi) as consumption,
//      Uom,
      case when Chargeout = 'D' then
      sum(transferprice) 
      else 0
      end  as Transferprice ,

      case when Chargeout = 'D' then
      sum(tp_totalsrvmarkupabs) else 0 end as totalmarkuptransferprice,

      sum(totaludmarkupabs)                as totaludmarkupabs,

      sum(totalcostbaseabs)                as Totalcostbase,

      sum(valuaddabs)                      as Totalvalueaddabs,

      sum(passthruabs)                     as Totalpassthruabs,

      sum(chargeoutforservice)             as chargeoutforservice,
      Currency

}
group by
  Fplv,
  Ryear,
  Poper,
  Sysid,
  Legalentity,
  Ccode,
  Serviceproduct,
  Receivingentity,
  Currencytype,
  Billingfrequqncy,
  Billingperiod,
  Chargeout,
//  CapacityVersion,
//  ConsumptionVersion,
  Servicetype,
  Transactiongroup,
  Exchdate,
  Currency
//  Uom
