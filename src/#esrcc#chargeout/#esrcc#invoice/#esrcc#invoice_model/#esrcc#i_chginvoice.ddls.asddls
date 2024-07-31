@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Invoice Chargeout'
define root view entity /ESRCC/I_CHGINVOICE
  as select from /ESRCC/I_CHGINVOICE_UNION as _invoice

  association [0..1] to /ESRCC/I_LEGALENTITY_F4     as _legalentity      on  _legalentity.Legalentity = _invoice.Legalentity

  association [0..1] to /ESRCC/I_COMPANYCODES_F4    as _ccode            on  _ccode.Ccode       = _invoice.Ccode
                                                                         and _ccode.Sysid       = _invoice.Sysid
                                                                         and _ccode.Legalentity = _invoice.Legalentity

  association [0..1] to /ESRCC/I_COSTOBJECTS        as _costobject       on  _costobject.Costobject = _invoice.Costobject

  association [0..1] to /ESRCC/I_COSCEN_F4          as _costcenter       on  _costcenter.Costcenter = _invoice.Costcenter
                                                                         and _costcenter.Sysid      = _invoice.Sysid
                                                                         and _costcenter.Costobject = _invoice.Costobject

  association [0..1] to /ESRCC/I_COSTDATASET        as _costdataset      on  _costdataset.costdataset = _invoice.Fplv

  association [0..1] to /ESRCC/I_SERVICEPRODUCT_F4  as _serviceproduct   on  _serviceproduct.ServiceProduct = _invoice.Serviceproduct

  association [0..1] to /ESRCC/I_CHGOUT             as _chargout         on  _chargout.Chargeout = _invoice.chargeout

  association [0..1] to /ESRCC/I_RECEIVINGENTITY_F4 as _rcventity        on  _rcventity.Receivingentity = $projection.Receivingentity

  association [0..1] to /ESRCC/I_SERVICETYPE_F4     as _servicetype      on  _servicetype.ServiceType = _invoice.ServiceType

  association [0..1] to /ESRCC/I_CURR               as _CurrencyTypeText on  _CurrencyTypeText.Currencytype = $projection.Currencytype

  association [0..1] to /ESRCC/I_INVOICESTATUS      as _InvoiceStatus    on  _InvoiceStatus.InvoiceStatus = _invoice.Invoicestatus

  association [0..1] to /ESRCC/I_BILLINGFREQ as _billingfreq
  on _billingfreq.Billingfreq = _invoice.BillingFrequency
  
  association [0..1] to /ESRCC/I_BILLINGPERIOD as _billingperiod
  on _billingperiod.Billingperiod = _invoice.BillingPeriod
{
  key Fplv,
  key Ryear,
  key Poper,
  key Sysid,
  key _invoice.Legalentity,
  key _invoice.Ccode,
  key _invoice.Costobject,
  key _invoice.Costcenter,
  key Serviceproduct,
  key Receivingentity,
  key Currencytype,
      Currency,
      BillingFrequency,
      BillingPeriod,      
      chargeout,
      Receivergroup,
      Allockey,
      Alloctype,
      ConsumptionVersion,
      KeyVersion,
      Transferprice,
      Reckpi,
      Reckpishare,
      Reckpishareabs,
      Recvalueaddmarkupabs,
      Recpassthrumarkupabs,
      Rectotalmarkupabs,
      Recvalueadded,
      Recpassthrough,
      Reccostshare,
      Recorigtotalcost,
      Recpasstotalcost,
      Recincludedcost,
      Recexcludedcost,
      Rectotalcost,
      Uom,
      Status,
      Workflowid,
      Exchdate,
      InvoiceUUID,
      Invoicenumber,
      Invoicestatus,
      ServiceType,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      Invoicenumber                as Filename,
      case _InvoiceStatus.InvoiceStatus
        when '02' then 'application/pdf'
        when '03' then 'application/pdf'
        else '' end as Mimetype,
      _legalentity.Country as legalentitycountry,
      _rcventity.Country as receivingentitycountry,
      //descriptions
      _ccode.ccodedescription,
      _legalentity.Description     as legalentitydescription,
      _costobject.text             as costobjectdescription,
      _costcenter.Description      as costcenterdescription,
      _costdataset.text            as costdatasetdescription,
      _serviceproduct.Description  as Serviceproductdescription,
      //    _srvtyp.Description         as Servicetypedescription,
      _rcventity.Description       as receivingentitydescription,
      _chargout.text               as chargeoutdescription,
      _CurrencyTypeText.text       as currencytypedescription,
      _InvoiceStatus.text          as invoicestatusdescription,
      _servicetype.Description     as servicetypedescription,
      _legalentity.CountryName as legalentitycountryname,
      _rcventity.CountryName as receivingentitycountryname,
      _billingfreq.text as billingfrequencydescription,
      _billingperiod.text as billingperioddescription,
      //    _association_name // Make association public
      //  status color
      case _InvoiceStatus.InvoiceStatus
       when '01' then 0
       when '02' then 2
       when '03' then 3
       else
       0
      end                          as invoicestatuscriticallity
}
