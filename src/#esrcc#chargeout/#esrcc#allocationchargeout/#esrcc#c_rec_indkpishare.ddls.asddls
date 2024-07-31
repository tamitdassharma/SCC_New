@EndUserText.label: 'Indirect Allocation KPI Share'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'fplv', 'ryear', 'poper', 'sysid', 'legalentity', 'costobject', 'costcenter']
define root view entity /ESRCC/C_REC_INDKPISHARE
  provider contract transactional_query
  as projection on /ESRCC/I_REC_INDKPISHARE
{
      @ObjectModel.text.element: [ 'CostVersionDescription' ]
  key fplv,
  key ryear,
  key poper,
  key sysid,
      @ObjectModel.text.element: [ 'ccodedescription' ]
  key ccode,
      @ObjectModel.text.element: [ 'legalentitydescription' ]
  key legalentity,
      @ObjectModel.text.element: [ 'costobjectdescription' ]
  key costobject,
      @ObjectModel.text.element: [ 'costcenterdescription' ]
  key costcenter,
      @ObjectModel.text.element: [ 'serviceproductdescription' ]
  key serviceproduct,
      @ObjectModel.text.element: [ 'receivingentitydescription' ]
  key receivingentity,
      @ObjectModel.text.element: [ 'KeyVersionDescription' ]
  key keyversion,
      @ObjectModel.text.element: [ 'AllocationKeyDescription' ]
  key allockey,
//      @ObjectModel.filter.enabled: false
//      @ObjectModel.text.element: [ 'AllocationTypeDescription' ]
//  key alloctype,
      @ObjectModel.filter.enabled: false
      @ObjectModel.text.element: [ 'AllocationPeriodDescription' ]
  key allocationperiod,
      @ObjectModel.filter.enabled: false
  key refperiod,
      @ObjectModel.filter.enabled: false
      weightage,
      @DefaultAggregation: #SUM
      reckpivalue,
//      totalreckpi,
//      @DefaultAggregation: #SUM
      totalreckpishare,
      @DefaultAggregation: #SUM
      reckpishare,
//      hideaverage,
//      hidecumulative,
      @ObjectModel.text.element: [ 'oecdDescription' ]
      _serviceproduct.OECD,
      @Semantics.text: true
      _serviceproduct.oecdDescription,
      @Semantics.text: true
      _legalentity.Description     as legalentitydescription,
      @Semantics.text: true
      _ccode.ccodedescription,
      @Semantics.text: true
      _costobject.text             as costobjectdescription,
      @Semantics.text: true
      _costcenter.Description      as costcenterdescription,
      @Semantics.text: true
      _receivingentity.Description as receivingentitydescription,
      @Semantics.text: true
      _serviceproduct.Description  as serviceproductdescription,
      @ObjectModel.text.element: [ 'legalcountryname' ]
      _legalentity.Country         as legalentitycountry,
      @ObjectModel.text.element: [ 'receivingcountryname' ]
      _receivingentity.Country     as receivingentitycountry,

      _legalentity.LocalCurr       as legalentitycurrecy,
      _receivingentity.LocalCurr   as receivingentitycurrency,
      _legalentity.Region          as legalentityregion,
      _receivingentity.Region      as receivingentityregion,
      @Semantics.text: true
      _CostVersionText.text        as CostVersionDescription,
      @Semantics.text: true
      _KeyVersionText.text         as KeyVersionDescription,
      @Semantics.text: true
      _AllocKeyText.AllocationKeyDescription,
//      @Semantics.text: true
//      _AllocTypeText.text          as AllocationTypeDescription,
      @Semantics.text: true
      _AllocPeriodText.text        as AllocationPeriodDescription,
      @Semantics.text: true
      _legalCountryText.CountryName as legalcountryname,
      @Semantics.text: true
      _RecCountryText.CountryName as receivingcountryname,

      /* Associations */
      _ReceiverAllocation : redirected to composition child /ESRCC/C_RECALLOCVALUE
//      _AverageReceiverAllocation : redirected to composition child /ESRCC/C_AVERAGERECALLOCVALUE
}
