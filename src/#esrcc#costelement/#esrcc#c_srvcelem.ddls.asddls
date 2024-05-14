@EndUserText.label: 'Mapping Cost Element - Maintain'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_SrvCeleM
  as projection on /ESRCC/I_SrvCeleM
{
      @ObjectModel.text.element: ['LegalEntityDesc']
  key Legalentity,
      @ObjectModel.text.element: ['SysidDescription']
  key Sysid,
      @ObjectModel.text.element: ['CcodeDesc']
  key Ccode,
      @ObjectModel.text.element: ['CostElementDesc']
  key Costelement,
  key ValidFrom,
      @ObjectModel.text.element: ['CostTypeDesc']
      Costtype,
      @ObjectModel.text.element: ['PostingTypeDesc']
      Postingtype,
      @ObjectModel.text.element: ['CostIndDesc']
      Costind,
      @ObjectModel.text.element: ['UsageTypeDesc']
      Usagetype,

      ValidTo,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,

      @Semantics.text: true
      _SystemInfoText.Description             as SysidDescription,
      @Semantics.text: true
      _LeText.Description                     as LegalEntityDesc,
      @Semantics.text: true
      _CcodeText.ccodedescription             as CcodeDesc,
      @Semantics.text: true
      _CostElementText.costelementdescription as CostElementDesc,
      @Semantics.text: true
      _CostTypeText.text                      as CostTypeDesc,
      @Semantics.text: true
      _PostingTypeText.text                   as PostingTypeDesc,
      @Semantics.text: true
      _CostIndText.text                       as CostIndDesc,
      @Semantics.text: true
      _UsageTypeText.text                     as UsageTypeDesc,
      @Consumption.hidden: true
      SingletonID,
      _CostElementToLeAll : redirected to parent /ESRCC/C_SrvCeleM_S

}
