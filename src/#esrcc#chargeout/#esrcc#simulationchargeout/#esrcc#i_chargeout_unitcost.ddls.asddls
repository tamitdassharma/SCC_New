@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Charge-Out Markup'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_CHARGEOUT_UNITCOST
     as select from /ESRCC/I_TOTALCB_ALLOC as totalcb_li
     
    association [0..1] to /esrcc/dirplan as dirplan
    on  dirplan.ryear = totalcb_li.ryear
    and dirplan.poper = totalcb_li.poper
    and dirplan.fplv = totalcb_li.capacity_version
    and dirplan.serviceproduct = totalcb_li.serviceproduct
     
    association [0..1] to /esrcc/srvprrec as srvprec
    on srvprec.legalentity = totalcb_li.legalentity
    and srvprec.ccode = totalcb_li.ccode
    and srvprec.sysid = totalcb_li.sysid
    and srvprec.costobject = totalcb_li.costobject
    and srvprec.costcenter = totalcb_li.costcenter
    and srvprec.serviceproduct = totalcb_li.serviceproduct
    and totalcb_li.validon between srvprec.validfrom and srvprec.validto
      
    association [0..1] to /esrcc/srvmkp as srvmkp
     on srvmkp.serviceproduct = totalcb_li.serviceproduct
    and totalcb_li.validon between srvmkp.validfrom and srvmkp.validto
    
    association [0..1] to /esrcc/pro2srty as pro2srty
    on pro2srty.serviceproduct = totalcb_li.serviceproduct
    
    association [0..1] to /esrcc/le_cctr as cc2le
    on  cc2le.legalentity = totalcb_li.legalentity
    and cc2le.sysid = totalcb_li.sysid
    and cc2le.ccode = totalcb_li.ccode
    and cc2le.costobject = totalcb_li.costobject
    and cc2le.costcenter = totalcb_li.costcenter
    and totalcb_li.validon between cc2le.validfrom and cc2le.validto
{
    key ryear,
    key poper,
    key fplv,
    key sysid,
    key legalentity,
    key ccode,
    key costobject,
    key costcenter,
    key serviceproduct,

// Additonal Characteristicsa
    profitcenter,
    businessdivision,
    controllingarea,
    billfrequency,   
    pro2srty.servicetype,
    pro2srty.transactiongroup,   
    capacity_version,
    cost_version,
    consumption_version, 
    key_version,   
    chargeout, 
    validon,
    localcurr,
    groupcurr,

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
    cast( remainingorigcostbase_l as abap.dec(23,5) ) as remainingorigcostbase_l,
    cast( remainingpasscostbase_l as abap.dec(23,5) ) as remainingpasscostbase_l,
    cast( remainingorigcostbase_g as abap.dec(23,5) ) as remainingorigcostbase_g,
    cast( remainingpasscostbase_g as abap.dec(23,5) ) as remainingpasscostbase_g,
    cast((remainingorigcostbase_l + remainingpasscostbase_l ) as abap.dec(23,5) ) as remainingcostbase_l,
    cast((remainingorigcostbase_g + remainingpasscostbase_g ) as abap.dec(23,5) ) as remainingcostbase_g, 
    cc2le.stewardship,   
    srvprec.costshare,
    
//  Indirect Allocation& Service calculation
    cast( srvcostshareL as abap.dec(23,5) ) as srvcostshareL,
    cast( valueaddshareL as abap.dec(23,5) ) as valueaddshareL,
    cast( passthroughshareL as abap.dec(23,5) ) as passthroughshareL,
    cast( srvcostshareG as abap.dec(23,5) ) as srvcostshareG,
    cast( valueaddshareG as abap.dec(23,5) ) as valueaddshareG,
    cast( passthroughshareG as abap.dec(23,5) ) as passthroughshareG,
    
//  Direct allocation unit cost
    @Semantics.quantity.unitOfMeasure: 'uom'
    cast(case when chargeout = 'D' and dirplan.uom <> uom then
    unit_conversion( 
                     client => $session.client,
                     quantity => dirplan.planning,
                     source_unit => dirplan.uom,
                     target_unit => uom,
                     error_handling => 'SET_TO_NULL' ) 
    else
    dirplan.planning end as abap.quan( 23, 2 )) as planning,
    uom,
    cast(case when chargeout = 'D' and  dirplan.planning <> 0 then
    totalcb_li.srvcostshareL / case when chargeout = 'D' and dirplan.uom <> uom then
                                    unit_conversion( 
                                                     client => $session.client,
                                                     quantity => dirplan.planning,
                                                     source_unit => dirplan.uom,
                                                     target_unit => uom,
                                                     error_handling => 'SET_TO_NULL' ) 
                                    else dirplan.planning end   
    else
    0 end as abap.dec(10,5)) as servicecostperunitL,
    
    cast(case when chargeout = 'D' and  dirplan.planning <> 0  then
    ( valueaddshareL / case when chargeout = 'D' and dirplan.uom <> uom then
                                    unit_conversion( 
                                                     client => $session.client,
                                                     quantity => dirplan.planning,
                                                     source_unit => dirplan.uom,
                                                     target_unit => uom,
                                                     error_handling => 'SET_TO_NULL' ) 
                                    else dirplan.planning end ) 
    else
    0 end as abap.dec(10,5)) as valueaddcostperunitL,
    
    cast(case when chargeout = 'D' and  dirplan.planning <> 0 then
    (passthroughshareL / case when chargeout = 'D' and dirplan.uom <> uom then
                                    unit_conversion( 
                                                     client => $session.client,
                                                     quantity => dirplan.planning,
                                                     source_unit => dirplan.uom,
                                                     target_unit => uom,
                                                     error_handling => 'SET_TO_NULL' ) 
                                    else dirplan.planning end ) 
    else
    0 end as abap.dec(10,5)) as passthrucostperunitL,
    
//    0  as overallcostperunitG,   
    
    cast(case when chargeout = 'D' and  dirplan.planning <> 0 then
    (totalcb_li.srvcostshareG / case when chargeout = 'D' and dirplan.uom <> uom then
                                    unit_conversion( 
                                                     client => $session.client,
                                                     quantity => dirplan.planning,
                                                     source_unit => dirplan.uom,
                                                     target_unit => uom,
                                                     error_handling => 'SET_TO_NULL' ) 
                                    else dirplan.planning end ) 
    else
    0 end as abap.dec(10,5)) as servicecostperunitG,
    
    cast(case when chargeout = 'D' and  dirplan.planning <> 0 then
    (valueaddshareG / case when chargeout = 'D' and dirplan.uom <> uom then
                                    unit_conversion( 
                                                     client => $session.client,
                                                     quantity => dirplan.planning,
                                                     source_unit => dirplan.uom,
                                                     target_unit => uom,
                                                     error_handling => 'SET_TO_NULL' ) 
                                    else dirplan.planning end )  
    else
    0 end as abap.dec(10,5)) as valueaddcostperunitG,
    
    cast(case when chargeout = 'D' and  dirplan.planning <> 0  then
    (passthroughshareG / case when chargeout = 'D' and dirplan.uom <> uom then
                                    unit_conversion( 
                                                     client => $session.client,
                                                     quantity => dirplan.planning,
                                                     source_unit => dirplan.uom,
                                                     target_unit => uom,
                                                     error_handling => 'SET_TO_NULL' ) 
                                    else dirplan.planning end ) 
    else
    0 end as abap.dec(10,5)) as passthrucostperunitG,
    
// Markup calulation
    srvmkp.origcost as valueaddmarkup,
    srvmkp.passcost as passthrumarkup,
    
    cast(case when chargeout = 'D' and dirplan.planning <> 0 then
    (valueaddshareL / case when chargeout = 'D' and dirplan.uom <> uom then
                                    unit_conversion( 
                                                     client => $session.client,
                                                     quantity => dirplan.planning,
                                                     source_unit => dirplan.uom,
                                                     target_unit => uom,
                                                     error_handling => 'SET_TO_NULL' ) 
                                    else dirplan.planning end ) * (srvmkp.origcost / 100) 
    else 0 end as abap.dec(10,5)) as tp_valueaddmarkupcostperunitL,
    
    cast(case when chargeout = 'D' and dirplan.planning <> 0 then
    (valueaddshareG / case when chargeout = 'D' and dirplan.uom <> uom then
                                    unit_conversion( 
                                                     client => $session.client,
                                                     quantity => dirplan.planning,
                                                     source_unit => dirplan.uom,
                                                     target_unit => uom,
                                                     error_handling => 'SET_TO_NULL' ) 
                                    else dirplan.planning end ) * (srvmkp.origcost / 100) 
    else 0 end as abap.dec(10,5)) as tp_valueaddmarkupcostperunitG,
    
    cast(case when chargeout = 'D' and dirplan.planning <> 0 then
    (passthroughshareL / case when chargeout = 'D' and dirplan.uom <> uom then
                                    unit_conversion( 
                                                     client => $session.client,
                                                     quantity => dirplan.planning,
                                                     source_unit => dirplan.uom,
                                                     target_unit => uom,
                                                     error_handling => 'SET_TO_NULL' ) 
                                    else dirplan.planning end ) * (srvmkp.passcost / 100) 
    else 0 end as abap.dec(10,5)) as tp_passthrumarkupcostperunitL,
    
    cast(case when chargeout = 'D' and dirplan.planning <> 0 then
    (passthroughshareG / case when chargeout = 'D' and dirplan.uom <> uom then
                                    unit_conversion( 
                                                     client => $session.client,
                                                     quantity => dirplan.planning,
                                                     source_unit => dirplan.uom,
                                                     target_unit => uom,
                                                     error_handling => 'SET_TO_NULL' ) 
                                    else dirplan.planning end ) * (srvmkp.passcost / 100) 
    else 0 end as abap.dec(10,5)) as tp_passthrumarkupcostperunitG,
    
    cast(valueaddshareL * ( srvmkp.origcost / 100 ) as abap.dec(23,5)) as valueaddmarkupabsL,
    
    cast(passthroughshareL * ( srvmkp.passcost / 100 ) as abap.dec(23,5)) as passthrumarkupabsL,

    cast(valueaddshareG * ( srvmkp.origcost / 100 ) as abap.dec(23,5)) as valueaddmarkupabsG,

    cast(passthroughshareG * ( srvmkp.passcost / 100 ) as abap.dec(23,5)) as passthrumarkupabsG    

}
