@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service cosrt & Share'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_TOTALCOSTABSE 
   as select from /ESRCC/I_CB_LI as cb_li

    association [0..*] to /esrcc/le_cctr as ccsrv
    on ccsrv.legalentity = cb_li.Legalentity
    and ccsrv.sysid = cb_li.Sysid
    and ccsrv.ccode = cb_li.Ccode
    and ccsrv.costobject = cb_li.Costobject
    and ccsrv.costcenter = cb_li.Costcenter
    and cb_li.validon >= ccsrv.validfrom
    and cb_li.validon <= ccsrv.validto
    
    association [0..1] to /esrcc/coscen as cosobj
    on cosobj.sysid = cb_li.Sysid
    and cosobj.costobject = cb_li.Costobject
    and cosobj.costcenter = cb_li.Costcenter
    
    association [0..1] to /esrcc/le_ccode as ccode
    on ccode.sysid  = cb_li.Sysid
    and ccode.ccode = cb_li.Ccode
    and ccode.active = 'X'
 
{
    key Ryear,
    key Poper,
    key Fplv,
    key cb_li.Sysid,
    key Legalentity,
    key cb_li.Ccode,
    key Costobject,
    key Costcenter,
    ccsrv.profitcenter,
    ccsrv.businessdivision,
    ccode.controllingarea,
    cosobj.billfrequency,
    validon,
    Localcurr,
    Groupcurr,   
    @Semantics.amount.currencyCode: 'Localcurr'
    sum(excludedcost_l) as excludedtotalcost_l,
    @Semantics.amount.currencyCode: 'Localcurr'
    sum(origcost_l) as origtotalcost_l,
    @Semantics.amount.currencyCode: 'Localcurr'
    sum(passcost_l) as passtotalcost_l,
    @Semantics.amount.currencyCode: 'Groupcurr'
    sum(excludedcost_g) as excludedtotalcost_g,
    @Semantics.amount.currencyCode: 'Groupcurr'
    sum(origcost_g) as origtotalcost_g,
    @Semantics.amount.currencyCode: 'Groupcurr'
    sum(passcost_g) as passtotalcost_g 
    
}
group by
Ryear,
Poper,
Fplv,
Sysid,
Legalentity,
cb_li.Ccode,
Costobject,
Costcenter,
ccsrv.profitcenter,
ccsrv.businessdivision,
ccode.controllingarea,
cosobj.billfrequency,
validon,
Localcurr,
Groupcurr
