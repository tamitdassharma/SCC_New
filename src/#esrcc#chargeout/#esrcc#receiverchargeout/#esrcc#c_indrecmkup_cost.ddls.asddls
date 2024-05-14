@EndUserText.label: 'Receiver Markup View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity /ESRCC/C_INDRECMKUP_COST 
as projection on /ESRCC/I_INDRECMKUP_COST
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
//    Reckpi,
//    Reckpishare,
    Currency,
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
    /* Associations */
    _ReceiverCost : redirected to parent /ESRCC/C_RECEIVER_COST
}
