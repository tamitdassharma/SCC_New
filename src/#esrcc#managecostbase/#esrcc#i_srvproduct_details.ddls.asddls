@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Adhoc Service Chargeout Details'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_SRVPRODUCT_DETAILS 
as select from /esrcc/srvpro as srvpro
    
    association [0..*] to /esrcc/srvmkp as srvmkup
     on srvmkup.serviceproduct = $projection.Serviceproduct
     
    association [0..1] to /esrcc/srvprot  as srvprot 
        on  srvpro.serviceproduct = srvprot.serviceproduct
       and srvprot.spras         = $session.system_language
     
    association [0..*] to /esrcc/chargeout as _chargeout
     on _chargeout.serviceproduct = $projection.Serviceproduct
     
    association [0..1] to /esrcc/co_rule as rule
      on rule.rule_id = $projection.chargeoutruleid
      and rule.workflow_status = 'F'
      
    association [0..1] to /esrcc/co_rulet as rulet
      on rulet.rule_id = $projection.chargeoutruleid
      and rulet.spras = $session.system_language
{
    key srvpro.serviceproduct as Serviceproduct,
    key srvmkup.validfrom as markupvalidfrom,
    key srvmkup.validto as markupvalidto,
    key _chargeout.validfrom,
    key _chargeout.validto,
    srvpro.servicetype as Servicetype,
    srvpro.transactiongroup as Transactiongroup,
    srvpro.ip_owner as IpOwner,
    srvpro.oecdtpg as Oecdtpg,
    srvprot.description as serviceproductdescription,
    
    srvmkup.intra_origcost,
    srvmkup.intra_passcost,
    srvmkup.origcost,
    srvmkup.passcost,
    
  //allocation
    _chargeout.chargeout_rule_id as chargeoutruleid,
    
  //associations
    rule,
    rulet
    
}
