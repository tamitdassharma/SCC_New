@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED Indirect Allocation'
define root view entity /ESRCC/I_INDIRECTALLOCATION
  as select from /esrcc/indalloc as IndirectAllocation

  association [0..1] to /ESRCC/I_LegalEntityAll_F4 as _ReceiverText   on $projection.Receivingentity = _ReceiverText.Legalentity
  association [0..1] to /ESRCC/I_KEY_VERSION       as _KeyVersionText on $projection.Fplv = _KeyVersionText.KeyVersion
  association [0..1] to /ESRCC/I_ALLOCATION_KEY_F4 as _AllockeyText   on $projection.Allocationkey = _AllockeyText.Allocationkey
  association        to /ESRCC/I_POPER             as _PoperText      on _PoperText.Poper = $projection.Poper

{
  key receivingentity       as Receivingentity,
  key ryear                 as Ryear,
  key poper                 as Poper,
  key allocationkey         as Allocationkey,
  key fplv                  as Fplv,
      value                 as Value,
      currency              as Currency,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _ReceiverText,
      _KeyVersionText,
      _AllockeyText,
      _PoperText
}
