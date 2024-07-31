@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED Manage Cost Base Line Items'
@Metadata.allowExtensions: true

define root view entity /ESRCC/I_MANAGECOSTBASE
  as select from /esrcc/cb_li as ManageCostBase 
  
  association [0..1] to /ESRCC/I_LEGALENTITY_F4 as legalentity
  on legalentity.Legalentity = ManageCostBase.legalentity
  
  association [0..1] to /ESRCC/I_COMPANYCODES_F4 as ccode  
  on ccode.Ccode = ManageCostBase.ccode
  and ccode.Sysid = $projection.SysID
  and ccode.Legalentity = $projection.Legalentity
  
  association [0..1] to /ESRCC/I_COSTOBJECTS as costobject  
  on costobject.Costobject = ManageCostBase.costobject
  
  association [0..1] to /ESRCC/I_COSCEN_F4 as costcenter
  on costcenter.Costcenter = ManageCostBase.costcenter
  and costcenter.Sysid = ManageCostBase.sysid
  and costcenter.Costobject = $projection.Costobject
  
  association [0..1] to /ESRCC/I_COSTELEMENT_F4 as costelement
  on costelement.Costelement = ManageCostBase.costelement
  and costelement.Sysid = $projection.SysID
  
  association [0..1] to /ESRCC/I_COSTTYPE as costtype
  on costtype.Costtype = ManageCostBase.costtype
  
  association [0..1] to /ESRCC/I_COSTIND as costind
  on costind.costind = ManageCostBase.costind
  
  association [0..1] to /ESRCC/I_POSTINGTYPE as postingtype
  on postingtype.Postingtype = ManageCostBase.postingtype
 
  association [0..1] to /ESRCC/I_COSTDATASET as costdataset
  on costdataset.costdataset = ManageCostBase.fplv
  
  association [0..1] to /ESRCC/I_USAGECALCULATION as usagecal
  on usagecal.usagecal = ManageCostBase.usagecal
  
  association [0..1] to /ESRCC/I_STATUS as status
  on status.Status = ManageCostBase.status  
  
  association [0..1] to /ESRCC/I_BUSINESSDIV_F4 as _businessdiv
  on _businessdiv.BusinessDivision = ManageCostBase.businessdivision
  
  association [0..1] to /ESRCC/I_PROFITCENTER_F4 as _profitcenter
  on _profitcenter.ProfitCenter = ManageCostBase.profitcenter
  
  association [0..1] to /ESRCC/I_REASON_F4 as _reason
  on _reason.Reasonid = ManageCostBase.reasonid
  
  association [0..1] to I_CountryText as _legalCountryText
  on _legalCountryText.Country = $projection.country
  and _legalCountryText.Language = $session.system_language  
{
  key ryear as Ryear,
  key poper as Poper,
  key fplv  as Fplv,
  key sysid as SysID,  
  key ManageCostBase.legalentity as Legalentity,
  key ManageCostBase.ccode as Ccode,
  key belnr as Belnr,
  key buzei as Buzei,
  key ManageCostBase.costobject as Costobject,
  key ManageCostBase.costcenter as Costcenter,
  key ManageCostBase.costelement as Costelement,
  businessdivision as Businessdivision,
  profitcenter as Profitcenter,
  ManageCostBase.costtype as Costtype,
  @Semantics.amount.currencyCode: 'Localcurr'
  hsl as Hsl,
  localcurr as Localcurr,  
  @Semantics.amount.currencyCode: 'Groupcurr'
  ksl as Ksl,
  groupcurr as Groupcurr,
  vendor as Vendor,
  ManageCostBase.postingtype as Postingtype,
  ManageCostBase.costind as Costind,
  ManageCostBase.usagecal as Usagecal,
  ManageCostBase.reasonid as ReasonId,
//  ManageCostBase.costdataset as Costdataset,
  ManageCostBase.status as Status, 
  ManageCostBase.workflowid as WorkflowId,
  oldcostind,
  oldcostdataset,  
  oldusagecal,
  comments as Comments,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  ccode.ccodedescription,
  legalentity.Description as legalentitydescription,
  costobject.text as costobjectdescription,
  costcenter.Description as costcenterdescription,
  costelement.costelementdescription,
  costtype.text as costtypedescription,
  costind.text as costinddescription,
  postingtype.text as postingtypedescription,
  costdataset.text as costdatasetdescription,
  usagecal.text as usagecaldescription,
  _reason.reasondescription,
  status.text as statusdescription,
  legalentity.Country,
  _businessdiv.Description as businessdivdescription,
  _profitcenter.profitcenterdescription,
  case ManageCostBase.usagecal
    when 'I' then 3
    else 1
   end as usagecriticallity,
  
   case ManageCostBase.status 
     when 'D' then 2
     when 'P' then 2
     when 'W' then 2
     when 'U' then 3
     when 'E' then 3
     when 'A' then 3
     when 'F' then 3
     when 'R' then 1 
     when 'C' then 1 
     else
     0
   end as statuscriticallity,
   _legalCountryText
  
  
} 
