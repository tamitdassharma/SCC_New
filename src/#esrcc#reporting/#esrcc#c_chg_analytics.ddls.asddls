@EndUserText.label: 'Charge-Out Receiver'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity /ESRCC/C_CHG_ANALYTICS 
provider contract transactional_query
as projection on /ESRCC/I_CHG_ANALYTICS
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
    @ObjectModel.text.element: [ 'serviceproductdescription' ]
    key Serviceproduct,
    @ObjectModel.text.element: [ 'receivingentitydescription' ]
    key Receivingentity,
    @ObjectModel.filter.enabled: false
    Billfrequency,
    @ObjectModel.filter.enabled: false
    Billingperiod,
    @ObjectModel.text.element: [ 'businessdescription' ]
    Businessdivision,
    @ObjectModel.text.element: [ 'profitcenterdescription' ]
    Profitcenter,
    @ObjectModel.filter.enabled: false
    Controllingarea,
    @ObjectModel.text.element: [ 'servicetypedescription' ]
    Servicetype,
    @ObjectModel.text.element: [ 'transactiongroupdescription' ]
    Transactiongroup,
    @ObjectModel.filter.enabled: false
    Chargeout,
//    CapacityVersion,
//    ConsumptionVersion,
//    Planning,
    @ObjectModel.filter.enabled: false
    Uom,
//    Stewardship,
    @ObjectModel.filter.enabled: false
    Reckpi,
    @ObjectModel.filter.enabled: false
    Reckpishare,
    @ObjectModel.filter.enabled: false
    @Semantics.amount.currencyCode: 'Localcurr'
    Reckpishareabsl,
    @ObjectModel.filter.enabled: false
    @Semantics.amount.currencyCode: 'Groupcurr'
    Reckpishareabsg,
    @ObjectModel.filter.enabled: false
    @Semantics.amount.currencyCode: 'Localcurr'
    Rectotalmarkupabsl,
    @ObjectModel.filter.enabled: false
    @Semantics.amount.currencyCode: 'Groupcurr'
    Rectotalmarkupabsg,
    @ObjectModel.filter.enabled: false
    @Semantics.amount.currencyCode: 'Localcurr'
    Recvalueaddmarkupabsl,
    @ObjectModel.filter.enabled: false
    @Semantics.amount.currencyCode: 'Groupcurr'
    Recvalueaddmarkupabsg,
    @ObjectModel.filter.enabled: false
    @Semantics.amount.currencyCode: 'Localcurr'
    Recpassthrumarkupabsl,
    @ObjectModel.filter.enabled: false
    @Semantics.amount.currencyCode: 'Groupcurr'
    Recpassthrumarkupabsg,
    @ObjectModel.filter.enabled: false
    @Semantics.amount.currencyCode: 'Localcurr'
    Reccostsharel,
    @ObjectModel.filter.enabled: false
    @Semantics.amount.currencyCode: 'Groupcurr'
    Reccostshareg,
    @ObjectModel.filter.enabled: false
    @Semantics.amount.currencyCode: 'Localcurr'
    Recvalueaddedl,
    @ObjectModel.filter.enabled: false
    @Semantics.amount.currencyCode: 'Groupcurr'
    Recvalueaddedg,
    @ObjectModel.filter.enabled: false
    @Semantics.amount.currencyCode: 'Localcurr'
    Recpassthroughl,
    @ObjectModel.filter.enabled: false
    @Semantics.amount.currencyCode: 'Groupcurr'
    Recpassthroughg,
    @ObjectModel.filter.enabled: false
    @Semantics.amount.currencyCode: 'Groupcurr'
    Stewardshipg,
    @ObjectModel.filter.enabled: false
    @Semantics.amount.currencyCode: 'Localcurr'
    Stewardshipl,
    @ObjectModel.filter.enabled: false
    @Semantics.amount.currencyCode: 'Localcurr'
    Recincludedcostl,
    @ObjectModel.filter.enabled: false
    @Semantics.amount.currencyCode: 'Groupcurr'
    Recincludedcostg,
    @ObjectModel.filter.enabled: false
    @Semantics.amount.currencyCode: 'Localcurr'
    Recorigtotalcostl,
    @ObjectModel.filter.enabled: false
    @Semantics.amount.currencyCode: 'Groupcurr'
    Recorigtotalcostg,
    @ObjectModel.filter.enabled: false
    @Semantics.amount.currencyCode: 'Localcurr'
    Recpasstotalcostl,
    @ObjectModel.filter.enabled: false
    @Semantics.amount.currencyCode: 'Groupcurr'
    Recpasstotalcostg,
    @ObjectModel.filter.enabled: false
    @Semantics.amount.currencyCode: 'Localcurr'
    Recexcludedcostl,
    @ObjectModel.filter.enabled: false
    @Semantics.amount.currencyCode: 'Groupcurr'
    Recexcludedcostg,
    @ObjectModel.filter.enabled: false
    @Semantics.amount.currencyCode: 'Localcurr'
    Rectotalcostl,
    @ObjectModel.filter.enabled: false
    @Semantics.amount.currencyCode: 'Groupcurr'
    Rectotalcostg,
    @ObjectModel.filter.enabled: false
    @Semantics.amount.currencyCode: 'Localcurr'
    Totalchargeoutamountl,
    @ObjectModel.filter.enabled: false
    @Semantics.amount.currencyCode: 'Groupcurr'
    Totalchargeoutamountg,
    @ObjectModel.text.element: [ 'statusdescription' ]
    status,
    
    @ObjectModel.filter.enabled: false
    Localcurr,
    @ObjectModel.filter.enabled: false
    Groupcurr,
    @Semantics.text: true
    legalentitydescription,
    @Semantics.text: true
    costobjectdescription,
    @Semantics.text: true
    costcenterdescription,
    @Semantics.text: true
    receivingentitydescription,
    @Semantics.text: true
    serviceproductdescription,
    @Semantics.text: true
    transactiongroupdescription,
    @Semantics.text: true
    servicetypedescription,
    @Semantics.text: true
    ccodedescription,
    @Semantics.text: true
    businessdescription,
    @Semantics.text: true
    profitcenterdescription,
    @Semantics.text: true
    costdatasetdescription,
    @Semantics.text: true
    statusdescription,
    @ObjectModel.filter.enabled: false
    legalentitycountry,
    @ObjectModel.filter.enabled: false
    receivingentitycountry,
    @ObjectModel.filter.enabled: false
    legalentitycurrecy,
    @ObjectModel.filter.enabled: false
    receivingentitycurrency,
    @ObjectModel.filter.enabled: false
    legalentityregion,
    @ObjectModel.filter.enabled: false
    receivingentityregion
}
