@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Invoice Chargeout'
define root view entity /ESRCC/I_CHGINVOICE
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
      _ServiceCost._CostCenterCost.ProcessType,
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
      case Currencytype
      when 'I' then
       InvoicingCurrency
      else
      Currency end as Currency,  
      @Semantics.amount.currencyCode: 'Currency'
      case when Currencytype = 'I' and Currency <> InvoicingCurrency then
      currency_conversion( client => $session.client,
                         amount => cast(TransferPrice as abap.curr(23,2)),
                         source_currency => Currency,
                         round => 'X',
                         target_currency => InvoicingCurrency,
                         exchange_rate_date => Exchdate,                         
                         error_handling => 'SET_TO_NULL' ) 
      else cast(TransferPrice as abap.curr(23,2)) end as TransferPrice,
      Reckpi,
      Uom,
      Reckpishare,
      @Semantics.amount.currencyCode: 'Currency'
      case when Currencytype = 'I' and Currency <> InvoicingCurrency then
      currency_conversion( client => $session.client,
                         amount => cast(TotalChargeout as abap.curr(23,2)),
                         source_currency => Currency,
                         round => 'X',
                         target_currency => InvoicingCurrency,
                         exchange_rate_date => Exchdate,                         
                         error_handling => 'SET_TO_NULL' ) 
      else cast(TotalChargeout as abap.curr(23,2)) end as TotalChargeout,
      InvoiceUUID,
      InvoiceNumber,
      InvoiceStatus,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      InvoiceNumber                        as Filename,
      case ReceiverChargeout.InvoiceStatus
        when '02' then 'application/pdf'
        when '03' then 'application/pdf'
        else '' end                        as Mimetype,
      _ServiceCost._CostCenterCost.Country as LECountry,
      Country                              as receivingentitycountry,
      //descriptions
//      @Semantics.text: true
      _CurrencyTypeText,
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
      ccodedescription                     as RecCcodedescription,
      @Semantics.text: true
      receivingentitydescription,
      @Semantics.text: true
      costcenterdescription                as RecCostCenterdescription,
      @Semantics.text: true
      costobjectdescription                as RecCostObjectdescription,
      @Semantics.text: true
      invoicestatusdescription,
      @Semantics.text: true
      _ServiceCost._CostCenterCost.ProcessTypedescription,
      //    _association_name // Make association public
      //  status color
      case ReceiverChargeout.InvoiceStatus
         when '01' then 0
         when '02' then 2
         when '03' then 3
         else
         0
        end                                as invoicestatuscriticallity,
      _ReceivingCountryText,
      _ServiceCost._CostCenterCost._legalCountryText
} where Status = 'F'
