@EndUserText.label: 'Receiver Markup View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity /ESRCC/C_RECMKUP_COST 
as projection on /ESRCC/I_RECMKUP_COST
{

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
    @ObjectModel.text.element: [ 'receivingentitydescription' ]
    key Receivingentity,
    key Currencytype,
    key Billingfrequqncy,
    key Billingperiod,
//    Chargeout,
//    Receivergroup,
//    Allockey,
    @Semantics.quantity.unitOfMeasure: 'UoM'
    Reckpi,
    @ObjectModel.text.element: [ 'unitname' ]
    UoM,
    Currency,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    transferprice,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Servicecostperunit,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Valueaddcostperunit,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    Passthrucostperunit,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    tp_valueaddmarkupabs,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    tp_passthrumarkupabs,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    tp_totalsrvmarkupabs,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    onvalueaddedmarkupabs,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    onvpassthrudmarkupabs,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    totaludmarkupabs,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    totalcostbaseabs,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    valuaddabs,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    passthruabs,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'Currency'
    chargeoutforservice,
//    Costshare,
//    Stewardship,
    legalentitydescription,
    ccodedescription,
    costobjectdescription,
    costcenterdescription,
    Serviceproductdescription,
    Servicetypedescription,
    receivingentitydescription,
    _UoM.UnitOfMeasureName as unitname,
    /* Associations */
    _ReceiverCost : redirected to parent /ESRCC/C_RECEIVER_COST
}
