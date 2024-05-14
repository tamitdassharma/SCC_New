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
define root view entity /ESRCC/I_RECEIVER_COST
  as select from /ESRCC/I_TOTALREC_COST as receivercost
  
  composition [0..*] of /ESRCC/I_RECMKUP_COST           as _RecmkupCost
  
  composition [0..*] of /ESRCC/I_INDRECMKUP_COST           as _IndRecmkupCost
  
  association [0..1] to /ESRCC/I_LEGALENTITY_F4 as _legalentity
  on _legalentity.Legalentity = $projection.Legalentity
  
  association [0..1] to /ESRCC/I_COMPANYCODES_F4 as _ccode  
  on _ccode.Ccode = $projection.Ccode
  and _ccode.Sysid = $projection.Sysid
  and _ccode.Legalentity = $projection.Legalentity
  
  association [0..1] to /ESRCC/I_COSTDATASET as _costdataset
  on _costdataset.costdataset = $projection.Fplv
  
  association [0..1] to /ESRCC/I_BILLINGFREQ as _billingfreq
  on _billingfreq.Billingfreq = $projection.Billingfrequqncy
  
  association [0..1] to /ESRCC/I_BILLINGPERIOD as _billingperiod
  on _billingperiod.Billingperiod = $projection.Billingperiod
  
  association [0..1] to /ESRCC/I_SERVICEPRODUCT_F4   as _serviceproduct      
  on  _serviceproduct.ServiceProduct = $projection.Serviceproduct
  
  association [0..1] to /ESRCC/I_SERVICETYPE_F4      as _srvtyp           
  on  _srvtyp.ServiceType = $projection.Servicetype  

  association [0..1] to /ESRCC/I_TRANSACTIONGROUP_F4 as _srvtransactiongroup 
  on  _srvtransactiongroup.Transactiongroup = $projection.Transactiongroup
  
  association [0..1] to /ESRCC/I_RECEIVINGENTITY_F4 as _rcventity
  on _rcventity.Receivingentity = $projection.Receivingentity
  
  association [0..1] to /ESRCC/I_CHGOUT as _chgout
  on _chgout.Chargeout = $projection.Chargeout
  
  association [0..1] to I_CountryText as _legalCountryText
  on _legalCountryText.Country = $projection.LECountry
  and _legalCountryText.Language = $session.system_language  
  
  association [0..1] to I_CountryText as _RecCountryText
  on _RecCountryText.Country = $projection.RecCountry
  and _RecCountryText.Language = $session.system_language 
  
//  association [0..1] to I_UnitOfMeasureText as _UoM
//  on _UoM.UnitOfMeasure_E = $projection.Uom
//  and _UoM.Language = $session.system_language 
  
  association [0..1] to /ESRCC/I_CURR as _CurrencyTypeText
  on _CurrencyTypeText.Currencytype = $projection.Currencytype

{
    key receivercost.Fplv,
    key receivercost.Ryear,
    key receivercost.Poper,
    key receivercost.Sysid,
    key receivercost.Legalentity,
    key receivercost.Ccode,
    key receivercost.Serviceproduct,
    key receivercost.Receivingentity,
    key receivercost.Currencytype,
    key receivercost.Billingfrequqncy,
    receivercost.Billingperiod,
    receivercost.Chargeout,
//    receivercost.CapacityVersion,
//    receivercost.ConsumptionVersion,
    receivercost.Servicetype,
    receivercost.Transactiongroup,
//    consumption,
//    Uom,
    @Semantics.amount.currencyCode: 'Currency'
    case when Currencytype = 'L' and Currency <> _rcventity.LocalCurr then
    currency_conversion( amount => cast(receivercost.Transferprice as abap.curr(23,2)),
                         source_currency => Currency,
                         round => 'X',
                         target_currency => _rcventity.LocalCurr,
                         exchange_rate_date => Exchdate,                         
                         error_handling => 'SET_TO_NULL' ) 
    else cast(receivercost.Transferprice as abap.curr(23,2)) end as Transferprice,
//    receivercost.Transferprice,
    @Semantics.amount.currencyCode: 'Currency'
    case when Currencytype = 'L' and Currency <> _rcventity.LocalCurr then
    currency_conversion( amount => cast(receivercost.totalmarkuptransferprice as abap.curr(23,2)),
                         source_currency => Currency,
                         round => 'X',
                         target_currency => _rcventity.LocalCurr,
                         exchange_rate_date => Exchdate,                         
                         error_handling => 'SET_TO_NULL' ) 
    else cast(receivercost.totalmarkuptransferprice as abap.curr(23,2)) end as totalmarkuptransferprice,
//    receivercost.totalmarkuptransferprice,
    @Semantics.amount.currencyCode: 'Currency'
    case when Currencytype = 'L' and Currency <> _rcventity.LocalCurr then
    currency_conversion( amount => cast(receivercost.totaludmarkupabs as abap.curr(23,2)),
                         source_currency => Currency,
                         round => 'X',
                         target_currency => _rcventity.LocalCurr,
                         exchange_rate_date => Exchdate,                         
                         error_handling => 'SET_TO_NULL' ) 
    else cast(receivercost.totaludmarkupabs as abap.curr(23,2)) end as totaludmarkupabs,
//    receivercost.totaludmarkupabs,
    @Semantics.amount.currencyCode: 'Currency'
    case when Currencytype = 'L' and Currency <> _rcventity.LocalCurr then
    currency_conversion( amount => cast(receivercost.Totalcostbase as abap.curr(23,2)),
                         source_currency => Currency,
                         round => 'X',
                         target_currency => _rcventity.LocalCurr,
                         exchange_rate_date => Exchdate,                         
                         error_handling => 'SET_TO_NULL' ) 
    else cast(receivercost.Totalcostbase as abap.curr(23,2)) end as Totalcostbase,
//    receivercost.Totalcostbase,
    @Semantics.amount.currencyCode: 'Currency'
    case when Currencytype = 'L' and Currency <> _rcventity.LocalCurr then
    currency_conversion( amount => cast(receivercost.Totalvalueaddabs as abap.curr(23,2)),
                         source_currency => Currency,
                         round => 'X',
                         target_currency => _rcventity.LocalCurr,
                         exchange_rate_date => Exchdate,                         
                         error_handling => 'SET_TO_NULL' ) 
    else cast(receivercost.Totalvalueaddabs as abap.curr(23,2)) end as Totalvalueaddabs,
//    receivercost.Totalvalueaddabs,
    @Semantics.amount.currencyCode: 'Currency'
    case when Currencytype = 'L' and Currency <> _rcventity.LocalCurr then
    currency_conversion( amount => cast(receivercost.Totalpassthruabs as abap.curr(23,2)),
                         source_currency => Currency,
                         round => 'X',
                         target_currency => _rcventity.LocalCurr,
                         exchange_rate_date => Exchdate,                         
                         error_handling => 'SET_TO_NULL' ) 
    else cast(receivercost.Totalpassthruabs as abap.curr(23,2)) end as Totalpassthruabs,
//    receivercost.Totalpassthruabs,
    @Semantics.amount.currencyCode: 'Currency'
    case when Currencytype = 'L' and Currency <> _rcventity.LocalCurr then
    currency_conversion( amount => cast(receivercost.chargeoutforservice as abap.curr(23,2)),
                         source_currency => Currency,
                         round => 'X',
                         target_currency => _rcventity.LocalCurr,
                         exchange_rate_date => Exchdate,                         
                         error_handling => 'SET_TO_NULL' ) 
    else cast(receivercost.chargeoutforservice as abap.curr(23,2)) end as chargeoutforservice,
//    receivercost.chargeoutforservice,
    case receivercost.Currencytype
    when 'L' then
    _rcventity.LocalCurr
    else
    receivercost.Currency end as Currency,      

    cast( case when Chargeout = 'D' then
    'X'
    else '' end as abap_boolean preserving type ) as hideindirect,
    
    cast( case when Chargeout = 'I' then
    'X'
    else '' end as abap_boolean preserving type ) as hidedirect,
    //association
    _legalentity.Country as LECountry,
    _ccode,
    _costdataset,
    _billingfreq,
    _billingperiod,
    _serviceproduct,
    _srvtyp,
    _srvtransactiongroup,
    _rcventity.Country as RecCountry,
    _chgout,    
    _legalentity,
    _rcventity,
//    _UoM,
    _CurrencyTypeText,
    _legalCountryText,
    _RecCountryText,
    _RecmkupCost,
    _IndRecmkupCost
}


