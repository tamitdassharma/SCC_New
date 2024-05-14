@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Cost Center Cost'
@Metadata.ignorePropagatedAnnotations: true
@Analytics.dataCategory: #CUBE
define root view entity /ESRCC/I_CC_COST
as select from /ESRCC/I_CC_COST_UNION as cc_cost   
  
 composition [0..*] of /ESRCC/I_SRVMKUP_COST            as _ServiceMarkup

 association [0..1] to /ESRCC/I_LEGALENTITY_F4 as legalentity
  on legalentity.Legalentity = cc_cost.Legalentity
  
  association [0..1] to /ESRCC/I_COMPANYCODES_F4 as ccode  
  on ccode.Ccode = cc_cost.Ccode
  and ccode.Sysid = cc_cost.Sysid
  and ccode.Legalentity = cc_cost.Legalentity
  
  association [0..1] to /ESRCC/I_COSTOBJECTS as costobject  
  on costobject.Costobject = cc_cost.Costobject
  
  association [0..1] to /ESRCC/I_COSCEN_F4 as costcenter
  on costcenter.Costcenter = cc_cost.Costcenter
  and costcenter.Sysid = cc_cost.Sysid
  and costcenter.Costobject = cc_cost.Costobject
  
  association [0..1] to /ESRCC/I_COSTDATASET as costdataset
  on costdataset.costdataset = cc_cost.Fplv
  
  association [0..1] to /ESRCC/I_PROFITCENTER_F4 as profitcenter
  on profitcenter.ProfitCenter = cc_cost.Profitcenter
  
  association [0..1] to /ESRCC/I_BUSINESSDIV_F4 as businessdiv
  on businessdiv.BusinessDivision = cc_cost.Businessdivision
  
  association [0..1] to /ESRCC/I_BILLINGFREQ as billingfreq
  on billingfreq.Billingfreq = cc_cost.Billfrequency
  
  association [0..1] to /ESRCC/I_BILLINGPERIOD as billingperiod
  on billingperiod.Billingperiod = cc_cost.Billingperiod
  
  association [0..1] to /ESRCC/I_STATUS as status
  on status.Status = cc_cost.Status
  
  association [0..1] to I_CountryText as _legalCountryText
  on _legalCountryText.Country = $projection.country
  and _legalCountryText.Language = $session.system_language  
  
{
    key Fplv as Fplv,
    key Ryear as Ryear,
    key Poper as Poper,
    key Sysid as Sysid,
    key cc_cost.Legalentity as Legalentity,
    key cc_cost.Ccode as Ccode,
    key cc_cost.Costobject as Costobject,
    key cc_cost.Costcenter as Costcenter,
    key Currencytype,
    cc_cost.Billfrequency as Billingfrequqncy,
    cc_cost.Businessdivision as Businessdivision,
    cc_cost.Profitcenter as Profitcenter,
    Controllingarea as Controllingarea,    
    cc_cost.Billingperiod as Billingperiod,
    Currency,
    @Semantics.amount.currencyCode: 'Currency'
    Totalcost,
    @Semantics.amount.currencyCode: 'Currency'
    Excludedtotalcost,
    ( Totalcost - Excludedtotalcost ) as Includetotalcost,
    Origtotalcost,
    Passtotalcost,  
    Stewardship as Stewardship,
    cast((Totalcost -  Excludedtotalcost) * (1 - (Stewardship / 100)) as abap.dec(23,2)) as Remainingcostbase,
    cc_cost.Status,
    Workflowid,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    ccode.ccodedescription,
    legalentity.Description as legalentitydescription,
    costobject.text as costobjectdescription,
    costcenter.Description as costcenterdescription,
    costdataset.text as costdatasetdescription,
    businessdiv.Description as businessdescription,
    profitcenter.profitcenterdescription,
    billingfreq.text as billingfrequencydescription,
    billingperiod.text as billingperioddescription,
    status.text as statusdescription,
    legalentity.Country,
    _legalCountryText,
    // Make association public   
    _ServiceMarkup
    
}

