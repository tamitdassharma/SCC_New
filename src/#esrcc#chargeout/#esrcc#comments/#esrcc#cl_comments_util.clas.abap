CLASS /esrcc/cl_comments_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS modify_comments
      IMPORTING
        !comments    TYPE /esrcc/comments
        !iv_comments TYPE /esrcc/comment.

    CLASS-METHODS read_comments
      IMPORTING
        !workflowid TYPE /esrcc/sww_wiid
      EXPORTING
        !commentext TYPE string
        !comments   TYPE /esrcc/tt_comment.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /ESRCC/CL_COMMENTS_UTIL IMPLEMENTATION.


  METHOD modify_comments.

    DATA _comments TYPE /esrcc/comments.

    MOVE-CORRESPONDING comments TO _comments.

    _comments-created_by = sy-uname.

    " Get timestamp value in the UTC format.
    GET TIME STAMP FIELD _comments-created_at.
    " Provide date and time interpreting the UTC timestamp for central use.

    _comments-wfcomment = xco_cp=>string( iv_comments
      )->as_xstring( xco_cp_character=>code_page->utf_8
      )->value.

    cl_uuid_factory=>create_system_uuid(
      RECEIVING
        generator = DATA(lo_uuid)
    ).

    TRY.
        _comments-id = lo_uuid->create_uuid_c32( ).
      CATCH cx_uuid_error.
    ENDTRY.

    MODIFY /esrcc/comments FROM @_comments.

  ENDMETHOD.


  METHOD read_comments.

    SELECT * FROM /esrcc/comments WHERE worfklow_id = @workflowid
                                  INTO CORRESPONDING FIELDS OF TABLE @comments.

    LOOP AT comments ASSIGNING FIELD-SYMBOL(<comment>).

      <comment>-wfcommenttext = xco_cp=>xstring( <comment>-wfcomment
        )->as_string( xco_cp_character=>code_page->utf_8 )->value.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
