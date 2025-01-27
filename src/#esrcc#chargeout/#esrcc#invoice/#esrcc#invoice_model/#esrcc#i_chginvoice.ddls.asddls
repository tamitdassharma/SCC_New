@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Invoice Chargeout'
define root view entity /ESRCC/I_CHGINVOICE
  as select from /ESRCC/I_ReceiverChargeout as ReceiverChargeout
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
      Currency,
      TransferPrice,
      Reckpi,
      Uom,
      Reckpishare,
      TotalChargeout,
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
