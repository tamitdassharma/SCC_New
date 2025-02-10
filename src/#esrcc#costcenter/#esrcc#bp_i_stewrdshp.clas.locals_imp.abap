CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_stewardship      TYPE STRUCTURE FOR READ RESULT /esrcc/i_stewrdshp_s\\stewardship,
      ts_service_product  TYPE STRUCTURE FOR READ RESULT /esrcc/i_stewrdshp_s\\serviceproduct,
      ts_service_receiver TYPE STRUCTURE FOR READ RESULT /esrcc/i_stewrdshp_s\\servicereceiver,
      tt_sharecost        TYPE STANDARD TABLE OF /esrcc/stwd_sp WITH EMPTY KEY,
      tt_stewardship      TYPE TABLE FOR READ RESULT /esrcc/i_stewrdshp_s\\stewardship,

      BEGIN OF ts_control_stewardship,
        chainid       TYPE if_abap_behv=>t_xflag,
        chainsequence TYPE if_abap_behv=>t_xflag,
        validfrom     TYPE if_abap_behv=>t_xflag,
        validto       TYPE if_abap_behv=>t_xflag,
        stewardship   TYPE if_abap_behv=>t_xflag,
      END OF ts_control_stewardship,
      BEGIN OF ts_control_service_product,
        validfrom   TYPE if_abap_behv=>t_xflag,
        validto     TYPE if_abap_behv=>t_xflag,
        shareofcost TYPE if_abap_behv=>t_xflag,
      END OF ts_control_service_product,
      BEGIN OF ts_control_service_receiver,
        invoicecurrency TYPE if_abap_behv=>t_xflag,
      END OF ts_control_service_receiver.

    METHODS:
      constructor
        IMPORTING
          config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_stewardship
        IMPORTING
          entity  TYPE ts_stewardship
          control TYPE ts_control_stewardship,
      validate_service_product
        IMPORTING
          entity  TYPE ts_service_product
          control TYPE ts_control_service_product,
      validate_service_receiver
        IMPORTING
          entity  TYPE ts_service_receiver
          control TYPE ts_control_service_receiver,
      calculate_costshare_sum
        IMPORTING
          sharecost     TYPE tt_sharecost
        EXPORTING
          sharecost_sum TYPE tt_sharecost.

  PRIVATE SECTION.
    DATA:
      config_util_ref TYPE REF TO /esrcc/cl_config_util.
ENDCLASS.

CLASS lcl_custom_validation IMPLEMENTATION.
  METHOD constructor.
    me->config_util_ref = config_util_ref.
  ENDMETHOD.

  METHOD validate_stewardship.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-chainid       = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'CHAINID' ) TO fields. ENDIF.
    IF control-chainsequence = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'CHAINSEQUENCE' ) TO fields. ENDIF.
    IF control-validfrom     = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALIDFROM' ) TO fields. ENDIF.
    IF control-validto       = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALIDTO' ) TO fields. ENDIF.

    config_util_ref->validate_initial(
      fields = fields
      entity = entity
    ).

    IF control-stewardship = if_abap_behv=>mk-on.
      config_util_ref->validate_percentage(
        fields = VALUE #( ( fieldname = 'STEWARDSHIP' ) )
        entity = entity
      ).
    ENDIF.

    IF control-validfrom = if_abap_behv=>mk-on OR control-validto = if_abap_behv=>mk-on.
      config_util_ref->validate_validity(
        from   = entity-validfrom
        to     = entity-validto
        entity = entity
      ).

      DATA(lv_validfrom) = entity-validfrom.
      DATA(lv_validto) = entity-validto.

      config_util_ref->validate_start_end_of_month(
        EXPORTING
          entity     = entity
        CHANGING
          start_date = lv_validfrom
          end_date   = lv_validto
      ).
    ENDIF.
  ENDMETHOD.

  METHOD validate_service_product.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-shareofcost = if_abap_behv=>mk-on.
      config_util_ref->validate_percentage(
        fields = VALUE #( ( fieldname = 'SHAREOFCOST' ) )
        entity = entity
      ).
    ENDIF.

    IF control-validfrom = if_abap_behv=>mk-on OR control-validto = if_abap_behv=>mk-on.
      config_util_ref->validate_validity(
        from   = entity-validfrom
        to     = entity-validto
        entity = entity
      ).

      DATA(lv_validfrom) = entity-validfrom.
      DATA(lv_validto) = entity-validto.
      config_util_ref->validate_start_end_of_month(
        EXPORTING
          entity     = entity
        CHANGING
          start_date = lv_validfrom
          end_date   = lv_validto
      ).

      IF control-validto = if_abap_behv=>mk-on.
        config_util_ref->validate_initial(
          fields = VALUE #( ( fieldname = 'VALIDTO' ) )
          entity = entity
        ).
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD validate_service_receiver.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-invoicecurrency = if_abap_behv=>mk-on. fields = VALUE #( ( fieldname = 'INVOICECURRENCY' ) ). ENDIF.

    config_util_ref->validate_initial(
      fields     = fields
      entity     = entity
    ).
  ENDMETHOD.

  METHOD calculate_costshare_sum.
    SELECT stewardship_uuid, valid_from AS date
      FROM @sharecost AS share
      WHERE share~valid_to <> '00000000'
      INTO TABLE @DATA(dates).

    SELECT stewardship_uuid,
           CASE WHEN share~valid_to <> '99991231' THEN dats_add_days( share~valid_to , 1 ) ELSE share~valid_to END AS date
      FROM @sharecost AS share
      WHERE share~valid_to <> '00000000'
      APPENDING TABLE @dates.

    SORT dates BY stewardship_uuid date.
    DELETE ADJACENT DUPLICATES FROM dates COMPARING stewardship_uuid date.
    DATA(count) = lines( dates ).

    DATA curr LIKE LINE OF dates.
    LOOP AT dates INTO DATA(date).
      IF curr-stewardship_uuid <> date-stewardship_uuid.
        curr = CORRESPONDING #( date ).
        APPEND CORRESPONDING #( date MAPPING valid_from = date ) TO sharecost_sum ASSIGNING FIELD-SYMBOL(<sum>).
      ELSE.
        <sum>-valid_to = COND #( WHEN date-date <> '99991231' THEN date-date - 1 ELSE date-date ).
        LOOP AT sharecost INTO DATA(share) WHERE stewardship_uuid = date-stewardship_uuid.
          IF <sum>-valid_from BETWEEN share-valid_from AND share-valid_to OR
             <sum>-valid_to BETWEEN share-valid_from AND share-valid_to.
            <sum>-share_of_cost = <sum>-share_of_cost + share-share_of_cost.
          ENDIF.
        ENDLOOP.
        IF count <> sy-tabix.
          APPEND CORRESPONDING #( date MAPPING valid_from = date ) TO sharecost_sum ASSIGNING <sum>.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.


CLASS lhc_rap_tdat_cts DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      get
        RETURNING
          VALUE(result) TYPE REF TO if_mbc_cp_rap_table_cts.

ENDCLASS.

CLASS lhc_rap_tdat_cts IMPLEMENTATION.
  METHOD get.
    result = mbc_cp_api=>rap_table_cts( table_entity_relations = VALUE #(
                                         ( entity = 'Stewardship' table = '/ESRCC/STEWRDSHP' )
                                       ) ).
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_stewrdshp_s DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR stewardshipall
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR stewardshipall
        RESULT result,
      precheck_cba_stewardship FOR PRECHECK
        IMPORTING entities FOR CREATE stewardshipall\_stewardship,
      edit FOR MODIFY
        IMPORTING keys FOR ACTION stewardshipall~edit.
ENDCLASS.

CLASS lhc_/esrcc/i_stewrdshp_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA: selecttransport_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled,
          edit_flag            TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.

    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
        iv_objectname = '/ESRCC/STEWRDSHP'
        iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    DATA(transport_service) = cl_bcfg_cd_reuse_api_factory=>get_transport_service_instance(
                                iv_objectname = '/ESRCC/STEWRDSHP'
                                iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table ).
    IF transport_service->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
    ENTITY stewardshipall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(all).
    IF all[ 1 ]-%is_draft = if_abap_behv=>mk-off.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result = VALUE #( (
               %tky = all[ 1 ]-%tky
               %action-edit = edit_flag
               %assoc-_stewardship = edit_flag ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_STEWRDSHP' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_stewardship.
    TYPES ts_stewardship TYPE STRUCTURE FOR READ RESULT /esrcc/i_stewrdshp_s\\stewardship.

    DATA(lo_stewardship) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'StewardshipAll' ) )
        source_entity_name = '/ESRCC/C_STEWRDSHP'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported-stewardship
        failed_entity      = failed-stewardship
    ).
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_stewardship ).

    DATA(target_entities) = VALUE #( entities[ 1 ]-%target ).
    SELECT DISTINCT
           stw~sysid,
           stw~legalentity,
           stw~companycode,
           stw~costobject,
           stw~costcenter
        FROM /esrcc/d_stewrds AS stw
        INNER JOIN @target_entities AS tent
            ON  tent~sysid       = stw~sysid
            AND tent~legalentity = stw~legalentity
            AND tent~companycode = stw~companycode
            AND tent~costobject  = stw~costobject
            AND tent~costcenter  = stw~costcenter
            AND tent~validfrom   = stw~validfrom
        WHERE stw~draftentityoperationcode NOT IN ( 'D', 'L' )
        INTO TABLE @DATA(duplicate_entities).

    LOOP AT target_entities INTO DATA(entity) GROUP BY ( sysid       = entity-sysid
                                                         legalentity = entity-legalentity
                                                         companycode = entity-companycode
                                                         costobject  = entity-costobject
                                                         costcenter  = entity-costcenter
                                                         validfrom   = entity-validfrom
                                                         size        = GROUP SIZE )
        ASCENDING REFERENCE INTO DATA(group_ref).
      CHECK lo_stewardship->check_authorization(
        EXPORTING
          entity       = CORRESPONDING ts_stewardship( group_ref->* )
          legal_entity = group_ref->legalentity
          cost_object  = group_ref->costobject
          cost_number  = group_ref->costcenter
          activity     = /esrcc/cl_config_util=>c_authorization_activity-create
      ) = abap_true.

      lo_validation->validate_stewardship(
        entity  = CORRESPONDING #( group_ref->* )
        control = VALUE #( validfrom = if_abap_behv=>mk-on )
      ).

      IF line_exists( duplicate_entities[ sysid       = group_ref->sysid
                                          legalentity = group_ref->legalentity
                                          companycode = group_ref->companycode
                                          costobject  = group_ref->costobject
                                          costcenter  = group_ref->costcenter ] ) OR group_ref->size > 1.
        lo_stewardship->set_duplicate_error( entity = CORRESPONDING ts_stewardship( group_ref->* ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD edit.
    DATA(lo_util) = /esrcc/cl_config_util=>create_for_authorization( ).
    SELECT DISTINCT legalentity FROM /esrcc/i_stewrdshp INTO TABLE @DATA(legal_entities). "#EC CI_NOWHERE

    LOOP AT legal_entities INTO DATA(entity).
      DATA(is_unauthorized) = lo_util->is_unauthorized(
        EXPORTING
          legal_entity = entity-legalentity
          create       = abap_true
          update       = abap_true
          delete       = abap_true
      ).

      IF is_unauthorized = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF is_unauthorized = abap_false.
      SELECT DISTINCT costobject, costcenter FROM /esrcc/i_stewrdshp INTO TABLE @DATA(cost_numbers). "#EC CI_NOWHERE
      LOOP AT cost_numbers INTO DATA(cost_number).
        is_unauthorized = lo_util->is_unauthorized(
          EXPORTING
            cost_object = cost_number-costobject
            cost_number = cost_number-costcenter
            create      = abap_true
            update      = abap_true
            delete      = abap_true
        ).

        IF is_unauthorized = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF is_unauthorized = abap_true.
      reported-stewardshipall = VALUE #( ( %msg = new_message( id       = /esrcc/cl_config_util=>c_config_msg
                                                               number   = '019'
                                                               severity = if_abap_behv_message=>severity-success ) ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_stewrdshp_s DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_stewrdshp_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-stewardshipall INDEX 1 INTO DATA(all).
    IF all-transportrequestid IS NOT INITIAL.
      lhc_rap_tdat_cts=>get( )->record_changes(
                                  transport_request = all-transportrequestid
                                  create            = REF #( create )
                                  update            = REF #( update )
                                  delete            = REF #( delete ) ).
    ENDIF.
  ENDMETHOD.
  METHOD cleanup_finalize.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_/esrcc/i_stewrdshp DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    TYPES: tt_stewardship TYPE TABLE FOR READ RESULT /esrcc/i_stewrdshp_s\\stewardship.

    CLASS-METHODS set_workflow_status_to_draft
      IMPORTING entities TYPE tt_stewardship.

  PRIVATE SECTION.
    METHODS:
*      get_global_features FOR GLOBAL FEATURES
*        IMPORTING
*        REQUEST requested_features FOR Stewardship
*        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR stewardship RESULT result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
            IMPORTING REQUEST requested_authorizations FOR stewardship RESULT result.

    METHODS submit FOR MODIFY
      IMPORTING keys FOR ACTION stewardship~submit RESULT result.
    METHODS finalize FOR MODIFY
      IMPORTING keys FOR ACTION stewardship~finalize RESULT result.
    METHODS updateworkflowstatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR stewardship~updateworkflowstatus.
    METHODS validatedata FOR VALIDATE ON SAVE
      IMPORTING keys FOR stewardship~validatedata.
    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE stewardship.

    METHODS precheck_cba_serviceproduct FOR PRECHECK
      IMPORTING entities FOR CREATE stewardship\_serviceproduct.

    METHODS comments FOR MODIFY
      IMPORTING keys FOR ACTION stewardship~comments RESULT result.
    METHODS precheck_cba_servicereceiver FOR PRECHECK
      IMPORTING entities FOR CREATE stewardship\_servicereceiver.
    METHODS triggerworkflow FOR DETERMINE ON SAVE
      IMPORTING keys FOR stewardship~triggerworkflow.

ENDCLASS.

CLASS lhc_/esrcc/i_stewrdshp IMPLEMENTATION.
*  METHOD get_global_features.
*    DATA edit_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.
*    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
*         iv_objectname = '/ESRCC/STEWRDSHP'
*         iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
*      edit_flag = if_abap_behv=>fc-o-disabled.
*    ENDIF.
**    result-%update = edit_flag.
*    result-%delete = edit_flag.
*  ENDMETHOD.
  METHOD get_instance_features.
    IF keys[ 1 ]-%is_draft = if_abap_behv=>mk-on.
      /esrcc/cl_config_util=>create_for_authorization( )->set_instance_authorization(
        EXPORTING
          keys            = keys
          update          = abap_true
          delete          = abap_true
          create_by_assoc = abap_true
          field_mapping   = VALUE #( legal_entity = 'LEGALENTITY' cost_object = 'COSTOBJECT' cost_number = 'COSTCENTER' )
          assoc_path      = VALUE #( ( path = '_ServiceProduct' ) ( path = '_ServiceReceiver' ) )
        CHANGING
          result          = result
      ).
      DATA(auth_result) = result.
    ENDIF.

    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY stewardship
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    result = VALUE #( FOR wa IN entities
                      LET submit   = COND #( WHEN ( wa-workflowstatus = '' OR wa-workflowstatus = 'D' ) AND wa-%is_draft = if_abap_behv=>mk-on THEN if_abap_behv=>fc-o-enabled
                                             ELSE if_abap_behv=>fc-o-disabled )
                          finalize = COND #( WHEN wa-workflowstatus = 'A' AND wa-%is_draft = if_abap_behv=>mk-on THEN if_abap_behv=>fc-o-enabled
                                             ELSE if_abap_behv=>fc-o-disabled )
                          update   = COND #( WHEN VALUE #( auth_result[ %tky = wa-%tky ]-%update OPTIONAL ) = if_abap_behv=>fc-o-disabled
                                                THEN if_abap_behv=>fc-o-disabled
                                             WHEN wa-workflowstatus = '' OR wa-workflowstatus = 'D' OR wa-workflowstatus = 'R' OR wa-workflowstatus = 'A'
                                                THEN if_abap_behv=>fc-o-enabled
                                             ELSE if_abap_behv=>fc-o-disabled )
                          delete   = COND #( WHEN VALUE #( auth_result[ %tky = wa-%tky ]-%delete OPTIONAL ) = if_abap_behv=>fc-o-disabled
                                                THEN if_abap_behv=>fc-o-disabled
                                             WHEN wa-workflowstatus = 'F' OR wa-workflowstatus = 'P'
                                                THEN if_abap_behv=>fc-o-disabled
                                             ELSE if_abap_behv=>fc-o-enabled )
                      IN ( %tky                    = wa-%tky
                           %action-submit          = submit
                           %action-finalize        = finalize
                           %update                 = update
                           %delete                 = delete
                           %assoc-_serviceproduct  = update
                           %assoc-_servicereceiver = update ) ).
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD submit.
    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY stewardship
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities)

        ENTITY stewardship
        BY \_serviceproduct
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(products)

        ENTITY stewardship
        BY \_servicereceiver
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(receivers).

    DELETE entities WHERE workflowstatus <> '' AND workflowstatus <> 'D'.
    IF entities IS INITIAL.
      RETURN.
    ENDIF.

    IF products IS INITIAL OR receivers IS INITIAL.
      /esrcc/cl_config_util=>create(
        EXPORTING
          paths              = VALUE #( ( path = 'StewardshipAll' ) )
          source_entity_name = '/ESRCC/C_STEWRDSHIP'
        CHANGING
          reported_entity    = reported-stewardship
          failed_entity      = failed-stewardship
      )->set_state_message(
        entity     = entities[ 1 ]
        msg        = new_message(
                       id       = /esrcc/cl_config_util=>c_config_msg
                       number   = '027'
                       severity = if_abap_behv_message=>severity-error
                     )
        state_area = CONV #( /esrcc/cl_config_util=>child_mandatory )
      ).

      RETURN.
    ENDIF.

    MODIFY ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY stewardship
        UPDATE FIELDS ( comments workflowid workflowstatus workflowstatuscriticality triggerworkflow )
        WITH VALUE #( FOR entity IN entities
                        ( %tky                      = entity-%tky
                          workflowid                = ''
                          comments                  = VALUE #( keys[ %tky = entity-%tky ]-%param-comments OPTIONAL )
                          workflowstatus            = 'P'
                          workflowstatuscriticality = '2'
                          triggerworkflow           = abap_true ) )
        FAILED failed
        REPORTED reported
        MAPPED mapped.



    result = VALUE #( FOR entity IN entities ( %tky = entity-%tky
                                               %is_draft = entity-%is_draft
                                               %param = entity ) ).
  ENDMETHOD.

  METHOD finalize.
    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY stewardship
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    MODIFY ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY stewardship
        UPDATE FIELDS ( workflowstatus workflowstatuscriticality )
        WITH VALUE #( FOR entity IN entities WHERE ( workflowstatus = 'A' )
                        ( %tky                      = entity-%tky
                          workflowstatus            = 'F'
                          workflowstatuscriticality = '3' ) )
        FAILED failed
        REPORTED reported
        MAPPED mapped.

    result = VALUE #( FOR entity IN entities ( %tky = entity-%tky
                                               %param = entity ) ).
  ENDMETHOD.

  METHOD updateworkflowstatus.
    CHECK keys[ 1 ]-%is_draft = if_abap_behv=>mk-on.

    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY stewardship
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    set_workflow_status_to_draft( entities ).
  ENDMETHOD.

  METHOD set_workflow_status_to_draft.
    MODIFY ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY stewardship
        UPDATE FIELDS ( workflowstatus workflowstatuscriticality )
        WITH VALUE #( FOR entity IN entities WHERE ( workflowstatus <> 'D' )
                        ( %tky                      = entity-%tky
                          %is_draft                 = entity-%is_draft
                          workflowstatus            = 'D'
                          workflowstatuscriticality = '2'
                          %control                  = VALUE #( workflowstatus            = if_abap_behv=>mk-on
                                                               workflowstatuscriticality = if_abap_behv=>mk-on ) ) ).
  ENDMETHOD.

  METHOD validatedata.
    DATA:
      draft           TYPE STRUCTURE FOR READ RESULT /esrcc/i_stewrdshp_s\\stewardship,
      service_product TYPE STRUCTURE FOR READ RESULT /esrcc/i_stewrdshp_s\\serviceproduct.

    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
         ENTITY stewardship
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

*   To validate overlapping dates
    SELECT st~*
      FROM /esrcc/d_stewrds AS st
      INNER JOIN @entities AS ent
        ON  ent~sysid       = st~sysid
        AND ent~legalentity = st~legalentity
        AND ent~companycode = st~companycode
        AND ent~costobject  = st~costobject
        AND ent~costcenter  = st~costcenter
      WHERE st~draftentityoperationcode NOT IN ( 'D', 'L' )
      INTO TABLE @DATA(overlapping_dates).

    " To validate duplicate chain sequence
    DATA overlapping_chain_seqs TYPE TABLE OF /esrcc/d_stewrds.
    SELECT st~*
      FROM /esrcc/d_stewrds AS st
      INNER JOIN @entities AS ent
        ON  ent~chainid = st~chainid
        AND ent~chainid <> ''
        AND ( st~validfrom BETWEEN ent~validfrom AND ent~validto OR st~validto BETWEEN ent~validfrom AND ent~validto )
      WHERE st~draftentityoperationcode NOT IN ( 'D', 'L' )
      INTO CORRESPONDING FIELDS OF TABLE @overlapping_chain_seqs.
    SORT overlapping_chain_seqs BY stewardshipuuid.
    DELETE ADJACENT DUPLICATES FROM overlapping_chain_seqs COMPARING stewardshipuuid.

    " Calculate sum of share % for Service Product
    SELECT share~stewardshipuuid, share~validfrom, share~validto, share~shareofcost
      FROM /esrcc/d_stwd_sp AS share
      INNER JOIN @entities AS ent
        ON  ent~stewardshipuuid = share~stewardshipuuid
      WHERE share~draftentityoperationcode NOT IN ( 'D', 'L' )
      INTO TABLE @DATA(products).

    DATA(lo_stewardship) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'StewardshipAll' ) )
        source_entity_name = '/ESRCC/C_STEWRDSHP'
      CHANGING
        reported_entity    = reported-stewardship
        failed_entity      = failed-stewardship ).

    DATA(lo_service_product) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'StewardshipAll' )
                                      ( path = 'Stewardship' ) )
        source_entity_name = '/ESRCC/C_STWDSP'
      CHANGING
        reported_entity    = reported-serviceproduct
        failed_entity      = failed-serviceproduct ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_stewardship ).
    lo_validation->calculate_costshare_sum(
      EXPORTING
        sharecost     = CORRESPONDING #( products )
      IMPORTING
        sharecost_sum = DATA(sharecost_sum) ).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_stewardship( entity = entity control = VALUE #( chainid       = COND #( WHEN entity-chainsequence IS NOT INITIAL THEN if_abap_behv=>mk-on )
                                                                              chainsequence = COND #( WHEN entity-chainid IS NOT INITIAL THEN if_abap_behv=>mk-on )
                                                                              validto       = if_abap_behv=>mk-on
                                                                              stewardship   = if_abap_behv=>mk-on ) ).

      LOOP AT sharecost_sum TRANSPORTING NO FIELDS WHERE stewardship_uuid = entity-stewardshipuuid
                                                     AND share_of_cost    <> 100.
        lo_stewardship->set_state_message(
          entity     = entity
          msg        = new_message( id = /esrcc/cl_config_util=>c_config_msg number = '009' severity = if_abap_behv_message=>severity-error v1 = lo_stewardship->get_field_text( fieldname = 'COSTSHARE' data_element = '/ESRCC/COSTSHARE' ) )
          state_area = CONV #( /esrcc/cl_config_util=>percentage )
        ).
        EXIT.
      ENDLOOP.

      " Validate overlapping dates
      LOOP AT overlapping_dates INTO DATA(date) WHERE sysid           = entity-sysid
                                                  AND legalentity     = entity-legalentity
                                                  AND companycode     = entity-companycode
                                                  AND costobject      = entity-costobject
                                                  AND costcenter      = entity-costcenter
                                                  AND stewardshipuuid <> entity-stewardshipuuid.
        draft = CORRESPONDING #( date ).
        draft = CORRESPONDING #( BASE ( draft ) entity MAPPING %is_draft = %is_draft singletonid = singletonid EXCEPT * ).
        lo_stewardship->validate_overlapping_validity( EXPORTING src_from    = draft-validfrom
                                                                 src_to      = draft-validto
                                                                 src_entity  = draft
                                                                 curr_from   = entity-validfrom
                                                                 curr_to     = entity-validto
                                                                 curr_entity = entity ).
        EXIT.
      ENDLOOP.

      " Validate validity of Service Product
      LOOP AT products INTO DATA(product) WHERE stewardshipuuid = entity-stewardshipuuid
                                            AND ( validfrom NOT BETWEEN entity-validfrom AND entity-validto
                                             OR   validto NOT BETWEEN entity-validfrom AND entity-validto ).
        service_product = CORRESPONDING #( product ).
        service_product = CORRESPONDING #( BASE ( service_product ) entity MAPPING %is_draft = %is_draft singletonid = singletonid EXCEPT * ).
        lo_service_product->set_state_message(
          entity     = service_product
          msg        = new_message( id = /esrcc/cl_config_util=>c_config_msg number = '013' severity = cl_abap_behv=>ms-error )
          state_area = CONV #( /esrcc/cl_config_util=>date_out_of_range )
        ).
      ENDLOOP.

      " Validate chain sequence
      LOOP AT overlapping_chain_seqs INTO DATA(chain_seq) WHERE chainid         = entity-chainid
                                                            AND chainsequence   = entity-chainsequence
                                                            AND stewardshipuuid <> entity-stewardshipuuid.
        draft = CORRESPONDING #( chain_seq ).
        draft = CORRESPONDING #( BASE ( draft ) entity MAPPING %is_draft = %is_draft singletonid = singletonid EXCEPT * ).
        lo_stewardship->set_state_message(
          fieldname  = 'CHAINSEQUENCE'
          entity     = draft
          msg        = new_message( id = /esrcc/cl_config_util=>c_config_msg number = '024' severity = cl_abap_behv=>ms-error
                                    v1 = lo_stewardship->get_field_text( fieldname = 'CHAINSEQUENCE' data_element = '/ESRCC/CHAIN_SEQUENCE' )
                                    v2 = lo_stewardship->get_field_text( fieldname = 'CHAINID' data_element = '/ESRCC/CHAIN_ID' )
                                    v3 = chain_seq-chainid )
          state_area = CONV #( /esrcc/cl_config_util=>overlapping_sequence )
        ).
        EXIT.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'StewardshipAll' ) )
        source_entity_name = '/ESRCC/C_STEWRDSHP'
      CHANGING
        reported_entity    = reported-stewardship
        failed_entity      = failed-stewardship ) ).

    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY stewardship
        ALL FIELDS WITH CORRESPONDING #( entities )
        RESULT DATA(stewardships).

    LOOP AT entities INTO DATA(entity) WHERE %control-chainid       = if_abap_behv=>mk-on
                                          OR %control-chainsequence = if_abap_behv=>mk-on
                                          OR %control-stewardship   = if_abap_behv=>mk-on
                                          OR %control-validto       = if_abap_behv=>mk-on.
      IF entity-%control-chainid = if_abap_behv=>mk-on AND entity-%control-chainsequence = if_abap_behv=>mk-off.
        entity-chainsequence = stewardships[ %tky = entity-%tky ]-chainsequence.
      ENDIF.

      IF entity-%control-chainid = if_abap_behv=>mk-off AND entity-%control-chainsequence = if_abap_behv=>mk-on.
        entity-chainid = stewardships[ %tky = entity-%tky ]-chainid.
      ENDIF.

      lo_validation->validate_stewardship(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( chainid       = COND #( WHEN entity-chainsequence IS NOT INITIAL THEN if_abap_behv=>mk-on )
                           chainsequence = COND #( WHEN entity-chainid IS NOT INITIAL THEN if_abap_behv=>mk-on )
                           validto       = entity-%control-validto
                           stewardship   = entity-%control-stewardship )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_cba_serviceproduct.
    TYPES ts_product TYPE STRUCTURE FOR READ RESULT /esrcc/i_stewrdshp_s\\serviceproduct.

    DATA(lo_product) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'StewardshipAll' )
                                      ( path = 'Stewardship' ) )
        source_entity_name = '/ESRCC/C_STWDSP'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported-serviceproduct
        failed_entity      = failed-serviceproduct
    ).
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_product ).

    DATA(target_entities) = VALUE #( entities[ 1 ]-%target ).
    DATA(stewardship_uuid) = VALUE #( entities[ 1 ]-stewardshipuuid ).
    SELECT DISTINCT
           prod~serviceproduct
        FROM /esrcc/d_stwd_sp AS prod
        INNER JOIN @target_entities AS tent
            ON  tent~serviceproduct  = prod~serviceproduct
            AND tent~validfrom       = prod~validfrom
        WHERE prod~draftentityoperationcode NOT IN ( 'D', 'L' )
          AND prod~stewardshipuuid = @stewardship_uuid
        INTO TABLE @DATA(duplicate_entities).

    LOOP AT target_entities INTO DATA(entity) GROUP BY ( prod      = entity-serviceproduct
                                                         validfrom = entity-validfrom
                                                         size      = GROUP SIZE )
        ASCENDING REFERENCE INTO DATA(group_ref).
      lo_validation->validate_service_product(
        entity  = CORRESPONDING #( group_ref->* )
        control = VALUE #( validfrom = if_abap_behv=>mk-on )
      ).

      IF line_exists( duplicate_entities[ serviceproduct = group_ref->prod ] ) OR group_ref->size > 1.
        lo_product->set_duplicate_error( entity = CORRESPONDING ts_product( entity ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD comments.
*    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
*        ENTITY stewardship
*        ALL FIELDS WITH CORRESPONDING #( keys )
*        RESULT DATA(entities).
*
*    LOOP AT entities INTO DATA(entity).
*
*    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_cba_servicereceiver.
    TYPES ts_receiver TYPE STRUCTURE FOR READ RESULT /esrcc/i_stewrdshp_s\\servicereceiver.

    DATA(lo_receiver) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'StewardshipAll' )
                                      ( path = 'Stewardship' ) )
        source_entity_name = '/ESRCC/C_STWDSPREC'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported-servicereceiver
        failed_entity      = failed-servicereceiver
    ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_receiver ).

    DATA(target_entities) = VALUE #( entities[ 1 ]-%target ).
    DATA(stewardship_uuid) = VALUE #( entities[ 1 ]-stewardshipuuid ).
    SELECT
           rec~serviceproduct,
           rec~costobjectuuid
        FROM /esrcc/d_stwdspr AS rec
        INNER JOIN @target_entities AS tent
            ON  tent~serviceproduct = rec~serviceproduct
            AND tent~costobjectuuid = rec~costobjectuuid
        WHERE rec~draftentityoperationcode NOT IN ( 'D', 'L' )
          AND rec~stewardshipuuid = @stewardship_uuid
        INTO TABLE @DATA(duplicate_entities).

    SELECT DISTINCT
           prod~serviceproduct
        FROM /esrcc/d_stwd_sp AS prod
        INNER JOIN @target_entities AS tent
            ON tent~serviceproduct = prod~serviceproduct
        WHERE prod~draftentityoperationcode NOT IN ( 'D', 'L' )
          AND prod~stewardshipuuid = @stewardship_uuid
        INTO TABLE @DATA(service_products).

    LOOP AT target_entities INTO DATA(entity) GROUP BY ( prod = entity-serviceproduct costobjectuuid = entity-costobjectuuid size = GROUP SIZE )
        ASCENDING REFERENCE INTO DATA(group_ref).
      IF line_exists( duplicate_entities[ serviceproduct = group_ref->prod costobjectuuid = group_ref->costobjectuuid ] ) OR group_ref->size > 1.
        lo_receiver->set_duplicate_error( entity = CORRESPONDING ts_receiver( entity ) ).
        CONTINUE.
      ENDIF.

      IF NOT line_exists( service_products[ serviceproduct = group_ref->prod ] ).
        lo_receiver->set_state_message(
          entity     = CORRESPONDING ts_receiver( entity )
          msg        = new_message(
                         id       = /esrcc/cl_config_util=>c_config_msg
                         number   = '025'
                         severity = if_abap_behv_message=>severity-error
                       )
          state_area = CONV #( /esrcc/cl_config_util=>not_exists ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD triggerworkflow.
    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY stewardship
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    DELETE entities WHERE triggerworkflow = abap_false.
    IF entities IS INITIAL.
      RETURN.
    ENDIF.

    DATA(trigger_workflow) = abap_false.
    /esrcc/cl_wf_utility=>is_wf_on(
      EXPORTING
        iv_apptype   = 'CST'
      IMPORTING
        ev_wf_active = DATA(wf_active)
    ).

    IF wf_active = abap_true.
      CALL FUNCTION '/ESRCC/FM_WF_START'
        EXPORTING
          it_leading_object = CORRESPONDING /esrcc/tt_wf_leadingobject( entities MAPPING stewardship_uuid = stewardshipuuid EXCEPT * )
          iv_apptype        = 'CST'.

*      DATA(workflow_status) = 'P'.
*      DATA(workflow_status_crit) = '2'.
      MODIFY ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
         ENTITY stewardship
         UPDATE FIELDS ( triggerworkflow )
         WITH VALUE #( FOR entity IN entities
                         ( %tky            = entity-%tky
                           triggerworkflow = trigger_workflow ) )
         FAILED DATA(failed_mod)
         MAPPED DATA(mapped_mod).
    ELSE.
      DATA(workflow_status) = 'A'.
      DATA(workflow_status_crit) = '3'.

*     TO-DO: Set to in process after workflow is started successfully else set to error
      MODIFY ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY stewardship
        UPDATE FIELDS ( workflowstatus workflowstatuscriticality triggerworkflow )
        WITH VALUE #( FOR entity IN entities
                        ( %tky                      = entity-%tky
                          workflowstatus            = workflow_status
                          workflowstatuscriticality = workflow_status_crit
                          triggerworkflow           = trigger_workflow ) )
        FAILED failed_mod
        MAPPED mapped_mod.
    ENDIF.
  ENDMETHOD.

ENDCLASS.


CLASS lhc_serviceproduct DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR serviceproduct RESULT result.
    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE serviceproduct.

    METHODS validatedata FOR VALIDATE ON SAVE
      IMPORTING keys FOR serviceproduct~validatedata.
    METHODS precheck_delete FOR PRECHECK
      IMPORTING keys FOR DELETE serviceproduct.
    METHODS updateworkflowstatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR serviceproduct~updateworkflowstatus.

ENDCLASS.

CLASS lhc_serviceproduct IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY serviceproduct
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(service_products).

    SELECT SINGLE CASE WHEN stw~workflowstatus = ' ' OR stw~workflowstatus = 'D' OR stw~workflowstatus = 'A' OR workflowstatus = 'R' THEN @if_abap_behv=>fc-o-enabled
                       ELSE @if_abap_behv=>fc-o-disabled
                  END AS editability
        FROM /esrcc/i_stewrdshp AS stw
        INNER JOIN @service_products AS srv_prd
            ON srv_prd~stewardshipuuid = stw~stewardshipuuid
        INTO @DATA(editability).

    result = VALUE #( FOR wa IN service_products
                         ( %tky    = wa-%tky
                           %update = editability
                           %delete = editability ) ).
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'StewardshipAll' )
                                      ( path = 'Stewardship' ) )
        source_entity_name = '/ESRCC/C_STWDSP'
      CHANGING
        reported_entity    = reported-serviceproduct
        failed_entity      = failed-serviceproduct ) ).

    LOOP AT entities INTO DATA(entity) WHERE %control-shareofcost = if_abap_behv=>mk-on
                                          OR %control-validfrom   = if_abap_behv=>mk-on
                                          OR %control-validto     = if_abap_behv=>mk-on.
      lo_validation->validate_service_product(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( validto     = entity-%control-validto
                           shareofcost = entity-%control-shareofcost )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD validatedata.
    DATA: draft TYPE STRUCTURE FOR READ RESULT /esrcc/i_stewrdshp_s\\serviceproduct.

    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
         ENTITY serviceproduct
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities)

         ENTITY serviceproduct
         BY \_stewardship
         FIELDS ( validfrom validto ) WITH CORRESPONDING #( keys )
         RESULT DATA(stewardships).

    SELECT prod~*
      FROM /esrcc/d_stwd_sp AS prod
      INNER JOIN @entities AS ent
        ON  ent~serviceproduct  = prod~serviceproduct
        AND ent~stewardshipuuid = prod~stewardshipuuid
      WHERE prod~draftentityoperationcode NOT IN ( 'D', 'L' )
      INTO TABLE @DATA(overlapping_dates).

    DATA(lo_service_product) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'StewardshipAll' )
                                      ( path = 'Stewardship' ) )
        source_entity_name = '/ESRCC/C_STWDSP'
      CHANGING
        reported_entity    = reported-serviceproduct
        failed_entity      = failed-serviceproduct ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_service_product ).
    lo_validation->calculate_costshare_sum(
      EXPORTING
        sharecost     = CORRESPONDING #( entities MAPPING service_product_uuid = serviceproductuuid
                                                          service_product      = serviceproduct
                                                          valid_from           = validfrom
                                                          valid_to             = validto
                                                          share_of_cost        = shareofcost
                                                          stewardship_uuid     = stewardshipuuid )
      IMPORTING
        sharecost_sum = DATA(sharecost_sum)
    ).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_service_product(
        entity  = entity
        control = VALUE #( validto = if_abap_behv=>mk-on shareofcost = if_abap_behv=>mk-on )
      ).

      " Validate sum of share cost
      LOOP AT sharecost_sum TRANSPORTING NO FIELDS WHERE stewardship_uuid = entity-stewardshipuuid
                                                     AND share_of_cost    <> 100.
        lo_service_product->set_state_message(
          entity     = entity
          msg        = new_message( id = /esrcc/cl_config_util=>c_config_msg number = '009' severity = if_abap_behv_message=>severity-error v1 = lo_service_product->get_field_text( fieldname = 'SHAREOFCOST' data_element = '/ESRCC/COSTSHARE' ) )
          state_area = CONV #( /esrcc/cl_config_util=>percentage )
        ).
        EXIT.
      ENDLOOP.

      " Validate overlapping dates
      LOOP AT overlapping_dates INTO DATA(date) WHERE serviceproduct     = entity-serviceproduct
                                                  AND stewardshipuuid    = entity-stewardshipuuid
                                                  AND serviceproductuuid <> entity-serviceproductuuid.
        draft = CORRESPONDING #( date ).
        draft = CORRESPONDING #( BASE ( draft ) entity MAPPING %is_draft = %is_draft singletonid = singletonid EXCEPT * ).
        lo_service_product->validate_overlapping_validity(
          src_from    = draft-validfrom
          src_to      = draft-validto
          src_entity  = draft
          curr_from   = entity-validfrom
          curr_to     = entity-validto
          curr_entity = entity
        ).
      ENDLOOP.

      " Validate dates overflow with Cost Object Type validity
      DATA(stw) = VALUE #( stewardships[ stewardshipuuid = entity-stewardshipuuid ] OPTIONAL ).
      IF     stw IS NOT INITIAL
         AND (    entity-validfrom NOT BETWEEN stw-validfrom AND stw-validto
               OR entity-validto NOT BETWEEN stw-validfrom AND stw-validto ).
        lo_service_product->set_state_message(
          entity     = entity
          msg        = new_message( id       = /esrcc/cl_config_util=>c_config_msg
                                    number   = '013'
                                    severity = cl_abap_behv=>ms-error )
          state_area = CONV #( /esrcc/cl_config_util=>date_out_of_range )
        ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_delete.
    DATA(lo_service_product) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'StewardshipAll' )
                                      ( path = 'Stewardship' ) )
        source_entity_name = '/ESRCC/C_STWDSP'
      CHANGING
        reported_entity    = reported-serviceproduct
        failed_entity      = failed-serviceproduct ).

    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY serviceproduct
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(products).

    SELECT DISTINCT rec~serviceproduct
        FROM /esrcc/d_stwdspr AS rec
        INNER JOIN @products AS prod
            ON  prod~serviceproduct  = rec~serviceproduct
            AND prod~stewardshipuuid = rec~stewardshipuuid
        WHERE rec~draftentityoperationcode NOT IN ( 'D', 'L' )
        INTO TABLE @DATA(receivers).

    LOOP AT products INTO DATA(product).
      IF line_exists( receivers[ serviceproduct = product-serviceproduct ] ).
        lo_service_product->set_state_message(
              entity     = product
              msg        = new_message(
                             id       = /esrcc/cl_config_util=>c_config_msg
                             number   = '021'
                             severity = if_abap_behv_message=>severity-error
                             v1       = TEXT-001
                           )
              state_area = CONV #( /esrcc/cl_config_util=>not_exists ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD updateworkflowstatus.
    CHECK keys[ 1 ]-%is_draft = if_abap_behv=>mk-on.

    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY serviceproduct
        BY \_stewardship
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    IF entities IS INITIAL.     " When entry is deleted
      SELECT DISTINCT prod~stewardshipuuid, key~%is_draft
        FROM /esrcc/i_stwdsp AS prod
        INNER JOIN @keys AS key
          ON key~serviceproductuuid = prod~serviceproductuuid
        INTO CORRESPONDING FIELDS OF TABLE @entities.
    ENDIF.

    lhc_/esrcc/i_stewrdshp=>set_workflow_status_to_draft( entities = entities ).
  ENDMETHOD.

ENDCLASS.


CLASS lhc_servicereceiver DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR servicereceiver RESULT result.
    METHODS validatedata FOR VALIDATE ON SAVE
      IMPORTING keys FOR servicereceiver~validatedata.
    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE servicereceiver.
    METHODS updateworkflowstatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR servicereceiver~updateworkflowstatus.

ENDCLASS.

CLASS lhc_servicereceiver IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY servicereceiver
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(receivers).

    SELECT SINGLE CASE WHEN stw~workflowstatus = ' ' OR stw~workflowstatus = 'D' OR workflowstatus = 'A' OR workflowstatus = 'R' THEN @if_abap_behv=>fc-o-enabled
                       ELSE @if_abap_behv=>fc-o-disabled
                  END AS editability
        FROM /esrcc/i_stewrdshp AS stw
        INNER JOIN @receivers AS rec
            ON rec~stewardshipuuid = stw~stewardshipuuid
        INTO @DATA(editability).

    result = VALUE #( FOR wa IN receivers
                         ( %tky    = wa-%tky
                           %update = editability
                           %delete = editability ) ).
  ENDMETHOD.

  METHOD validatedata.
    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
         ENTITY servicereceiver
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities)

         ENTITY servicereceiver
         BY \_stewardship
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(stewardship).

    DATA(lo_config_util) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'StewardshipAll' )
                                      ( path = 'Stewardship' ) )
        source_entity_name = '/ESRCC/C_STWDSPREC'
      CHANGING
        reported_entity    = reported-servicereceiver
        failed_entity      = failed-servicereceiver ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_config_util ).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_service_receiver(
        entity  = entity
        control = VALUE #( invoicecurrency = if_abap_behv=>mk-on )
      ).

      IF line_exists( stewardship[ costobjectuuid = entity-costobjectuuid ] ).
        lo_config_util->set_state_message(
          entity     = entity
          msg        = new_message(
                         id       = /esrcc/cl_config_util=>c_config_msg
                         number   = '026'
                         severity = if_abap_behv_message=>severity-error
                       )
          state_area = CONV #( /esrcc/cl_config_util=>duplicate )
        ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
        EXPORTING
          paths              = VALUE #( ( path = 'StewardshipAll' )
                                        ( path = 'Stewardship' ) )
          source_entity_name = '/ESRCC/C_STWDSPREC'
        CHANGING
          reported_entity    = reported-servicereceiver
          failed_entity      = failed-servicereceiver ) ).

    LOOP AT entities INTO DATA(entity) WHERE %control-invoicecurrency = if_abap_behv=>mk-on.
      lo_validation->validate_service_receiver(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( invoicecurrency = entity-%control-invoicecurrency )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD updateworkflowstatus.
    CHECK keys[ 1 ]-%is_draft = if_abap_behv=>mk-on.

    READ ENTITIES OF /esrcc/i_stewrdshp_s IN LOCAL MODE
        ENTITY servicereceiver
        BY \_stewardship
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).

    IF entities IS INITIAL.     " When entry is deleted
      SELECT DISTINCT rec~stewardshipuuid, key~%is_draft
        FROM /esrcc/i_stwdsprec AS rec
        INNER JOIN @keys AS key
          ON key~servicereceiveruuid = rec~servicereceiveruuid
        INTO CORRESPONDING FIELDS OF TABLE @entities.
    ENDIF.

    lhc_/esrcc/i_stewrdshp=>set_workflow_status_to_draft( entities = entities ).
  ENDMETHOD.

ENDCLASS.
