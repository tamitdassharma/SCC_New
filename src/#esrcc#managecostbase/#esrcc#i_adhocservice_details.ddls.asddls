@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Adhoc Service Chargeout Details'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_ADHOCSERVICE_DETAILS
  as select from /ESRCC/I_SRVPRODUCT_DETAILS as srvpro

  association [0..1] to /ESRCC/I_ALLOCKEYS as allockeys 
  on allockeys.Allockey = $projection.adhoc_allocation_key
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
      // chargeout details
      @UI.textArrangement: #TEXT_ONLY
      rule.chargeout_method,
      rule.key_version,
      rule.cost_version,
      rule.uom,
      rule.adhoc_allocation_key,
      @Semantics.text: true
      rulet.description as ruledescription,
      /* Associations */
      allockeys
}
