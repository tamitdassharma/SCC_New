@EndUserText.label: 'Receiver Total Cost'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'Fplv', 'Ryear', 'Poper', 'Legalentity', 'Ccode', 'Costobject', 'Costcenter', 'Serviceproduct' ]
define view entity /ESRCC/C_REC_COST 
as projection on /ESRCC/I_REC_COST
{
    key Fplv,
    key Ryear,
    key Poper,
    key Sysid,
    key Legalentity,
    key Ccode,
    key Costobject,
    key Costcenter,    
    key Serviceproduct,
    @ObjectModel.text.element: [ 'receivingentitydescription' ]
    key Receivingentity,
    key Currencytype,
    @ObjectModel.text.element: [ 'consumptionversiontext' ]
    ConsumptionVersion,
    @ObjectModel.text.element: [ 'keyversiontext' ]
    KeyVersion,
    Reckpi,
    @ObjectModel.text.element: [ 'unitname' ]
    Uom,
    @DefaultAggregation: #SUM
    Reckpishare,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    chargeoutforservice,
    @ObjectModel.text.element: [ 'statusdescription' ]
    Status,
    Workflowid,
    Currency,
    receivingentitydescription,
    statusdescription,
    @ObjectModel.text.element: [ 'receivingcountryname' ]
    Country,
    CreatedBy,
    CreatedAt,
    LastChangedAt,
    LastChangedBy,
    _ReceivingCountryText.CountryName as receivingcountryname,
    _UoM.UnitOfMeasureName as unitname,
    _ConsumptionVersion.text as consumptionversiontext,
    _KeyVersion.text as keyversiontext,    
    /* Associations */    
    _ServiceCost : redirected to parent /ESRCC/C_SRVMKUP_COST
}
