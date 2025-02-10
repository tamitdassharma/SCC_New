@EndUserText.label: 'Invoice Chargeout'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity /ESRCC/C_CHGINVOICE
  provider contract transactional_query
  as projection on /ESRCC/I_CHGINVOICE
{
  key     UUID,
  key     ParentUUID,
  key     RootUUID,
          @ObjectModel.text.element: [ 'currencytypetext' ]
  key     Currencytype,
          @ObjectModel.text.element: [ 'costdatasetdescription' ]
          Fplv,
          Ryear,
          Poper,
          Sysid,
          @ObjectModel.text.element: [ 'legalentitydescription' ]
          Legalentity,
          @ObjectModel.text.element: [ 'ccodedescription' ]
          Ccode,
          @ObjectModel.text.element: [ 'costobjectdescription' ]
          Costobject,
          @ObjectModel.text.element: [ 'costcenterdescription' ]
          Costcenter,
          @ObjectModel.text.element: [ 'ProcessTypedescription' ]
          ProcessType,
          @ObjectModel.text.element: [ 'serviceproductdescription' ]
          Serviceproduct,
          ReceiverSysId,
          @ObjectModel.text.element: [ 'RecCcodedescription' ]
          ReceiverCompanyCode,
          @ObjectModel.text.element: [ 'receivingentitydescription' ]
          Receivingentity,
          @ObjectModel.text.element: [ 'RecCostObjectdescription' ]
          ReceiverCostObject,
          @ObjectModel.text.element: [ 'RecCostCenterdescription' ]
          ReceiverCostCenter,
          @ObjectModel.text.element: [ 'billingfrequencydescription' ]
          Billingfrequqncy,
          @ObjectModel.text.element: [ 'billingperioddescription' ]
          Billingperiod,
          @ObjectModel.text.element: [ 'chargeoutdescription' ]
          Chargeout,
          @ObjectModel.text.element: [ 'servicetypedescription' ]
          Servicetype,
          @ObjectModel.text.element: [ 'transactiongroupdescription' ]
          Transactiongroup,
          @Semantics.amount.currencyCode: 'Currency'
          TransferPrice,
//          @Semantics.quantity.unitOfMeasure: 'Uom'
          Reckpi,
          Uom,
          Currency,
          Reckpishare,
          @Semantics.amount.currencyCode: 'Currency'
          TotalChargeout,
          InvoiceUUID,
          InvoiceNumber,
          @ObjectModel.text.element: [ 'invoicestatusdescription' ]
          InvoiceStatus,
          Filename,
          Mimetype,
          @Semantics.largeObject: {
             mimeType: 'Mimetype',
             fileName: 'Filename',
             contentDispositionPreference: #INLINE }
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:/ESRCC/DEFAULT_VIRTUAL_ELEMENT'
  virtual Stream : abap.rawstring(0),
          //          legalentitycountry,

          CreatedBy,
          CreatedAt,
          LastChangedBy,
          LastChangedAt,

          //descriptions
          @Semantics.text: true
          billingfrequencydescription,
          @Semantics.text: true
          billingperioddescription,
          @Semantics.text: true
          legalentitydescription,
          @Semantics.text: true
          costobjectdescription,
          @Semantics.text: true
          costcenterdescription,
          @Semantics.text: true
          Serviceproductdescription,
          @Semantics.text: true
          Transactiongroupdescription,
          @Semantics.text: true
          Servicetypedescription,
          @Semantics.text: true
          ccodedescription,
          @Semantics.text: true
          oecdDescription,
          @Semantics.text: true
          costdatasetdescription,
          @Semantics.text: true
          RecCcodedescription,
          @Semantics.text: true
          receivingentitydescription,
          @Semantics.text: true
          RecCostCenterdescription,
          @Semantics.text: true
          RecCostObjectdescription,
          @Semantics.text: true
          chargeoutdescription,
          @Semantics.text: true
          invoicestatusdescription,
          @Semantics.text: true
          ProcessTypedescription,
          invoicestatuscriticallity,
          @Semantics.text: true
          _CurrencyTypeText.text as currencytypetext,    
          @ObjectModel.text.element: [ 'legalentitycountryname' ]
          LECountry as legalentitycountry,
          @ObjectModel.text.element: [ 'receivingentitycountryname' ]
          receivingentitycountry,
          _legalCountryText.CountryName as legalentitycountryname,
          _ReceivingCountryText.CountryName as receivingentitycountryname
}
