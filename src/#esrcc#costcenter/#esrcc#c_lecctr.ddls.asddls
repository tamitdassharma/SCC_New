@EndUserText.label: 'Cost Center to LE Mapping - Maintain'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_LeCctr
  as projection on /ESRCC/I_LeCctr
{
      @ObjectModel.text.element: ['LegalEntityDesc']
  key Legalentity,
      @ObjectModel.text.element: ['SysidDesc']
  key Sysid,
      @ObjectModel.text.element: ['CcodeDesc']
  key Ccode,
      @ObjectModel.text.element: ['CostobjectDesc']
  key Costobject,
      @ObjectModel.text.element: ['CostcenterDesc']
  key Costcenter,
  key Validfrom,
      Validto,
      @ObjectModel.text.element: ['ProfitcenterDesc']
      Profitcenter,
      @ObjectModel.text.element: ['BusinessdivisionDesc']
      Businessdivision,
      Stewardship,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Semantics.text: true
      _SysInfoText.Description                  as SysidDesc,
      @Semantics.text: true
      _LeText.Description                       as LegalEntityDesc,
      @Semantics.text: true
      _CcodeText.ccodedescription               as CcodeDesc,
      @Semantics.text: true
      _CostObjText.text                         as CostobjectDesc,
      @Semantics.text: true
      _CosCenText.Description                   as CostcenterDesc,
      @Semantics.text: true
      _ProfitCenterText.profitcenterdescription as ProfitcenterDesc,
      @Semantics.text: true
      _BusinessDivisionText.Description         as BusinessdivisionDesc,
      @Consumption.hidden: true
      SingletonID,
      _LeToCostCenterAll : redirected to parent /ESRCC/C_LeCctr_S,
      _ServiceParameter  : redirected to composition child /ESRCC/C_ServiceParameter,
      _ServiceReceiver   : redirected to composition child /ESRCC/C_ServiceAllocReceiver
}
