CLASS /esrcc/cl_config_cost_element DEFINITION
  PUBLIC
  INHERITING FROM /esrcc/cl_config_util
  CREATE PRIVATE
  FINAL.

  PUBLIC SECTION.

    CLASS-METHODS create_sub_instance
      IMPORTING
        !paths              TYPE /esrcc/cl_config_util=>tt_path
        !source_entity_name TYPE sxco_cds_object_name
        !is_transition      TYPE abap_boolean OPTIONAL
      CHANGING
        !reported_entity    TYPE STANDARD TABLE
        !failed_entity      TYPE STANDARD TABLE
      RETURNING
        VALUE(instance)     TYPE REF TO /esrcc/cl_config_cost_element.

    METHODS validate_duplicate.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: gv_tab_name TYPE string VALUE '/ESRCC/CST_ELMNT'.

    METHODS constructor
      IMPORTING
        !paths              TYPE /esrcc/cl_config_util=>tt_path
        !source_entity_name TYPE sxco_cds_object_name
        !is_transition      TYPE abap_boolean.
ENDCLASS.



CLASS /ESRCC/CL_CONFIG_COST_ELEMENT IMPLEMENTATION.


  METHOD constructor.
    super->constructor(
      paths              = paths
      source_entity_name = source_entity_name
      is_transition      = is_transition
    ).
    gv_tab_name = '/ESRCC/CST_ELMNT'.
  ENDMETHOD.


  METHOD create_sub_instance.
    instance = NEW /esrcc/cl_config_cost_element(
      paths              = paths
      source_entity_name = source_entity_name
      is_transition      = is_transition
    ).
*    instance = NEW /esrcc/cl_config_cost_element(
*      paths              = paths
*      source_entity_name = source_entity_name
*      is_transition      = is_transition
*    ).

    instance->set_entity(
      CHANGING
        reported_entity = reported_entity
        failed_entity   = failed_entity
    ).
  ENDMETHOD.


  METHOD validate_duplicate.
*    DATA(metadata_tab) = get_db_metadata( ).
*
*    DATA(metadata) = VALUE #( metadata_tab[ tab_name = gv_tab_name ] OPTIONAL ).
*    IF metadata IS INITIAL.
*      RETURN.
*    ENDIF.
*
*    TYPES:
*      BEGIN OF ts_selection,
*        fields       TYPE string,
*        where_clause TYPE string,
*      END OF ts_selection.
*    DATA: selection TYPE ts_selection.
*
*    " Build Where Clause
*    LOOP AT metadata-field_metadata INTO DATA(field).
*      IF selection-where_clause IS INITIAL.
*        selection-where_clause = |{ field-fieldname } = @entities-{ field-cds_fieldname }|.
*      ELSE.
*        selection-where_clause = |{ selection-where_clause } AND { field-fieldname } = @entities-{ field-cds_fieldname }|.
*      ENDIF.
*
*      IF selection-fields IS INITIAL.
*        selection-fields = field-fieldname.
*      ELSE.
*        selection-fields = |{ selection-fields } AND { field-fieldname } = @entities-{ field-cds_fieldname }|.
*      ENDIF.
*    ENDLOOP.
*
**    DATA(where2) = REDUCE ts_selection(
**                        INIT select = VALUE ts_selection( )
**                        FOR field IN metadata-field_metadata INDEX INTO index
**                        NEXT select = VALUE #( fields       = COND #( WHEN index = 1 THEN field-fieldname
**                                                                      ELSE |{ select-fields }, { field-fieldname }| )
**                                               where_clause = COND #( WHEN index = 1 THEN |{ field-fieldname } = @entities-{ field-cds_fieldname }|
**                                                                      ELSE |{ select-where_clause } AND { field-fieldname } = @entities-{ field-cds_fieldname }| ) ) ).
***                        NEXT select-fields = COND #( WHEN clause IS INITIAL THEN |{ field-fieldname } = @entities-{ field-cds_fieldname }|
***                                                     ELSE |{ where_clause } AND { field-fieldname } = @entities-{ field-cds_fieldname }| ) )
*
*    SELECT * FROM /esrcc/cst_elmnt INTO TABLE @DATA(lt_elements).
*    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).
*    ENDLOOP.
**    SELECT ent~*
**      FROM @entities AS ent
**      INNER JOIN /esrcc/cst_elmnt AS db
**        ON  ent~sysid = db~sysid
**        AND ent~legalentity = db~legal_entity
**        AND ent~companycode = db~company_code
**        AND ent~costcenter = db~cost_center
***      FROM /esrcc/cst_elmnt
***      FOR ALL ENTRIES IN @entities
***      WHERE (selection-where_clause)
**      INTO TABLE @DATA(db_entries).
*    IF sy-subrc = 0.
*      super->validate_duplicate( entities = entities ).
*    ENDIF.
  ENDMETHOD.
ENDCLASS.
