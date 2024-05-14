@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Indirect Allocation KPI Share'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define root view entity /ESRCC/I_REC_INDKPISHARE
  as select from /esrcc/recshare as weightage

  composition [0..*] of /ESRCC/I_RECALLOCVALUE      as _ReceiverAllocation
  composition [0..*] of /ESRCC/I_AVGRECALLOCVALUE   as _AverageReceiverAllocation

  association [0..1] to /ESRCC/I_LEGALENTITY_F4     as _legalentity     on  _legalentity.Legalentity = weightage.legalentity

  association [0..1] to /ESRCC/I_RECEIVINGENTITY_F4 as _receivingentity on  _receivingentity.Receivingentity = weightage.receivingentity

  association [0..1] to /ESRCC/I_COMPANYCODES_F4    as _ccode           on  _ccode.Sysid = weightage.sysid
                                                                        and _ccode.Ccode = weightage.ccode

  association [0..1] to /ESRCC/I_COSTOBJECTS        as _costobject      on  _costobject.Costobject = weightage.costobject

  association [0..1] to /ESRCC/I_COSCEN_F4          as _costcenter      on  _costcenter.Costcenter = weightage.costcenter
                                                                        and _costcenter.Costobject = weightage.costobject
                                                                        and _costcenter.Sysid      = weightage.sysid

  association [0..1] to /ESRCC/I_SERVICEPRODUCT_F4  as _serviceproduct  on  _serviceproduct.ServiceProduct = weightage.serviceproduct

  association [0..1] to /ESRCC/I_COST_VERSION       as _CostVersionText on  _CostVersionText.CostVersion = $projection.fplv
  association [0..1] to /ESRCC/I_KEY_VERSION        as _KeyVersionText  on  _KeyVersionText.KeyVersion = $projection.keyversion
  association [0..1] to /ESRCC/I_ALLOCATION_KEY_F4  as _AllocKeyText    on  _AllocKeyText.Allocationkey = $projection.allockey

  association [0..1] to /ESRCC/I_ALLOCATIONTYPE     as _AllocTypeText   on  _AllocTypeText.AllocType = $projection.alloctype
  association [0..1] to /ESRCC/I_ALLOCATIONPERIOD   as _AllocPeriodText on  _AllocPeriodText.AllocationPeriod = $projection.allocationperiod

  association [0..1] to I_CountryText as _legalCountryText
  on _legalCountryText.Country = $projection.legalentitycountry
  and _legalCountryText.Language = $session.system_language  
  
  association [0..1] to I_CountryText as _RecCountryText
  on _RecCountryText.Country = $projection.receivingcountry
  and _RecCountryText.Language = $session.system_language 
  
{
  key fplv,
  key ryear,
  key poper,
  key sysid,
  key ccode,
  key legalentity,
  key costobject,
  key costcenter,
  key serviceproduct,
  key receivingentity,
  key keyversion,
  key allockey,
  key alloctype,
  key allocationperiod,
  key refperiod,
      weightage,
      weightage.reckpivalue,
      cast(initialreckpishare * 100 as abap.dec(15,2)) as totalreckpishare,
      cast(reckpishare * 100 as abap.dec(15,2)) as reckpishare,
      _legalentity.Country as legalentitycountry,
      _receivingentity.Country as receivingcountry,
      cast(case alloctype
      when 'A' then /*avergae*/
      'X'
      else '' end as abap_boolean preserving type ) as hidecumulative,

      cast(case alloctype
      when 'C' then /*cumulated*/
      'X'
      else '' end as abap_boolean preserving type ) as hideaverage,
      
      
      /* Associations */
      _ReceiverAllocation,
      _AverageReceiverAllocation,
      //Associations//
      _costcenter,
      _ccode,
      _costobject,
      _legalentity,
      _receivingentity,
      _serviceproduct,
      _CostVersionText,
      _KeyVersionText,
      _AllocKeyText,
      _AllocTypeText,
      _AllocPeriodText,
      _legalCountryText,
      _RecCountryText
}
