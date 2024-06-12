CLASS /esrcc/cl_application_logs DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /esrcc/if_application_logs.

    CLASS-METHODS:
      create_instance RETURNING VALUE(instance) TYPE REF TO /esrcc/if_application_logs,
      get_instance    RETURNING VALUE(instance) TYPE REF TO /esrcc/if_application_logs,

      reuse_instance IMPORTING log_header_id   TYPE sysuuid_c32
                     RETURNING VALUE(instance) TYPE REF TO /esrcc/if_application_logs.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF _log_model_type,
        header          TYPE /esrcc/log_hdr,
        items           TYPE STANDARD TABLE OF /esrcc/log_item WITH EMPTY KEY,
        invalid_records TYPE STANDARD TABLE OF /esrcc/inv_rcrds WITH EMPTY KEY,
      END OF _log_model_type.

    CLASS-METHODS:
      _generate_log_header RETURNING VALUE(log_header) TYPE _log_model_type-header.

    CLASS-DATA:
      _logger TYPE REF TO /esrcc/cl_application_logs,
      _logs   TYPE _log_model_type.
ENDCLASS.



CLASS /ESRCC/CL_APPLICATION_LOGS IMPLEMENTATION.


  METHOD /esrcc/if_application_logs~add_message.
    /esrcc/cl_utility_core=>get_utc_date_time_ts( IMPORTING time_stamp = FINAL(timestamp) ).
    TRY.
        READ TABLE _logs-items ASSIGNING FIELD-SYMBOL(<message>) WITH KEY message_id = log_message-message_id message_number = log_message-message_number
            message_type = log_message-message_type message_v1 = log_message-message_v1 message_v2 = log_message-message_v2 message_v3 = log_message-message_v3
            message_v4 = log_message-message_v4.
        IF sy-subrc NE 0.
          DATA(message) = VALUE /esrcc/log_item(
              BASE CORRESPONDING #( log_message EXCEPT log_uuid )
              log_uuid        = cl_system_uuid=>create_uuid_c32_static( )
              log_header_uuid = _logs-header-log_header_uuid
              created_at      = COND #( WHEN log_message-created_at IS INITIAL THEN timestamp ELSE log_message-created_at )  ).
          APPEND message TO _logs-items.
        ELSE.
          message = <message>.
        ENDIF.

*        IF message-is_parent = abap_true.
        leading_msg_uuid = message-log_uuid.
*        ENDIF.

        IF invalid_record IS NOT INITIAL.
          APPEND VALUE #(
              BASE CORRESPONDING #( invalid_record ) invalid_record_uuid = cl_system_uuid=>create_uuid_c32_static( )
               log_header_uuid = message-log_header_uuid log_uuid = message-log_uuid )
                  TO _logs-invalid_records.
        ENDIF.
      CATCH cx_uuid_error.
        " handle exception
    ENDTRY.
  ENDMETHOD.


  METHOD /esrcc/if_application_logs~add_messages.
    /esrcc/cl_utility_core=>get_utc_date_time_ts( IMPORTING time_stamp = FINAL(timestamp) ).
    TRY.
        APPEND LINES OF VALUE _log_model_type-items(
            FOR <msg> IN log_messages
            ( VALUE #(
                  BASE CORRESPONDING #( <msg> EXCEPT log_uuid log_header_uuid )
                  log_uuid        = cl_system_uuid=>create_uuid_c32_static( )
                  log_header_uuid = _logs-header-log_header_uuid
                  created_at      = COND #( WHEN <msg>-created_at IS INITIAL THEN timestamp ELSE <msg>-created_at ) ) ) ) TO _logs-items.
      CATCH cx_uuid_error.
        " handle exception
    ENDTRY.
  ENDMETHOD.


  METHOD /esrcc/if_application_logs~add_text_to_message.
*    DATA: lv_text_prev TYPE string,
*          lv_m         TYPE string,
*          lv_text      TYPE string,
*          lv_remainder TYPE i,
*          lv_lines     TYPE i,
*          lv_tabix     TYPE i.

    /esrcc/cl_utility_core=>get_utc_date_time_ts( IMPORTING time_stamp = FINAL(timestamp) ).
    TRY.

        IF strlen( log_message_text ) < 75.

          APPEND VALUE /esrcc/log_item(
              log_uuid        = cl_system_uuid=>create_uuid_c32_static( )
              log_header_uuid = _logs-header-log_header_uuid
              parent_log_uuid = log_parent_uuid
              message_id      = log_message_id
              message_number  = log_message_number
              message_type    = log_message_type
              message_v1      = log_message_text
              created_at      = timestamp ) TO _logs-items.
        ELSE.
*     Long Text
          DATA: texts TYPE string_table.
          CALL FUNCTION '/ESRCC/STRING_TO_TABLE'
            EXPORTING
              long_text           = log_message_text
              length_of_each_line = 38
            TABLES
              table_of_texts      = texts.
          DATA(number_of_lines) = lines( texts ).
          LOOP AT texts ASSIGNING FIELD-SYMBOL(<text>).
            DATA(table_index) = sy-tabix.

            DATA(remainder) = table_index MOD 2.
            IF remainder NE 0.
              DATA(previous_text) = <text>.

*         For Last line
              IF table_index = number_of_lines.
                APPEND VALUE /esrcc/log_item(
                   log_uuid        = cl_system_uuid=>create_uuid_c32_static( )
                   log_header_uuid = _logs-header-log_header_uuid
                   parent_log_uuid = log_parent_uuid
                   message_id      = log_message_id
                   message_number  = log_message_number
                   message_type    = log_message_type
                   message_v1      = <text>
                   created_at      = timestamp ) TO _logs-items.
              ENDIF.
            ELSE.
              APPEND VALUE /esrcc/log_item(
                 log_uuid        = cl_system_uuid=>create_uuid_c32_static( )
                 log_header_uuid = _logs-header-log_header_uuid
                 parent_log_uuid = log_parent_uuid
                 message_id      = log_message_id
                 message_number  = log_message_number
                 message_type    = log_message_type
                 message_v1      = previous_text
                 message_v2      = <text>
                 created_at      = timestamp ) TO _logs-items.
            ENDIF.
          ENDLOOP.
        ENDIF.
      CATCH cx_uuid_error.
        " handle exception
    ENDTRY.
*   New Code
  ENDMETHOD.


  METHOD /esrcc/if_application_logs~get_log_header_id.
    log_header_uuid = _logs-header-log_header_uuid.
  ENDMETHOD.


  METHOD /esrcc/if_application_logs~get_log_header_info.
    log_header = _logs-header.
  ENDMETHOD.


  METHOD /esrcc/if_application_logs~map_invalid_record_to_messages.
    IF invalid_record IS NOT INITIAL AND lines( message_ids ) > 0.
      TRY.
          APPEND LINES OF VALUE _log_model_type-invalid_records( FOR <message_id> IN message_ids
            ( VALUE #( BASE CORRESPONDING #( invalid_record ) invalid_record_uuid = cl_system_uuid=>create_uuid_c32_static( )
              log_header_uuid = _logs-header-log_header_uuid log_uuid = <message_id> ) ) ) TO _logs-invalid_records.
        CATCH cx_uuid_error.
          "handle exception
      ENDTRY.

    ENDIF.
  ENDMETHOD.


  METHOD /esrcc/if_application_logs~read_messages.
    messages = _logs-items.
  ENDMETHOD.


  METHOD /esrcc/if_application_logs~save_header.
    MODIFY /esrcc/log_hdr FROM @_logs-header.
    " Need to uncomment if LUW does not trigger implicit commits
    COMMIT WORK.
  ENDMETHOD.


  METHOD /esrcc/if_application_logs~save_header_and_messages.
    /esrcc/if_application_logs~save_header( ).
    /esrcc/if_application_logs~save_messages( ).
    " Need to uncomment if LUW does not trigger implicit commits
    COMMIT WORK.
  ENDMETHOD.


  METHOD /esrcc/if_application_logs~save_messages.
    MODIFY /esrcc/log_item FROM TABLE @_logs-items.
    MODIFY /esrcc/inv_rcrds FROM TABLE @_logs-invalid_records.
    " Need to uncomment if LUW does not trigger implicit commits
    COMMIT WORK.
  ENDMETHOD.


  METHOD /esrcc/if_application_logs~set_log_header_info.
    /esrcc/cl_utility_core=>get_utc_date_time_ts( IMPORTING time_stamp = FINAL(timestamp) ).
    _logs-header = VALUE #( BASE CORRESPONDING #( BASE ( _logs-header ) log_header EXCEPT log_header_uuid run_number )
            created_by = sy-uname created_at = timestamp ).
*    _logs-header = VALUE #( BASE CORRESPONDING #( log_header EXCEPT log_header_uuid run_number ) created_by = sy-uname ).
    IF _logs-header-run_number IS INITIAL.
      SELECT run_number FROM /esrcc/log_hdr WHERE application = @_logs-header-application
          AND sub_application = @_logs-header-sub_application AND reporting_year = @_logs-header-reporting_year
          AND period_from = @_logs-header-period_from AND period_to = @_logs-header-period_to
          AND planning_version = @_logs-header-planning_version AND legal_entity = @_logs-header-legal_entity
          AND system_id = @_logs-header-system_id AND company_code = @_logs-header-company_code
          ORDER BY run_number DESCENDING INTO TABLE @FINAL(run_numbers).
      " Generate run number
      _logs-header-run_number = COND #( WHEN sy-subrc = 0 THEN VALUE #( run_numbers[ 1 ]-run_number OPTIONAL ) + 1 ELSE 1 ).
    ENDIF.
    /esrcc/if_application_logs~save_header( ).
  ENDMETHOD.


  METHOD create_instance.
    _logger = NEW /esrcc/cl_application_logs( ).
    _logger->_logs-header = _generate_log_header( ).

    instance = _logger.
  ENDMETHOD.


  METHOD get_instance.
    IF _logger IS NOT BOUND.
      _logger = CAST #( create_instance( ) ).
    ENDIF.
    instance = _logger.
  ENDMETHOD.


  METHOD reuse_instance.
    _logger = NEW /esrcc/cl_application_logs( ).
    SELECT SINGLE * FROM /esrcc/log_hdr WHERE log_header_uuid = @log_header_id INTO @_logger->_logs-header.

    instance = _logger.
  ENDMETHOD.


  METHOD _generate_log_header.
    TRY.
        log_header-log_header_uuid = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_uuid_error.
        " handle exception
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
