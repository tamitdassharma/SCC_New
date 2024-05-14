@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Service Final Charge Out Amount'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity /ESRCC/I_SRVMKUP_COST
  as select from /ESRCC/I_SRVCOST_UNION as srvcost

  composition [0..*] of /ESRCC/I_REC_COST            as _ReceiverCost

  association        to parent /ESRCC/I_CC_COST             as _CostCenterCost on  $projection.Fplv        = _CostCenterCost.Fplv
                                                                               and $projection.Ryear       = _CostCenterCost.Ryear
                                                                               and $projection.Poper       = _CostCenterCost.Poper
                                                                               and $projection.Sysid       = _CostCenterCost.Sysid
                                                                               and $projection.Legalentity = _CostCenterCost.Legalentity
                                                                               and $projection.Ccode       = _CostCenterCost.Ccode
                                                                               and $projection.Costobject  = _CostCenterCost.Costobject
                                                                               and $projection.Costcenter  = _CostCenterCost.Costcenter 
                                                                               and $projection.Currencytype  = _CostCenterCost.Currencytype   

  association [0..1] to /ESRCC/I_SERVICEPRODUCT_F4   as serviceproduct         on  serviceproduct.ServiceProduct = srvcost.Serviceproduct

  association [0..1] to /ESRCC/I_SERVICETYPE_F4      as srvtyp                 on  srvtyp.ServiceType = srvcost.Servicetype

  association [0..1] to /ESRCC/I_TRANSACTIONGROUP_F4 as srvtransactiongroup    on  srvtransactiongroup.Transactiongroup = srvcost.Transactiongroup
  
  association [0..1] to /ESRCC/I_STATUS as status
  on status.Status = srvcost.Status
  
  association [0..1] to /ESRCC/I_CHGOUT as method
  on method.Chargeout = $projection.Chargeout
  
  association [0..1] to I_UnitOfMeasureText as _UoM
  on _UoM.UnitOfMeasure_E = srvcost.Uom
  and _UoM.Language = $session.system_language 
  
  association [0..1] to /ESRCC/I_CURR as _CurrencyTypeText
  on _CurrencyTypeText.Currencytype = $projection.Currencytype
  
  association [0..1] to /ESRCC/I_CAPACITY_VERSION as _CapacityVersion
  on _CapacityVersion.CapacityVersion = $projection.CapacityVersion
  
{
    key Fplv as Fplv,
    key Ryear as Ryear,
    key Poper as Poper,
    key Sysid as Sysid,
    key Legalentity as Legalentity,
    key Ccode as Ccode,
    key Costobject as Costobject,
    key Costcenter as Costcenter,
//    key Billfrequency,
    key srvcost.Serviceproduct as Serviceproduct,
    key srvcost.Currencytype,
    _CostCenterCost.Billingfrequqncy,
    _CostCenterCost.Billingperiod,
    srvcost.Servicetype as Servicetype,
    srvcost.Transactiongroup as Transactiongroup, 
    CapacityVersion,  
    Costshare as Costshare,    
    Srvcostshare,  
    Valueaddshare,     
    Passthroughshare,   
     
    Valueaddmarkup as Valueaddmarkup,    
    Passthrumarkup as Passthroughmarkup,

    Chargeout,
    Planning,
    Uom, 
    Servicecostperunit,   
    Valueaddcostperunit,
    Passthrucostperunit,
        
//Transfer Price Markups  
    Tp_valueaddmarkupcostperunit + Tp_passthrumarkupcostperunit as tp_totalsrvmarkupabs,
    Tp_valueaddmarkupcostperunit as tp_valueaddmarkupabs,
    Tp_passthrumarkupcostperunit  as tp_passthrumarkupabs,      
//Markups      
    Valueaddmarkupabs,
    Passthrumarkupabs,    
 //Totals
    Valueaddmarkupabs + Passthrumarkupabs as totalsrvmarkupabs,
    Servicecostperunit + Tp_valueaddmarkupcostperunit + Tp_passthrumarkupcostperunit as transferprice,
      Srvcostshare + Valueaddmarkupabs + Passthrumarkupabs as totalchargeoutamount,
     
      srvcost.Status,
      Workflowid,
      cast(case Chargeout
      when 'D' then 'X' 
      when 'I' then ''
      else  '' end as abap_boolean preserving type) as hidedirectalloc,
      
      case srvcost.Status 
         when 'D' then 2
         when 'W' then 2
         when 'A' then 3
         when 'F' then 3
         when 'R' then 1 
         when 'C' then 1 
         else
         0
        end as statuscriticallity,
      _CostCenterCost.Remainingcostbase,
      _CostCenterCost.Includetotalcost,
      _CostCenterCost.Origtotalcost,
      _CostCenterCost.Passtotalcost,
      _CostCenterCost.costdatasetdescription,
      _CostCenterCost.legalentitydescription,
      _CostCenterCost.ccodedescription,
      _CostCenterCost.costobjectdescription,
      _CostCenterCost.costcenterdescription,
      _CostCenterCost.billingfrequencydescription,
      _CostCenterCost.billingperioddescription,
      _CostCenterCost.Country,
      serviceproduct.Description                         as Serviceproductdescription,
      srvtyp.Description                                 as Servicetypedescription,
      srvtransactiongroup.Description                    as Transactiongroupdescription,
      status.text as statusdescription,
      _CostCenterCost.Stewardship,
      _CostCenterCost.Currency,
      method.text as chargeoutdescription,
      CreatedBy,
      CreatedAt,
      LastChangedAt,
      LastChangedBy,
      //association
      _CostCenterCost,
      _ReceiverCost,
      _UoM,
      _CurrencyTypeText,
      _CapacityVersion

}
