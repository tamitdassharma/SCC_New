@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Chargout to Receivers Share'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Analytics.dataCategory: #CUBE
define root view entity /ESRCC/I_CHARGEOUT_RECSHARE
  as select from /ESRCC/I_CHARGEOUT_RECEIVERS as chargeoutreckpi
  
  association [0..1] to /ESRCC/I_INDTOTALKPISHARE as _chargeoutreckpisum     on  _chargeoutreckpisum.Fplv          = chargeoutreckpi.fplv
                                                                             and _chargeoutreckpisum.Ryear         = chargeoutreckpi.ryear
                                                                             and _chargeoutreckpisum.Poper         = chargeoutreckpi.poper
                                                                             and _chargeoutreckpisum.Sysid         = chargeoutreckpi.sysid
                                                                             and _chargeoutreckpisum.Legalentity   = chargeoutreckpi.legalentity
                                                                             and _chargeoutreckpisum.Ccode         = chargeoutreckpi.ccode
                                                                             and _chargeoutreckpisum.Costobject    = chargeoutreckpi.costobject
                                                                             and _chargeoutreckpisum.Costcenter    = chargeoutreckpi.costcenter
                                                                             and _chargeoutreckpisum.serviceproduct = chargeoutreckpi.serviceproduct
                                                                             and _chargeoutreckpisum.receivingentity = chargeoutreckpi.receivingentity
                                                                             and chargeoutreckpi.chargeout =  'I'

  association [0..1] to /esrcc/diralloc              as _diralloc           on  _diralloc.serviceproduct  =  chargeoutreckpi.serviceproduct
                                                                            and _diralloc.receivingentity =  chargeoutreckpi.receivingentity
                                                                            and _diralloc.ryear           =  chargeoutreckpi.ryear
                                                                            and _diralloc.poper           =  chargeoutreckpi.poper
                                                                            and _diralloc.fplv            =  chargeoutreckpi.consumption_version
                                                                            and chargeoutreckpi.chargeout =  'D'


  association [0..1] to /ESRCC/I_LEGALENTITY_F4      as _legalentity        on  _legalentity.Legalentity = chargeoutreckpi.legalentity

  association [0..1] to /ESRCC/I_RECEIVINGENTITY_F4  as _receivingentity    on  _receivingentity.Receivingentity = chargeoutreckpi.receivingentity

  association [0..1] to /ESRCC/I_COMPANYCODES_F4     as _ccode              on  _ccode.Sysid = chargeoutreckpi.sysid
                                                                            and _ccode.Ccode = chargeoutreckpi.ccode
                                                                            and _ccode.Legalentity = chargeoutreckpi.legalentity

  association [0..1] to /ESRCC/I_COSTOBJECTS         as _costobject         on  _costobject.Costobject = chargeoutreckpi.costobject

  association [0..1] to /ESRCC/I_COSCEN_F4           as _costcenter         on  _costcenter.Costcenter = chargeoutreckpi.costcenter
                                                                           and  _costcenter.Sysid      = chargeoutreckpi.sysid
                                                                           and  _costcenter.Costobject = chargeoutreckpi.costobject

  association [0..1] to /ESRCC/I_SERVICEPRODUCT_F4   as _serviceproduct     on  _serviceproduct.ServiceProduct = chargeoutreckpi.serviceproduct

  association [0..1] to /ESRCC/I_SERVICETYPE_F4      as _servicetype        on  _servicetype.ServiceType = chargeoutreckpi.servicetype

  association [0..1] to /ESRCC/I_TRANSACTIONGROUP_F4 as _transactiongroup   on  _transactiongroup.Transactiongroup = chargeoutreckpi.transactiongroup

{
  key ryear,
  key poper,
  key fplv,
  key sysid,
  key chargeoutreckpi.legalentity,
  key chargeoutreckpi.ccode,
  key chargeoutreckpi.costobject,
  key chargeoutreckpi.costcenter,
  key chargeoutreckpi.serviceproduct,
  key chargeoutreckpi.receivingentity as Receivingentity,
      validon,
      chargeoutreckpi.servicetype,
      chargeoutreckpi.transactiongroup,            
      chargeout,
      // Additonal Characteristicsa
      profitcenter,
      businessdivision,
      controllingarea,
      billfrequency,
      capacity_version,
      consumption_version,
      key_version,
      @Semantics.quantity.unitOfMeasure: 'uom'
      planning,
      uom,
      stewardship,
      @Semantics.quantity.unitOfMeasure: 'uom'
      cast(case when chargeout = 'I' then
       0 
      else
      case when _diralloc.uom <> chargeoutreckpi.uom then
      unit_conversion( quantity => _diralloc.consumption,
                     source_unit => _diralloc.uom,
                     target_unit => chargeoutreckpi.uom,
                     error_handling => 'SET_TO_NULL' ) 
      else
      _diralloc.consumption end 
      end as abap.quan( 23, 2))       as reckpi,
      @Semantics.amount.currencyCode: 'Localcurr'
      @DefaultAggregation: #SUM
      totalcost_l,
      localcurr,
      @Semantics.amount.currencyCode: 'Groupcurr'
      totalcost_g,
      groupcurr,
      @DefaultAggregation: #SUM
      excludedtotalcost_l,
      @DefaultAggregation: #SUM
      includetotalcost_l,
      @DefaultAggregation: #SUM
      origtotalcost_l,
      @DefaultAggregation: #SUM
      passtotalcost_l,
      excludedtotalcost_g,
      includetotalcost_g,
      origtotalcost_g,
      passtotalcost_g,
      @DefaultAggregation: #SUM
      remainingcostbase_l,
      remainingcostbase_g,      
      costshare,
      srvcostsharel,
      valueaddsharel,
      passthroughsharel,
      valueaddmarkup,
      passthrumarkup,
      valueaddmarkupabsl,
      passthrumarkupabsl,
      srvtotalmarkupabsL,
      totalchargeoutamountL,
      srvcostshareg,
      valueaddshareg,
      passthroughshareg,
      valueaddmarkupabsg,
      passthrumarkupabsg,
      srvtotalmarkupabsG,
      totalchargeoutamountG,
      servicecostperunitl,
      servicecostperunitg,
      valueaddcostperunitl,
      valueaddcostperunitg,
      passthrucostperunitl,
      passthrucostperunitg,
      tp_valueaddmarkupcostperunitl,
      tp_valueaddmarkupcostperunitg,
      tp_passthrumarkupcostperunitl,
      tp_passthrumarkupcostperunitg,
      transferpriceL,
      transferpriceG,
      case when chargeout = 'I' then
      cast( _chargeoutreckpisum.totalreckpishare * 100 as abap.dec(5,2))
      else
       0
      end                             as reckpishare,

      case when chargeout = 'I' then      
      cast( ( _chargeoutreckpisum.totalreckpishare  * totalchargeoutamountL ) as abap.dec(23,2)) 
      else
      cast(transferpriceL * (cast(case when _diralloc.uom <> chargeoutreckpi.uom then
                              unit_conversion( quantity => _diralloc.consumption,
                                             source_unit => _diralloc.uom,
                                             target_unit => chargeoutreckpi.uom,
                                             error_handling => 'SET_TO_NULL' ) 
                                  else
                                  _diralloc.consumption end as abap.dec(23,2))  )
        as abap.dec(23,2))  end as reckpishareabsL,

      case when chargeout = 'I' then
      cast( ( _chargeoutreckpisum.totalreckpishare  * totalchargeoutamountG ) as abap.dec(23,2)) 
      else
      cast(transferpriceG * (cast(case when _diralloc.uom <> chargeoutreckpi.uom then
                              unit_conversion( quantity => _diralloc.consumption,
                                             source_unit => _diralloc.uom,
                                             target_unit => chargeoutreckpi.uom,
                                             error_handling => 'SET_TO_NULL' ) 
                                  else
                                  _diralloc.consumption end as abap.dec(23,2))  ) as abap.dec(23,2))
      end                            as reckpishareabsG,
       
      case when chargeout = 'I'  then
      cast( ( _chargeoutreckpisum.totalreckpishare  * srvtotalmarkupabsL ) as abap.dec(23,2))
      else 
      cast( (tp_valueaddmarkupcostperunitl + tp_passthrumarkupcostperunitl) * (cast(case when _diralloc.uom <> chargeoutreckpi.uom then
                              unit_conversion( quantity => _diralloc.consumption,
                                             source_unit => _diralloc.uom,
                                             target_unit => chargeoutreckpi.uom,
                                             error_handling => 'SET_TO_NULL' ) 
                                  else
                                  _diralloc.consumption end as abap.dec(23,2))  ) as abap.dec(23,2)) 
      end                      as rectotalmarkupabsL,

      case when chargeout = 'I'then
      cast( ( _chargeoutreckpisum.totalreckpishare  * srvtotalmarkupabsG ) as abap.dec(23,2))
      else 
      cast( (tp_valueaddmarkupcostperunitg + tp_passthrumarkupcostperunitg) * (cast(case when _diralloc.uom <> chargeoutreckpi.uom then
                              unit_conversion( quantity => _diralloc.consumption,
                                             source_unit => _diralloc.uom,
                                             target_unit => chargeoutreckpi.uom,
                                             error_handling => 'SET_TO_NULL' ) 
                                  else
                                  _diralloc.consumption end as abap.dec(23,2))  ) as abap.dec(23,2)) 
      end                      as rectotalmarkupabsG,
      
      case when chargeout = 'I'  then
      cast( ( _chargeoutreckpisum.totalreckpishare  * valueaddmarkupabsl ) as abap.dec(23,2))
      else 
      cast( tp_valueaddmarkupcostperunitl * (cast(case when _diralloc.uom <> chargeoutreckpi.uom then
                              unit_conversion( quantity => _diralloc.consumption,
                                             source_unit => _diralloc.uom,
                                             target_unit => chargeoutreckpi.uom,
                                             error_handling => 'SET_TO_NULL' ) 
                                  else
                                  _diralloc.consumption end as abap.dec(23,2))  ) as abap.dec(23,2)) 
       end                      as recvalueaddmarkupabsL,

      case when chargeout = 'I'then
      cast( ( _chargeoutreckpisum.totalreckpishare  * valueaddmarkupabsg ) as abap.dec(23,2))
      else 
      cast( tp_valueaddmarkupcostperunitg * (cast(case when _diralloc.uom <> chargeoutreckpi.uom then
                              unit_conversion( quantity => _diralloc.consumption,
                                             source_unit => _diralloc.uom,
                                             target_unit => chargeoutreckpi.uom,
                                             error_handling => 'SET_TO_NULL' ) 
                                  else
                                  _diralloc.consumption end as abap.dec(23,2))  ) as abap.dec(23,2)) 
      end                      as recvalueaddmarkupabsG,
      
      case when chargeout = 'I'  then
      cast( ( _chargeoutreckpisum.totalreckpishare  * passthrumarkupabsl ) as abap.dec(23,2))
      else 
      cast( tp_passthrumarkupcostperunitl * (cast(case when _diralloc.uom <> chargeoutreckpi.uom then
                              unit_conversion( quantity => _diralloc.consumption,
                                             source_unit => _diralloc.uom,
                                             target_unit => chargeoutreckpi.uom,
                                             error_handling => 'SET_TO_NULL' ) 
                                  else
                                  _diralloc.consumption end as abap.dec(23,2))  ) as abap.dec(23,2)) 
      end                      as recpassthrumarkupabsL,

      case when chargeout = 'I'then
      cast( ( _chargeoutreckpisum.totalreckpishare  * passthrumarkupabsg ) as abap.dec(23,2))
      else 
      cast( tp_passthrumarkupcostperunitg * (cast(case when _diralloc.uom <> chargeoutreckpi.uom then
                              unit_conversion( quantity => _diralloc.consumption,
                                             source_unit => _diralloc.uom,
                                             target_unit => chargeoutreckpi.uom,
                                             error_handling => 'SET_TO_NULL' ) 
                                  else
                                  _diralloc.consumption end as abap.dec(23,2))  ) as abap.dec(23,2)) 
      end                      as recpassthrumarkupabsG,

      case when chargeout = 'I' then
      cast( ( _chargeoutreckpisum.totalreckpishare  * srvcostsharel )  as abap.dec(23,2))
      else 
      cast( servicecostperunitl * (cast(case when _diralloc.uom <> chargeoutreckpi.uom then
                              unit_conversion( quantity => _diralloc.consumption,
                                             source_unit => _diralloc.uom,
                                             target_unit => chargeoutreckpi.uom,
                                             error_handling => 'SET_TO_NULL' ) 
                                  else
                                  _diralloc.consumption end as abap.dec(23,2))  ) as abap.dec(23,2)) 
      end                      as reccostshareL,

      case when chargeout = 'I' then
      cast( ( _chargeoutreckpisum.totalreckpishare  * srvcostshareg )  as abap.dec(23,2))
      else 
      cast( servicecostperunitg * (cast(case when _diralloc.uom <> chargeoutreckpi.uom then
                              unit_conversion( quantity => _diralloc.consumption,
                                             source_unit => _diralloc.uom,
                                             target_unit => chargeoutreckpi.uom,
                                             error_handling => 'SET_TO_NULL' ) 
                                  else
                                  _diralloc.consumption end as abap.dec(23,2))  ) as abap.dec(23,2))
      end                      as reccostshareG,
      
      case when chargeout = 'I' then
      cast( ( _chargeoutreckpisum.totalreckpishare  * valueaddsharel )  as abap.dec(23,2))
      else 
      cast( valueaddcostperunitl * (cast(case when _diralloc.uom <> chargeoutreckpi.uom then
                              unit_conversion( quantity => _diralloc.consumption,
                                             source_unit => _diralloc.uom,
                                             target_unit => chargeoutreckpi.uom,
                                             error_handling => 'SET_TO_NULL' ) 
                                  else
                                  _diralloc.consumption end as abap.dec(23,2))  ) as abap.dec(23,2))
      end                      as recvalueaddedL,

      case when chargeout = 'I' then
      cast( ( _chargeoutreckpisum.totalreckpishare  * valueaddshareg )  as abap.dec(23,2))
      else 
      cast( valueaddcostperunitg * (cast(case when _diralloc.uom <> chargeoutreckpi.uom then
                              unit_conversion( quantity => _diralloc.consumption,
                                             source_unit => _diralloc.uom,
                                             target_unit => chargeoutreckpi.uom,
                                             error_handling => 'SET_TO_NULL' ) 
                                  else
                                  _diralloc.consumption end as abap.dec(23,2))  ) as abap.dec(23,2))
      end                      as recvalueaddedG,
      
      case when chargeout = 'I' then
      cast( ( _chargeoutreckpisum.totalreckpishare  * passthroughsharel )  as abap.dec(23,2))
      else 
      cast( passthrucostperunitl * (cast(case when _diralloc.uom <> chargeoutreckpi.uom then
                              unit_conversion( quantity => _diralloc.consumption,
                                             source_unit => _diralloc.uom,
                                             target_unit => chargeoutreckpi.uom,
                                             error_handling => 'SET_TO_NULL' ) 
                                  else
                                  _diralloc.consumption end as abap.dec(23,2))  ) as abap.dec(23,2))
      end                      as recpassthroughL,

      case when chargeout = 'I' then
      cast( ( _chargeoutreckpisum.totalreckpishare  * passthroughshareg )  as abap.dec(23,2))
      else 
      cast( passthrucostperunitg * (cast(case when _diralloc.uom <> chargeoutreckpi.uom then
                              unit_conversion( quantity => _diralloc.consumption,
                                             source_unit => _diralloc.uom,
                                             target_unit => chargeoutreckpi.uom,
                                             error_handling => 'SET_TO_NULL' ) 
                                  else
                                  _diralloc.consumption end as abap.dec(23,2))  ) as abap.dec(23,2))
      end                      as recpassthroughG,
      
      case when chargeout = 'I' then
      cast( ( _chargeoutreckpisum.totalreckpishare  * ( costshare / 100 ) * remainingcostbase_l )  as abap.dec(23,2))
      else 
      case when srvcostsharel <> 0 then
      cast( ( ( servicecostperunitl * (cast(case when _diralloc.uom <> chargeoutreckpi.uom then
                              unit_conversion( quantity => _diralloc.consumption,
                                             source_unit => _diralloc.uom,
                                             target_unit => chargeoutreckpi.uom,
                                             error_handling => 'SET_TO_NULL' ) 
                                  else
                                  _diralloc.consumption end as abap.dec(23,2))  ) / srvcostsharel )  * ( costshare / 100 ) * remainingcostbase_l )  as abap.dec(23,2))
      else 0 end
      end                      as srvremainingcogsL,

      case when chargeout = 'I' then
      cast( ( _chargeoutreckpisum.totalreckpishare  * ( costshare / 100 ) * remainingcostbase_g )  as abap.dec(23,2))
      else 
      case when srvcostshareg <> 0 then
      cast( ( ( servicecostperunitg * (cast(case when _diralloc.uom <> chargeoutreckpi.uom then
                              unit_conversion( quantity => _diralloc.consumption,
                                             source_unit => _diralloc.uom,
                                             target_unit => chargeoutreckpi.uom,
                                             error_handling => 'SET_TO_NULL' ) 
                                  else
                                  _diralloc.consumption end as abap.dec(23,2))  ) / srvcostshareg )  * ( costshare / 100 ) * remainingcostbase_g )  as abap.dec(23,2))
      else 0 end
      end                      as srvremainingcogsG,
      
      case when chargeout = 'I' then
      cast( ( ( _chargeoutreckpisum.totalreckpishare  * ( costshare / 100 ) * remainingcostbase_l ) * 100 ) / ( 100 - stewardship ) as abap.dec(23,2) )
      else 
      case when srvcostsharel <> 0 then
      cast( ( ( ( servicecostperunitl * (cast(case when _diralloc.uom <> chargeoutreckpi.uom then
                              unit_conversion( quantity => _diralloc.consumption,
                                             source_unit => _diralloc.uom,
                                             target_unit => chargeoutreckpi.uom,
                                             error_handling => 'SET_TO_NULL' ) 
                                  else
                                  _diralloc.consumption end as abap.dec(23,2))  ) / srvcostsharel )  * ( costshare / 100 ) * remainingcostbase_l ) * 100 ) / ( 100 - stewardship ) as abap.dec(23,2) )
      else 0 end 
      end                      as recincludedcostL,

      case when chargeout = 'I' then
      cast( ( ( _chargeoutreckpisum.totalreckpishare  * ( costshare / 100 ) * remainingcostbase_g ) * 100 ) / ( 100 - stewardship ) as abap.dec(23,2) )
      else 
      case when srvcostshareg <> 0 then
      cast( ( ( ( servicecostperunitg * (cast(case when _diralloc.uom <> chargeoutreckpi.uom then
                              unit_conversion( quantity => _diralloc.consumption,
                                             source_unit => _diralloc.uom,
                                             target_unit => chargeoutreckpi.uom,
                                             error_handling => 'SET_TO_NULL' ) 
                                  else
                                  _diralloc.consumption end as abap.dec(23,2))  ) / srvcostshareg )  * ( costshare / 100 ) * remainingcostbase_g ) * 100 ) / ( 100 - stewardship ) as abap.dec(23,2) ) 
      else 0 end
      end                      as recincludedcostG,
      
      case when includetotalcost_l <> 0 and chargeout = 'I' then
      cast( ( ( ( ( _chargeoutreckpisum.totalreckpishare  * ( costshare / 100 ) * remainingcostbase_l ) * 100 ) / ( 100 - stewardship ) ) * ( origtotalcost_l / includetotalcost_l ) ) as abap.dec(23,2))
      else 
      case when srvcostsharel <> 0 then
      cast( ( ( ( ( ( servicecostperunitl * (cast(case when _diralloc.uom <> chargeoutreckpi.uom then
                              unit_conversion( quantity => _diralloc.consumption,
                                             source_unit => _diralloc.uom,
                                             target_unit => chargeoutreckpi.uom,
                                             error_handling => 'SET_TO_NULL' ) 
                                  else
                                  _diralloc.consumption end as abap.dec(23,2))  ) / srvcostsharel )  * ( costshare / 100 ) * remainingcostbase_l ) * 100 ) / ( 100 - stewardship ) ) * ( origtotalcost_l / includetotalcost_l ) ) as abap.dec(23,2))
      else 0 end
      end                      as recorigtotalcostL,
      
      case when includetotalcost_g <> 0 and chargeout = 'I' then
      cast( ( ( ( ( _chargeoutreckpisum.totalreckpishare  * ( costshare / 100 ) * remainingcostbase_g ) * 100 ) / ( 100 - stewardship ) ) * ( origtotalcost_g / includetotalcost_g ) ) as abap.dec(23,2))
      else 
      case when srvcostshareg <> 0 then
      cast( ( ( ( ( ( servicecostperunitg * (cast(case when _diralloc.uom <> chargeoutreckpi.uom then
                              unit_conversion( quantity => _diralloc.consumption,
                                             source_unit => _diralloc.uom,
                                             target_unit => chargeoutreckpi.uom,
                                             error_handling => 'SET_TO_NULL' ) 
                                  else
                                  _diralloc.consumption end as abap.dec(23,2))  ) / srvcostshareg )  * ( costshare / 100 ) * remainingcostbase_g ) * 100 ) / ( 100 - stewardship ) ) * ( origtotalcost_g / includetotalcost_g ) ) as abap.dec(23,2))
      else 0 end
      end                      as recorigtotalcostG,
      
      case when includetotalcost_l <> 0 and chargeout = 'I' then
      cast( ( ( ( ( _chargeoutreckpisum.totalreckpishare  * ( costshare / 100 ) * remainingcostbase_l ) * 100 ) / ( 100 - stewardship ) ) * ( passtotalcost_l / includetotalcost_l ) ) as abap.dec(23,2))
      else 
      case when srvcostsharel <> 0 then
      cast( ( ( ( ( ( servicecostperunitl * (cast(case when _diralloc.uom <> chargeoutreckpi.uom then
                              unit_conversion( quantity => _diralloc.consumption,
                                             source_unit => _diralloc.uom,
                                             target_unit => chargeoutreckpi.uom,
                                             error_handling => 'SET_TO_NULL' ) 
                                  else
                                  _diralloc.consumption end as abap.dec(23,2))  ) / srvcostsharel )  * ( costshare / 100 ) * remainingcostbase_l ) * 100 ) / ( 100 - stewardship ) ) * ( passtotalcost_l / includetotalcost_l ) ) as abap.dec(23,2))
      else 0 end
      end                      as recpasstotalcostL,
      
      case when includetotalcost_g <> 0 and chargeout = 'I' then
      cast( ( ( ( ( _chargeoutreckpisum.totalreckpishare  * ( costshare / 100 ) * remainingcostbase_g ) * 100 ) / ( 100 - stewardship ) ) * ( passtotalcost_g / includetotalcost_g ) ) as abap.dec(23,2))
      else 
      case when srvcostshareg <> 0 then
      cast( ( ( ( ( ( servicecostperunitg * (cast(case when _diralloc.uom <> chargeoutreckpi.uom then
                              unit_conversion( quantity => _diralloc.consumption,
                                             source_unit => _diralloc.uom,
                                             target_unit => chargeoutreckpi.uom,
                                             error_handling => 'SET_TO_NULL' ) 
                                  else
                                  _diralloc.consumption end as abap.dec(23,2))  ) / srvcostshareg )  * ( costshare / 100 ) * remainingcostbase_g ) * 100 ) / ( 100 - stewardship ) ) * ( passtotalcost_g / includetotalcost_g ) ) as abap.dec(23,2))
      else 0 end
      end                      as recpasstotalcostG,
      
      case when chargeout = 'I' then
      cast( ( _chargeoutreckpisum.totalreckpishare  * ( costshare / 100 ) * excludedtotalcost_l )  as abap.dec(23,2))
      else 
      case when srvcostsharel <> 0 then
      cast( ( ( servicecostperunitl * (cast(case when _diralloc.uom <> chargeoutreckpi.uom then
                              unit_conversion( quantity => _diralloc.consumption,
                                             source_unit => _diralloc.uom,
                                             target_unit => chargeoutreckpi.uom,
                                             error_handling => 'SET_TO_NULL' ) 
                                  else
                                  _diralloc.consumption end as abap.dec(23,2))  ) / srvcostsharel )  * ( costshare / 100 ) * excludedtotalcost_l )  as abap.dec(23,2))
      else 0 end
      end                      as recexcludedcostL,

      case when chargeout = 'I' then
      cast( ( _chargeoutreckpisum.totalreckpishare  * ( costshare / 100 ) * excludedtotalcost_g )  as abap.dec(23,2))
      else 
      case when srvcostshareg <> 0 then
      cast( ( ( servicecostperunitg * (cast(case when _diralloc.uom <> chargeoutreckpi.uom then
                              unit_conversion( quantity => _diralloc.consumption,
                                             source_unit => _diralloc.uom,
                                             target_unit => chargeoutreckpi.uom,
                                             error_handling => 'SET_TO_NULL' ) 
                                  else
                                  _diralloc.consumption end as abap.dec(23,2))  ) / srvcostshareg )  * ( costshare / 100 ) * excludedtotalcost_g )  as abap.dec(23,2))
      else 0 end
      end                      as recexcludedcostG,
      
      case when chargeout = 'I' then
      cast( ( _chargeoutreckpisum.totalreckpishare  * ( costshare / 100 ) * totalcost_l )  as abap.dec(23,2))
      else 
      case when srvcostsharel <> 0 then
      cast( ( ( servicecostperunitl * (cast(case when _diralloc.uom <> chargeoutreckpi.uom then
                              unit_conversion( quantity => _diralloc.consumption,
                                             source_unit => _diralloc.uom,
                                             target_unit => chargeoutreckpi.uom,
                                             error_handling => 'SET_TO_NULL' ) 
                                  else
                                  _diralloc.consumption end as abap.dec(23,2))  ) / srvcostsharel )  * ( costshare / 100 ) * totalcost_l )  as abap.dec(23,2))
      else 0 end
      end                      as rectotalcostL,

      case when chargeout = 'I' then
      cast( ( _chargeoutreckpisum.totalreckpishare  * ( costshare / 100 ) * totalcost_g )  as abap.dec(23,2))
      else 
      case when srvcostshareg <> 0 then
      cast( ( ( servicecostperunitg * (cast(case when _diralloc.uom <> chargeoutreckpi.uom then
                              unit_conversion( quantity => _diralloc.consumption,
                                             source_unit => _diralloc.uom,
                                             target_unit => chargeoutreckpi.uom,
                                             error_handling => 'SET_TO_NULL' ) 
                                  else
                                  _diralloc.consumption end as abap.dec(23,2))  ) / srvcostshareg )  * ( costshare / 100 ) * totalcost_g )  as abap.dec(23,2))
      else 0 end
      end                      as rectotalcostG,
      
      //   Descriptions, Country & regions
      @Semantics.text: true
      _legalentity.Description      as legalentitydescription,
      @Semantics.text: true
      _ccode.ccodedescription,
      @Semantics.text: true       
      _costobject.text              as costobjectdescription,
      @Semantics.text: true
      _costcenter.Description       as costcenterdescription,
      @Semantics.text: true
      _receivingentity.Description  as receivingentitydescription,
      @Semantics.text: true
      _serviceproduct.Description   as serviceproductdescription,
      
      _legalentity.Country          as legalentitycountry,
     
      _receivingentity.Country      as receivingentitycountry,
      
      _legalentity.LocalCurr        as legalentitycurrecy,
      _receivingentity.LocalCurr    as receivingentitycurrency,
      _legalentity.Region           as legalentityregion,
      _receivingentity.Region       as receivingentityregion,
      @Semantics.text: true
      _transactiongroup.Description as transactiongroupdescription,
      @Semantics.text: true
      _servicetype.Description      as servicetypedescription,
      
      //Associations//
      _costcenter,
      _ccode,
      _chargeoutreckpisum,
      _costobject,
      _diralloc,
      _legalentity,
      _receivingentity,
      _serviceproduct,
      _servicetype,
      _transactiongroup


}
