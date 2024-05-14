@EndUserText.label: 'Service Cost Share'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_SRVMKUP_COST 
as projection on /ESRCC/I_SRVMKUP_COST
{
    @ObjectModel.text.element: [ 'costdatasetdescription' ]
    key Fplv,
    key Ryear,
    key Poper,
    key Sysid,
    @ObjectModel.text.element: [ 'legalentitydescription' ]
    key Legalentity,
    @ObjectModel.text.element: [ 'ccodedescription' ]
    key Ccode,
    @ObjectModel.text.element: [ 'costobjectdescription' ]
    key Costobject,
    @ObjectModel.text.element: [ 'costcenterdescription' ]
    key Costcenter,
    @ObjectModel.text.element: [ 'Serviceproductdescription' ]
    key Serviceproduct,
    @ObjectModel.text.element: [ 'currencytypetext' ]
    key Currencytype,
    @ObjectModel.text.element: [ 'Servicetypedescription' ]
    Servicetype,
    @ObjectModel.text.element: [ 'Transactiongroupdescription' ]
    Transactiongroup,
    @DefaultAggregation: #SUM
    Costshare,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Srvcostshare,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Valueaddshare,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Passthroughshare,
    Valueaddmarkup,
    Passthroughmarkup,
    @ObjectModel.text.element: [ 'chargeoutdescription' ]
    Chargeout,
    @ObjectModel.text.element: [ 'capacityversiontext' ]
    CapacityVersion,
    Planning,
    @ObjectModel.text.element: [ 'unitname' ]
    Uom,
//    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Servicecostperunit,
//    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Valueaddcostperunit,
//    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Passthrucostperunit,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Valueaddmarkupabs,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Passthrumarkupabs,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    totalsrvmarkupabs,
//    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    transferprice,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    totalchargeoutamount, 
    
    costdatasetdescription,
    legalentitydescription,
    ccodedescription,
    costobjectdescription,
    costcenterdescription,
    Serviceproductdescription,
    Servicetypedescription,
    Transactiongroupdescription,
    statusdescription,
    chargeoutdescription,

    Currency,
    @ObjectModel.text.element: [ 'statusdescription' ]
    Status,
    Workflowid,
    CreatedBy,
    CreatedAt,
    LastChangedAt,
    LastChangedBy,
    @Semantics.text: true
    _UoM.UnitOfMeasureName as unitname,
    @Semantics.text: true
    _CurrencyTypeText.text as currencytypetext,
    _CapacityVersion.text as capacityversiontext,
    /* Associations */
    _CostCenterCost : redirected to parent /ESRCC/C_CC_COST,
    _ReceiverCost: redirected to composition child /ESRCC/C_REC_COST
}
