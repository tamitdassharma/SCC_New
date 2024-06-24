CLASS lcl_custom_validation DEFINITION.
  PUBLIC SECTION.
    TYPES:
      ts_le_cctr           TYPE STRUCTURE FOR READ RESULT /esrcc/i_lecctr_s\\letocostcenter,
      ts_service_parameter TYPE STRUCTURE FOR READ RESULT /esrcc/i_lecctr_s\\serviceparameter,
      tt_sharecost         TYPE STANDARD TABLE OF /esrcc/srvprrec WITH EMPTY KEY,

      BEGIN OF ts_control_lecctr,
        validfrom   TYPE if_abap_behv=>t_xflag,
        validto     TYPE if_abap_behv=>t_xflag,
        stewardship TYPE if_abap_behv=>t_xflag,
      END OF ts_control_lecctr,
      BEGIN OF ts_control_service_parameter,
        validfrom TYPE if_abap_behv=>t_xflag,
        validto   TYPE if_abap_behv=>t_xflag,
        costshare TYPE if_abap_behv=>t_xflag,
      END OF ts_control_service_parameter.

    METHODS:
      constructor
        IMPORTING
          config_util_ref TYPE REF TO /esrcc/cl_config_util,
      validate_le_cctr
        IMPORTING
          entity  TYPE ts_le_cctr
          control TYPE ts_control_lecctr,
      validate_service_parameter
        IMPORTING
          entity  TYPE ts_service_parameter
          control TYPE ts_control_service_parameter,
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

  METHOD validate_le_cctr.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-validfrom   = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALIDFROM' ) TO fields. ENDIF.
    IF control-validto     = if_abap_behv=>mk-on. APPEND VALUE #( fieldname = 'VALIDTO' ) TO fields. ENDIF.

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

  METHOD validate_service_parameter.
    DATA fields TYPE /esrcc/cl_config_util=>tt_fields.

    IF config_util_ref IS NOT BOUND.
      RETURN.
    ENDIF.

    IF control-costshare = if_abap_behv=>mk-on.
      config_util_ref->validate_percentage(
        fields = VALUE #( ( fieldname = 'COSTSHARE' ) )
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

  METHOD calculate_costshare_sum.
    SELECT sysid, legalentity, ccode, costobject, costcenter, costcenter_vf, validfrom AS date
      FROM @sharecost AS share
      WHERE share~validto <> '00000000'
      INTO TABLE @DATA(dates).

    SELECT sysid, legalentity, ccode, costobject, costcenter, costcenter_vf,
           CASE WHEN share~validto <> '99991231' THEN dats_add_days(  share~validto , 1 ) ELSE share~validto END AS date
      FROM @sharecost AS share
      WHERE share~validto <> '00000000'
      APPENDING TABLE @dates.

    SORT dates BY sysid legalentity ccode costobject costcenter costcenter_vf date.
    DELETE ADJACENT DUPLICATES FROM dates COMPARING sysid legalentity ccode costobject costcenter costcenter_vf date.
    DATA(count) = lines( dates ).

    DATA curr LIKE LINE OF dates.
    LOOP AT dates INTO DATA(date).
      IF curr-sysid         <> date-sysid OR
         curr-legalentity   <> date-legalentity OR
         curr-ccode         <> date-ccode OR
         curr-costobject    <> date-costobject OR
         curr-costcenter    <> date-costcenter OR
         curr-costcenter_vf <> date-costcenter_vf.
        curr = CORRESPONDING #( date ).
        APPEND CORRESPONDING #( date MAPPING validfrom = date ) TO sharecost_sum ASSIGNING FIELD-SYMBOL(<sum>).
      ELSE.
        <sum>-validto = COND #( WHEN date-date <> '99991231' THEN date-date - 1 ELSE date-date ).
        LOOP AT sharecost INTO DATA(share) WHERE sysid         = date-sysid
                                             AND legalentity   = date-legalentity
                                             AND ccode         = date-ccode
                                             AND costobject    = date-costobject
                                             AND costcenter    = date-costcenter
                                             AND costcenter_vf = date-costcenter_vf.
          IF <sum>-validfrom BETWEEN share-validfrom AND share-validto OR
             <sum>-validto BETWEEN share-validfrom AND share-validto.
            <sum>-costshare = <sum>-costshare + share-costshare.
          ENDIF.
        ENDLOOP.
        IF count <> sy-tabix.
          APPEND CORRESPONDING #( date MAPPING validfrom = date ) TO sharecost_sum ASSIGNING <sum>.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lhc_receiver DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR servicereceiver RESULT result.

ENDCLASS.

CLASS lhc_receiver IMPLEMENTATION.
  METHOD get_instance_features.
    IF keys[ 1 ]-%is_draft = if_abap_behv=>mk-on.
      /esrcc/cl_config_util=>create_for_authorization( )->set_instance_authorization(
          EXPORTING
            keys          = keys
            update        = abap_true
            delete        = abap_true
            field_mapping = VALUE #( legal_entity = 'LEGALENTITY' cost_object = 'COSTOBJECT' cost_number = 'COSTCENTER' )
          CHANGING
            result        = result
        ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_serviceparameter DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS validatedata FOR VALIDATE ON SAVE
      IMPORTING keys FOR serviceparameter~validatedata.
    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE serviceparameter.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR serviceparameter RESULT result.
ENDCLASS.

CLASS lhc_serviceparameter IMPLEMENTATION.
  METHOD validatedata.
    DATA: draft TYPE STRUCTURE FOR READ RESULT /esrcc/i_lecctr_s\\serviceparameter.

    READ ENTITIES OF /esrcc/i_lecctr_s IN LOCAL MODE
         ENTITY serviceparameter
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities)

         ENTITY letocostcenter
         FIELDS ( validfrom validto ) WITH CORRESPONDING #( keys MAPPING validfrom = costcentervf )
         RESULT DATA(lecctr_entities).

    SELECT param~*
      FROM /esrcc/d_srvprre AS param
      INNER JOIN @keys AS key
        ON  key~sysid           = param~sysid
        AND key~legalentity     = param~legalentity
        AND key~ccode           = param~ccode
        AND key~costobject      = param~costobject
        AND key~costcenter      = param~costcenter
        AND key~serviceproduct  = param~serviceproduct
        AND key~costcentervf    = param~costcentervf
        AND key~validfrom      <> param~validfrom
      WHERE param~draftentityoperationcode NOT IN ( 'D', 'L' )
      INTO TABLE @DATA(draft_entities).

    DATA(lecctr) = VALUE #( lecctr_entities[ 1 ] OPTIONAL ).

    DATA(lo_service_parameter) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'LeToCostCenterAll' )
                                      ( path = 'LeToCostCenter' ) )
        source_entity_name = '/ESRCC/C_SERVICEPARAMETER'
      CHANGING
        reported_entity    = reported-serviceparameter
        failed_entity      = failed-serviceparameter ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_service_parameter ).
    lo_validation->calculate_costshare_sum(
      EXPORTING
        sharecost     = CORRESPONDING #( entities MAPPING costcenter_vf = costcentervf )
      IMPORTING
        sharecost_sum = DATA(sharecost_sum)
    ).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_service_parameter(
        entity  = entity
        control = VALUE #( validto = if_abap_behv=>mk-on costshare = if_abap_behv=>mk-on )
      ).

      LOOP AT sharecost_sum TRANSPORTING NO FIELDS WHERE sysid         = entity-sysid
                                                     AND legalentity   = entity-legalentity
                                                     AND ccode         = entity-ccode
                                                     AND costobject    = entity-costobject
                                                     AND costcenter    = entity-costcenter
                                                     AND costcenter_vf = entity-costcentervf
                                                     AND validfrom     = entity-validfrom
                                                     AND costshare     <> 100.
        lo_service_parameter->set_state_message(
          entity     = entity
          msg        = new_message( id = /esrcc/cl_config_util=>c_config_msg number = '009' severity = if_abap_behv_message=>severity-error v1 = lo_service_parameter->get_field_text( fieldname = 'COSTSHARE' data_element = '/ESRCC/COSTSHARE' ) )
          state_area = CONV #( /esrcc/cl_config_util=>percentage )
        ).
        EXIT.
      ENDLOOP.

      LOOP AT draft_entities ASSIGNING FIELD-SYMBOL(<draft>)
           WHERE     sysid           = entity-sysid
                 AND legalentity     = entity-legalentity
                 AND ccode           = entity-ccode
                 AND costobject      = entity-costobject
                 AND costcenter      = entity-costcenter
                 AND serviceproduct  = entity-serviceproduct
                 AND costcentervf    = entity-costcentervf
                 AND validfrom      <> entity-validfrom.
        draft = CORRESPONDING #( <draft> ).
        draft = CORRESPONDING #( BASE ( draft ) entity MAPPING %is_draft = %is_draft singletonid = singletonid EXCEPT * ).
        lo_service_parameter->validate_overlapping_validity(
          src_from    = <draft>-validfrom
          src_to      = <draft>-validto
          src_entity  = draft
          curr_from   = entity-validfrom
          curr_to     = entity-validto
          curr_entity = entity
        ).
      ENDLOOP.

      " Validate dates overflow with Cost Object Type validity
      IF     lecctr IS NOT INITIAL
         AND (    entity-validfrom NOT BETWEEN lecctr-validfrom AND lecctr-validto
               OR entity-validto NOT   BETWEEN lecctr-validfrom AND lecctr-validto ).
        lo_service_parameter->set_state_message(
          entity     = entity
          msg        = new_message( id       = /esrcc/cl_config_util=>c_config_msg
                                    number   = '013'
                                    severity = cl_abap_behv=>ms-error )
          state_area = CONV #( /esrcc/cl_config_util=>date_out_of_range )
        ).
      ENDIF.

      LOOP AT reported-serviceparameter ASSIGNING FIELD-SYMBOL(<fs_reported>) WHERE %path-letocostcenter IS NOT INITIAL.
        <fs_reported>-%path-letocostcenter-validfrom = entity-costcentervf.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'LeToCostCenterAll' )
                                      ( path = 'LeToCostCenter' ) )
        source_entity_name = '/ESRCC/C_SERVICEPARAMETER'
      CHANGING
        reported_entity    = reported-serviceparameter
        failed_entity      = failed-serviceparameter ) ).

    LOOP AT entities INTO DATA(entity) WHERE %control-costshare = if_abap_behv=>mk-on
                                          OR %control-validfrom = if_abap_behv=>mk-on
                                          OR %control-validto   = if_abap_behv=>mk-on.
      lo_validation->validate_service_parameter(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( validto   = entity-%control-validto
                           costshare = entity-%control-costshare )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.
    IF keys[ 1 ]-%is_draft = if_abap_behv=>mk-on.
      /esrcc/cl_config_util=>create_for_authorization( )->set_instance_authorization(
        EXPORTING
          keys          = keys
          update        = abap_true
          delete        = abap_true
          field_mapping = VALUE #( legal_entity = 'LEGALENTITY' cost_object = 'COSTOBJECT' cost_number = 'COSTCENTER' )
        CHANGING
          result        = result
      ).
    ENDIF.
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
                                         ( entity = 'LeToCostCenter' table = '/ESRCC/LE_CCTR' )
                                       ) ).
  ENDMETHOD.
ENDCLASS.

CLASS lhc_/esrcc/i_lecctr DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
*      validaterecordchanges FOR VALIDATE ON SAVE
*        IMPORTING
*          keys FOR letocostcenter~validaterecordchanges,
      validatedata FOR VALIDATE ON SAVE
        IMPORTING keys FOR letocostcenter~validatedata,
      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE letocostcenter,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR letocostcenter RESULT result,
      precheck_cba_serviceparameter FOR PRECHECK
        IMPORTING entities FOR CREATE letocostcenter\_serviceparameter.
ENDCLASS.

CLASS lhc_/esrcc/i_lecctr IMPLEMENTATION.
*  METHOD validaterecordchanges.
*  DATA change TYPE REQUEST FOR CHANGE /esrcc/i_lecctr_s.
*  SELECT SINGLE transportrequestid FROM /esrcc/d_le_cc_s INTO @DATA(transportrequestid). "#EC CI_NOORDER
*    lhc_rap_tdat_cts=>get( )->validate_changes(
*                                transport_request = transportrequestid
*                                table             = '/ESRCC/LE_CCTR'
*                                keys              = REF #( keys )
*                                reported          = REF #( reported )
*                                failed            = REF #( failed )
*                                change            = REF #( change-letocostcenter ) ).
*  ENDMETHOD.

  METHOD validatedata.
    DATA:
      draft             TYPE STRUCTURE FOR READ RESULT /esrcc/i_lecctr_s\\letocostcenter,
      service_parameter TYPE STRUCTURE FOR READ RESULT /esrcc/i_lecctr_s\\serviceparameter.

    READ ENTITIES OF /esrcc/i_lecctr_s IN LOCAL MODE
         ENTITY letocostcenter
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(entities).

    SELECT lecctr~*
      FROM /esrcc/d_le_cctr AS lecctr
      INNER JOIN @keys AS key
        ON  key~sysid       = lecctr~sysid
        AND key~legalentity = lecctr~legalentity
        AND key~ccode       = lecctr~ccode
        AND key~costobject  = lecctr~costobject
        AND key~costcenter  = lecctr~costcenter
        AND key~validfrom   <> lecctr~validfrom
      WHERE lecctr~draftentityoperationcode NOT IN ( 'D', 'L' )
      INTO TABLE @DATA(draft_entries).

    SELECT share~*
      FROM /esrcc/d_srvprre AS share
      INNER JOIN @entities AS ent
        ON  ent~sysid       = share~sysid
        AND ent~legalentity = share~legalentity
        AND ent~ccode       = share~ccode
        AND ent~costobject  = share~costobject
        AND ent~costcenter  = share~costcenter
        AND ent~validfrom   = share~costcentervf
      WHERE share~draftentityoperationcode NOT IN ( 'D', 'L' )
      INTO TABLE @DATA(shares).

    DATA(lo_le_cctr) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'LeToCostCenterAll' ) )
        source_entity_name = '/ESRCC/C_LECCTR'
      CHANGING
        reported_entity    = reported-letocostcenter
        failed_entity      = failed-letocostcenter ).

    DATA(lo_service_parameter) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'LeToCostCenterAll' )
                                      ( path = 'LeToCostCenter' ) )
        source_entity_name = '/ESRCC/C_SERVICEPARAMETER'
      CHANGING
        reported_entity    = reported-serviceparameter
        failed_entity      = failed-serviceparameter ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_le_cctr ).
    lo_validation->calculate_costshare_sum(
      EXPORTING
        sharecost     = CORRESPONDING #( shares MAPPING costcenter_vf = costcentervf )
      IMPORTING
        sharecost_sum = DATA(sharecost_sum) ).

    LOOP AT entities INTO DATA(entity).
      lo_validation->validate_le_cctr( entity = entity control = VALUE #( validto = if_abap_behv=>mk-on stewardship = if_abap_behv=>mk-on ) ).

      LOOP AT sharecost_sum TRANSPORTING NO FIELDS WHERE sysid         = entity-sysid
                                                     AND legalentity   = entity-legalentity
                                                     AND ccode         = entity-ccode
                                                     AND costobject    = entity-costobject
                                                     AND costcenter    = entity-costcenter
                                                     AND costcenter_vf = entity-validfrom
                                                     AND costshare     <> 100.
        lo_le_cctr->set_state_message(
          entity     = entity
          msg        = new_message( id = /esrcc/cl_config_util=>c_config_msg number = '009' severity = if_abap_behv_message=>severity-error v1 = lo_le_cctr->get_field_text( fieldname = 'COSTSHARE' data_element = '/ESRCC/COSTSHARE' ) )
          state_area = CONV #( /esrcc/cl_config_util=>percentage )
        ).
        EXIT.
      ENDLOOP.

      " Validate overlapping date
      LOOP AT draft_entries ASSIGNING FIELD-SYMBOL(<draft>)
           WHERE     legalentity  = entity-legalentity
                 AND sysid        = entity-sysid
                 AND ccode        = entity-ccode
                 AND costobject   = entity-costobject
                 AND costcenter   = entity-costcenter
                 AND validfrom   <> entity-validfrom.
        draft = CORRESPONDING #( <draft> ).
        draft = CORRESPONDING #( BASE ( draft ) entity MAPPING %is_draft = %is_draft singletonid = singletonid EXCEPT * ).
        lo_le_cctr->validate_overlapping_validity( EXPORTING src_from    = <draft>-validfrom
                                                             src_to      = <draft>-validto
                                                             src_entity  = draft
                                                             curr_from   = entity-validfrom
                                                             curr_to     = entity-validto
                                                             curr_entity = entity ).
      ENDLOOP.

      " Validate validity of Service Cost Share
      LOOP AT shares INTO DATA(share) WHERE sysid        = entity-sysid
                                        AND legalentity  = entity-legalentity
                                        AND ccode        = entity-ccode
                                        AND costobject   = entity-costobject
                                        AND costcenter   = entity-costcenter
                                        AND costcentervf = entity-validfrom
                                        AND ( validfrom NOT BETWEEN entity-validfrom AND entity-validto
                                         OR   validto NOT BETWEEN entity-validfrom AND entity-validto ).
        service_parameter = CORRESPONDING #( share ).
        service_parameter = CORRESPONDING #( BASE ( service_parameter ) entity MAPPING %is_draft = %is_draft singletonid = singletonid EXCEPT * ).
        lo_service_parameter->set_state_message(
          entity     = service_parameter
          msg        = new_message( id = /esrcc/cl_config_util=>c_config_msg number = '013' severity = cl_abap_behv=>ms-error )
          state_area = CONV #( /esrcc/cl_config_util=>date_out_of_range )
        ).
      ENDLOOP.

      LOOP AT reported-serviceparameter ASSIGNING FIELD-SYMBOL(<path>) WHERE %path-letocostcenter IS NOT INITIAL.
        <path>-%path-letocostcenter-validfrom = entity-validfrom.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'LeToCostCenterAll' ) )
        source_entity_name = '/ESRCC/C_LECCTR'
      CHANGING
        reported_entity    = reported-letocostcenter
        failed_entity      = failed-letocostcenter ) ).

    LOOP AT entities INTO DATA(entity) WHERE %control-stewardship = if_abap_behv=>mk-on
                                          OR %control-validto     = if_abap_behv=>mk-on.
      lo_validation->validate_le_cctr(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( validto = entity-%control-validto stewardship = entity-%control-stewardship )
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.
    IF keys[ 1 ]-%is_draft = if_abap_behv=>mk-on.
      /esrcc/cl_config_util=>create_for_authorization( )->set_instance_authorization(
        EXPORTING
          keys            = keys
          update          = abap_true
          delete          = abap_true
          create_by_assoc = abap_true
          field_mapping   = VALUE #( legal_entity = 'LEGALENTITY' cost_object = 'COSTOBJECT' cost_number = 'COSTCENTER' )
          assoc_path      = VALUE #( ( path = '_ServiceParameter' ) ( path = '_ServiceReceiver' ) )
        CHANGING
          result          = result
      ).
    ENDIF.
  ENDMETHOD.

  METHOD precheck_cba_serviceparameter.
    TYPES ts_service_parameter TYPE STRUCTURE FOR READ RESULT /esrcc/i_lecctr_s\\serviceparameter.

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'LeToCostCenterAll' )
                                      ( path = 'LeToCostCenter' ) )
        source_entity_name = '/ESRCC/C_SERVICEPARAMETER'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported-serviceparameter
        failed_entity      = failed-serviceparameter ) ).

    LOOP AT entities[ 1 ]-%target INTO DATA(entity).
      lo_validation->validate_service_parameter(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( validfrom = if_abap_behv=>mk-on )
      ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_/esrcc/i_lecctr_s DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES: ts_reported TYPE RESPONSE FOR REPORTED EARLY /esrcc/i_lecctr_s.

    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR letocostcenterall
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR letocostcenterall
        RESULT result,
      precheck_cba_letocostcenter FOR PRECHECK
        IMPORTING entities FOR CREATE letocostcenterall\_letocostcenter,
      edit FOR MODIFY
        IMPORTING keys FOR ACTION letocostcenterall~edit.
ENDCLASS.

CLASS lhc_/esrcc/i_lecctr_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA: selecttransport_flag TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled,
          edit_flag            TYPE abp_behv_flag VALUE if_abap_behv=>fc-o-enabled.

    IF cl_bcfg_cd_reuse_api_factory=>get_cust_obj_service_instance(
        iv_objectname = '/ESRCC/LE_CCTR'
        iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    DATA(transport_service) = cl_bcfg_cd_reuse_api_factory=>get_transport_service_instance(
      iv_objectname = '/ESRCC/LE_CCTR'
      iv_objecttype = cl_bcfg_cd_reuse_api_factory=>simple_table ).
    IF transport_service->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    READ ENTITIES OF /esrcc/i_lecctr_s IN LOCAL MODE
    ENTITY letocostcenterall
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(all).
    IF all[ 1 ]-%is_draft = if_abap_behv=>mk-off.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result = VALUE #( (
               %tky = all[ 1 ]-%tky
               %action-edit = edit_flag
               %assoc-_letocostcenter = edit_flag ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD '/ESRCC/I_LECCTR' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%update      = is_authorized.
    result-%action-edit = is_authorized.
  ENDMETHOD.
  METHOD precheck_cba_letocostcenter.

    TYPES ts_le_cctr TYPE STRUCTURE FOR READ RESULT /esrcc/i_lecctr_s\\letocostcenter.

    DATA(lo_le_cctr) = /esrcc/cl_config_util=>create(
      EXPORTING
        paths              = VALUE #( ( path = 'LeToCostCenterAll' ) )
        source_entity_name = '/ESRCC/C_LECCTR'
        is_transition      = abap_true
      CHANGING
        reported_entity    = reported-letocostcenter
        failed_entity      = failed-letocostcenter
    ).

    DATA(lo_validation) = NEW lcl_custom_validation( config_util_ref = lo_le_cctr ).

    DATA(target) = entities[ 1 ]-%target.
    SELECT * FROM /esrcc/coscen
        FOR ALL ENTRIES IN @target
        WHERE sysid      = @target-sysid
          AND costobject = @target-costobject
          AND costcenter = @target-costcenter
        INTO TABLE @DATA(cost_centers).

    LOOP AT target INTO DATA(entity).
      CHECK lo_le_cctr->check_authorization(
        EXPORTING
          entity       = CORRESPONDING ts_le_cctr( entity )
          legal_entity = entity-legalentity
          cost_object  = entity-costobject
          cost_number  = entity-costcenter
          activity     = /esrcc/cl_config_util=>c_authorization_activity-create
      ) = abap_true.

      lo_validation->validate_le_cctr(
        entity  = CORRESPONDING #( entity )
        control = VALUE #( validfrom = if_abap_behv=>mk-on )
      ).

      " Validate System ID against Cost Number
      IF NOT line_exists( cost_centers[ sysid      = entity-sysid
                                        costobject = entity-costobject
                                        costcenter = entity-costcenter ] ).
        lo_le_cctr->set_state_message(
          entity     = CORRESPONDING ts_le_cctr( entity )
          msg        = new_message( id = /esrcc/cl_config_util=>c_config_msg
                                    number = '008'
                                    severity = cl_abap_behv=>ms-error
                                    v1 = lo_le_cctr->get_field_text( fieldname = 'COSTCENTER' data_element = '/ESRCC/COSTCENTER' )
                                    v2 = entity-costcenter
                                    v3 = entity-sysid )
          state_area = CONV #( /esrcc/cl_config_util=>invalid_data )
        ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD edit.
    DATA(lo_util) = /esrcc/cl_config_util=>create_for_authorization( ).
    SELECT DISTINCT legalentity FROM /esrcc/i_lecctr INTO TABLE @DATA(legal_entities).      "#EC CI_NOWHERE

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
      SELECT DISTINCT costobject, costcenter FROM /esrcc/i_lecctr INTO TABLE @DATA(cost_numbers).       "#EC CI_NOWHERE
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
      reported-letocostcenterall = VALUE #( ( %msg = new_message( id       = /esrcc/cl_config_util=>c_config_msg
                                                                  number   = '019'
                                                                  severity = if_abap_behv_message=>severity-success ) ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
CLASS lsc_/esrcc/i_lecctr_s DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION,
      cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_/esrcc/i_lecctr_s IMPLEMENTATION.
  METHOD save_modified.
    READ TABLE update-letocostcenterall INDEX 1 INTO DATA(all).
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
