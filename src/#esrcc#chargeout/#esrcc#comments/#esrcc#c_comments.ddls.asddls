@EndUserText.label: 'Workflow Comments'
@ObjectModel.query.implementedBy : 'ABAP:/ESRCC/CL_C_COMMENTS'
@Metadata.allowExtensions: true
define custom entity /ESRCC/C_COMMENTS
{
  @UI.selectionField: [{ position: 10 }]
  key workflow_id   : /esrcc/workflowid;
  key approverlevel : /esrcc/approvallevel;
  status            : /esrcc/status_de;
  wfcomment         : abap.rawstring(0);
  wfcommenttext     : abap.string;
  created_by        : abp_creation_user;
  created_at        : abp_creation_tstmpl;
  last_changed_by   : abp_lastchange_user;
  last_changed_at   : abp_lastchange_tstmpl;
}
