@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Receivers Chargeout'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

@Metadata.allowExtensions: true
define root view entity /ESRCC/I_ChargeoutReceived
  as select from /ESRCC/I_ReceiverChargeout as ReceiverChargeout
  association [0..1] to /ESRCC/I_CURR as _CurrencyTypeText
  on _CurrencyTypeText.Currencytype = $projection.Currencytype

{
    key UUID,
    key ParentUUID,
    key RootUUID,
    key Currencytype,
    _ServiceCost._CostCenterCost.Fplv,
    _ServiceCost._CostCenterCost.Ryear,
    _ServiceCost._CostCenterCost.Poper,
    _ServiceCost._CostCenterCost.Sysid,
    _ServiceCost._CostCenterCost.Legalentity,
    _ServiceCost._CostCenterCost.Ccode,
    _ServiceCost._CostCenterCost.Costobject,
    _ServiceCost._CostCenterCost.Costcenter,
    _ServiceCost.Serviceproduct,
    ReceiverSysId,
    ReceiverCompanyCode,
    Receivingentity,
    ReceiverCostObject,
    ReceiverCostCenter,
    
    _ServiceCost._CostCenterCost.Billingfrequqncy,
    _ServiceCost._CostCenterCost.Billingperiod,
    _ServiceCost.Chargeout,
    _ServiceCost.Servicetype,
    _ServiceCost.Transactiongroup,
//    @Semantics.amount.currencyCode: 'Currency'
//    case when Currencytype = 'L' and Currency <> _ServiceMarkup._ReceiverCost.ReceiverCurrency then
//    currency_conversion( client => $session.client,
//                         amount => cast(_ServiceMarkup._ReceiverCost.TransferPrice as abap.curr(23,2)),
//                         source_currency => Currency,
//                         round => 'X',
//                         target_currency => _ServiceMarkup._ReceiverCost.ReceiverCurrency,
//                         exchange_rate_date => _ServiceMarkup._ReceiverCost.Exchdate,                         
//                         error_handling => 'SET_TO_NULL' ) 
//    else cast(_ServiceMarkup._ReceiverCost.TransferPrice as abap.curr(23,2)) end as Transferprice,
//
//    @Semantics.amount.currencyCode: 'Currency'
//    case when Currencytype = 'L' and Currency <> _ServiceMarkup._ReceiverCost.ReceiverCurrency then
//    currency_conversion( client => $session.client,
//                         amount => cast(_ServiceMarkup._ReceiverCost.TpValueaddmarkupCostperunit 
//                                       + _ServiceMarkup._ReceiverCost.TpPassthrumarkupCostperunit as abap.curr(23,2)),
//                         source_currency => Currency,
//                         round => 'X',
//                         target_currency => _ServiceMarkup._ReceiverCost.ReceiverCurrency,
//                         exchange_rate_date => _ServiceMarkup._ReceiverCost.Exchdate,                         
//                         error_handling => 'SET_TO_NULL' ) 
//    else cast(_ServiceMarkup._ReceiverCost.TpValueaddmarkupCostperunit 
//              + _ServiceMarkup._ReceiverCost.TpPassthrumarkupCostperunit as abap.curr(23,2)) end as TotalMarkupperunit,

    @Semantics.amount.currencyCode: 'Currency'
    case when Currencytype = 'L' and Currency <> ReceiverCurrency then
    currency_conversion( client => $session.client,
                         amount => cast(TotalRecMarkup as abap.curr(23,2)),
                         source_currency => Currency,
                         round => 'X',
                         target_currency => ReceiverCurrency,
                         exchange_rate_date => Exchdate,                         
                         error_handling => 'SET_TO_NULL' ) 
    else cast(TotalRecMarkup as abap.curr(23,2)) end as TotalMarkup,

    @Semantics.amount.currencyCode: 'Currency'
    case when Currencytype = 'L' and Currency <> ReceiverCurrency then
    currency_conversion( client => $session.client,
                         amount => cast(RecCostShare as abap.curr(23,2)),
                         source_currency => Currency,
                         round => 'X',
                         target_currency => ReceiverCurrency,
                         exchange_rate_date => Exchdate,                         
                         error_handling => 'SET_TO_NULL' ) 
    else cast(RecCostShare as abap.curr(23,2)) end as TotalCostbase,

    @Semantics.amount.currencyCode: 'Currency'
    case when Currencytype = 'L' and Currency <> ReceiverCurrency then
    currency_conversion( client => $session.client,
                         amount => cast(RecValueadded as abap.curr(23,2)),
                         source_currency => Currency,
                         round => 'X',
                         target_currency => ReceiverCurrency,
                         exchange_rate_date => Exchdate,                         
                         error_handling => 'SET_TO_NULL' ) 
    else cast(RecValueadded as abap.curr(23,2)) end as TotalValueAdd,

    @Semantics.amount.currencyCode: 'Currency'
    case when Currencytype = 'L' and Currency <> ReceiverCurrency then
    currency_conversion( client => $session.client,
                         amount => cast(RecPassthrough as abap.curr(23,2)),
                         source_currency => Currency,
                         round => 'X',
                         target_currency => ReceiverCurrency,
                         exchange_rate_date => Exchdate,                         
                         error_handling => 'SET_TO_NULL' ) 
    else cast(RecPassthrough as abap.curr(23,2)) end as TotalPassthrough,

    @Semantics.amount.currencyCode: 'Currency'
    case when Currencytype = 'L' and Currency <> ReceiverCurrency then
    currency_conversion( client => $session.client,
                         amount => cast(TotalChargeout as abap.curr(23,2)),
                         source_currency => Currency,
                         round => 'X',
                         target_currency => ReceiverCurrency,
                         exchange_rate_date => Exchdate,                         
                         error_handling => 'SET_TO_NULL' ) 
    else cast(TotalChargeout as abap.curr(23,2)) end as TotalChargeoutAmount,

    case Currencytype
    when 'L' then
    ReceiverCurrency
    else
    _ServiceCost._CostCenterCost.Currency end as Currency,      

    cast( case when _ServiceCost.Chargeout = 'D' then
    'X'
    else '' end as abap_boolean preserving type ) as hideindirect,
    
    cast( case when _ServiceCost.Chargeout = 'I' then
    'X'
    else '' end as abap_boolean preserving type ) as hidedirect,
    _ServiceCost.OECD,
    
    //association
    @Semantics.text: true
    _ServiceCost._CostCenterCost.billingfrequencydescription,
    @Semantics.text: true
    _ServiceCost._CostCenterCost.billingperioddescription,
    @Semantics.text: true
    _ServiceCost._CostCenterCost.legalentitydescription,
    @Semantics.text: true
    _ServiceCost._CostCenterCost.costobjectdescription,
    @Semantics.text: true
    _ServiceCost._CostCenterCost.costcenterdescription,
    @Semantics.text: true
    _ServiceCost.Serviceproductdescription,
    @Semantics.text: true
    _ServiceCost.Transactiongroupdescription,
    @Semantics.text: true
    _ServiceCost.Servicetypedescription,
    @Semantics.text: true
    _ServiceCost._CostCenterCost.ccodedescription,
    @Semantics.text: true
    _ServiceCost._CostCenterCost.functionalareadescription,
    @Semantics.text: true
    _ServiceCost._CostCenterCost.businessdescription,
    @Semantics.text: true
    _ServiceCost._CostCenterCost.profitcenterdescription,
    @Semantics.text: true
    _ServiceCost.oecdDescription,
    @Semantics.text: true
    _ServiceCost.chargeoutdescription,
    @Semantics.text: true
    _ServiceCost._CostCenterCost.costdatasetdescription,
    @Semantics.text: true
    ccodedescription as RecCcodedescription,
    @Semantics.text: true
    receivingentitydescription,
    @Semantics.text: true
    costcenterdescription as RecCostCenterdescription,
    @Semantics.text: true
    costobjectdescription as RecCostObjectdescription,
    _ServiceCost._CostCenterCost.Country as LECountry,
    Country as RecCountry,
    _CurrencyTypeText,
    _ServiceCost._CostCenterCost._legalCountryText,
    _ReceivingCountryText
//    _RecmkupCost,
//    _IndRecmkupCost
} 
