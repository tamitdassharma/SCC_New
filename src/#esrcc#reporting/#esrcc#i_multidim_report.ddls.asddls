@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flexible Reporting Utility'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Analytics.query: true

define view entity /ESRCC/I_MULTIDIM_REPORT
  as select from /ESRCC/I_MultiDimension
 
{
      //    DIMENSIONS
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #ROWS
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: true, mandatory: false }
      @AnalyticsDetails.query.variableSequence: 2
      @Semantics.fiscal.year: true
  key ryear,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #ROWS
      @Semantics.fiscal.period: true
      @Consumption.filter: { selectionType : #INTERVAL, multipleSelections: false, mandatory: false }
      @AnalyticsDetails.query.variableSequence: 3
  key poper,
      @AnalyticsDetails.query.display: #TEXT
      @AnalyticsDetails.query.axis: #ROWS
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: false, mandatory: false }
      @AnalyticsDetails.query.variableSequence: 1
  key fplv,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
  key sysid,
      @AnalyticsDetails.query.display: #KEY_TEXT
      @AnalyticsDetails.query.axis: #ROWS
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: true, mandatory: false }
      @AnalyticsDetails.query.variableSequence: 4
  key legalentity,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #ROWS
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: true, mandatory: false }
      @AnalyticsDetails.query.variableSequence: 5
  key ccode,
      @AnalyticsDetails.query.display: #TEXT
      @AnalyticsDetails.query.axis: #ROWS
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: true, mandatory: false }
      @AnalyticsDetails.query.variableSequence: 6
      @Consumption.semanticObject: 'BusinessConfiguration'
  key costobject,

      @AnalyticsDetails.query.axis: #ROWS
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: true, mandatory: false }
      @AnalyticsDetails.query.variableSequence: 7
      @AnalyticsDetails.query.display: #KEY_TEXT
  key costcenter,
      @AnalyticsDetails.query.display: #KEY_TEXT
      @AnalyticsDetails.query.axis: #ROWS
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: true, mandatory: false }
      @AnalyticsDetails.query.variableSequence: 8
  key serviceproduct,
      @AnalyticsDetails.query.display: #KEY_TEXT
      @AnalyticsDetails.query.axis: #FREE
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: true, mandatory: false }
      @AnalyticsDetails.query.variableSequence: 9
  key receivingentity,
      @AnalyticsDetails.query.display: #KEY_TEXT
      @AnalyticsDetails.query.axis: #FREE
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: true, mandatory: false }
      servicetype,
      @AnalyticsDetails.query.display: #KEY_TEXT
      @AnalyticsDetails.query.axis: #FREE
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: true, mandatory: false }
      transactiongroup,
      @AnalyticsDetails.query.display: #KEY_TEXT
      @AnalyticsDetails.query.axis: #FREE
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: true, mandatory: false }
      businessdivision,
      @AnalyticsDetails.query.display: #KEY_TEXT
      @AnalyticsDetails.query.axis: #FREE
      @Consumption.filter: { selectionType : #SINGLE, multipleSelections: true, mandatory: false }
      profitcenter,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      localcurr,
//      @AnalyticsDetails.query.display: #KEY
//      @AnalyticsDetails.query.axis: #FREE
//      groupcurr,
      
      
      //    Measures
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      @Semantics.amount.currencyCode: 'Localcurr'
      rectotalcostl,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      @Semantics.amount.currencyCode: 'Localcurr'
      recexcludedcostl,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      @Semantics.amount.currencyCode: 'Localcurr'
      Recincludedcostl,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      @Semantics.amount.currencyCode: 'Localcurr'
      recorigtotalcostl,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      @Semantics.amount.currencyCode: 'Localcurr'
      recpasstotalcostl,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      @Semantics.amount.currencyCode: 'Localcurr'
      Stewardshipl,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      @Semantics.amount.currencyCode: 'Localcurr'
      Reccostsharel,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      @Semantics.amount.currencyCode: 'Localcurr'
      recvalueaddedl,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      @Semantics.amount.currencyCode: 'Localcurr'
      recpassthroughl,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      @Semantics.amount.currencyCode: 'Localcurr'
      Rectotalmarkupabsl,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      @Semantics.amount.currencyCode: 'Localcurr'
      recvalueaddmarkupabsl,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      @Semantics.amount.currencyCode: 'Localcurr'
      recpassthrumarkupabsl,
      @AnalyticsDetails.query.display: #KEY
      @AnalyticsDetails.query.axis: #FREE
      @Semantics.amount.currencyCode: 'Localcurr'
      reckpishareabsl
      
}
