@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Company Code (Provider)'
@Search.searchable: true

define view entity /ESRCC/I_COMPANYCODES_PR_F4
  as select from /ESRCC/I_COMPANYCODES_F4
  association [0..1] to /ESRCC/I_LEGALENTITY_F4 as _LegalEntity on _LegalEntity.Legalentity = $projection.Legalentity
{
  key Sysid,
  key Ccode,
      Legalentity,
      Controllingarea,
      ccodedescription,
      LegalentityDescription,
      /* Associations */
      _SystemText,
      _Text
}
where
  _LegalEntity.Legalentity is not null
