@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Receivers Cost'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_REC_COST
  as select from /ESRCC/I_RECCOST_UNION as reccost
  association        to parent /ESRCC/I_SRVMKUP_COST as _ServiceCost on  $projection.Fplv           = _ServiceCost.Fplv
                                                                     and $projection.Ryear          = _ServiceCost.Ryear
                                                                     and $projection.Poper          = _ServiceCost.Poper
                                                                     and $projection.Sysid          = _ServiceCost.Sysid
                                                                     and $projection.Legalentity    = _ServiceCost.Legalentity
                                                                     and $projection.Ccode          = _ServiceCost.Ccode
                                                                     and $projection.Costobject     = _ServiceCost.Costobject
                                                                     and $projection.Costcenter     = _ServiceCost.Costcenter
                                                                     and $projection.Serviceproduct = _ServiceCost.Serviceproduct
                                                                     and $projection.Currencytype   = _ServiceCost.Currencytype
  
  association [0..1] to /ESRCC/I_RECEIVINGENTITY_F4  as rcventity    on  rcventity.Receivingentity = $projection.Receivingentity

  association [0..1] to /ESRCC/I_STATUS              as status       on  status.Status = reccost.Status
  
  association [0..1] to I_CountryText as _ReceivingCountryText
  on _ReceivingCountryText.Country = $projection.country
  and _ReceivingCountryText.Language = $session.system_language 
  
  association [0..1] to I_UnitOfMeasureText as _UoM
  on _UoM.UnitOfMeasure_E = reccost.Uom
  and _UoM.Language = $session.system_language  
  
  association [0..1] to /ESRCC/I_CONSUMPTION_VERSION as _ConsumptionVersion
  on _ConsumptionVersion.ConsumptionVersion = $projection.ConsumptionVersion
  
  association [0..1] to /ESRCC/I_KEY_VERSION as _KeyVersion
  on _KeyVersion.KeyVersion = $projection.KeyVersion
  
  association [0..1] to /ESRCC/I_INVOICESTATUS      as _InvoiceStatus    
  on  _InvoiceStatus.InvoiceStatus = $projection.InvoiceStatus
  
{
  key Fplv                  as Fplv,
  key Ryear                 as Ryear,
  key Poper                 as Poper,
  key Sysid                 as Sysid,
  key reccost.Legalentity   as Legalentity,
  key Ccode                 as Ccode,
  key Costobject            as Costobject,
  key Costcenter            as Costcenter,
  key Serviceproduct        as Serviceproduct,
  key Receivingentity       as Receivingentity,
  key Currencytype,
      Reckpi                as Reckpi,
      Uom,
      Reckpishare,
      _ServiceCost.Billingfrequqncy,
      _ServiceCost.Billingperiod,
      _ServiceCost.Chargeout,
      _ServiceCost.CapacityVersion,
      ConsumptionVersion,
      KeyVersion,
      _ServiceCost.Servicetype,
      _ServiceCost.Transactiongroup,

      //Direct Allocation
      _ServiceCost.transferprice,
      _ServiceCost.tp_valueaddmarkupabs,
      _ServiceCost.tp_passthrumarkupabs,
      _ServiceCost.tp_totalsrvmarkupabs,
      _ServiceCost.Servicecostperunit,
      _ServiceCost.Valueaddcostperunit,
      _ServiceCost.Passthrucostperunit,

      //Indirect Allocation
      Recvalueaddmarkupabs  as onvalueaddedmarkupabs,
      Recpassthrumarkupabs  as onvpassthrudmarkupabs,
      Rectotalmarkupabs     as totaludmarkupabs,
      Reccostshare          as totalcostbaseabs,
      Recvalueadded         as valuaddabs,
      Recpassthrough        as passthruabs,
      Reckpishareabs        as chargeoutforservice,
      reccost.Status,
      Workflowid,
      Exchdate,
      rcventity.Country,
      _ServiceCost.Country as legalentitycountry,
      _ServiceCost.Currency,
      _ServiceCost.Costshare,
      _ServiceCost.Stewardship,
      _ServiceCost.costdatasetdescription,
      _ServiceCost.legalentitydescription,
      _ServiceCost.ccodedescription,
      _ServiceCost.costobjectdescription,
      _ServiceCost.costcenterdescription,
      _ServiceCost.Serviceproductdescription,
      _ServiceCost.Servicetypedescription,
      rcventity.Description as receivingentitydescription,
      status.text           as statusdescription,
      _ServiceCost.billingfrequencydescription,
      _ServiceCost.billingperioddescription,
      _ServiceCost.hidedirectalloc,
      case reccost.Status
       when 'D' then 2
       when 'W' then 2
       when 'A' then 3
       when 'F' then 3
       when 'R' then 1
       when 'C' then 1
       else
       0
      end                   as statuscriticallity,
      InvoiceNumber,
      InvoiceStatus,
      _InvoiceStatus.text as invoicestatusdescription,
      CreatedBy,
      CreatedAt,
      LastChangedAt,
      LastChangedBy,
      
      //association
      _ConsumptionVersion,
      _KeyVersion,
      _ReceivingCountryText,
      _UoM,
      _ServiceCost
}
