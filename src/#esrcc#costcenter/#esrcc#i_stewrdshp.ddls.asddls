@EndUserText.label: 'Stewardship'
@AccessControl.authorizationCheck: #CHECK
define view entity /ESRCC/I_Stewrdshp
  as select from /esrcc/stewrdshp
  association        to parent /ESRCC/I_Stewrdshp_S as _StewardshipAll     on  $projection.SingletonID = _StewardshipAll.SingletonID
  association [1..1] to /ESRCC/I_CstObjct           as _CostObject         on  _CostObject.CostObjectUuid = $projection.CostObjectUuid
  association [1..1] to /ESRCC/I_CstObjctText       as _CostObjectText     on  _CostObjectText.CostObjectUuid = $projection.CostObjectUuid
                                                                           and _CostObjectText.Spras          = $session.system_language
  association [1..1] to /ESRCC/I_STATUS             as _WorkflowStatusText on  _WorkflowStatusText.Status = $projection.WorkflowStatus

  composition [0..*] of /ESRCC/I_StwdSp             as _ServiceProduct
  composition [0..*] of /ESRCC/I_StwdSpRec          as _ServiceReceiver
{
  key stewardship_uuid         as StewardshipUuid,
      valid_from               as ValidFrom,
      valid_to                 as Validto,
      stewardship              as Stewardship,
      cost_object_uuid         as CostObjectUuid,
      chain_id                 as ChainId,
      chain_sequence           as ChainSequence,
      workflow_id              as WorkflowId,
      workflow_status          as WorkflowStatus,
      comments                 as Comments,
      _CostObject.Sysid,
      _CostObject.LegalEntity,
      _CostObject.CompanyCode,
      _CostObject.CostObject,
      _CostObject.CostCenter,
      @Semantics.user.createdBy: true
      created_by               as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at               as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by          as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at          as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at    as LocalLastChangedAt,
      1                        as SingletonID,

      case workflow_status
        when 'D' then 2
        when 'P' then 2
        when 'W' then 2
        when 'U' then 3
        when 'E' then 3
        when 'A' then 3
        when 'F' then 3
        when 'R' then 1
        when 'C' then 1
        else 0
      end                      as WorkflowStatusCriticality,
      cast('' as abap_boolean) as TriggerWorkflow,

      _StewardshipAll,
      _ServiceProduct,
      _ServiceReceiver,
      _CostObject,
      _CostObjectText,
      _WorkflowStatusText

}
