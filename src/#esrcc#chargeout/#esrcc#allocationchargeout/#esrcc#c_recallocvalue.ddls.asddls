@EndUserText.label: 'Allocation Values'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity /ESRCC/C_RECALLOCVALUE
  as projection on /ESRCC/I_RECALLOCVALUE
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
      @ObjectModel.text.element: [ 'AllocationKeyDescription' ]
  key allockey,
      //    key alloctype,
  key allocationperiod,
  key refperiod,
  key refpoper,
      @DefaultAggregation: #SUM
      reckpivalue,

      @Semantics.text: true
      _AllocationKeyText.AllocationKeyDescription,
      /* Associations */
      _indkpishare : redirected to parent /ESRCC/C_REC_INDKPISHARE
}
