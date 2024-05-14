CLASS LHC_/ESRCC/I_COSTELE_S DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      AUGMENT FOR MODIFY
        IMPORTING
          ENTITIES_CREATE FOR CREATE CostElementAll\_CostElement
          ENTITIES_UPDATE FOR UPDATE CostElement.
ENDCLASS.

CLASS LHC_/ESRCC/I_COSTELE_S IMPLEMENTATION.
  METHOD AUGMENT.
    DATA: text_for_new_entity      TYPE TABLE FOR CREATE /ESRCC/I_CostEle\_CostElementText,
          text_for_existing_entity TYPE TABLE FOR CREATE /ESRCC/I_CostEle\_CostElementText,
          text_update              TYPE TABLE FOR UPDATE /ESRCC/I_CostEleText.
    DATA: text_tky_link  TYPE STRUCTURE FOR READ LINK /ESRCC/I_CostEle\_CostElementText,
          text_tky       LIKE text_tky_link-target.

    READ TABLE entities_create INDEX 1 INTO DATA(entity).
    LOOP AT entity-%TARGET ASSIGNING FIELD-SYMBOL(<target>).
      INSERT VALUE #( %CID_REF = <target>-%CID
                      %IS_DRAFT = <target>-%IS_DRAFT
                      %KEY-Sysid = <target>-%KEY-Sysid
                        %KEY-Costelement = <target>-%KEY-Costelement
                      %TARGET = VALUE #( (
                        %CID = |CREATETEXTCID{ sy-tabix }|
                        %IS_DRAFT = <target>-%IS_DRAFT
                        Spras = sy-langu
                        Description = <target>-Description
                        %CONTROL-Spras = if_abap_behv=>mk-on
                        %CONTROL-Description = <target>-%CONTROL-Description ) ) )
                   INTO TABLE text_for_new_entity.
    ENDLOOP.
    MODIFY AUGMENTING ENTITIES OF /ESRCC/I_CostEle_S
      ENTITY CostElement
        CREATE BY \_CostElementText
        FROM text_for_new_entity.

    IF entities_update IS NOT INITIAL.
      READ ENTITIES OF /ESRCC/I_CostEle_S
        ENTITY CostElement BY \_CostElementText
          FROM CORRESPONDING #( entities_update )
          LINK DATA(link).
      LOOP AT entities_update INTO DATA(update) WHERE %CONTROL-Description = if_abap_behv=>mk-on.
        DATA(tabix) = sy-tabix.
        text_tky = CORRESPONDING #( update-%TKY ).
        text_tky-Spras = sy-langu.
        IF line_exists( link[ KEY draft source-%TKY  = CORRESPONDING #( update-%TKY )
                                        target-%TKY  = CORRESPONDING #( text_tky ) ] ).
          APPEND VALUE #( %TKY = text_tky
                          %CID_REF = update-%CID_REF
                          Description = update-Description
                          %CONTROL = VALUE #( Description = update-%CONTROL-Description )
          ) TO text_update.
        ELSEIF line_exists(  text_for_new_entity[ KEY cid %IS_DRAFT = update-%IS_DRAFT
                                                          %CID_REF  = update-%CID_REF ] ).
          APPEND VALUE #( %TKY = text_tky
                          %CID_REF = text_for_new_entity[ %IS_DRAFT = update-%IS_DRAFT
                          %CID_REF = update-%CID_REF ]-%TARGET[ 1 ]-%CID
                          Description = update-Description
                          %CONTROL = VALUE #( Description = update-%CONTROL-Description )
          ) TO text_update.
        ELSE.
          APPEND VALUE #( %TKY = CORRESPONDING #( update-%TKY )
                          %CID_REF = update-%CID_REF
                          %TARGET  = VALUE #( (
                            %CID = |UPDATETEXTCID{ tabix }|
                            Spras = sy-langu
                            %IS_DRAFT = text_tky-%IS_DRAFT
                            Description = update-Description
                            %CONTROL-Spras = if_abap_behv=>mk-on
                            %CONTROL-Description = update-%CONTROL-Description
                          ) )
          ) TO text_for_existing_entity.
        ENDIF.
      ENDLOOP.
      IF text_update IS NOT INITIAL.
        MODIFY AUGMENTING ENTITIES OF /ESRCC/I_CostEle_S
          ENTITY CostElementText
            UPDATE FROM text_update.
      ENDIF.
      IF text_for_existing_entity IS NOT INITIAL.
        MODIFY AUGMENTING ENTITIES OF /ESRCC/I_CostEle_S
          ENTITY CostElement
            CREATE BY \_CostElementText
            FROM text_for_existing_entity.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
