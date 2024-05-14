@EndUserText.label: 'Allocation Values'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity /ESRCC/C_AVERAGERECALLOCVALUE 
as projection on /ESRCC/I_AVGRECALLOCVALUE
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
    key refpoper,
    @DefaultAggregation: #AVG
    avgvalue,   
    /* Associations */
    _indkpishare : redirected to parent /ESRCC/C_REC_INDKPISHARE
}
