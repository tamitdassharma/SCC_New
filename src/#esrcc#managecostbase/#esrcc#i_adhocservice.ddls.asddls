@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Adhoc Service Chargeout Details'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_ADHOCSERVICE 
as select from /ESRCC/I_ADHOCSERVICE_DETAILS as adhoc
      
{   
   
   key Serviceproduct,
   key markupvalidfrom,
   key markupvalidto,
   key validfrom,
   key validto,
   Servicetype,
   Transactiongroup,
   IpOwner,
   Oecdtpg,
   serviceproductdescription,
   intra_origcost,
   intra_passcost,
   origcost,
   passcost,
   chargeoutruleid,
   chargeout_method,
   key_version,
   cost_version,
   uom,
   adhoc_allocation_key,
   ruledescription,
   /* Associations */
   allockeys.text as allockeydescription    
} 
where chargeout_method = 'A'
