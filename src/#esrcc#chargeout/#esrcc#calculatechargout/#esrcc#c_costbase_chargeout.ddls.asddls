@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cost Base Chargeout'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity /ESRCC/C_COSTBASE_CHARGEOUT 
provider contract transactional_interface
as projection on /ESRCC/I_COSTBASE_CHARGEOUT
{
    key CcUuid,
    Fplv,
    Ryear,
    Poper,
    Sysid,
    Legalentity,
    Ccode,
    Costobject,
    Costcenter,
    Billfrequency,
    Functionalarea,
    Businessdivision,
    Profitcenter,
    Controllingarea,
    Billingperiod,
    Localcurr,
    Groupcurr,
    TotalcostL,
    TotalcostG,
    ExcludedtotalcostL,
    ExcludedtotalcostG,
    OrigtotalcostL,
    OrigtotalcostG,
    PasstotalcostL,
    PasstotalcostG,
    Stewardship,
    Status,
    Workflowid,
    Comments,
    Validon,
    Processtype,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt
}
