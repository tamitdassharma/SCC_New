@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for /ESRCC/I_INDIRECTALLOCATION'
//@ObjectModel.semanticKey: [ 'Receivingentity', 'Ryear', 'Poper', 'Allocationkey', 'Fplv' ]
define root view entity /ESRCC/C_INIRECTALLOCATION
  provider contract transactional_query
  as projection on /ESRCC/I_INDIRECTALLOCATION
{
      @ObjectModel.text.element: ['ReceivingentityDescription']
  key Receivingentity,
  key Ryear,
      @ObjectModel.text.element: [ 'PoperDescription' ]
  key Poper,
      @ObjectModel.text.element: ['AllocationKeyDescription']
  key Allocationkey,
      @ObjectModel.text.element: ['FplvDescription']
  key Fplv,
      Value,
      Currency,
      CreatedAt,
      CreatedBy,
      LastChangedAt,
      LastChangedBy,
      LocalLastChangedAt,
      @Semantics.text: true
      _ReceiverText.Description as ReceivingentityDescription,

      @Semantics.text: true
      _KeyVersionText.text      as FplvDescription,
      @Semantics.text: true
      _AllockeyText.AllocationKeyDescription,
      @Semantics.text: true
      _PoperText.text           as PoperDescription

}
