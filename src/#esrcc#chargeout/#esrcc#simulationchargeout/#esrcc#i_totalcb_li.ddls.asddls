@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service cosrt & Share'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_TOTALCB_LI 
//   as select from /ESRCC/I_CB_LI as cb_li
   as select from /esrcc/cc_cost as cb_li

    association [0..*] to /esrcc/le_cctr as ccsrv
    on ccsrv.legalentity = cb_li.legalentity
    and ccsrv.sysid = cb_li.sysid
    and ccsrv.ccode = cb_li.ccode
    and ccsrv.costobject = cb_li.costobject
    and ccsrv.costcenter = cb_li.costcenter
    and cb_li.validon >= ccsrv.validfrom
    and cb_li.validon <= ccsrv.validto
    
    association [0..*] to /esrcc/srvprrec as srvprm
    on srvprm.legalentity = cb_li.legalentity
    and srvprm.sysid = cb_li.sysid
    and srvprm.ccode = cb_li.ccode
    and srvprm.costobject = cb_li.costobject
    and srvprm.costcenter = cb_li.costcenter
    and cb_li.validon >= srvprm.validfrom
    and cb_li.validon <= srvprm.validto
    
    association [0..1] to /esrcc/coscen as cosobj
    on cosobj.sysid = cb_li.sysid
    and cosobj.costobject = cb_li.costobject
    and cosobj.costcenter = cb_li.costcenter
    
    association [0..1] to /esrcc/le_ccode as ccode
    on ccode.sysid  = cb_li.sysid
    and ccode.ccode = cb_li.ccode
    and ccode.active = 'X'
 
{
    key ryear,
    key poper,
    key fplv,
    key cb_li.sysid,
    key legalentity,
    key cb_li.ccode,
    key costobject,
    key costcenter,
    key srvprm.serviceproduct,
    ccsrv.profitcenter,
    ccsrv.businessdivision,
    ccode.controllingarea,
    cosobj.billfrequency,
    validon,
    localcurr,
    groupcurr,   
//    @Semantics.amount.currencyCode: 'Localcurr'
//    sum(excludedcost_l) as excludedtotalcost_l,
//    @Semantics.amount.currencyCode: 'Localcurr'
//    sum(origcost_l) as origtotalcost_l,
//    @Semantics.amount.currencyCode: 'Localcurr'
//    sum(passcost_l) as passtotalcost_l,
//    @Semantics.amount.currencyCode: 'Groupcurr'
//    sum(excludedcost_g) as excludedtotalcost_g,
//    @Semantics.amount.currencyCode: 'Groupcurr'
//    sum(origcost_g) as origtotalcost_g,
//    @Semantics.amount.currencyCode: 'Groupcurr'
//    sum(passcost_g) as passtotalcost_g,
// 
//// Stewardship    
//    @Semantics.amount.currencyCode: 'Localcurr' 
//    sum(origcost_l - ( ( ccsrv.stewardship / 100 ) * origcost_l )) as remainingorigcostbase_l,
//    @Semantics.amount.currencyCode: 'Localcurr' 
//    sum(passcost_l - ( ( ccsrv.stewardship / 100 ) * passcost_l )) as remainingpasscostbase_l,
//    
//    @Semantics.amount.currencyCode: 'Localcurr' 
//    sum(origcost_g - ( ( ccsrv.stewardship / 100 ) * origcost_g )) as remainingorigcostbase_g,
//    @Semantics.amount.currencyCode: 'Localcurr' 
//    sum(passcost_g - ( ( ccsrv.stewardship / 100 ) * passcost_g )) as remainingpasscostbase_g,
// 
// //Share of Cost
//    cast(sum(( srvprm.costshare / 100 ) * (origcost_l - ( ( ccsrv.stewardship / 100 ) * origcost_l )) +
//        ( srvprm.costshare / 100 ) * (passcost_l - ( ( ccsrv.stewardship / 100 ) * passcost_l ))) as abap.dec(23,2)) as srvcostshareL,
//    cast(sum(( srvprm.costshare / 100 ) * (origcost_l - ( ( ccsrv.stewardship / 100 ) * origcost_l ))) as abap.dec(23,2)) as valueaddshareL,
//    cast(sum(( srvprm.costshare / 100 ) * (passcost_l - ( ( ccsrv.stewardship / 100 ) * passcost_l ))) as abap.dec(23,2)) as passthroughshareL,
//
//    cast(sum(( srvprm.costshare / 100 ) * (origcost_g - ( ( ccsrv.stewardship / 100 ) * origcost_g )) +
//        ( srvprm.costshare / 100 ) * (passcost_g - ( ( ccsrv.stewardship / 100 ) * passcost_g ))) as abap.dec(23,2)) as srvcostshareG,
//    cast(sum(( srvprm.costshare / 100 ) * (origcost_g - ( ( ccsrv.stewardship / 100 ) * origcost_g ))) as abap.dec(23,2)) as valueaddshareG,
//    cast( sum(( srvprm.costshare / 100 ) * (passcost_g - ( ( ccsrv.stewardship / 100 ) * passcost_g ))) as abap.dec(23,2)) as passthroughshareG
//   
    @Semantics.amount.currencyCode: 'Localcurr'
    excludedtotalcost_l,
    @Semantics.amount.currencyCode: 'Localcurr'
    origtotalcost_l,
    @Semantics.amount.currencyCode: 'Localcurr'
    passtotalcost_l,
    @Semantics.amount.currencyCode: 'Groupcurr'
    excludedtotalcost_g,
    @Semantics.amount.currencyCode: 'Groupcurr'
    origtotalcost_g,
    @Semantics.amount.currencyCode: 'Groupcurr'
    passtotalcost_g,
 
// Stewardship    
    @Semantics.amount.currencyCode: 'Localcurr' 
    origtotalcost_l - ( ( ccsrv.stewardship / 100 ) * origtotalcost_l ) as remainingorigcostbase_l,
    @Semantics.amount.currencyCode: 'Localcurr' 
    passtotalcost_l - ( ( ccsrv.stewardship / 100 ) * passtotalcost_l ) as remainingpasscostbase_l,
    
    @Semantics.amount.currencyCode: 'Localcurr' 
    origtotalcost_g - ( ( ccsrv.stewardship / 100 ) * origtotalcost_g ) as remainingorigcostbase_g,
    @Semantics.amount.currencyCode: 'Localcurr' 
    passtotalcost_g - ( ( ccsrv.stewardship / 100 ) * passtotalcost_g ) as remainingpasscostbase_g,
 
 //Share of Cost
    cast(( srvprm.costshare / 100 ) * (origtotalcost_l - ( ( ccsrv.stewardship / 100 ) * origtotalcost_l )) +
        ( srvprm.costshare / 100 ) * (passtotalcost_l - ( ( ccsrv.stewardship / 100 ) * passtotalcost_l )) as abap.dec(23,2)) as srvcostshareL,
    cast(( srvprm.costshare / 100 ) * (origtotalcost_l - ( ( ccsrv.stewardship / 100 ) * origtotalcost_l )) as abap.dec(23,2)) as valueaddshareL,
    cast(( srvprm.costshare / 100 ) * (passtotalcost_l - ( ( ccsrv.stewardship / 100 ) * passtotalcost_l )) as abap.dec(23,2)) as passthroughshareL,

    cast(( srvprm.costshare / 100 ) * (origtotalcost_g - ( ( ccsrv.stewardship / 100 ) * origtotalcost_g )) +
        ( srvprm.costshare / 100 ) * (passtotalcost_g - ( ( ccsrv.stewardship / 100 ) * passtotalcost_g )) as abap.dec(23,2)) as srvcostshareG,
    cast(( srvprm.costshare / 100 ) * (origtotalcost_g - ( ( ccsrv.stewardship / 100 ) * origtotalcost_g )) as abap.dec(23,2)) as valueaddshareG,
    cast(( srvprm.costshare / 100 ) * (passtotalcost_g - ( ( ccsrv.stewardship / 100 ) * passtotalcost_g )) as abap.dec(23,2)) as passthroughshareG
   
}
//group by
//Ryear,
//Poper,
//Fplv,
//Sysid,
//Legalentity,
//cb_li.Ccode,
//Costobject,
//Costcenter,
//srvprm.serviceproduct,
//ccsrv.profitcenter,
//ccsrv.businessdivision,
//ccode.controllingarea,
//cosobj.billfrequency,
//validon,
//Localcurr,
//Groupcurr
