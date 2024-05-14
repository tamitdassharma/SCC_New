@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Service Parameter'
@Metadata.allowExtensions: true

define view entity /ESRCC/C_ServiceParameter
  as projection on /ESRCC/I_ServiceParameter
{

      @ObjectModel.text.element: ['LegalentityDesc']
  key Legalentity,
      @ObjectModel.text.element: ['SysidDescription']
  key Sysid,
      @ObjectModel.text.element: ['CcodeDesc']
  key Ccode,
      @ObjectModel.text.element: ['CostobjectDesc']
  key Costobject,
      @ObjectModel.text.element: ['CostcenterDesc']
  key Costcenter,
      @ObjectModel.text.element: ['ServiceproductDesc']
  key Serviceproduct,
  key CostcenterVf,
  key Validfrom,
      Validto,
      Costshare,
      Erpsalesorder,
      Contractid,
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
      _LeText.Description         as LegalentityDesc,
      @Semantics.text: true
      _CcodeText.ccodedescription as CcodeDesc,
      @Semantics.text: true
      _CostObjText.text           as CostobjectDesc,
      @Semantics.text: true
      _CostCenterText.Description as CostcenterDesc,
      @Semantics.text: true
      _ServProdText.Description   as ServiceproductDesc,

      _LeToCostcenter    : redirected to parent /ESRCC/C_LeCctr,
      _LeToCostcenterAll : redirected to /ESRCC/C_LeCctr_S
}
