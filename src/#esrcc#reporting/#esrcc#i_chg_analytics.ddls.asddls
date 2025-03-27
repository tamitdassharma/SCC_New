@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Charge-Out Receiver'
@Analytics.dataCategory: #CUBE
<<<<<<< HEAD
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
=======
define root view entity /ESRCC/I_CHG_ANALYTICS
  as select from /ESRCC/I_ReceiverChargeout as ReceiverChargeout
{

  key UUID,
  key ParentUUID,
  key RootUUID,
  key Currencytype,
      _ServiceCost._CostCenterCost.Fplv,
      _ServiceCost._CostCenterCost.Ryear,
      _ServiceCost._CostCenterCost.Poper,
      cast( _ServiceCost._CostCenterCost.Sysid as /esrcc/provider_sysid )                                             as Sysid,
      cast( _ServiceCost._CostCenterCost.Legalentity as /esrcc/provider_entity )                                      as Legalentity,
      cast( _ServiceCost._CostCenterCost.Ccode as /esrcc/provider_ccode )                                             as Ccode,
      cast( _ServiceCost._CostCenterCost.Costobject as /esrcc/provider_costobject )                                   as Costobject,
      cast( _ServiceCost._CostCenterCost.Costcenter as /esrcc/provider_costcenter )                                   as Costcenter,
      _ServiceCost._CostCenterCost.ProcessType,
      _ServiceCost.Serviceproduct,
      ReceiverSysId,
      ReceiverCompanyCode,
      Receivingentity,
      ReceiverCostObject,
      ReceiverCostCenter,
      ConsumptionUom                                                                                                  as Uom,
      _ServiceCost._CostCenterCost.Billingfrequqncy,
      _ServiceCost._CostCenterCost.Billingperiod,
      _ServiceCost._CostCenterCost.Businessdivision,
      _ServiceCost._CostCenterCost.FunctionalArea,
      _ServiceCost._CostCenterCost.Profitcenter,
      _ServiceCost._CostCenterCost.Controllingarea,
      _ServiceCost.Servicetype,
      _ServiceCost.Transactiongroup,
      _ServiceCost.ContractId,
      _ServiceCost.Chargeout,
      Currency,
      Reckpi,
      Reckpishare,
      TotalChargeout,
      TotalRecMarkup,
      RecValueaddMarkup,
      RecPassthroughMarkup,
      RecCostShare,
      RecValueadded,
      RecPassthrough,
      _ServiceCost._CostCenterCost.Stewardship,
      cast((RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) as abap.dec(23,5))                as RecIncludedCost,
      cast((RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) - RecCostShare as abap.dec(23,5)) as RecStewardship,

      case when _ServiceCost._CostCenterCost.Includetotalcost <> 0 then
      cast(( (RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) / _ServiceCost._CostCenterCost.Includetotalcost) * _ServiceCost._CostCenterCost.Excludedtotalcost as abap.dec(23,5))
      else 0 end                                                                                                      as RecExcludedCost,

      case when _ServiceCost._CostCenterCost.Includetotalcost <> 0 then
      cast((RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) +
      (( (RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) / _ServiceCost._CostCenterCost.Includetotalcost) * _ServiceCost._CostCenterCost.Excludedtotalcost ) as abap.dec(23,5))
      else 0 end                                                                                                      as RecTotalCost,

      case when _ServiceCost._CostCenterCost.Includetotalcost <> 0 then
      cast((((RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) / _ServiceCost._CostCenterCost.Includetotalcost) * _ServiceCost._CostCenterCost.VirtualCost ) as abap.dec(23,5))
      else 0 end                                                                                                      as RecVirtualTotalCost,

      case when _ServiceCost._CostCenterCost.Includetotalcost <> 0 then
      cast((RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) +
      (( (RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) / _ServiceCost._CostCenterCost.Includetotalcost) * _ServiceCost._CostCenterCost.Excludedtotalcost ) as abap.dec(23,5))
      -
      cast((((RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) / _ServiceCost._CostCenterCost.Includetotalcost) * _ServiceCost._CostCenterCost.VirtualCost ) as abap.dec(23,5))
      else 0 end                                                                                                      as RecERPTotalCost,

      case when _ServiceCost._CostCenterCost.Includetotalcost <> 0 then
      cast((((RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) / _ServiceCost._CostCenterCost.Includetotalcost) * _ServiceCost._CostCenterCost.Origtotalcost ) as abap.dec(23,5))
      else 0 end                                                                                                      as RecOrigTotalCost,

      case when _ServiceCost._CostCenterCost.Includetotalcost <> 0 then
      cast((((RecCostShare / ( 1 - (_ServiceCost._CostCenterCost.Stewardship / 100))) / _ServiceCost._CostCenterCost.Includetotalcost) * _ServiceCost._CostCenterCost.Passtotalcost ) as abap.dec(23,5))
      else 0 end                                                                                                      as RecPassTotalCost,

      Status,
      _ServiceCost.OECD,
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
      _ServiceCost._CostCenterCost.costdatasetdescription,
      @Semantics.text: true
      ccodedescription                                                                                                as RecCcodedescription,
      @Semantics.text: true
      receivingentitydescription,
      @Semantics.text: true
      costcenterdescription                                                                                           as RecCostCenterdescription,
      @Semantics.text: true
      costobjectdescription                                                                                           as RecCostObjectdescription,
      @Semantics.text: true
      statusdescription,
      @Semantics.text: true
      _ServiceCost._CostCenterCost.ProcessTypedescription,
      _ServiceCost._CostCenterCost.Country                                                                            as legalentitycountry,
      Country                                                                                                         as receivingentitycountry,
      _ServiceCost._CostCenterCost.LocalCurr                                                                          as legalentitycurrecy,
      ReceiverCurrency,
      _ServiceCost._CostCenterCost.Region                                                                             as legalentityregion,
      _ServiceCost._CostCenterCost.RegionDesc                                                                         as LegalEntityRegionDesc,
      ReceiverRegion,
      ReceiverRegionDesc,
      //Associations
      _ServiceCost._CostCenterCost._legalCountryText,
      _ReceivingCountryText
}
where
      Currencytype   =  'G'
  and TotalChargeout <> 0
>>>>>>> origin/main
