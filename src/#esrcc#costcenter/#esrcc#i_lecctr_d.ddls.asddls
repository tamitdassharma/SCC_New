@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Draft Query View'

define view entity /ESRCC/I_LeCctr_D
  as select from /esrcc/d_le_cctr
{
  key legalentity                   as Legalentity,
  key sysid                         as Sysid,
  key ccode                         as Ccode,
  key costobject                    as Costobject,
  key costcenter                    as Costcenter,
  key validfrom                     as Validfrom,
      validto                       as Validto,
      profitcenter                  as Profitcenter,
      businessdivision              as Businessdivision,
      stewardship                   as Stewardship,
      createdby                     as Createdby,
      createdat                     as Createdat,
      lastchangedby                 as Lastchangedby,
      lastchangedat                 as Lastchangedat,
      locallastchangedat            as Locallastchangedat,
      singletonid                   as Singletonid,
      draftentitycreationdatetime   as Draftentitycreationdatetime,
      draftentitylastchangedatetime as Draftentitylastchangedatetime,
      draftadministrativedatauuid   as Draftadministrativedatauuid,
      draftentityoperationcode      as Draftentityoperationcode,
      hasactiveentity               as Hasactiveentity,
      draftfieldchanges             as Draftfieldchanges
}
