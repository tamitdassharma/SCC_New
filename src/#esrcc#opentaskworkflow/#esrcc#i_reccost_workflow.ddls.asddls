@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Receivers Cost'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define root view entity /ESRCC/I_RECCOST_WORKFLOW 
<<<<<<< HEAD
            as select from /ESRCC/I_REC_COST as reccost     
            
  association [0..1] to I_CountryText as _legalCountryText
  on _legalCountryText.Country = $projection.legalentitycountry
  and _legalCountryText.Language = $session.system_language                                               
=======
            as select from /ESRCC/I_ReceiverChargeout as reccost                                                           
>>>>>>> origin/main

{
    key Fplv as Fplv,
    key Ryear as Ryear,
    key Poper as Poper,
    key Sysid as Sysid,
    key Legalentity as Legalentity,
    key Ccode as Ccode,
    key Costobject as Costobject,
    key Costcenter as Costcenter,
    key Serviceproduct as Serviceproduct,
    key Receivingentity as Receivingentity,
    key Currencytype,
    key Billingfrequqncy,
    key Billingperiod,
    Reckpi as Reckpi,  
    Reckpishare as Reckpishare,
    Chargeout as Chargeout,
  //Direct Allocation   
    transferprice,
    Servicecostperunit,
    Valueaddcostperunit,
    Passthrucostperunit,  
        
<<<<<<< HEAD
    tp_totalsrvmarkupabs,   
    tp_valueaddmarkupabs,    
    tp_passthrumarkupabs,
    
    onvalueaddedmarkupabs,
    onvpassthrudmarkupabs,
    totaludmarkupabs,
    
    totalcostbaseabs,
=======
    TotalRecMarkup,   
    Valueaddmarkup,    
    Passthrumarkup,   
   
    RecCostShare,
>>>>>>> origin/main
    
    valuaddabs,
    passthruabs,
    chargeoutforservice,
    
    Status,
    Workflowid, 
    CreatedBy,
    CreatedAt,
    LastChangedAt,
    LastChangedBy,
    
    Currency,
<<<<<<< HEAD
    Costshare,
    Stewardship,
    costdatasetdescription,   
    legalentitydescription,
=======
    _ServiceCost._CostCenterCost.costdatasetdescription,   
    _ServiceCost._CostCenterCost.legalentitydescription,
>>>>>>> origin/main
    ccodedescription,
    costobjectdescription,
    costcenterdescription,
    Serviceproductdescription,
    Servicetypedescription,
    statusdescription,
    receivingentitydescription,
<<<<<<< HEAD
    billingfrequencydescription,
    billingperioddescription,
=======
    ccodedescription as Reccodedescription,
    costobjectdescription as Reccostobjectdescription,
    costcenterdescription as Reccostcenterdescription,
>>>>>>> origin/main
    Country as receivingentitycountry,
    legalentitycountry,
    //association
    _ReceivingCountryText,
    _legalCountryText
}
