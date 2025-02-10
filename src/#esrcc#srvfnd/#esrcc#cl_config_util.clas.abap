CLASS /esrcc/cl_config_util DEFINITION PUBLIC
  INHERITING FROM cl_abap_behv
*  CREATE PRIVATE .
  CREATE PROTECTED.

  PUBLIC SECTION.
    CONSTANTS c_config_msg TYPE symsgid VALUE '/ESRCC/CONFIG_MSG' ##NO_TEXT.

    CONSTANTS:
      BEGIN OF c_authorization_activity,
        create  TYPE activ_auth VALUE '01',
        change  TYPE activ_auth VALUE '02',
        display TYPE activ_auth VALUE '03',
        delete  TYPE activ_auth VALUE '06',
      END OF c_authorization_activity.

    TYPES:
      BEGIN OF ENUM validation_type,
        mandatory,
        non_mandatory,
        validity,
        overlapping_validity,
        overlapping_sequence,
        start_end_of_month,
        period,
        percentage,
        invalid_data,
        date_out_of_range,
        child_mandatory,
        child_non_mandatory,
        no_authorization,
        duplicate,
        not_exists,
      END OF ENUM validation_type,

      BEGIN OF ts_field,
        fieldname TYPE abp_field_name,
        fieldtext TYPE string,
      END OF ts_field,

      BEGIN OF ts_path,
        path TYPE string,
      END OF ts_path,

      BEGIN OF ts_field_mapping_auth,
        legal_entity TYPE abp_field_name,
        cost_object  TYPE abp_field_name,
        cost_number  TYPE abp_field_name,
      END OF ts_field_mapping_auth,

      BEGIN OF ts_uuid_16,
        uuid      TYPE sysuuid_x16,
        serv_con  TYPE abap_boolean,
        serv_cap  TYPE abap_boolean,
        alloc_key TYPE abap_boolean,
      END OF ts_uuid_16,

      BEGIN OF ts_operation,
        create TYPE abap_boolean,
        update TYPE abap_boolean,
        delete TYPE abap_boolean,
      END OF ts_operation,

      BEGIN OF ts_foreign_check,
        serv_consumption TYPE abap_boolean,
        serv_capacity    TYPE abap_boolean,
        alloc_key        TYPE abap_boolean,
      END OF ts_foreign_check,

      BEGIN OF ts_co_rule_config,
        chargeout_method     TYPE /esrcc/chargout,
        cost_version         TYPE abap_boolean,
        capacity_version     TYPE abap_boolean,
        consumption_version  TYPE abap_boolean,
        key_version          TYPE abap_boolean,
        uom                  TYPE abap_boolean,
        adhoc_allocation_key TYPE abap_boolean,
        weightage_tab        TYPE abap_boolean,
      END OF ts_co_rule_config,

      BEGIN OF ts_field_metadata,
        fieldname      TYPE abp_field_name,
        is_not_initial TYPE abap_boolean,
        is_virtual_key TYPE abap_boolean,
        cds_fieldname  TYPE abp_field_name,
      END OF ts_field_metadata,
      BEGIN OF ts_table_metadata,
        tab_name       TYPE string,
        class_name     TYPE string,
        field_metadata TYPE SORTED TABLE OF ts_field_metadata WITH UNIQUE KEY fieldname,
      END OF ts_table_metadata.

    TYPES:
      tt_fields         TYPE STANDARD TABLE OF ts_field,
      tt_path           TYPE STANDARD TABLE OF ts_path,
      tt_uuid_16        TYPE STANDARD TABLE OF ts_uuid_16 WITH EMPTY KEY,
      tt_co_rule_config TYPE STANDARD TABLE OF ts_co_rule_config WITH KEY chargeout_method,
      tt_table_metadata TYPE SORTED TABLE OF ts_table_metadata WITH UNIQUE KEY tab_name.

    CLASS-METHODS
      create
        IMPORTING paths              TYPE /esrcc/cl_config_util=>tt_path
                  source_entity_name TYPE sxco_cds_object_name
                  is_transition      TYPE abap_boolean OPTIONAL
        CHANGING  reported_entity    TYPE STANDARD TABLE
                  failed_entity      TYPE STANDARD TABLE
        RETURNING VALUE(instance)    TYPE REF TO /esrcc/cl_config_util.
    CLASS-METHODS
      create_for_authorization
        RETURNING VALUE(instance) TYPE REF TO /esrcc/cl_config_util.

    CLASS-METHODS get_db_metadata
      RETURNING
        VALUE(metadata) TYPE tt_table_metadata.

    CLASS-METHODS get_co_rule_config
      RETURNING
        VALUE(co_rule_config) TYPE tt_co_rule_config.

    METHODS validate_initial
      IMPORTING
        fields     TYPE tt_fields
        !entity    TYPE any
        message_no TYPE symsgno DEFAULT '001'.
    METHODS validate_non_mandatory
      IMPORTING
        fields  TYPE tt_fields
        !entity TYPE any.
    METHODS validate_validity
      IMPORTING
        !from   TYPE /esrcc/validfrom
        !to     TYPE /esrcc/validto
        !entity TYPE any.
    METHODS validate_overlapping_validity
      IMPORTING
        !src_from    TYPE /esrcc/validfrom
        !src_to      TYPE /esrcc/validto
        !src_entity  TYPE any
        !curr_from   TYPE /esrcc/validfrom
        !curr_to     TYPE /esrcc/validto
        !curr_entity TYPE any.
    METHODS validate_start_end_of_month
      IMPORTING
        !entity     TYPE any
      CHANGING
        !start_date TYPE /esrcc/validfrom
        !end_date   TYPE /esrcc/validto.
    METHODS validate_poper
      IMPORTING
        fields  TYPE tt_fields
        !entity TYPE any.
    METHODS validate_percentage
      IMPORTING
        fields  TYPE tt_fields
        !entity TYPE any.
    METHODS set_duplicate_error
      IMPORTING
        entity TYPE any.
    METHODS set_state_message
      IMPORTING
        fieldname  TYPE abp_field_name OPTIONAL
        entity     TYPE any
        msg        TYPE REF TO if_abap_behv_message
        state_area TYPE string.
    METHODS get_field_text
      IMPORTING
        fieldname    TYPE abp_field_name OPTIONAL
        data_element TYPE sxco_ad_object_name OPTIONAL
      RETURNING
        VALUE(text)  TYPE string.
    METHODS check_authorization
      IMPORTING
        entity               TYPE any
        legal_entity         TYPE /esrcc/legalentity OPTIONAL
        cost_object          TYPE /esrcc/costobject_de OPTIONAL
        cost_number          TYPE /esrcc/costcenter OPTIONAL
        activity             TYPE activ_auth
      RETURNING
        VALUE(is_authorized) TYPE abap_boolean.
    METHODS set_instance_authorization
      IMPORTING
        keys                 TYPE STANDARD TABLE
        create               TYPE abap_boolean OPTIONAL
        update               TYPE abap_boolean OPTIONAL
        delete               TYPE abap_boolean OPTIONAL
        create_by_assoc      TYPE abap_boolean OPTIONAL
        field_mapping        TYPE ts_field_mapping_auth
        assoc_path           TYPE tt_path OPTIONAL
      CHANGING
        result               TYPE STANDARD TABLE OPTIONAL
      RETURNING
        VALUE(is_authorized) TYPE abap_boolean.
    METHODS is_unauthorized
      IMPORTING
        legal_entity           TYPE /esrcc/legalentity OPTIONAL
        cost_object            TYPE /esrcc/costobject_de OPTIONAL
        cost_number            TYPE /esrcc/costcenter OPTIONAL
        create                 TYPE abap_boolean
        update                 TYPE abap_boolean
        delete                 TYPE abap_boolean
      RETURNING
        VALUE(is_unauthorized) TYPE abap_boolean.
    METHODS foreign_check_cost_object
      IMPORTING
        entities           TYPE STANDARD TABLE
        uuid_fieldname     TYPE abp_field_name
        cost_object_uuids  TYPE tt_uuid_16
        operation          TYPE ts_operation
        foreign_check      TYPE ts_foreign_check
      RETURNING
        VALUE(foreign_ref) TYPE abap_boolean.

  PROTECTED SECTION.
    METHODS constructor
      IMPORTING
        paths              TYPE /esrcc/cl_config_util=>tt_path OPTIONAL
        source_entity_name TYPE sxco_cds_object_name OPTIONAL
        is_transition      TYPE abap_boolean OPTIONAL.

    METHODS set_entity
      CHANGING
        reported_entity TYPE STANDARD TABLE
        failed_entity   TYPE STANDARD TABLE.

  PRIVATE SECTION.

    CONSTANTS c_singletonid TYPE abp_field_name VALUE 'SINGLETONID' ##NO_TEXT.

    TYPES:
      BEGIN OF ts_authorized_list,
        legal_entity TYPE /esrcc/legalentity,
        cost_object  TYPE /esrcc/costobject_de,
        cost_number  TYPE /esrcc/costcenter,
        create       TYPE if_abap_behv=>t_xflag,
        update       TYPE if_abap_behv=>t_xflag,
        delete       TYPE if_abap_behv=>t_xflag,
      END OF ts_authorized_list.

    DATA:
      gv_state_area         TYPE string,
      gv_source_entity_name TYPE sxco_cds_object_name,
      gv_data_element       TYPE sxco_ad_object_name,
      gv_is_transition      TYPE abap_boolean,
      gv_first              TYPE abap_boolean,
      gs_active_field       TYPE ts_field,
      gt_paths              TYPE tt_path,
      gt_fields             TYPE SORTED TABLE OF ts_field WITH NON-UNIQUE DEFAULT KEY,
      gt_authorized_list    TYPE SORTED TABLE OF ts_authorized_list WITH NON-UNIQUE DEFAULT KEY,
      go_abap_dictionary    TYPE REF TO /esrcc/cl_abap_dictionary.

    DATA:
      gr_reported TYPE REF TO data,
      gr_failed   TYPE REF TO data.

    METHODS set_message
      IMPORTING
        !entity TYPE any
        !msg    TYPE REF TO if_abap_behv_message.
    METHODS set_element_field_error
      CHANGING
        !reported TYPE any.
    METHODS extract_field_label
      IMPORTING
                fieldname    TYPE abp_field_name
                data_element TYPE sxco_ad_object_name
      RETURNING VALUE(text)  TYPE string.
    METHODS check_auth_legal_entity
      IMPORTING
        legal_entity         TYPE /esrcc/legalentity
        activity             TYPE activ_auth
      RETURNING
        VALUE(is_authorized) TYPE abap_boolean.
    METHODS check_auth_cost_object
      IMPORTING
        cost_object          TYPE /esrcc/costobject_de
        activity             TYPE activ_auth
      RETURNING
        VALUE(is_authorized) TYPE abap_boolean.
    METHODS check_auth_cost_number
      IMPORTING
        cost_object          TYPE /esrcc/costobject_de
        cost_number          TYPE /esrcc/costcenter
        activity             TYPE activ_auth
      RETURNING
        VALUE(is_authorized) TYPE abap_boolean.
    METHODS is_authorized
      IMPORTING
        legal_entity_flag    TYPE abap_boolean
        cost_object_flag     TYPE abap_boolean
        cost_number_flag     TYPE abap_boolean
        legal_entity         TYPE /esrcc/legalentity
        cost_object          TYPE /esrcc/costobject_de
        cost_number          TYPE /esrcc/costcenter
        activity             TYPE activ_auth
      RETURNING
        VALUE(is_authorized) TYPE if_abap_behv=>t_xflag.
ENDCLASS.



CLASS /ESRCC/CL_CONFIG_UTIL IMPLEMENTATION.


  METHOD extract_field_label.
    DATA(field) = VALUE ts_field( fieldname = fieldname
                                  fieldtext = go_abap_dictionary->derive_field_label(
                                                EXPORTING
                                                  iv_entity_name  = gv_source_entity_name
                                                  iv_data_element = data_element
                                                  iv_field_name   = fieldname
                                              ) ).

    text = field-fieldtext.

    INSERT field INTO TABLE gt_fields.
  ENDMETHOD.


  METHOD create.
    instance = NEW /esrcc/cl_config_util(
        paths              = paths
        source_entity_name = source_entity_name
        is_transition      = is_transition
    ).

    instance->set_entity(
      CHANGING
        reported_entity = reported_entity
        failed_entity   = failed_entity
    ).

*    instance->gt_paths = paths.
*    instance->gv_source_entity_name = source_entity_name.
*    instance->gv_is_transition = is_transition.
*    instance->gr_reported = REF #( reported_entity ).
*    instance->gr_failed = REF #( failed_entity ).
*    instance->go_abap_dictionary = NEW /esrcc/cl_abap_dictionary( ).
  ENDMETHOD.


  METHOD validate_percentage.
    gv_state_area = percentage.
    gv_first = abap_true.

    LOOP AT fields INTO gs_active_field.
      ASSIGN COMPONENT gs_active_field-fieldname OF STRUCTURE entity TO FIELD-SYMBOL(<value>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF <value> NOT BETWEEN 0 AND 100.
        gv_data_element = /esrcc/cl_abap_dictionary=>get_data_element_by_value( EXPORTING iv_value = <value> ).
        set_message(
          EXPORTING
            entity = entity
            msg    = NEW cl_abap_behv( )->new_message( id = c_config_msg number = '005' severity = cl_abap_behv=>ms-error v1 = get_field_text( ) ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD validate_start_end_of_month.
    gv_state_area = start_end_of_month.
    gv_first = abap_true.

    IF start_date IS NOT INITIAL AND start_date+6(2) <> '01'.
      gs_active_field-fieldname = 'VALIDFROM'.
      start_date+6(2) = '01'.

      gv_data_element = /esrcc/cl_abap_dictionary=>get_data_element_by_value( EXPORTING iv_value = start_date ).

      set_message(
        EXPORTING
          entity = entity
          msg    = NEW cl_abap_behv( )->new_message( id = c_config_msg number = '006' severity = cl_abap_behv=>ms-error v1 = get_field_text( ) ) ).
    ENDIF.

    IF end_date IS NOT INITIAL.
      DATA(lv_date) = /esrcc/cl_utility_core=>get_last_day_of_month( EXPORTING date = end_date ).
      IF end_date <> lv_date.
        gs_active_field-fieldname = 'VALIDTO'.
        end_date = lv_date.
        gv_data_element = /esrcc/cl_abap_dictionary=>get_data_element_by_value( EXPORTING iv_value = end_date ).

        set_message(
          EXPORTING
            entity = entity
            msg    = NEW cl_abap_behv( )->new_message( id = c_config_msg number = '007' severity = cl_abap_behv=>ms-error v1 = get_field_text( ) ) ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD set_element_field_error.
    IF gs_active_field-fieldname IS INITIAL OR gv_is_transition = abap_true.
      RETURN.
    ENDIF.

    ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-element OF STRUCTURE reported TO FIELD-SYMBOL(<elements>).
    IF sy-subrc = 0.
      ASSIGN COMPONENT gs_active_field-fieldname OF STRUCTURE <elements> TO FIELD-SYMBOL(<field>).
      IF sy-subrc = 0.
        <field> = if_abap_behv=>mk-on.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD validate_validity.
    gv_state_area = validity.
    gv_first = abap_true.

    IF from IS NOT INITIAL AND to IS NOT INITIAL AND from > to.
      gs_active_field-fieldname = 'VALIDTO'.
      set_message(
        EXPORTING
          entity = entity
          msg    = NEW cl_abap_behv( )->new_message( id = c_config_msg number = '002' severity = cl_abap_behv=>ms-error ) ).
    ENDIF.
  ENDMETHOD.


  METHOD set_state_message.
    gv_state_area = state_area.
    gv_first = abap_true.
    gs_active_field-fieldname = fieldname.

    set_message(
      entity = entity
      msg    = msg
    ).
  ENDMETHOD.


  METHOD set_message.
    FIELD-SYMBOLS:
      <reported_entities> TYPE STANDARD TABLE,
      <failed_entities>   TYPE STANDARD TABLE.

*   Set reported information with message
    ASSIGN gr_reported->* TO <reported_entities>.

    ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-tky OF STRUCTURE entity TO FIELD-SYMBOL(<tky>).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

*   Reset the state area
    IF gv_first = abap_true AND gv_is_transition = abap_false. " To be set only once
      APPEND INITIAL LINE TO <reported_entities> ASSIGNING FIELD-SYMBOL(<reported_entity>).
      ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-tky OF STRUCTURE <reported_entity> TO FIELD-SYMBOL(<tky_r>).
      IF sy-subrc = 0.
        <tky_r> = <tky>.
      ENDIF.

      ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-state_area OF STRUCTURE <reported_entity> TO FIELD-SYMBOL(<state_area>).
      IF sy-subrc = 0.
        <state_area> = gv_state_area.
      ENDIF.

      CLEAR gv_first.
    ENDIF.

    APPEND INITIAL LINE TO <reported_entities> ASSIGNING <reported_entity>.
    ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-tky OF STRUCTURE <reported_entity> TO <tky_r>.
    IF sy-subrc = 0.
      <tky_r> = <tky>.
    ENDIF.

    ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-msg OF STRUCTURE <reported_entity> TO FIELD-SYMBOL(<msg>).
    IF sy-subrc = 0.
      <msg> = msg.
    ENDIF.

    IF gv_is_transition = abap_false.
      ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-state_area OF STRUCTURE <reported_entity> TO <state_area>.
      IF sy-subrc = 0.
        <state_area> = gv_state_area.
      ENDIF.
    ENDIF.

    ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-path OF STRUCTURE <reported_entity> TO FIELD-SYMBOL(<path>).
    IF sy-subrc = 0.
      LOOP AT gt_paths INTO DATA(path).
        TRANSLATE path-path TO UPPER CASE.
        ASSIGN COMPONENT path-path OF STRUCTURE <path> TO FIELD-SYMBOL(<path_entity>).
        IF sy-subrc = 0.
          <path_entity> = CORRESPONDING #( entity ).

          ASSIGN COMPONENT c_singletonid OF STRUCTURE <path_entity> TO FIELD-SYMBOL(<singletonid>).
          IF sy-subrc = 0 AND <singletonid> IS INITIAL.
            ASSIGN COMPONENT c_singletonid OF STRUCTURE entity TO FIELD-SYMBOL(<singletonid_entity>).
            IF sy-subrc = 0.
              <singletonid> = <singletonid_entity>.
            ELSE.
              <singletonid> = 1.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    set_element_field_error( CHANGING reported = <reported_entity> ).

*   Set failed information
    ASSIGN gr_failed->* TO <failed_entities>.

    APPEND INITIAL LINE TO <failed_entities> ASSIGNING FIELD-SYMBOL(<failed>).
    ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-tky OF STRUCTURE <failed> TO FIELD-SYMBOL(<tky_f>).
    IF sy-subrc = 0.
      <tky_f> = <tky>.
    ENDIF.
  ENDMETHOD.


  METHOD check_authorization.
    DATA(msg_no) = SWITCH symsgno( activity WHEN c_authorization_activity-create THEN '016'
                                            WHEN c_authorization_activity-change THEN '017'
                                            WHEN c_authorization_activity-delete THEN '018' ).

    DATA(list) = VALUE #( gt_authorized_list[ legal_entity = legal_entity cost_object = cost_object cost_number = cost_number ] OPTIONAL ).
    IF list IS NOT INITIAL.
      DATA(authorized_status) = SWITCH #( activity WHEN c_authorization_activity-create THEN list-create
                                                   WHEN c_authorization_activity-change THEN list-update
                                                   WHEN c_authorization_activity-delete THEN list-delete ).
    ENDIF.

    IF legal_entity IS SUPPLIED.
      is_authorized = COND #( WHEN list IS INITIAL THEN check_auth_legal_entity( legal_entity = legal_entity activity = activity )
                                                   ELSE SWITCH #( authorized_status WHEN if_abap_behv=>auth-allowed THEN abap_true ELSE abap_false ) ).
      IF is_authorized = abap_false.
        DATA(v1) = |{ get_field_text( fieldname = 'LEGALENTITY' data_element = CONV #( /esrcc/cl_abap_dictionary=>get_data_element_by_value( EXPORTING iv_value = legal_entity ) ) ) }: { legal_entity }|.
      ENDIF.
    ELSE.
      is_authorized = abap_true.
    ENDIF.

    IF cost_object IS SUPPLIED AND is_authorized = abap_true.
      SELECT SINGLE text FROM /esrcc/i_costobjects WHERE costobject = @cost_object INTO @DATA(cost_object_desc).

      IF cost_number IS SUPPLIED.
        is_authorized = COND #( WHEN list IS INITIAL THEN check_auth_cost_number( cost_object = cost_object cost_number = cost_number activity = activity )
                                                     ELSE SWITCH #( authorized_status WHEN if_abap_behv=>auth-allowed THEN abap_true ELSE abap_false ) ).
        IF is_authorized = abap_false.
          v1 = |{ get_field_text( fieldname = 'COSTOBJECT' data_element = CONV #( /esrcc/cl_abap_dictionary=>get_data_element_by_value( EXPORTING iv_value = cost_object ) ) ) }: { cost_object_desc }, { get_field_text( fieldname = 'COSTCENTER'
                    data_element = CONV #( /esrcc/cl_abap_dictionary=>get_data_element_by_value( EXPORTING iv_value = cost_number ) ) ) }: { cost_number }|.
        ENDIF.
      ELSE.
        is_authorized = COND #( WHEN list IS INITIAL THEN check_auth_cost_object( cost_object = cost_object activity = activity )
                                                     ELSE SWITCH #( authorized_status WHEN if_abap_behv=>auth-allowed THEN abap_true ELSE abap_false ) ).
        IF is_authorized = abap_false.
          v1 = |{ get_field_text( fieldname = 'COSTOBJECT' data_element = CONV #( /esrcc/cl_abap_dictionary=>get_data_element_by_value( EXPORTING iv_value = cost_object ) ) ) }: { cost_object_desc }|.
        ENDIF.
      ENDIF.
    ENDIF.

    IF is_authorized = abap_false.
      gv_state_area = no_authorization.
      gv_first = abap_true.
      set_message(
        entity = entity
        msg    = new_message( id = c_config_msg number = msg_no severity = if_abap_behv_message=>severity-error v1 = v1 )
      ).
    ENDIF.

    IF list IS INITIAL.
      INSERT VALUE #( legal_entity = legal_entity
                      cost_object = cost_object
                      cost_number = cost_number
                      create = COND #( WHEN activity = c_authorization_activity-create THEN authorized_status )
                      update = COND #( WHEN activity = c_authorization_activity-change THEN authorized_status )
                      delete = COND #( WHEN activity = c_authorization_activity-delete THEN authorized_status ) ) INTO TABLE gt_authorized_list.
    ENDIF.
  ENDMETHOD.


  METHOD check_auth_cost_number.
    AUTHORITY-CHECK OBJECT '/ESRCC/CO'
    ID '/ESRCC/OBJ' FIELD cost_object
    ID '/ESRCC/CN'  FIELD cost_number
    ID 'ACTVT'      FIELD activity.
    is_authorized = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).
  ENDMETHOD.


  METHOD check_auth_cost_object.
    AUTHORITY-CHECK OBJECT '/ESRCC/CO'      ##AUTH_FLD_MISSING
    ID '/ESRCC/OBJ' FIELD cost_object
    ID 'ACTVT'      FIELD activity.
    is_authorized = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).
  ENDMETHOD.


  METHOD check_auth_legal_entity.
    AUTHORITY-CHECK OBJECT '/ESRCC/LE'
    ID '/ESRCC/LE' FIELD legal_entity
    ID 'ACTVT'     FIELD activity.
    is_authorized = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).
  ENDMETHOD.


  METHOD create_for_authorization.
    instance = NEW /esrcc/cl_config_util( ).
  ENDMETHOD.


  METHOD get_field_text.
    DATA(lv_fieldname) = COND #( WHEN fieldname IS NOT INITIAL THEN fieldname ELSE gs_active_field-fieldname ).

    text = COND #( WHEN gs_active_field-fieldtext IS NOT INITIAL THEN gs_active_field-fieldtext
                   ELSE VALUE #( gt_fields[ fieldname = lv_fieldname ]-fieldtext OPTIONAL ) ).

    IF text IS INITIAL.
      text = extract_field_label( fieldname = lv_fieldname data_element = COND #( WHEN data_element IS NOT INITIAL THEN data_element ELSE gv_data_element ) ).
    ENDIF.
  ENDMETHOD.


  METHOD is_authorized.
    is_authorized = SWITCH #( COND abap_boolean( WHEN ( legal_entity_flag = abap_true AND check_auth_legal_entity( legal_entity = legal_entity activity = activity ) = abap_true ) OR legal_entity_flag = abap_false
                                                 THEN COND #( WHEN cost_object_flag = abap_true AND cost_number_flag = abap_true
                                                                 THEN check_auth_cost_number( cost_object = cost_object cost_number = cost_number activity = activity )
                                                              WHEN cost_object_flag = abap_true AND cost_number_flag = abap_false
                                                                 THEN check_auth_cost_object( cost_object = cost_object activity = activity )
                                                              ELSE abap_true )
                                                  ELSE abap_false )
                              WHEN abap_true THEN if_abap_behv=>auth-allowed
                              ELSE if_abap_behv=>auth-unauthorized ).
  ENDMETHOD.


  METHOD is_unauthorized.
    DATA: lt_list TYPE STANDARD TABLE OF ts_authorized_list.

    lt_list = VALUE #( ( legal_entity = legal_entity cost_object = cost_object cost_number = cost_number ) ).

    DATA(is_authorized) = set_instance_authorization(
      EXPORTING
        keys          = lt_list
        create        = abap_true
        update        = abap_true
        delete        = abap_true
        field_mapping = VALUE #( legal_entity = COND #( WHEN legal_entity IS SUPPLIED THEN 'LEGAL_ENTITY' )
                                 cost_object  = COND #( WHEN cost_object  IS SUPPLIED THEN 'COST_OBJECT' )
                                 cost_number  = COND #( WHEN cost_number  IS SUPPLIED THEN 'COST_NUMBER' ) )
    ).

    is_unauthorized = SWITCH #( is_authorized WHEN abap_true THEN abap_false ELSE abap_true ).
  ENDMETHOD.


  METHOD set_instance_authorization.
    DATA:
      legal_entity TYPE /esrcc/legalentity,
      cost_object  TYPE /esrcc/costobject_de,
      cost_number  TYPE /esrcc/costcenter.

    IF create = abap_false AND update = abap_false AND delete = abap_false AND ( create_by_assoc = abap_false OR ( create_by_assoc = abap_true AND assoc_path IS INITIAL ) ).
      RETURN.
    ENDIF.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      ASSIGN COMPONENT field_mapping-legal_entity OF STRUCTURE <key> TO FIELD-SYMBOL(<legal_entity>).
      IF sy-subrc = 0.
        DATA(legal_entity_flag) = abap_true.
        legal_entity = <legal_entity>.
      ENDIF.

      ASSIGN COMPONENT field_mapping-cost_object OF STRUCTURE <key> TO FIELD-SYMBOL(<cost_object>).
      IF sy-subrc = 0.
        DATA(cost_object_flag) = abap_true.
        cost_object = <cost_object>.
      ENDIF.

      ASSIGN COMPONENT field_mapping-cost_number OF STRUCTURE <key> TO FIELD-SYMBOL(<cost_number>).
      IF sy-subrc = 0.
        DATA(cost_number_flag) = abap_true.
        cost_number = <cost_number>.
      ENDIF.

      IF legal_entity_flag = abap_false AND cost_object_flag = abap_false AND cost_number_flag = abap_false.
        RETURN.
      ENDIF.

      IF result IS SUPPLIED.
        APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<res>).

        ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-tky OF STRUCTURE <key> TO FIELD-SYMBOL(<tky>).
        IF sy-subrc = 0.
          ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-tky OF STRUCTURE <res> TO FIELD-SYMBOL(<tky_r>).
          IF sy-subrc = 0.
            <tky_r> = CORRESPONDING #( <tky> ).
          ENDIF.
        ENDIF.
      ENDIF.

      DATA(authorized) = VALUE #( gt_authorized_list[ legal_entity = legal_entity cost_object = cost_object cost_number = cost_number ] OPTIONAL ).
      IF authorized IS INITIAL.
        DATA(auth_check_not_performed) = abap_true.
        authorized = VALUE #( legal_entity = legal_entity cost_object = cost_object cost_number = cost_number ).
      ELSE.
        auth_check_not_performed = abap_false.
      ENDIF.

      IF create = abap_true OR create_by_assoc = abap_true.
        IF auth_check_not_performed = abap_true.
          authorized-create = is_authorized(
            EXPORTING
              legal_entity_flag = legal_entity_flag
              cost_object_flag  = cost_object_flag
              cost_number_flag  = cost_number_flag
              legal_entity      = legal_entity
              cost_object       = cost_object
              cost_number       = cost_number
              activity          = c_authorization_activity-create ).
        ENDIF.
        IF create = abap_true AND <res> IS ASSIGNED.
          ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-create OF STRUCTURE <res> TO FIELD-SYMBOL(<create>).
          IF sy-subrc = 0.
            <create> = authorized-create.
          ENDIF.
        ENDIF.

        IF create_by_assoc = abap_true AND <res> IS ASSIGNED.
          ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-assoc OF STRUCTURE <res> TO FIELD-SYMBOL(<assoc>).
          IF sy-subrc = 0.
            LOOP AT assoc_path INTO DATA(path).
              TRANSLATE path-path TO UPPER CASE.
              ASSIGN COMPONENT path-path OF STRUCTURE <assoc> TO FIELD-SYMBOL(<path>).
              IF sy-subrc = 0.
                <path> = authorized-create.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDIF.

      IF update = abap_true.
        IF auth_check_not_performed = abap_true.
          authorized-update = is_authorized(
            EXPORTING
              legal_entity_flag = legal_entity_flag
              cost_object_flag  = cost_object_flag
              cost_number_flag  = cost_number_flag
              legal_entity      = legal_entity
              cost_object       = cost_object
              cost_number       = cost_number
              activity          = c_authorization_activity-change ).
        ENDIF.

        IF <res> IS ASSIGNED.
          ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-update OF STRUCTURE <res> TO FIELD-SYMBOL(<update>).
          IF sy-subrc = 0.
            <update> = authorized-update.
          ENDIF.
        ENDIF.
      ENDIF.

      IF delete = abap_true.
        IF auth_check_not_performed = abap_true.
          authorized-delete = is_authorized(
            EXPORTING
              legal_entity_flag = legal_entity_flag
              cost_object_flag  = cost_object_flag
              cost_number_flag  = cost_number_flag
              legal_entity      = legal_entity
              cost_object       = cost_object
              cost_number       = cost_number
              activity          = c_authorization_activity-delete ).
        ENDIF.

        IF <res> IS ASSIGNED.
          ASSIGN COMPONENT cl_abap_behv=>co_techfield_name-delete OF STRUCTURE <res> TO FIELD-SYMBOL(<delete>).
          IF sy-subrc = 0.
            <delete> = authorized-delete.
          ENDIF.
        ENDIF.
      ENDIF.

      IF auth_check_not_performed = abap_true.
        INSERT authorized INTO TABLE gt_authorized_list.
      ENDIF.

      is_authorized = COND #( WHEN authorized-create = if_abap_behv=>auth-unauthorized OR authorized-update = if_abap_behv=>auth-unauthorized OR authorized-delete = if_abap_behv=>auth-unauthorized THEN abap_false ELSE abap_true ).

      CLEAR authorized.
    ENDLOOP.
  ENDMETHOD.


  METHOD validate_initial.
    gv_state_area = mandatory.
    gv_first = abap_true.

    LOOP AT fields INTO gs_active_field.
      ASSIGN COMPONENT gs_active_field-fieldname OF STRUCTURE entity TO FIELD-SYMBOL(<value>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF <value> IS INITIAL.
        gv_data_element = /esrcc/cl_abap_dictionary=>get_data_element_by_value( EXPORTING iv_value = <value> ).
        set_message(
          EXPORTING
            entity = entity
            msg    = NEW cl_abap_behv( )->new_message( id = c_config_msg number = message_no severity = cl_abap_behv=>ms-error v1 = get_field_text( ) ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD validate_non_mandatory.
    gv_state_area = non_mandatory.
    gv_first = abap_true.

    LOOP AT fields INTO gs_active_field.
      ASSIGN COMPONENT gs_active_field-fieldname OF STRUCTURE entity TO FIELD-SYMBOL(<value>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF <value> IS NOT INITIAL.
        gv_data_element = /esrcc/cl_abap_dictionary=>get_data_element_by_value( EXPORTING iv_value = <value> ).
        set_message(
          EXPORTING
            entity = entity
            msg    = NEW cl_abap_behv( )->new_message( id = c_config_msg number = '014' severity = cl_abap_behv=>ms-error v1 = get_field_text( ) ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD validate_overlapping_validity.
    gv_state_area = overlapping_validity.
    gv_first = abap_true.

    IF curr_from BETWEEN src_from AND src_to OR curr_to BETWEEN src_from AND src_to
    OR src_from BETWEEN curr_from AND curr_to OR src_to BETWEEN curr_from AND curr_to.
      DATA(msg) = NEW cl_abap_behv( )->new_message( id = c_config_msg number = '003' severity = cl_abap_behv=>ms-error ).

*     Entity 1
      set_message(
        EXPORTING
          entity = src_entity
          msg    = msg ).

*     Entity 2
      set_message(
        EXPORTING
          entity = curr_entity
          msg    = msg ).
    ENDIF.
  ENDMETHOD.


  METHOD validate_poper.
    gv_state_area = period.
    gv_first = abap_true.

    LOOP AT fields INTO gs_active_field.
      ASSIGN COMPONENT gs_active_field-fieldname OF STRUCTURE entity TO FIELD-SYMBOL(<value>).
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.

      IF <value> NOT BETWEEN '001' AND '012'.
        gv_data_element = /esrcc/cl_abap_dictionary=>get_data_element_by_value( EXPORTING iv_value = <value> ).
        set_message(
          EXPORTING
            entity = entity
            msg    = NEW cl_abap_behv( )->new_message( id = c_config_msg number = '004' severity = cl_abap_behv=>ms-error v1 = get_field_text( ) ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD constructor.
    super->constructor( ).
    gt_paths = paths.
    gv_source_entity_name = source_entity_name.
    gv_is_transition = is_transition.
    go_abap_dictionary = NEW /esrcc/cl_abap_dictionary( ).
  ENDMETHOD.


  METHOD foreign_check_cost_object.
*   If Cost Object is used in Service Consumption, Capacity or Allocation Key apps, the requested action is restricted.
    IF cost_object_uuids IS INITIAL OR operation IS INITIAL OR foreign_check IS INITIAL.
      RETURN.
    ENDIF.

    DATA(uuid_usage_tab) = cost_object_uuids.

    IF foreign_check-serv_consumption = abap_true.
      SELECT DISTINCT
            uuid~uuid,
            CASE WHEN srv_con~cost_object_uuid IS NOT NULL THEN @abap_true ELSE @abap_false END AS serv_con,
            serv_cap,
            alloc_key
        FROM @uuid_usage_tab AS uuid
        LEFT OUTER JOIN /esrcc/consumptn AS srv_con
            ON srv_con~cost_object_uuid = uuid~uuid
        INTO TABLE @uuid_usage_tab.
    ENDIF.

    IF foreign_check-serv_capacity = abap_true.
      SELECT DISTINCT
            uuid~uuid,
            serv_con,
            CASE WHEN srv_cap~cost_object_uuid IS NOT NULL THEN @abap_true ELSE @abap_false END AS serv_cap,
            alloc_key
        FROM @uuid_usage_tab AS uuid
        LEFT OUTER JOIN /esrcc/srv_cpcty AS srv_cap
            ON srv_cap~cost_object_uuid = uuid~uuid
        INTO TABLE @uuid_usage_tab.
    ENDIF.

    IF foreign_check-alloc_key = abap_true.
      SELECT DISTINCT
            uuid~uuid,
            serv_con,
            serv_cap,
            CASE WHEN ind_alloc~cost_object_uuid IS NOT NULL THEN @abap_true ELSE @abap_false END AS alloc_key
        FROM @uuid_usage_tab AS uuid
        LEFT OUTER JOIN /esrcc/indtalloc AS ind_alloc
            ON ind_alloc~cost_object_uuid = uuid~uuid
        INTO TABLE @uuid_usage_tab.
    ENDIF.

    IF NOT line_exists( uuid_usage_tab[ serv_con  = abap_true ] ) AND
       NOT line_exists( uuid_usage_tab[ serv_cap  = abap_true ] ) AND
       NOT line_exists( uuid_usage_tab[ alloc_key = abap_true ] ).
      RETURN.
    ENDIF.

    foreign_ref = abap_true.

    " Raise message
    gv_state_area = mandatory.
    gv_first = abap_true.
    gs_active_field-fieldname = uuid_fieldname.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).
      ASSIGN COMPONENT uuid_fieldname OF STRUCTURE <entity> TO FIELD-SYMBOL(<uuid>).
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.

      DATA(uuid_usage) = VALUE #( uuid_usage_tab[ uuid = <uuid> ] OPTIONAL ).
      IF uuid_usage-serv_con = abap_true.
        DATA(v1) = CONV symsgv( TEXT-001 ).
      ENDIF.

      IF uuid_usage-serv_cap = abap_true.
        v1 = COND #( WHEN v1 IS INITIAL THEN TEXT-002 ELSE |{ v1 }{ COND #( WHEN uuid_usage-alloc_key = abap_true THEN ',' ELSE ' &' ) } { TEXT-002 }| ).
      ENDIF.

      IF uuid_usage-alloc_key = abap_true.
        DATA(v2) = COND symsgv( WHEN v1 IS INITIAL THEN TEXT-003 ELSE |& { TEXT-003 }| ).
      ENDIF.

      IF v1 IS NOT INITIAL OR v2 IS NOT INITIAL.
        set_message(
            EXPORTING
              entity = <entity>
              msg    = NEW cl_abap_behv( )->new_message( id       = c_config_msg
                                                         number   = COND #( WHEN operation-update = abap_true THEN '022'
                                                                            WHEN operation-delete = abap_true THEN '021' )
                                                         severity = cl_abap_behv=>ms-error
                                                         v1       = v1
                                                         v2       = v2 ) ).
      ENDIF.

      CLEAR: v1, v2.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_co_rule_config.
    APPEND VALUE #( chargeout_method     = 'D'
                    cost_version         = abap_true
                    capacity_version     = abap_true
                    consumption_version  = abap_true
                    uom                  = abap_true
                    key_version          = abap_false
                    adhoc_allocation_key = abap_false
                    weightage_tab        = abap_false ) TO co_rule_config.

    APPEND VALUE #( chargeout_method     = 'I'
                    cost_version         = abap_true
                    capacity_version     = abap_false
                    consumption_version  = abap_false
                    uom                  = abap_false
                    key_version          = abap_true
                    adhoc_allocation_key = abap_false
                    weightage_tab        = abap_true ) TO co_rule_config.


    APPEND VALUE #( chargeout_method     = 'A'
                    cost_version         = abap_false
                    capacity_version     = abap_false
                    consumption_version  = abap_false
                    uom                  = abap_false
                    key_version          = abap_false
                    adhoc_allocation_key = abap_true
                    weightage_tab        = abap_false ) TO co_rule_config.
  ENDMETHOD.


  METHOD get_db_metadata.
    metadata = VALUE #(
        ( tab_name       = '/ESRCC/CST_ELMNT'
          class_name     = '/ESRCC/CL_CONFIG_COST_ELEMENT'
          field_metadata = VALUE #( ( fieldname      = 'SYSID'
                                      is_not_initial = abap_true
                                      is_virtual_key = abap_true
                                      cds_fieldname  = 'SYSID' )
                                    ( fieldname      = 'LEGAL_ENTITY'
                                      is_not_initial = abap_true
                                      is_virtual_key = abap_true
                                      cds_fieldname  = 'LEGALENTITY' )
                                    ( fieldname      = 'COMPANY_CODE'
                                      is_not_initial = abap_true
                                      is_virtual_key = abap_true
                                      cds_fieldname  = 'COMPANYCODE' )
                                    ( fieldname      = 'COST_ELEMENT'
                                      is_not_initial = abap_true
                                      is_virtual_key = abap_true
                                      cds_fieldname  = 'COSTELEMENT' ) ) )

*        ( tab_name       = '/ESRCC/CST_ELEMNT'
*          class_name     = '/ESRCC/CL_CONFIG_COST_ELEMENT'
*          field_metadata = VALUE #( ( fieldname      = 'SYSID'
*                                      is_not_initial = abap_true
*                                      is_virtual_key = abap_true
*                                      cds_fieldname  = 'SYSID' ) ) )
*
*        ( tab_name       = '/ESRCC/CST_ELEMNT'
*          class_name     = '/ESRCC/CL_CONFIG_COST_ELEMENT'
*          field_metadata = VALUE #( ( fieldname      = 'SYSID'
*                                      is_not_initial = abap_true
*                                      is_virtual_key = abap_true
*                                      cds_fieldname  = 'SYSID' ) ) )
*
*        ( tab_name       = '/ESRCC/CST_ELEMNT'
*          class_name     = '/ESRCC/CL_CONFIG_COST_ELEMENT'
*          field_metadata = VALUE #( ( fieldname      = 'SYSID'
*                                      is_not_initial = abap_true
*                                      is_virtual_key = abap_true
*                                      cds_fieldname  = 'SYSID' ) ) )
    ).
  ENDMETHOD.


  METHOD set_entity.
    me->gr_reported = REF #( reported_entity ).
    me->gr_failed = REF #( failed_entity ).
  ENDMETHOD.


  METHOD set_duplicate_error.
    set_state_message(
      entity     = entity
      msg        = new_message(
                         id       = /esrcc/cl_config_util=>c_config_msg
                         number   = '023'
                         severity = if_abap_behv_message=>severity-error
                       )
      state_area = CONV #( /esrcc/cl_config_util=>duplicate )
    ).
  ENDMETHOD.
ENDCLASS.
