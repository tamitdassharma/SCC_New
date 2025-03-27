@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST, #UNION ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Allocation Data Mapping'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /ESRCC/I_TOTALCB_ALLOC
  as select from /ESRCC/I_TOTALCB_LI as totalcb_li

  association [0..1] to /esrcc/srvaloc               as srvalloc  on srvalloc.serviceproduct =       totalcb_li.serviceproduct
                                                                  and srvalloc.cost_version   =       totalcb_li.fplv
                                                                  and totalcb_li.validon      between srvalloc.validfrom and srvalloc.validto
 
{
  key ryear,
  key poper,
  key fplv,
  key sysid,
  key legalentity,
  key ccode,
  key costobject,
  key costcenter,
<<<<<<< HEAD
  key serviceproduct,
      profitcenter,
      businessdivision,
      controllingarea,
      billfrequency,
      srvalloc.chargeout,    
      srvalloc.capacity_version,
      srvalloc.cost_version,
      srvalloc.consumption_version,
      srvalloc.key_version,
      srvalloc.uom,
      validon,
      localcurr,
      groupcurr,
      excludedtotalcost_l,
      origtotalcost_l,
      passtotalcost_l,
      excludedtotalcost_g,
      origtotalcost_g,
      passtotalcost_g,
      remainingorigcostbase_l,
      remainingpasscostbase_l,
      remainingorigcostbase_g,
      remainingpasscostbase_g,
      srvcostshareL,
      valueaddshareL,
      passthroughshareL,
      srvcostshareG,
      valueaddshareG,
      passthroughshareG
=======
  key ServiceProduct,
      srvalloc.ChargeoutMethod as chargeout,    
      srvalloc.CapacityVersion as capacity_version,
      srvalloc.CostVersion as cost_version,
      srvalloc.ConsumptionVersion as consumption_version,
      srvalloc.KeyVersion as key_version,
//      srvalloc.Uom,
      validon,
      localcurr,
      groupcurr,
      ShareOfCost,
      ContractId
>>>>>>> origin/main
}
