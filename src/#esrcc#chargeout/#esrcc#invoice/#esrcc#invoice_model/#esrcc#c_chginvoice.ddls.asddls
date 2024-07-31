@EndUserText.label: 'Invoice Chargeout'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity /ESRCC/C_CHGINVOICE
  provider contract transactional_query
  as projection on /ESRCC/I_CHGINVOICE
{
          @ObjectModel.text.element: [ 'costdatasetdescription' ]
  key     Fplv,
  key     Ryear,
  key     Poper,
  key     Sysid,
          @ObjectModel.text.element: [ 'legalentitydescription' ]
  key     Legalentity,
          @ObjectModel.text.element: [ 'ccodedescription' ]
  key     Ccode,
          @ObjectModel.text.element: [ 'costobjectdescription' ]
  key     Costobject,
          @ObjectModel.text.element: [ 'costcenterdescription' ]
  key     Costcenter,
          @ObjectModel.text.element: [ 'Serviceproductdescription' ]
  key     Serviceproduct,
          @ObjectModel.text.element: [ 'receivingentitydescription' ]
  key     Receivingentity,
          @ObjectModel.text.element: [ 'currencytypedescription' ]
  key     Currencytype,
          Currency,
          @ObjectModel.text.element: [ 'billingfrequencydescription' ]
          BillingFrequency,
          @ObjectModel.text.element: [ 'billingperioddescription' ]
          BillingPeriod,
          @ObjectModel.text.element: [ 'chargeoutdescription' ]
          chargeout,
          @Semantics.amount.currencyCode: 'Currency'
          Transferprice,
          //      @Semantics.quantity.unitOfMeasure: 'Uom'
          Reckpi,
          Reckpishare,
          @Semantics.amount.currencyCode: 'Currency'
          Reckpishareabs,
          Uom,
          InvoiceUUID,
          Invoicenumber,
          @ObjectModel.text.element: [ 'invoicestatusdescription' ]
          Invoicestatus,
          @ObjectModel.text.element: [ 'servicetypedescription' ]
          ServiceType,
          Filename,
          Mimetype,
          @Semantics.largeObject: {
             mimeType: 'Mimetype',
             fileName: 'Filename',
             contentDispositionPreference: #INLINE }
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:/ESRCC/DEFAULT_VIRTUAL_ELEMENT'
  virtual Stream : abap.rawstring(0),
          legalentitycountry,
          receivingentitycountry,
          CreatedBy,
          CreatedAt,
          LastChangedBy,
          LastChangedAt,

          //descriptions
          ccodedescription,
          legalentitydescription,
          costobjectdescription,
          costcenterdescription,
          costdatasetdescription,
          Serviceproductdescription,
          //   _srvtyp.Description         as Servicetypedescription,
          receivingentitydescription,
          chargeoutdescription,
          currencytypedescription,
          invoicestatusdescription,
          invoicestatuscriticallity,
          servicetypedescription,
          legalentitycountryname,
          receivingentitycountryname,
          billingfrequencydescription,
          billingperioddescription

}
