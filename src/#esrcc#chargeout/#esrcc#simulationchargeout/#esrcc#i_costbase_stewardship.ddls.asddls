@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Charge-Out Markup'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_COSTBASE_STEWARDSHIP
     as select from /ESRCC/I_TOTALCOSTABSE as totalcb_li
  
    association [0..*] to /esrcc/le_cctr as cc2le
    on  cc2le.legalentity = totalcb_li.Legalentity
    and cc2le.sysid = totalcb_li.Sysid
    and cc2le.ccode = totalcb_li.Ccode
    and cc2le.costobject = totalcb_li.Costobject
    and cc2le.costcenter = totalcb_li.Costcenter
    and totalcb_li.validon between cc2le.validfrom and cc2le.validto
{
    key Ryear,
    key Poper,
    key Fplv,
    key Sysid,
    key Legalentity,
    key Ccode,
    key Costobject,
    key Costcenter,

// Additonal Characteristicsa
    profitcenter,
    businessdivision,
    controllingarea,
    billfrequency,    
    validon,
    Localcurr,
    Groupcurr,

//cost center cost evaluation
    ( origtotalcost_l + passtotalcost_l + excludedtotalcost_l ) as Totalcost_l,
    excludedtotalcost_l,
    ( origtotalcost_l + passtotalcost_l) as includetotalcost_l, 
    origtotalcost_l,
    passtotalcost_l,
    ( origtotalcost_g + passtotalcost_g + excludedtotalcost_g ) as Totalcost_g,
    excludedtotalcost_g,
    ( origtotalcost_g + passtotalcost_g) as includetotalcost_g,    
    origtotalcost_g,
    passtotalcost_g,
    cc2le.stewardship    

}
