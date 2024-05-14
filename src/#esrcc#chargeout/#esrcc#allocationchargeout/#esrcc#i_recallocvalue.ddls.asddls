@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Indirect Allocation'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity /ESRCC/I_RECALLOCVALUE
as select from /esrcc/srvvalues as srvallocvalues

  association to parent /ESRCC/I_REC_INDKPISHARE as _indkpishare on _indkpishare.fplv = $projection.fplv
                                                                and _indkpishare.ryear = $projection.ryear 
                                                                and _indkpishare.poper = $projection.poper
                                                                and _indkpishare.sysid = $projection.sysid
                                                                and _indkpishare.ccode = $projection.ccode
                                                                and _indkpishare.legalentity = $projection.legalentity
                                                                and _indkpishare.costobject = $projection.costobject
                                                                and _indkpishare.costcenter = $projection.costcenter
                                                                and _indkpishare.serviceproduct = $projection.serviceproduct
                                                                and _indkpishare.receivingentity = $projection.receivingentity
                                                                and _indkpishare.keyversion = $projection.keyversion                             
                                                                and _indkpishare.allockey = $projection.allockey
                                                                and _indkpishare.alloctype = $projection.alloctype
                                                                and _indkpishare.allocationperiod = $projection.allocationperiod
                                                                and _indkpishare.refperiod = $projection.refperiod                                                                                        

{
  key srvallocvalues.fplv,
  key srvallocvalues.ryear,
  key srvallocvalues.poper,
  key srvallocvalues.sysid,
  key srvallocvalues.ccode,
  key srvallocvalues.legalentity,
  key srvallocvalues.costobject,
  key srvallocvalues.costcenter,
  key srvallocvalues.serviceproduct,
  key srvallocvalues.receivingentity,
  key srvallocvalues.keyversion,
  key srvallocvalues.allockey,
  key srvallocvalues.alloctype,
  key srvallocvalues.allocationperiod,
  key srvallocvalues.refperiod,
  key srvallocvalues.refpoper,
  srvallocvalues.reckpivalue as cumvalue,
  
  /*Association*/
  _indkpishare
}where alloctype = 'C'

