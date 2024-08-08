@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Charge-Out Receiver'
@Analytics.dataCategory: #CUBE
define root view entity /ESRCC/I_CHG_ANALYTICS 
as select from /esrcc/rec_cost as ReceiverShare
  
  association [0..1] to /ESRCC/I_LEGALENTITY_F4 as legalentity
  on legalentity.Legalentity = $projection.Legalentity
  
  association [0..1] to /ESRCC/I_RECEIVINGENTITY_F4 as receivingentity
  on receivingentity.Receivingentity = $projection.Receivingentity
  
  association [0..1] to /ESRCC/I_COMPANYCODES_F4 as ccode  
  on ccode.Ccode = $projection.Ccode
  and ccode.Sysid = $projection.Sysid
//  and ccode.Legalentity = $projection.Legalentity
  
  association [0..1] to /ESRCC/I_COSTOBJECTS as costobject  
  on costobject.Costobject = $projection.Costobject
  
  association [0..1] to /ESRCC/I_COSCEN_F4 as costcenter
  on costcenter.Costcenter = ReceiverShare.costcenter
  and costcenter.Sysid = ReceiverShare.sysid
  and costcenter.Costobject = ReceiverShare.costobject
  
  association [0..1] to /ESRCC/I_COSTDATASET as costdataset
  on costdataset.costdataset = ReceiverShare.fplv
  
  association [0..1] to /ESRCC/I_PROFITCENTER_F4 as profitcenter
  on profitcenter.ProfitCenter = ReceiverShare.profitcenter
  
  association [0..1] to /ESRCC/I_BUSINESSDIV_F4 as businessdiv
  on businessdiv.BusinessDivision = ReceiverShare.businessdivision
  
  association [0..1] to /ESRCC/I_SERVICEPRODUCT_F4   as serviceproduct         
  on  serviceproduct.ServiceProduct = ReceiverShare.serviceproduct

  association [0..1] to /ESRCC/I_SERVICETYPE_F4      as srvtyp                
  on  srvtyp.ServiceType = ReceiverShare.servicetype

  association [0..1] to /ESRCC/I_TRANSACTIONGROUP_F4 as srvtransactiongroup    
  on  srvtransactiongroup.Transactiongroup = ReceiverShare.transactiongroup
  
  association [0..1] to /ESRCC/I_STATUS as _status    
  on  _status.Status = ReceiverShare.status
  
  association [0..1] to I_CountryText as _legalCountryText
  on _legalCountryText.Country = $projection.legalentitycountry
  and _legalCountryText.Language = $session.system_language  
  
  association [0..1] to I_CountryText as _RecCountryText
  on _RecCountryText.Country = $projection.receivingentitycountry
  and _RecCountryText.Language = $session.system_language 
  
{
    key fplv as Fplv,
    key ryear as Ryear,
    key poper as Poper,
    key sysid as Sysid,
    key ReceiverShare.legalentity as Legalentity,
    key ReceiverShare.ccode as Ccode,
    key ReceiverShare.costobject as Costobject,
    key ReceiverShare.costcenter as Costcenter,
    key ReceiverShare.serviceproduct as Serviceproduct,
    key ReceiverShare.receivingentity as Receivingentity,
    receivergroup as Receivergroup,
    billfrequency as Billfrequency,
    billingperiod as Billingperiod,
    businessdivision as Businessdivision,
    ReceiverShare.profitcenter as Profitcenter,
    controllingarea as Controllingarea,
    servicetype as Servicetype,
    transactiongroup as Transactiongroup,
    chargeout as Chargeout,
//    capacity_version as CapacityVersion,
//    consumption_version as ConsumptionVersion,
//    planning as Planning,
    uom as Uom,
//    stewardship as Stewardship,
    reckpi as Reckpi,
    reckpishare as Reckpishare,
    reckpishareabsl as Reckpishareabsl,
    reckpishareabsg as Reckpishareabsg,
    recvalueaddmarkupabsl + recpassthrumarkupabsl as Rectotalmarkupabsl,
    recvalueaddmarkupabsg + recpassthrumarkupabsg as Rectotalmarkupabsg,
    recvalueaddmarkupabsl as Recvalueaddmarkupabsl,
    recvalueaddmarkupabsg as Recvalueaddmarkupabsg,
    recpassthrumarkupabsl as Recpassthrumarkupabsl,
    recpassthrumarkupabsg as Recpassthrumarkupabsg,
    recvalueaddedl + recpassthroughl as Reccostsharel,
    recvalueaddedg + recpassthroughg as Reccostshareg,
    recvalueaddedl as Recvalueaddedl,
    recvalueaddedg as Recvalueaddedg,
    recpassthroughl as Recpassthroughl,
    recpassthroughg as Recpassthroughg,
//    srvremainingcogsl as Srvremainingcogsl,
//    srvremainingcogsg as Srvremainingcogsg,
    recorigtotalcostl + recpasstotalcostl as Recincludedcostl,
    recorigtotalcostg + recpasstotalcostg as Recincludedcostg,
    recorigtotalcostl as Recorigtotalcostl,
    recorigtotalcostg as Recorigtotalcostg,
    recpasstotalcostl as Recpasstotalcostl,
    recpasstotalcostg as Recpasstotalcostg,
    recexcludedcostl as Recexcludedcostl,
    recexcludedcostg as Recexcludedcostg,
    rectotalcostl as Rectotalcostl,
    rectotalcostg as Rectotalcostg,
    reckpishareabsl as Totalchargeoutamountl,
    reckpishareabsg as Totalchargeoutamountg,
    ReceiverShare.localcurr as Localcurr,
    ReceiverShare.groupcurr as Groupcurr,
    ( recorigtotalcostl + recpasstotalcostl ) - ( recvalueaddedl + recpassthroughl ) as Stewardshipl,  
    ( recorigtotalcostg + recpasstotalcostg ) - ( recvalueaddedg + recpassthroughg ) as Stewardshipg,  
    
    status,
    serviceproduct.OECD,
    @Semantics.text: true
    legalentity.Description as legalentitydescription,
    @Semantics.text: true
    costobject.text as costobjectdescription,
    @Semantics.text: true
    costcenter.Description as costcenterdescription,
    @Semantics.text: true
    receivingentity.Description as receivingentitydescription,
    @Semantics.text: true
    serviceproduct.Description as serviceproductdescription,
    @Semantics.text: true
    srvtransactiongroup.Description as transactiongroupdescription,
    @Semantics.text: true
    srvtyp.Description as servicetypedescription,
    @Semantics.text: true
    ccode.ccodedescription,
    @Semantics.text: true
    businessdiv.Description as businessdescription,
    @Semantics.text: true
    profitcenter.profitcenterdescription,
    @Semantics.text: true
    serviceproduct.oecdDescription,
    costdataset.text as costdatasetdescription,
    _status.text as statusdescription,   
    legalentity.Country          as legalentitycountry,
    receivingentity.Country      as receivingentitycountry,
    legalentity.LocalCurr        as legalentitycurrecy,
    receivingentity.LocalCurr    as receivingentitycurrency,
    legalentity.Region           as legalentityregion,
    receivingentity.Region       as receivingentityregion,
    //Associations
    _legalCountryText,
    _RecCountryText
}
