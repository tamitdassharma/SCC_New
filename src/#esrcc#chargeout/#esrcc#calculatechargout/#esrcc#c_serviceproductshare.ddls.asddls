@EndUserText.label: 'Service Cost Share'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity /ESRCC/C_ServiceProductShare 
as projection on /ESRCC/I_ServiceProductShare 
{
    key UUID,
    key ParentUUID,
    @ObjectModel.text.element: [ 'currencytypetext' ]
    key Currencytype,     
    Serviceproduct,  
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
    @ObjectModel.text.element: [ 'chargeoutdescription' ]
    Chargeout,
    @ObjectModel.text.element: [ 'capacityversiontext' ]
    CapacityVersion,
    @Semantics.quantity.unitOfMeasure: 'Uom'
    Planning,
    @ObjectModel.text.element: [ 'unitname' ]
    Uom,
    @Semantics.amount.currencyCode: 'Currency'
    Servicecostperunit,
    @Semantics.amount.currencyCode: 'Currency'
    Valueaddcostperunit,
    @Semantics.amount.currencyCode: 'Currency'
    Passthrucostperunit,
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
    _CostCenterCost : redirected to parent /ESRCC/C_CostBaseStewardship,
    _ReceiverCost: redirected to composition child /ESRCC/C_ReceiverChargeout
}
