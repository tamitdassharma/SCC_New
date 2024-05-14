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
define root view entity /ESRCC/I_RECCOST_WORKFLOW 
            as select from /ESRCC/I_REC_COST as reccost     
            
  association [0..1] to I_CountryText as _legalCountryText
  on _legalCountryText.Country = $projection.legalentitycountry
  and _legalCountryText.Language = $session.system_language                                               

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
        
    tp_totalsrvmarkupabs,   
    tp_valueaddmarkupabs,    
    tp_passthrumarkupabs,
    
    onvalueaddedmarkupabs,
    onvpassthrudmarkupabs,
    totaludmarkupabs,
    
    totalcostbaseabs,
    
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
    Costshare,
    Stewardship,    
    legalentitydescription,
    ccodedescription,
    costobjectdescription,
    costcenterdescription,
    Serviceproductdescription,
    Servicetypedescription,
    statusdescription,
    receivingentitydescription,
    Country as receivingentitycountry,
    legalentitycountry,
    //association
    _ReceivingCountryText,
    _legalCountryText
}
