@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Service Charge Out Analytical List'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}


define view entity /ESRCC/I_CHARGEOUT_CHARTS
  as select from /ESRCC/I_CHG_ANALYTICS
{
      @AnalyticsDetails.query.display: #KEY

      @ObjectModel.text.element: [ 'costdatasetdescription' ]
  key Fplv,


      @AnalyticsDetails.query.display: #KEY

  key Ryear,

  key Sysid,

  key Poper,


      @AnalyticsDetails.query.display: #KEY
      @ObjectModel.text.element: [ 'ccodedescription' ]      
  key Ccode,


      @AnalyticsDetails.query.display: #KEY
      @ObjectModel.text.element: [ 'legalentitydescription' ]
  key Legalentity,

      @ObjectModel.text.element: [ 'costobjectdescription' ]
      @AnalyticsDetails.query.display: #KEY
  key Costobject,




      @AnalyticsDetails.query.display: #KEY
      @ObjectModel.text.element: [ 'costcenterdescription' ]

  key Costcenter,



      @AnalyticsDetails.query.display: #KEY
      @ObjectModel.text.element: [ 'transactiongroupdescription' ]
  key Transactiongroup,



      @AnalyticsDetails.query.display: #KEY
      @ObjectModel.text.element: [ 'serviceproductdescription' ]
  key Serviceproduct,


      @AnalyticsDetails.query.display: #KEY
      @ObjectModel.text.element: [ 'servicetypedescription' ]
  key Servicetype,

      @AnalyticsDetails.query.display: #KEY
      @ObjectModel.text.element: [ 'receivingentitydescription' ]
  key Receivingentity,
      
      @AnalyticsDetails.query.display: #KEY
      @ObjectModel.text.element: [ 'businessdescription' ]
      Businessdivision,

      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Groupcurr'
      Reckpishareabsg       as Totalcost_g,


      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Groupcurr'
      Recexcludedcostg      as ExcludedTotalCost,

      //   @UI.lineItem: [{ position: 150 }]

      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Groupcurr'
      Recincludedcostg      as IncludedTotalCost,

      //  @UI.lineItem: [{ position: 160 }]

      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Groupcurr'
      Rectotalcostg         as TotalCostBase,



      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Groupcurr'
      Rectotalmarkupabsg    as SrvTotalMarkup,


      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Groupcurr'
      Recvalueaddmarkupabsg as ValueAddMarkup,


      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Groupcurr'
      Recpassthrumarkupabsg as PassThruMarkup,
      
      @ObjectModel.text.element: [ 'statusdescription' ]
      @AnalyticsDetails.query.display: #KEY
      status,      
      Groupcurr,
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Groupcurr'
      Stewardshipg          as Stewardship,
      @Semantics.text: true
      ccodedescription,
      @Semantics.text: true
      legalentitydescription,
      @Semantics.text: true
      costdatasetdescription,
      @Semantics.text: true
      transactiongroupdescription,
      @Semantics.text: true
      serviceproductdescription,
      @Semantics.text: true
      servicetypedescription,
      @Semantics.text: true
      receivingentitydescription,
      @Semantics.text: true
      costobjectdescription,
      @Semantics.text: true
      costcenterdescription,
      @Semantics.text: true
      businessdescription,
      @ObjectModel.text.element: [ 'legalcountryname' ]
      legalentitycountry,
      @ObjectModel.text.element: [ 'receivingcountryname' ]
      receivingentitycountry,
      @Semantics.text: true
      statusdescription,
      @Semantics.text: true
      _legalCountryText.CountryName as legalcountryname,
      @Semantics.text: true
      _RecCountryText.CountryName as receivingcountryname
      

}
