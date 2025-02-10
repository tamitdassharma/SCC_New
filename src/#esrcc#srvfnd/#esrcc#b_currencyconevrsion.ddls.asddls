@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Currency Conversion'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/B_CURRENCYCONEVRSION
  with parameters
    p_amount         : abap.dec(23,2), // Amount to convert
    p_source_curr    : abap.cuky,      // Source Currency
    p_target_curr    : abap.cuky,      // Target Currency
    p_conv_date      : abap.dats,      // Exchange Rate Date
    p_exch_rate_type : abap.char(4)    // Exchange Rate Type (e.g., 'M' for standard rate)
  as select from I_ExchangeRateRawData // Standard table for exchange rates
{
  key ExchangeRateType,
  key SourceCurrency,
  key TargetCurrency,
  key ValidityStartDate                   as ValidFrom,
      @Semantics.amount.currencyCode: 'TargetCurrency'
      currency_conversion
      ( client => $session.client,
        amount => cast($parameters.p_amount as abap.curr(23,2)),
        source_currency => $parameters.p_source_curr,
        round => 'X',
        target_currency => $parameters.p_target_curr,
        exchange_rate_date => $parameters.p_conv_date,
        error_handling => 'SET_TO_NULL' ) as ConvertedAmount
}
where
      SourceCurrency    = $parameters.p_source_curr
  and TargetCurrency    = $parameters.p_target_curr
  and ExchangeRateType  = $parameters.p_exch_rate_type
  and ValidityStartDate <= $parameters.p_conv_date;
