@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service Charge Out Cube'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel: {usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}}
@Analytics.dataCategory: #CUBE

define view entity /ESRCC/I_MultiDimension
  as select from /esrcc/rec_cost as ReceiverShare
  
  association  [0..1] to /ESRCC/I_RYEAR as _ryear on _ryear.ryear = $projection.ryear 
  
  association [0..1] to /ESRCC/I_LEGALENTITY_F4 as _legalentity on _legalentity.Legalentity = $projection.legalentity
  
  association [0..1] to /ESRCC/I_RECEIVINGENTITY_F4 as _receivingentity
  on _receivingentity.Receivingentity = $projection.receivingentity
  
  association [0..1] to /ESRCC/I_COSNUMBER_F4 as _costcenter
  on _costcenter.Costcenter = ReceiverShare.costcenter
  
  association [0..1] to /ESRCC/I_PROFITCENTER_F4 as _profitcenter
  on _profitcenter.ProfitCenter = $projection.profitcenter
  
  association [0..1] to /ESRCC/I_BUSINESSDIV_F4 as _businessdiv
  on _businessdiv.BusinessDivision = $projection.businessdivision
  
  association [0..1] to /ESRCC/I_SERVICEPRD_F4   as _serviceproduct         
  on _serviceproduct.ServiceProduct = $projection.serviceproduct
  
  association [0..1] to /ESRCC/I_SERVICETYPE_F4      as _srvtyp                
  on  _srvtyp.ServiceType = $projection.servicetype

  association [0..1] to /ESRCC/I_TRANSACTIONGROUP_F4 as _srvtransactiongroup    
  on  _srvtransactiongroup.Transactiongroup = ReceiverShare.transactiongroup
{

      /** DIMENSIONS **/
      @ObjectModel.foreignKey.association: '_ryear'
  key ryear,
  key poper,
  key fplv,
  key sysid,
      @ObjectModel.foreignKey.association: '_legalentity'
  key ReceiverShare.legalentity,
  key ReceiverShare.ccode,
  key ReceiverShare.costobject,
      @ObjectModel.foreignKey.association: '_costcenter'
  key ReceiverShare.costcenter,
      @ObjectModel.foreignKey.association: '_serviceproduct'
  key ReceiverShare.serviceproduct,
      @ObjectModel.foreignKey.association: '_receivingentity'
  key ReceiverShare.receivingentity,
      @ObjectModel.foreignKey.association: '_srvtyp'
      ReceiverShare.servicetype,
      @ObjectModel.foreignKey.association: '_srvtransactiongroup'
      ReceiverShare.transactiongroup,
      localcurr,
      groupcurr,    
      @ObjectModel.foreignKey.association: '_businessdiv'
      ReceiverShare.businessdivision,
      @ObjectModel.foreignKey.association: '_profitcenter'
      ReceiverShare.profitcenter,
      controllingarea,      
      chargeout,

      /** Additional Fields**/
      reckpi,
      reckpishare,

      /** MEASURES **/
      @EndUserText.label: 'Total Cost (Initial)'
      @DefaultAggregation: #SUM
      rectotalcostl,
      
      @EndUserText.label: 'Total Included Cost'
      @DefaultAggregation: #SUM
      recorigtotalcostl + recpasstotalcostl as Recincludedcostl,

      @EndUserText.label: 'Excluded Cost'
      @DefaultAggregation: #SUM
      recexcludedcostl,

      @EndUserText.label: 'Thereof Value-Add'
      @DefaultAggregation: #SUM
      recorigtotalcostl,

      @EndUserText.label: 'Thereof Pass-Through'
      @DefaultAggregation: #SUM
      recpasstotalcostl,
      
      @EndUserText.label: 'Total Stewardship'
      @DefaultAggregation: #SUM
      ( recorigtotalcostl + recpasstotalcostl ) - ( recvalueaddedl + recpassthroughl ) as Stewardshipl,      

      @EndUserText.label: 'Total Service Cost'
      @DefaultAggregation: #SUM
      recvalueaddedl + recpassthroughl as Reccostsharel,

      @EndUserText.label: 'Thereof Value-Add Service Cost'
      @DefaultAggregation: #SUM
      recvalueaddedl,

      @EndUserText.label: 'Thereof Pass-Through Service Cost'
      @DefaultAggregation: #SUM
      recpassthroughl,
      
      @EndUserText.label: 'Total Mark-up'
      @DefaultAggregation: #SUM
      recvalueaddmarkupabsl + recpassthrumarkupabsl as Rectotalmarkupabsl,
      
      @EndUserText.label: 'Thereof Value-Add Mark-up'
      @DefaultAggregation: #SUM
      recvalueaddmarkupabsl,

      @EndUserText.label: 'Thereof Pass-Through Mark-up'
      @DefaultAggregation: #SUM
      recpassthrumarkupabsl,
      

      @EndUserText.label: 'Total Charge-Out Amount'
      @DefaultAggregation: #SUM
      reckpishareabsl,
      
      _ryear,
      _legalentity,
      _receivingentity,
      _costcenter,
      _serviceproduct,
      _profitcenter,
      _businessdiv,
      _srvtyp,
      _srvtransactiongroup

      

}
