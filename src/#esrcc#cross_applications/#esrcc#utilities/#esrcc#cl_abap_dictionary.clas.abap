CLASS /esrcc/cl_abap_dictionary DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS:
      constructor,

      derive_field_label
        IMPORTING
          iv_entity_name  TYPE sxco_cds_object_name OPTIONAL
          iv_data_element TYPE sxco_ad_object_name OPTIONAL
          iv_field_name   TYPE sxco_cds_field_name OPTIONAL
        RETURNING
          VALUE(rv_text)  TYPE string,

      read_metadata_extension_text
        IMPORTING
          iv_metadata_extension_name TYPE sxco_cds_object_name
          iv_field_name              TYPE sxco_cds_field_name
        RETURNING
          VALUE(rv_text)             TYPE string,

      read_data_definition_text
        IMPORTING
          iv_entity_name TYPE sxco_cds_object_name
          iv_field_name  TYPE sxco_cds_field_name
        RETURNING
          VALUE(rv_text) TYPE string,

      read_data_element_text
        IMPORTING
          iv_data_element TYPE sxco_ad_object_name
          iv_field_name   TYPE sxco_cds_field_name
        RETURNING
          VALUE(rv_text)  TYPE string.

    CLASS-METHODS:
      get_data_element_by_value
        IMPORTING
          iv_value               TYPE any
        RETURNING
          VALUE(rv_data_element) TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:
      go_language TYPE REF TO if_xco_language.
ENDCLASS.



CLASS /ESRCC/CL_ABAP_DICTIONARY IMPLEMENTATION.


  METHOD constructor.
    go_language = xco_cp=>language( sy-langu ).
  ENDMETHOD.


  METHOD derive_field_label.
    CHECK iv_field_name IS NOT INITIAL.

    rv_text = read_metadata_extension_text( iv_metadata_extension_name = iv_entity_name iv_field_name = iv_field_name ).

    IF rv_text IS INITIAL.
      rv_text = read_data_definition_text( iv_entity_name = iv_entity_name iv_field_name = iv_field_name ).
    ENDIF.

    IF rv_text IS INITIAL.
      rv_text = read_data_element_text( iv_data_element = iv_data_element iv_field_name = iv_field_name ).
    ENDIF.
  ENDMETHOD.


  METHOD get_data_element_by_value.
    rv_data_element = cl_abap_elemdescr=>describe_by_data( EXPORTING p_data = iv_value )->get_relative_name( ).
  ENDMETHOD.


  METHOD read_data_definition_text.
    CHECK iv_entity_name IS NOT INITIAL.

    TRY.
        DATA(lo_target) = xco_cp_i18n=>target->data_definition->field(
          iv_entity_name = iv_entity_name
          iv_field_name  = iv_field_name
        ).

        " Read the translation
        DATA(lo_translation) = lo_target->get_translation(
          io_language        = go_language
          it_text_attributes = VALUE #( ( xco_cp_data_definition=>text_attribute->field->endusertext_label ) )
        ).

        IF lo_translation->texts IS NOT INITIAL.
          rv_text = lo_translation->texts[ 1 ]->get_string_value( ).
        ENDIF.
      CATCH cx_root INTO DATA(lr_exp).
        " No text available in current language
    ENDTRY.
  ENDMETHOD.


  METHOD read_data_element_text.
    CHECK iv_data_element IS NOT INITIAL.

    DATA(lo_target) = xco_cp_i18n=>target->data_element->object( iv_data_element ).

    TRY.
        DATA(lo_translation) = lo_target->get_translation(
          io_language        = go_language
          it_text_attributes = VALUE #( ( xco_cp_data_element=>text_attribute->short_field_label )
                                        ( xco_cp_data_element=>text_attribute->medium_field_label )
                                        ( xco_cp_data_element=>text_attribute->long_field_label )
                                        ( xco_cp_data_element=>text_attribute->heading_field_label ) )
        ).

        LOOP AT lo_translation->texts INTO DATA(lo_text).
          CASE lo_text->attribute->value.
            WHEN xco_cp_data_element=>text_attribute->short_field_label->value.
              DATA(lv_short_text) = lo_text->get_string_value( ).
            WHEN xco_cp_data_element=>text_attribute->medium_field_label->value.
              DATA(lv_medium_text) = lo_text->get_string_value( ).
            WHEN xco_cp_data_element=>text_attribute->long_field_label->value.
              DATA(lv_long_text) = lo_text->get_string_value( ).
            WHEN xco_cp_data_element=>text_attribute->heading_field_label->value.
              DATA(lv_heading_text) = lo_text->get_string_value( ).
          ENDCASE.
        ENDLOOP.
      CATCH cx_root INTO DATA(lr_exp).
        " No text available in current language
    ENDTRY.

    rv_text = COND #( WHEN lv_medium_text  IS NOT INITIAL THEN lv_medium_text
                      WHEN lv_long_text    IS NOT INITIAL THEN lv_long_text
                      WHEN lv_short_text   IS NOT INITIAL THEN lv_short_text
                      WHEN lv_heading_text IS NOT INITIAL THEN lv_heading_text ).
  ENDMETHOD.


  METHOD read_metadata_extension_text.
    CHECK iv_metadata_extension_name IS NOT INITIAL.

    TRY.
        DATA(lo_target) = xco_cp_i18n=>target->metadata_extension->field(
          iv_metadata_extension_name = iv_metadata_extension_name
          iv_field_name              = iv_field_name
        ).

        " Read the text.
        DATA(lo_translation) = lo_target->get_translation(
          io_language        = go_language
          it_text_attributes = VALUE #( "( xco_cp_metadata_extension=>text_attribute->field->ui_lineitem_label( 1 ) )
                                        ( xco_cp_metadata_extension=>text_attribute->field->endusertext_label ) )
        ).

        IF lo_translation->texts IS NOT INITIAL.
          rv_text = lo_translation->texts[ 1 ]->get_string_value( ).
        ENDIF.
      CATCH cx_root INTO DATA(lr_exp).
        " No text available in current language
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
