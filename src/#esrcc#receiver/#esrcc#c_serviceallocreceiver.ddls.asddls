@EndUserText.label: 'Service Allocation Receivers'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true

define view entity /ESRCC/C_ServiceAllocReceiver
  as projection on /ESRCC/I_ServiceAllocReceiver
{
      @ObjectModel.text.element: ['SysidDescription']
  key Sysid,
  key Ccode,
      @ObjectModel.text.element: ['LegalentityDescription']
  key Legalentity,
  key Costobject,
  key Costcenter,
      @ObjectModel.text.element: ['ServiceProductDescription']
  key Serviceproduct,
  key CcValidfrom,
      @ObjectModel.text.element: ['ReceiverDescription']
  key Receivingentity,

      Active,
      @Consumption.hidden: true
      CcValidto,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,
      @Semantics.text: true
      _SystemInfoText.Description as SysidDescription,
      @Semantics.text: true
      _ProductText.Description    as ServiceProductDescription,
      @Semantics.text: true
      _LeText.Description         as LegalentityDescription,
      @Semantics.text: true
      _ReceiverText.Description   as ReceiverDescription,

      /* Associations */
      _LeToCostCenter    : redirected to parent /ESRCC/C_LeCctr,
      _LeToCostCenterAll : redirected to /ESRCC/C_LeCctr_S
}
