@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service Final Charge Out Amount'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define root view entity /ESRCC/I_SRV_WORKFLOW
  as select from /ESRCC/I_SRVMKUP_COST as srvcost
  
  association [0..1] to I_CountryText as _legalCountryText
  on _legalCountryText.Country = srvcost.Country
  and _legalCountryText.Language = $session.system_language  

{
  key Fplv                     as Fplv,
  key Ryear                    as Ryear,
  key Poper                    as Poper,
  key Sysid                    as Sysid,
  key Legalentity              as Legalentity,
  key Ccode                    as Ccode,
  key Costobject               as Costobject,
  key Costcenter               as Costcenter,
  key srvcost.Serviceproduct   as Serviceproduct,
  key srvcost.Currencytype,
      Billingfrequqncy,
      Billingperiod,
      Servicetype,
      Transactiongroup,
      CapacityVersion,
      Costshare,
      Srvcostshare,
      Valueaddshare,
      Passthroughshare,
      Valueaddmarkup,
      Passthroughmarkup,
      Chargeout,
      Planning,
      Uom,
      Servicecostperunit,
      Valueaddcostperunit,
      Passthrucostperunit,
      tp_totalsrvmarkupabs,
      tp_valueaddmarkupabs,
      tp_passthrumarkupabs,
      //Markups
      Valueaddmarkupabs,
      Passthrumarkupabs,

      //Totals
      totalsrvmarkupabs,
      transferprice,
      totalchargeoutamount,
      srvcost.Status,
      Workflowid,
      hidedirectalloc,
      statuscriticallity,
      Remainingcostbase,
      Includetotalcost,
      Origtotalcost,
      Passtotalcost,
      costdatasetdescription,
      billingfrequencydescription,
      billingperioddescription,
      legalentitydescription,
      ccodedescription,
      costobjectdescription,
      costcenterdescription,
      Serviceproductdescription,
      Servicetypedescription,
      Transactiongroupdescription,
      statusdescription,
      Stewardship,
      Currency,
      Country,
      chargeoutdescription,
      CreatedBy,
      CreatedAt,
      LastChangedAt,
      LastChangedBy,
      
//      associations
      _UoM,
      _CurrencyTypeText,
      _legalCountryText

}
