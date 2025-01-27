@EndUserText.label: 'Charge-out - Maintain'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity /ESRCC/C_ChargeoutBc
  as projection on /ESRCC/I_ChargeoutBc
{
  key Uuid,
      @ObjectModel.text.element: ['ServiceProductDescription']
      Serviceproduct,
      Validfrom,
      Validto,
      @ObjectModel.text.element: ['ChargeoutRuleDescription']
      ChargeoutRuleId,
      @ObjectModel.text.element: ['ChargeoutMethodDescription']
      _Rule.ChargeoutMethod,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      @Consumption.hidden: true
      LocalLastChangedAt,
      @Consumption.hidden: true
      SingletonID,

      @Semantics.text: true
      _ProductText.Description as ServiceProductDescription,
      @Semantics.text: true
      _Rule.RuleDescription    as ChargeoutRuleDescription,
      @Semantics.text: true
      _Rule.ChargeoutMethodDescription,

      _ChargeoutAll : redirected to parent /ESRCC/C_ChargeoutBc_S

}
