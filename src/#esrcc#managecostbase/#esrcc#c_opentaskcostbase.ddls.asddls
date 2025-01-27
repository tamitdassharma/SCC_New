@EndUserText.label: 'Cost base application for Wf Open Task'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity /ESRCC/C_OPENTASKCOSTBASE 
 provider contract transactional_query
 as projection on /ESRCC/I_MANAGECOSTBASE {
  key Ryear,
  key Poper,
  @ObjectModel.text.element: [ 'costdatasetdescription' ]
  key Fplv,
  key SysID,
  @ObjectModel.text.element: [ 'legalentitydescription' ]
  key Legalentity,
  @ObjectModel.text.element: [ 'ccodedescription' ]
  key Ccode,
  key Belnr,
  key Buzei,
  @ObjectModel.text.element: [ 'costobjectdescription' ]
  key Costobject,
  @ObjectModel.text.element: [ 'costcenterdescription' ]
  key Costcenter,
  @ObjectModel.text.element: [ 'costelementdescription' ]
  key Costelement,
  @ObjectModel.text.element: [ 'valuesourcedescription' ]
  ValueSource,
  @ObjectModel.text.element: [ 'businessdivdescription' ]
  Businessdivision,
  @ObjectModel.text.element: [ 'profitcenterdescription' ]
  Profitcenter,
  @ObjectModel.text.element: [ 'costtypedescription' ]
  Costtype,  
  Hsl,
  Localcurr,
  Ksl,
  Groupcurr,
  Vendor,
  @ObjectModel.text.element: [ 'postingtypedescription' ]
  Postingtype,
  @ObjectModel.text.element: [ 'costinddescription' ]
  Costind,
  @ObjectModel.text.element: [ 'usagecaldescription' ]
  Usagecal,
  @ObjectModel.text.element: [ 'reasondescription' ]
  ReasonId,
//  @ObjectModel.text.element: [ 'costdatasetdescription' ]
//  Costdataset,
  @ObjectModel.text.element: [ 'statusdescription' ]
  Status,
  WorkflowId as Workflowid,
  @Semantics.user.createdBy: true
  CreatedBy,
  @ObjectModel.filter.enabled: false
  @Semantics.systemDateTime.createdAt: true
  CreatedAt,
  @Semantics.user.lastChangedBy: true
  LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  LastChangedAt,
  LocalLastChangedAt,
  @Semantics.text: true
  ccodedescription,
  @Semantics.text: true
  legalentitydescription,
  @Semantics.text: true
  costobjectdescription,
  @Semantics.text: true
  costcenterdescription,
  @Semantics.text: true
  costelementdescription,
  @Semantics.text: true
  costtypedescription,
  @Semantics.text: true
  costinddescription,
  @Semantics.text: true
  postingtypedescription,
  @Semantics.text: true
  costdatasetdescription,
  @Semantics.text: true
  usagecaldescription,
  @Semantics.text: true
  statusdescription,
  @Semantics.text: true
  businessdivdescription,
  profitcenterdescription,
  usagecriticallity,
  @Semantics.text: true
  valuesourcedescription,
  @Semantics.text: true
  reasondescription, 
  statuscriticallity,
  @ObjectModel.text.element: [ 'legalentitycountryname' ]
  Country,
  _legalCountryText.CountryName as legalentitycountryname  
  
}
