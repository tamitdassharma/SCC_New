CLASS /esrcc/cl_c_executioncockpit DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS determine_costbase_status.
    METHODS determine_stewardship_status.
    METHODS determine_chargeout_status.
ENDCLASS.



CLASS /ESRCC/CL_C_EXECUTIONCOCKPIT IMPLEMENTATION.


  METHOD determine_chargeout_status.

  ENDMETHOD.


  METHOD determine_costbase_status.


  ENDMETHOD.


  METHOD determine_stewardship_status.

  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TRY.
**filter
        DATA(lv_sql_filter) = io_request->get_filter( )->get_as_sql_string( ).
        TRY.
            DATA(lt_filter) = io_request->get_filter( )->get_as_ranges( ).
          CATCH cx_rap_query_filter_no_range.
            "handle exception
        ENDTRY.

**parameters
*            DATA(lt_parameters) = io_request->get_parameters( ).
*            DATA(lv_next_year) =  CONV /dmo/end_date( cl_abap_context_info=>get_system_date( ) + 365 )  .
*            DATA(lv_par_filter) = | BEGIN_DATE >= '{ cl_abap_dyn_prg=>escape_quotes( VALUE #( lt_parameters[ parameter_name = 'P_START_DATE' ]-value
*                                                                                              DEFAULT cl_abap_context_info=>get_system_date( ) ) ) }'| &&
*                                  | AND | &&
*                                  | END_DATE <= '{ cl_abap_dyn_prg=>escape_quotes( VALUE #( lt_parameters[ parameter_name = 'P_END_DATE' ]-value
*                                                                                            DEFAULT lv_next_year ) ) }'| .
*            IF lv_sql_filter IS INITIAL.
*              lv_sql_filter = lv_par_filter.
*            ELSE.
*              lv_sql_filter = |( { lv_sql_filter } AND { lv_par_filter } )| .
*            ENDIF.
**search
        DATA(lv_search_string) = io_request->get_search_expression( ).
        DATA(lv_search_sql) = |DESCRIPTION LIKE '%{ cl_abap_dyn_prg=>escape_quotes( lv_search_string ) }%'|.

        IF lv_sql_filter IS INITIAL.
          lv_sql_filter = lv_search_sql.
        ELSE.
          lv_sql_filter = |( { lv_sql_filter } AND { lv_search_sql } )|.
        ENDIF.
**request data
*        IF io_request->is_data_requested( ) = abap_false.
***paging
        DATA(lv_offset) = io_request->get_paging( )->get_offset( ).
        DATA(lv_page_size) = io_request->get_paging( )->get_page_size( ).
        DATA(lv_max_rows) = COND #( WHEN lv_page_size = if_rap_query_paging=>page_size_unlimited
                                    THEN 0 ELSE lv_page_size ).

**sorting
        DATA(sort_elements) = io_request->get_sort_elements( ).
        DATA(lt_sort_criteria) = VALUE string_table( FOR sort_element IN sort_elements
                                                   ( sort_element-element_name && COND #( WHEN sort_element-descending = abap_true THEN ` descending`
                                                                                                                                   ELSE ` ascending` ) ) ).
        DATA(lv_sort_string)  = COND #( WHEN lt_sort_criteria IS INITIAL THEN `primary key`
                                                                         ELSE concat_lines_of( table = lt_sort_criteria sep = `, ` ) ).
**requested elements
        DATA(lt_req_elements) = io_request->get_requested_elements( ).
**aggregate
        DATA(lt_aggr_element) = io_request->get_aggregation( )->get_aggregated_elements( ).

        IF lt_aggr_element IS NOT INITIAL.
          LOOP AT lt_aggr_element ASSIGNING FIELD-SYMBOL(<fs_aggr_element>).
            DELETE lt_req_elements WHERE table_line = <fs_aggr_element>-result_element.
            DATA(lv_aggregation) = |{ <fs_aggr_element>-aggregation_method }( { <fs_aggr_element>-input_element } ) as { <fs_aggr_element>-result_element }|.
            APPEND lv_aggregation TO lt_req_elements.
          ENDLOOP.
        ENDIF.
        DATA(lv_req_elements)  = concat_lines_of( table = lt_req_elements sep = `, ` ).
****grouping
        DATA(lt_grouped_element) = io_request->get_aggregation( )->get_grouped_elements( ).
        DATA(lv_grouping) = concat_lines_of( table = lt_grouped_element sep = `, ` ).
*
***select data
        TYPES: BEGIN OF ty_legalentity_status,
                 sysid          TYPE /esrcc/sysid,
                 fplv           TYPE /esrcc/costdataset_de,
                 ryear          TYPE /esrcc/ryear,
                 legalentity    TYPE /esrcc/legalentity,
                 ccode          TYPE /esrcc/ccode_de,
                 finalizedcount TYPE /esrcc/numc,
                 totalcount     TYPE /esrcc/numc,
                 process        TYPE /esrcc/process,
               END OF ty_legalentity_status.

        TYPES: BEGIN OF ty_costcenter_status,
                 sysid          TYPE /esrcc/sysid,
                 fplv           TYPE /esrcc/costdataset_de,
                 ryear          TYPE /esrcc/ryear,
                 legalentity    TYPE /esrcc/legalentity,
                 ccode          TYPE /esrcc/ccode_de,
                 costcenter     TYPE /esrcc/costcenter,
                 costobject     TYPE /esrcc/costobject_de,
                 finalizedcount TYPE /esrcc/numc,
                 totalcount     TYPE /esrcc/numc,
                 process        TYPE /esrcc/process,
               END OF ty_costcenter_status.

        TYPES: BEGIN OF ty_service_share,
                 stewardship        TYPE /esrcc/stewardship,
                 legalentity        TYPE /esrcc/legalentity,
                 sysid              TYPE /esrcc/sysid,
                 ccode              TYPE /esrcc/ccode_de,
                 costobject         TYPE /esrcc/costobject_de,
                 costcenter         TYPE /esrcc/costcenter,
                 serviceproduct     TYPE /esrcc/srvproduct,
                 costshare          TYPE /esrcc/costshare,
                 sysiddescription   TYPE /esrcc/description,
                 legalentitydesc    TYPE /esrcc/description,
                 ccodedesc          TYPE /esrcc/description,
                 costobjectdesc     TYPE /esrcc/description,
                 costcenterdesc     TYPE /esrcc/description,
                 serviceproductdesc TYPE /esrcc/description,
               END OF ty_service_share.

        DATA lt_result TYPE STANDARD TABLE OF /esrcc/c_execution_cockpit.
        DATA ls_result TYPE /esrcc/c_execution_cockpit.
        DATA lt_legal_status TYPE STANDARD TABLE OF ty_legalentity_status.
        DATA lt_costcenter_status TYPE STANDARD TABLE OF ty_costcenter_status.
        DATA lt_service_share TYPE STANDARD TABLE OF ty_service_share.
        DATA lt_li TYPE TABLE OF /esrcc/cb_li.
        DATA _sysid           TYPE RANGE OF /esrcc/sysid.
        DATA _fplv            TYPE RANGE OF /esrcc/costdataset_de.
        DATA _ryear           TYPE RANGE OF /esrcc/ryear.
        DATA _poper           TYPE RANGE OF poper.
        DATA _legalentity     TYPE RANGE OF /esrcc/legalentity.
        DATA _ccode           TYPE RANGE OF /esrcc/ccode_de.
        DATA _costobject      TYPE RANGE OF /esrcc/costobject_de.
        DATA _costcenter      TYPE RANGE OF /esrcc/costcenter.
        DATA _serviceproduct  TYPE RANGE OF /esrcc/srvproduct.
        DATA _billingfreq     TYPE /esrcc/billfrequency.
        DATA _billingperiod   TYPE /esrcc/billperiod.
        DATA _validon         TYPE /esrcc/validfrom.
        DATA _action          TYPE /esrcc/actions.

*   filters
        LOOP AT lt_filter ASSIGNING FIELD-SYMBOL(<ls_filter>).

          CASE <ls_filter>-name.

            WHEN 'SYSID'.
              _sysid = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'FPLV'.
              _fplv = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'RYEAR'.
              _ryear = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'POPER'.
              _poper = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'LEGALENTITY'.
              _legalentity = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'CCODE'.
              _ccode = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'COSTOBJECT'.
              _costobject = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'COSTCENTER'.
              _costcenter = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'BILLINGFREQ'.
              _billingfreq = <ls_filter>-range[ 1 ]-low.
            WHEN 'BILLINGPERIOD'.
              _billingperiod = <ls_filter>-range[ 1 ]-low.
            WHEN 'SERVICEPRODUCT'.
              _serviceproduct = CORRESPONDING #( <ls_filter>-range ).
            WHEN 'ACTION'.
              _action = <ls_filter>-range[ 1 ]-low.
            WHEN OTHERS.
          ENDCASE.

        ENDLOOP.

*Derive poper from billing frequency customizing
        SELECT 'I'  AS sign,
              'EQ'  AS option,
              poper AS low
              FROM /esrcc/billfreq
              WHERE billingfreq = @_billingfreq
                AND billingvalue = @_billingperiod
              ORDER BY low ASCENDING
              INTO CORRESPONDING FIELDS OF TABLE @_poper.

* get master data
        DATA(lv_year) = _ryear[ 1 ]-low.

        LOOP AT _poper ASSIGNING FIELD-SYMBOL(<ls_poper>).
          CONCATENATE lv_year <ls_poper>-low+1(2) '01' INTO _validon.

*         Read Cost Share
          SELECT *
          FROM  /esrcc/c_serviceparameter AS srv INNER JOIN
               /esrcc/c_coscen AS coscen
            ON coscen~costobject = srv~costobject
           AND coscen~costcenter = srv~costcenter
              INNER JOIN /esrcc/c_leccode AS leccode
              ON leccode~active = @abap_true
              AND leccode~legalentity = srv~legalentity
              AND leccode~ccode = srv~ccode
         WHERE srv~legalentity IN @_legalentity
           AND srv~sysid IN @_sysid
           AND srv~ccode IN @_ccode
           AND srv~costobject IN @_costobject
           AND srv~costcenter IN @_costcenter
           AND srv~serviceproduct IN @_serviceproduct
           AND coscen~billfrequency = @_billingfreq
           AND validfrom <= @_validon
           AND validto >= @_validon
           APPENDING CORRESPONDING FIELDS OF TABLE @lt_service_share.

          "  TK01+
          " lt_service_share is used as for all entries in all the below selects
          " therefore an initial check is required.
          IF lines( lt_service_share ) = 0.
            CONTINUE.
          ENDIF.
          "  TK01+

          SELECT *
            FROM /esrcc/c_lecctr AS lecctr INNER JOIN
                 /esrcc/c_coscen AS coscen
              ON coscen~costobject = lecctr~costobject
             AND coscen~costcenter = lecctr~costcenter
                 INNER JOIN /esrcc/c_leccode AS leccode
              ON leccode~active = @abap_true
              AND leccode~legalentity = lecctr~legalentity
              AND leccode~ccode = lecctr~ccode
           FOR ALL ENTRIES IN @lt_service_share
           WHERE lecctr~legalentity = @lt_service_share-legalentity
             AND lecctr~sysid = @lt_service_share-sysid
             AND lecctr~ccode = @lt_service_share-ccode
             AND lecctr~costobject = @lt_service_share-costobject
             AND lecctr~costcenter = @lt_service_share-costcenter
             AND coscen~billfrequency = @_billingfreq
             AND lecctr~validfrom <= @_validon
             AND lecctr~validto >= @_validon
             APPENDING CORRESPONDING FIELDS OF TABLE @lt_service_share.




          SELECT * FROM  /esrcc/srvmkp FOR ALL ENTRIES IN @lt_service_share
                                        WHERE serviceproduct = @lt_service_share-serviceproduct
                                         AND serviceproduct IS NOT INITIAL
                                         AND validfrom <= @_validon
                                         AND validto >= @_validon
                                         APPENDING TABLE @DATA(lt_srv_markup).

          SELECT * FROM  /esrcc/srvaloc FOR ALL ENTRIES IN @lt_service_share
                                        WHERE serviceproduct = @lt_service_share-serviceproduct
                                         AND cost_version IN @_fplv
                                         AND validfrom <= @_validon
                                         AND validto >= @_validon
                                         APPENDING TABLE @DATA(lt_srv_alloc).


        ENDLOOP.

        SORT lt_service_share BY sysid legalentity ccode costobject costcenter serviceproduct.
        DELETE ADJACENT DUPLICATES FROM lt_service_share COMPARING sysid legalentity ccode costobject costcenter serviceproduct.

        SORT lt_srv_markup BY serviceproduct.
        DELETE ADJACENT DUPLICATES FROM lt_srv_markup COMPARING serviceproduct.

        SORT lt_srv_alloc BY serviceproduct.
        DELETE ADJACENT DUPLICATES FROM lt_srv_alloc COMPARING serviceproduct.

        IF lt_srv_alloc IS NOT INITIAL.

          SELECT * FROM  /esrcc/alloc_wgt FOR ALL ENTRIES IN @lt_srv_alloc
                                          WHERE serviceproduct = @lt_srv_alloc-serviceproduct
                                           AND cost_version = @lt_srv_alloc-cost_version
                                           AND validfrom_alloc = @lt_srv_alloc-validfrom
                                           APPENDING TABLE @DATA(lt_srv_allocwght).
        ENDIF.

        IF lt_service_share IS NOT INITIAL.

          SELECT * FROM  /esrcc/srv_pr_le FOR ALL ENTRIES IN @lt_service_share
                                           WHERE sysid = @lt_service_share-sysid
                                            AND legalentity = @lt_service_share-legalentity
                                            AND ccode = @lt_service_share-ccode
                                            AND costobject = @lt_service_share-costobject
                                            AND costcenter = @lt_service_share-costcenter
                                            AND serviceproduct = @lt_service_share-serviceproduct
                                            AND active = @abap_true
                                            APPENDING TABLE @DATA(lt_srv_receivers).



          SELECT * FROM /esrcc/le FOR ALL ENTRIES IN @lt_service_share
                                     WHERE legalentity = @lt_service_share-legalentity INTO TABLE @DATA(lt_legalentity).

        ENDIF.

        CLEAR: _legalentity, _ccode, _costobject, _costcenter, _serviceproduct.

        LOOP AT lt_service_share ASSIGNING FIELD-SYMBOL(<ls_service_share>).

          READ TABLE lt_legalentity ASSIGNING FIELD-SYMBOL(<ls_legalentity>)
                                                  WITH KEY legalentity = <ls_service_share>-legalentity.
          IF sy-subrc = 0.
            DATA(lv_country) = <ls_legalentity>-country.
          ENDIF.
* legal entity
          READ TABLE lt_result TRANSPORTING NO FIELDS WITH KEY legalentity = <ls_service_share>-legalentity
                                                                    ccode  = <ls_service_share>-ccode.
          IF sy-subrc <> 0.
            CLEAR ls_result.
            ls_result-sysid = <ls_service_share>-sysid.
            ls_result-fplv = _fplv[ 1 ]-low.
            ls_result-ryear = lv_year.
            ls_result-legalentity = <ls_service_share>-legalentity.
            ls_result-ccode = <ls_service_share>-ccode.
            ls_result-billingfreq = _billingfreq.
            ls_result-billingperiod = _billingperiod.
            ls_result-legalentitydescription = <ls_service_share>-legalentitydesc.
            ls_result-ccodedescription = <ls_service_share>-ccodedesc.
            ls_result-legalcountry = lv_country.
            ls_result-hierarchylevel = 0.
            CONCATENATE <ls_service_share>-legalentity <ls_service_share>-ccode INTO ls_result-nodeid.
            APPEND ls_result TO lt_result.

          ENDIF.

          READ TABLE lt_result TRANSPORTING NO FIELDS WITH KEY legalentity = <ls_service_share>-legalentity
                                                                    ccode  = <ls_service_share>-ccode
                                                                    costobject = <ls_service_share>-costobject
                                                                    costcenter = <ls_service_share>-costcenter.
          IF sy-subrc <> 0 AND <ls_service_share>-serviceproduct IS INITIAL.
*  cost center
            CLEAR ls_result.
            ls_result-sysid = <ls_service_share>-sysid.
            ls_result-fplv = _fplv[ 1 ]-low.
            ls_result-ryear = lv_year.
            ls_result-legalentity = <ls_service_share>-legalentity.
            ls_result-ccode = <ls_service_share>-ccode.
            ls_result-costobject = <ls_service_share>-costobject.
            ls_result-costcenter = <ls_service_share>-costcenter.
            ls_result-billingfreq = _billingfreq.
            ls_result-billingperiod = _billingperiod.
            ls_result-legalentitydescription = <ls_service_share>-legalentitydesc.
            ls_result-ccodedescription = <ls_service_share>-ccodedesc.
            ls_result-costobjectdescription = <ls_service_share>-costobjectdesc.
            ls_result-costcenterdescription = <ls_service_share>-costcenterdesc.
            ls_result-legalcountry = lv_country.
            ls_result-hierarchylevel = 1.
            CONCATENATE <ls_service_share>-legalentity <ls_service_share>-ccode <ls_service_share>-costobject <ls_service_share>-costcenter INTO ls_result-nodeid.
            CONCATENATE <ls_service_share>-legalentity <ls_service_share>-ccode INTO ls_result-parentnodeid.
            APPEND ls_result TO lt_result.

          ENDIF.

          IF <ls_service_share>-serviceproduct IS NOT INITIAL.
*    service product
            CLEAR ls_result.
            ls_result-sysid = <ls_service_share>-sysid.
            ls_result-fplv = _fplv[ 1 ]-low.
            ls_result-ryear = lv_year.
            ls_result-legalentity = <ls_service_share>-legalentity.
            ls_result-ccode = <ls_service_share>-ccode.
            ls_result-costobject = <ls_service_share>-costobject.
            ls_result-costcenter = <ls_service_share>-costcenter.
            ls_result-serviceproduct = <ls_service_share>-serviceproduct.
            ls_result-billingfreq = _billingfreq.
            ls_result-billingperiod = _billingperiod.
            ls_result-legalentitydescription = <ls_service_share>-legalentitydesc.
            ls_result-ccodedescription = <ls_service_share>-ccodedesc.
            ls_result-costobjectdescription = <ls_service_share>-costobjectdesc.
            ls_result-costcenterdescription = <ls_service_share>-costcenterdesc.
            ls_result-serviceproductdescr = <ls_service_share>-serviceproductdesc.
            ls_result-legalcountry = lv_country.
            ls_result-hierarchylevel = 2.
            CONCATENATE <ls_service_share>-legalentity <ls_service_share>-ccode <ls_service_share>-costobject <ls_service_share>-costcenter <ls_service_share>-serviceproduct INTO ls_result-nodeid.
            CONCATENATE <ls_service_share>-legalentity <ls_service_share>-ccode <ls_service_share>-costobject <ls_service_share>-costcenter INTO ls_result-parentnodeid.
            APPEND ls_result TO lt_result.
          ENDIF.

          APPEND VALUE #( sign = 'I' option = 'EQ' low = <ls_service_share>-legalentity ) TO _legalentity.
          APPEND VALUE #( sign = 'I' option = 'EQ' low = <ls_service_share>-ccode ) TO _ccode.
          APPEND VALUE #( sign = 'I' option = 'EQ' low = <ls_service_share>-costobject ) TO _costobject.
          APPEND VALUE #( sign = 'I' option = 'EQ' low = <ls_service_share>-costcenter ) TO _costcenter.
          APPEND VALUE #( sign = 'I' option = 'EQ' low = <ls_service_share>-serviceproduct ) TO _serviceproduct.
          CLEAR: lv_country.

        ENDLOOP.

* Determine Status-----------------------------------------------------------
        SELECT * FROM /esrcc/procctrl
                      WHERE fplv IN @_fplv
                        AND ryear IN @_ryear
                        AND legalentity IN @_legalentity
                        AND ccode IN @_ccode
                        AND costobject IN @_costobject
                        AND costcenter IN @_costcenter
                        AND billingfreq = @_billingfreq
                        AND billingperiod = @_billingperiod
                        ORDER BY legalentity, ccode, costobject, costcenter, billingfreq, billingperiod, process, serviceproduct
                        INTO TABLE @DATA(lt_procctrl).

*Read line items for cost base status
        SELECT fplv,
              ryear,
              sysid,
              legalentity,
              ccode,
              costobject,
              costcenter,
              status,
              SUM( hsl ) AS totalcost ,
              localcurr
              FROM /esrcc/cb_li
              WHERE ryear IN @_ryear
                AND fplv  IN @_fplv
                AND poper IN @_poper
                AND legalentity IN @_legalentity
                AND ccode IN @_ccode
                AND costobject IN @_costobject
                AND costcenter IN @_costcenter
              GROUP BY
              fplv,
              ryear,
              sysid,
              legalentity,
              ccode,
              costobject,
              costcenter,
              status,
              localcurr APPENDING CORRESPONDING FIELDS OF TABLE @lt_li.


*   Read costbase & stewardship status
        SELECT  ryear,
                fplv,
                sysid,
                poper,
                legalentity,
                ccode,
                costobject,
                costcenter,
                billfrequency,
                billingperiod,
                status
                FROM /esrcc/cc_cost
                WHERE ryear IN @_ryear
                  AND fplv  IN @_fplv
                  AND sysid IN @_sysid
                  AND poper IN @_poper
                  AND legalentity IN @_legalentity
                  AND ccode IN @_ccode
                  AND costobject IN @_costobject
                  AND costcenter IN @_costcenter
               INTO TABLE @DATA(lt_cc_cost).

*   Read service cost share & markup status
        IF lt_cc_cost IS NOT INITIAL.
          SELECT  ryear,
                  fplv,
                  sysid,
                  poper,
                  legalentity,
                  ccode,
                  costobject,
                  costcenter,
                  serviceproduct,
                  status
                  FROM /esrcc/srv_cost
                  FOR ALL ENTRIES IN @lt_cc_cost
                  WHERE ryear = @lt_cc_cost-ryear
                    AND fplv  = @lt_cc_cost-fplv
                    AND sysid = @lt_cc_cost-sysid
                    AND poper = @lt_cc_cost-poper
                    AND sysid = @lt_cc_cost-sysid
                    AND legalentity = @lt_cc_cost-legalentity
                    AND ccode = @lt_cc_cost-ccode
                    AND costobject = @lt_cc_cost-costobject
                    AND costcenter = @lt_cc_cost-costcenter
                    AND serviceproduct IN @_serviceproduct
                 INTO TABLE @DATA(lt_srv_cost).

*   Read receiver status
          SELECT  ryear,
                  fplv,
                  sysid,
                  poper,
                  legalentity,
                  ccode,
                  costobject,
                  costcenter,
                  serviceproduct,
                  receivingentity,
                  status
                  FROM /esrcc/rec_cost
                  FOR ALL ENTRIES IN @lt_cc_cost
                  WHERE ryear = @lt_cc_cost-ryear
                    AND fplv  = @lt_cc_cost-fplv
                    AND sysid = @lt_cc_cost-sysid
                    AND poper = @lt_cc_cost-poper
                    AND sysid = @lt_cc_cost-sysid
                    AND legalentity = @lt_cc_cost-legalentity
                    AND ccode = @lt_cc_cost-ccode
                    AND costobject = @lt_cc_cost-costobject
                    AND costcenter = @lt_cc_cost-costcenter
                    AND serviceproduct IN @_serviceproduct
                 INTO TABLE @DATA(lt_rec_cost).


          SORT lt_cc_cost BY legalentity ccode costobject costcenter status.
          SORT lt_srv_cost BY legalentity ccode costobject costcenter serviceproduct status.
          SORT lt_rec_cost BY legalentity ccode costobject costcenter serviceproduct status.
        ENDIF.

*  Read status text
        SELECT st~application, st~status, st~color, description
        FROM /esrcc/exec_st AS st
        INNER JOIN /esrcc/execst_t AS tx
        ON st~application = tx~application
        AND st~status = tx~status
        AND tx~spras = @sy-langu
       INTO TABLE @DATA(lt_processstatus).

*Mapping Status to outupt
        LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<ls_result>).

*  Costbase status----------------------------------------------------
          IF <ls_result>-costbase_status IS INITIAL AND <ls_result>-costcenter IS NOT INITIAL AND <ls_result>-serviceproduct IS INITIAL.

            <ls_result>-costbase_status = '01'.   "Line Items not Available
            READ TABLE lt_procctrl ASSIGNING FIELD-SYMBOL(<ls_procctrl>) WITH KEY  sysid       = <ls_result>-sysid
                                                                                   ryear       = <ls_result>-ryear
                                                                                   fplv        = <ls_result>-fplv
                                                                                   legalentity = <ls_result>-legalentity
                                                                                   ccode      = <ls_result>-ccode
                                                                                   costobject = <ls_result>-costobject
                                                                                   costcenter = <ls_result>-costcenter
                                                                                   billingfreq = <ls_result>-billingfreq
                                                                                   billingperiod = <ls_result>-billingperiod
                                                                                   process    = 'CBS' BINARY SEARCH.
            IF sy-subrc = 0.
              <ls_result>-costbase_status = <ls_procctrl>-status.   "Cost Base Finalized.

              IF <ls_result>-costbase_status = '05' OR <ls_result>-costbase_status = '06'.  " In Process or In Approval Pending
*        Read from tables and check if workflow is updated.
                READ TABLE lt_cc_cost ASSIGNING FIELD-SYMBOL(<ls_cc_cost>) WITH KEY sysid       = <ls_result>-sysid
                                                                                    ryear       = <ls_result>-ryear
                                                                                    fplv        = <ls_result>-fplv
                                                                                    legalentity = <ls_result>-legalentity
                                                                                    ccode = <ls_result>-ccode
                                                                                    costobject = <ls_result>-costobject
                                                                                    costcenter = <ls_result>-costcenter
                                                                                    billfrequency = _billingfreq  BINARY SEARCH.

                IF sy-subrc = 0.
                  IF <ls_cc_cost>-status = 'W'.
                    <ls_result>-costbase_status = '06'.   "Approval pending
                  ELSEIF <ls_cc_cost>-status = 'A'.
                    <ls_result>-costbase_status = '07'.   "Approved
                  ELSEIF <ls_cc_cost>-status = 'R'.
                    <ls_result>-costbase_status = '10'.   "Rejected
                  ENDIF.
                ENDIF.

              ENDIF.
            ELSE.
              READ TABLE lt_li ASSIGNING FIELD-SYMBOL(<ls_li>) WITH KEY sysid       = <ls_result>-sysid
                                                                        ryear       = <ls_result>-ryear
                                                                        fplv        = <ls_result>-fplv
                                                                        legalentity = <ls_result>-legalentity
                                                                         ccode      = <ls_result>-ccode
                                                                         costobject = <ls_result>-costobject
                                                                         costcenter = <ls_result>-costcenter
                                                                         status     = 'D'.
              IF sy-subrc = 0.
                <ls_result>-costbase_status = '02'.   "Line Items In Draft
              ELSE.
                READ TABLE lt_li ASSIGNING <ls_li> WITH KEY  sysid       = <ls_result>-sysid
                                                             ryear       = <ls_result>-ryear
                                                             fplv        = <ls_result>-fplv
                                                             legalentity = <ls_result>-legalentity
                                                             ccode       = <ls_result>-ccode
                                                             costobject  = <ls_result>-costobject
                                                             costcenter  = <ls_result>-costcenter
                                                              status     = 'W'.
                IF sy-subrc = 0.
                  <ls_result>-costbase_status = '03'.   "Line Items In Approval Pending
                ELSE.
                  READ TABLE lt_li ASSIGNING <ls_li> WITH KEY sysid       = <ls_result>-sysid
                                                              ryear       = <ls_result>-ryear
                                                              fplv        = <ls_result>-fplv
                                                              legalentity = <ls_result>-legalentity
                                                              ccode      = <ls_result>-ccode
                                                              costobject = <ls_result>-costobject
                                                              costcenter = <ls_result>-costcenter.
                  IF sy-subrc = 0.
                    <ls_result>-costbase_status = '04'.   "Calculate Stewardship
                    READ TABLE lt_service_share ASSIGNING <ls_service_share> WITH KEY sysid       = <ls_result>-sysid
                                                                                      legalentity = <ls_result>-legalentity
                                                                                       ccode      = <ls_result>-ccode
                                                                                      costobject  = <ls_result>-costobject
                                                                                       costcenter = <ls_result>-costcenter BINARY SEARCH.
                    IF sy-subrc = 0 AND <ls_service_share>-stewardship = 0.
                      MESSAGE w000(/esrcc/execcockpit) INTO <ls_result>-messagecostbase.
                      <ls_result>-messagetypecostbase = 'W'.
                    ENDIF.
*        Read from tables and check if data exist with different billing frequency for same period
                    LOOP AT lt_cc_cost ASSIGNING <ls_cc_cost> WHERE sysid       = <ls_result>-sysid
                                                                AND ryear       = <ls_result>-ryear
                                                                AND fplv        = <ls_result>-fplv
                                                                AND legalentity = <ls_result>-legalentity
                                                                AND ccode       = <ls_result>-ccode
                                                                AND costobject  = <ls_result>-costobject
                                                                AND costcenter  = <ls_result>-costcenter
                                                                AND billfrequency NE _billingfreq.
*                    if sy-subrc = 0.
                      MESSAGE e005(/esrcc/execcockpit) WITH <ls_cc_cost>-billfrequency INTO <ls_result>-messagecostbase.
                      <ls_result>-messagetypecostbase = 'E'.
                      <ls_result>-costbase_status = '00'.   "Not Possible
                      EXIT.
                    ENDLOOP.
                  ENDIF.
                ENDIF.

              ENDIF.
            ENDIF.

*        Prepare legal entity Costbase status
            READ TABLE lt_legal_status ASSIGNING FIELD-SYMBOL(<ls_legal_status>) WITH KEY   sysid       = <ls_result>-sysid
                                                                                            ryear       = <ls_result>-ryear
                                                                                            fplv        = <ls_result>-fplv
                                                                                            legalentity = <ls_result>-legalentity
                                                                                            ccode = <ls_result>-ccode
                                                                                            process = 'CBS'.
            IF sy-subrc = 0.
              IF <ls_result>-costbase_status = '08'. "cost base finalized

                <ls_legal_status>-finalizedcount = <ls_legal_status>-finalizedcount + 1.
                <ls_legal_status>-totalcount = <ls_legal_status>-totalcount + 1.
              ELSE.
                <ls_legal_status>-totalcount = <ls_legal_status>-totalcount + 1.
              ENDIF.
            ELSE.
              IF <ls_result>-costbase_status = '08'. "cost base finalized
                APPEND VALUE #( sysid = <ls_result>-sysid fplv = <ls_result>-fplv ryear = <ls_result>-ryear legalentity = <ls_result>-legalentity
                                ccode = <ls_result>-ccode finalizedcount = 1 totalcount = 1 process = 'CBS' ) TO lt_legal_status.
              ELSE.
                APPEND VALUE #( sysid = <ls_result>-sysid fplv = <ls_result>-fplv ryear = <ls_result>-ryear legalentity = <ls_result>-legalentity
                                ccode = <ls_result>-ccode finalizedcount = 0  totalcount = 1 process = 'CBS' ) TO lt_legal_status.
              ENDIF.
            ENDIF.

*            map text description
            READ TABLE lt_processstatus ASSIGNING FIELD-SYMBOL(<ls_processstatus>) WITH KEY  application = 'CBS'
                                                                                             status = <ls_result>-costbase_status.
            IF sy-subrc = 0.
              <ls_result>-costbasestatusdescr = <ls_processstatus>-description.
              <ls_result>-costbasecriticallity = <ls_processstatus>-color.
            ENDIF.
            AUTHORITY-CHECK OBJECT '/ESRCC/LE'
                ID '/ESRCC/LE' FIELD <ls_result>-legalentity
                ID 'ACTVT'  FIELD '01'.
            IF sy-subrc = 0.
              AUTHORITY-CHECK OBJECT '/ESRCC/CO'
                  ID '/ESRCC/OBJ' FIELD <ls_result>-costobject
                  ID '/ESRCC/CN'  FIELD <ls_result>-costcenter
                  ID 'ACTVT'  FIELD '01'.
              IF sy-subrc = 0.
                IF _action = '01' AND  <ls_result>-costbase_status = '04'.
                  <ls_result>-selectionallowed = abap_true.
                ENDIF.
                IF ( _action = '02' OR _action = '01' ) AND <ls_result>-costbase_status = '07'.
                  <ls_result>-selectionallowed = abap_true.
                ELSEIF _action = '03' AND <ls_result>-costbase_status = '08'.
                  <ls_result>-selectionallowed = abap_true.
                ENDIF.
                IF _action = '01' AND <ls_result>-costbase_status = '10'.
                  <ls_result>-selectionallowed = abap_true.
                ENDIF.
              ELSE.
                MESSAGE e006(/esrcc/execcockpit) INTO <ls_result>-messagecostbase.
                <ls_result>-messagetypecostbase = 'E'.
              ENDIF.
            ELSE.
              MESSAGE w006(/esrcc/execcockpit) INTO <ls_result>-messagecostbase.
              <ls_result>-messagetypecostbase = 'E'.
            ENDIF.

          ENDIF.

*  Service Cost Share & Markup Status-----------------------------------------------------
          IF <ls_result>-stewardship_status IS INITIAL AND <ls_result>-costcenter IS NOT INITIAL AND <ls_result>-serviceproduct IS NOT INITIAL.
            READ TABLE lt_procctrl ASSIGNING <ls_procctrl> WITH KEY sysid         = <ls_result>-sysid
                                                                    ryear         = <ls_result>-ryear
                                                                    fplv          = <ls_result>-fplv
                                                                    legalentity   = <ls_result>-legalentity
                                                                    ccode         = <ls_result>-ccode
                                                                    costobject    = <ls_result>-costobject
                                                                    costcenter    = <ls_result>-costcenter
                                                                    billingfreq   = <ls_result>-billingfreq
                                                                    billingperiod = <ls_result>-billingperiod
                                                                       process    = 'CBS'
                                                                           status = '08'.    "Cost base Finalized
            IF sy-subrc = 0.
              <ls_result>-stewardship_status = '01'.  "Calculate Stewardship & Service Cost Share

              READ TABLE lt_procctrl ASSIGNING <ls_procctrl> WITH KEY sysid        = <ls_result>-sysid
                                                                     ryear         = <ls_result>-ryear
                                                                     fplv          = <ls_result>-fplv
                                                                     legalentity   = <ls_result>-legalentity
                                                                     ccode         = <ls_result>-ccode
                                                                     costobject    = <ls_result>-costobject
                                                                     costcenter    = <ls_result>-costcenter
                                                                     billingfreq   = <ls_result>-billingfreq
                                                                     billingperiod = <ls_result>-billingperiod
                                                                     serviceproduct = <ls_result>-serviceproduct
                                                                        process    = 'SCM'.

              IF sy-subrc = 0.
                <ls_result>-stewardship_status = <ls_procctrl>-status.     "Stewardship & Service Cost Share In Approval Pending, Stewardship & Service Cost Share Approved, Stewardship & Service Cost Share Finalized
*        Read from tables and check if workflow is updated.
                IF <ls_result>-stewardship_status = '02' OR <ls_result>-stewardship_status = '03'.  "In process
                  READ TABLE lt_srv_cost TRANSPORTING NO FIELDS WITH KEY sysid       = <ls_result>-sysid
                                                                         ryear       = <ls_result>-ryear
                                                                         fplv        = <ls_result>-fplv
                                                                         legalentity = <ls_result>-legalentity
                                                                               ccode = <ls_result>-ccode
                                                                          costobject = <ls_result>-costobject
                                                                          costcenter = <ls_result>-costcenter
                                                                          serviceproduct = <ls_result>-serviceproduct
                                                                              status = 'W' BINARY SEARCH.
                  IF sy-subrc = 0.
                    <ls_result>-stewardship_status = '03'.   "Approval Pending
                  ELSE.
                    READ TABLE lt_srv_cost TRANSPORTING NO FIELDS WITH KEY sysid       = <ls_result>-sysid
                                                                           ryear       = <ls_result>-ryear
                                                                           fplv        = <ls_result>-fplv
                                                                           legalentity = <ls_result>-legalentity
                                                                                 ccode = <ls_result>-ccode
                                                                            costobject = <ls_result>-costobject
                                                                            costcenter = <ls_result>-costcenter
                                                                            serviceproduct = <ls_result>-serviceproduct
                                                                                status = 'R' BINARY SEARCH.
                    IF sy-subrc = 0.
                      <ls_result>-stewardship_status = '06'.   "Reject
                    ELSE.
*        Read from tables and check if workflow is updated.
                      READ TABLE lt_srv_cost TRANSPORTING NO FIELDS WITH KEY sysid       = <ls_result>-sysid
                                                                             ryear       = <ls_result>-ryear
                                                                             fplv        = <ls_result>-fplv
                                                                             legalentity = <ls_result>-legalentity
                                                                                   ccode = <ls_result>-ccode
                                                                              costobject = <ls_result>-costobject
                                                                              costcenter = <ls_result>-costcenter
                                                                              serviceproduct = <ls_result>-serviceproduct
                                                                                  status = 'A' BINARY SEARCH.
                      IF sy-subrc = 0.
                        <ls_result>-stewardship_status = '04'.   "Approved
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ELSE.
              <ls_result>-stewardship_status = '00'.  "Not Possible
            ENDIF.

*           Check if service cost share and markup are maintained
            IF <ls_result>-stewardship_status = '01'.  "Calculate Stewardship & Service Cost Share
              READ TABLE lt_srv_alloc ASSIGNING FIELD-SYMBOL(<ls_srv_alloc>) WITH KEY serviceproduct = <ls_result>-serviceproduct
                                                                                        BINARY SEARCH.
              IF sy-subrc <> 0.
                MESSAGE e002(/esrcc/execcockpit) INTO <ls_result>-messageservice.
                <ls_result>-messagetypeservice = 'E'.
                <ls_result>-stewardship_status = '00'.  "Not Possible
              ELSE.
                READ TABLE lt_srv_markup ASSIGNING FIELD-SYMBOL(<ls_srv_markup>) WITH KEY serviceproduct = <ls_result>-serviceproduct
                                                                                          BINARY SEARCH.
                IF sy-subrc <> 0.
                  MESSAGE w001(/esrcc/execcockpit) INTO <ls_result>-messageservice.
                  <ls_result>-messagetypeservice = 'W'.
                ENDIF.
              ENDIF.
            ENDIF.


*        legal entity status
            READ TABLE lt_legal_status ASSIGNING <ls_legal_status> WITH KEY      sysid       = <ls_result>-sysid
                                                                                 ryear       = <ls_result>-ryear
                                                                                 fplv        = <ls_result>-fplv
                                                                                 legalentity = <ls_result>-legalentity
                                                                                  ccode = <ls_result>-ccode
                                                                                  process = 'SCM'.
            IF sy-subrc = 0.
              IF <ls_result>-stewardship_status = '05'. "Service cost share finalized

                <ls_legal_status>-finalizedcount = <ls_legal_status>-finalizedcount + 1.
                <ls_legal_status>-totalcount = <ls_legal_status>-totalcount + 1.
              ELSE.
                <ls_legal_status>-totalcount = <ls_legal_status>-totalcount + 1.
              ENDIF.
            ELSE.
              IF <ls_result>-stewardship_status = '05'. "Service cost share finalized
                APPEND VALUE #( sysid = <ls_result>-sysid fplv = <ls_result>-fplv ryear = <ls_result>-ryear legalentity = <ls_result>-legalentity
                                ccode = <ls_result>-ccode finalizedcount = 1 totalcount = 1 process = 'SCM' ) TO lt_legal_status.
              ELSE.
                APPEND VALUE #( sysid = <ls_result>-sysid fplv = <ls_result>-fplv ryear = <ls_result>-ryear legalentity = <ls_result>-legalentity
                                ccode = <ls_result>-ccode finalizedcount = 0  totalcount = 1 process = 'SCM' ) TO lt_legal_status.
              ENDIF.
            ENDIF.

*        Cost Center status
            READ TABLE lt_costcenter_status ASSIGNING FIELD-SYMBOL(<ls_costcenter_status>) WITH KEY     sysid       = <ls_result>-sysid
                                                                                                        ryear       = <ls_result>-ryear
                                                                                                        fplv        = <ls_result>-fplv
                                                                                                        legalentity = <ls_result>-legalentity
                                                                                                          ccode = <ls_result>-ccode
                                                                                                        costcenter = <ls_result>-costcenter
                                                                                                        costobject = <ls_result>-costobject
                                                                                                        process = 'SCM'.
            IF sy-subrc = 0.
              IF <ls_result>-stewardship_status = '05'. "Service cost share finalized

                <ls_costcenter_status>-finalizedcount = <ls_costcenter_status>-finalizedcount + 1.
                <ls_costcenter_status>-totalcount = <ls_costcenter_status>-totalcount + 1.
              ELSE.
                <ls_costcenter_status>-totalcount = <ls_costcenter_status>-totalcount + 1.
              ENDIF.
            ELSE.
              IF <ls_result>-stewardship_status = '05'. "Service cost share finalized
                APPEND VALUE #( sysid = <ls_result>-sysid fplv = <ls_result>-fplv ryear = <ls_result>-ryear legalentity = <ls_result>-legalentity
                                ccode = <ls_result>-ccode costcenter = <ls_result>-costcenter costobject = <ls_result>-costobject
                                finalizedcount = 1 totalcount = 1 process = 'SCM' ) TO lt_costcenter_status.
              ELSE.
                APPEND VALUE #( sysid = <ls_result>-sysid fplv = <ls_result>-fplv ryear = <ls_result>-ryear legalentity = <ls_result>-legalentity
                                ccode = <ls_result>-ccode costcenter = <ls_result>-costcenter costobject = <ls_result>-costobject
                                finalizedcount = 0  totalcount = 1 process = 'SCM' ) TO lt_costcenter_status.
              ENDIF.
            ENDIF.


*            map text description
            READ TABLE lt_processstatus ASSIGNING <ls_processstatus> WITH KEY  application = 'SCM'
                                                                               status = <ls_result>-stewardship_status.
            IF sy-subrc = 0.
              <ls_result>-stewardshipstatusdescr = <ls_processstatus>-description.
              <ls_result>-stewardshipcriticality = <ls_processstatus>-color.
            ENDIF.

            AUTHORITY-CHECK OBJECT '/ESRCC/LE'
                ID '/ESRCC/LE' FIELD <ls_result>-legalentity
                ID 'ACTVT'  FIELD '01'.
            IF sy-subrc = 0.
              AUTHORITY-CHECK OBJECT '/ESRCC/CO'
                  ID '/ESRCC/OBJ' FIELD <ls_result>-costobject
                  ID '/ESRCC/CN'  FIELD <ls_result>-costcenter
                  ID 'ACTVT'  FIELD '01'.
              IF sy-subrc = 0.
*            map status color
                IF ( _action = '05' OR _action = '04' ) AND <ls_result>-stewardship_status = '04'.
                  <ls_result>-selectionallowed = abap_true.
                ELSEIF _action = '06' AND <ls_result>-stewardship_status = '05'.
                  <ls_result>-selectionallowed = abap_true.
                ENDIF.
                IF _action = '04' AND <ls_result>-stewardship_status = '01'.
                  <ls_result>-selectionallowed = abap_true.
                ENDIF.
                IF _action = '04' AND <ls_result>-stewardship_status = '06'.
                  <ls_result>-selectionallowed = abap_true.
                ENDIF.
              ELSE.
                MESSAGE e007(/esrcc/execcockpit) INTO <ls_result>-messageservice.
                <ls_result>-messagetypeservice = 'E'.
              ENDIF.
            ELSE.
              MESSAGE e007(/esrcc/execcockpit) INTO <ls_result>-messageservice.
              <ls_result>-messagetypeservice = 'E'.
            ENDIF.

            IF <ls_result>-stewardship_status = '03' OR <ls_result>-stewardship_status = '02'.  "Approval Pending
              <ls_result>-selectionallowed = abap_false.
              READ TABLE lt_result ASSIGNING FIELD-SYMBOL(<ls_result_costobject>) WITH KEY sysid       = <ls_result>-sysid
                                                                    ryear       = <ls_result>-ryear
                                                                    fplv        = <ls_result>-fplv
                                                                    legalentity = <ls_result>-legalentity
                                                                    ccode = <ls_result>-ccode
                                                                    costcenter = <ls_result>-costcenter
                                                                    costobject = <ls_result>-costobject
                                                                    selectionallowed = abap_true.
              IF sy-subrc = 0.
                <ls_result_costobject>-selectionallowed = abap_false.
              ENDIF.
            ENDIF.
          ENDIF.

*  Charge-out to Receiver Status----------------------------------------------------------
          IF <ls_result>-chargeout_status IS INITIAL AND <ls_result>-costcenter IS NOT INITIAL AND <ls_result>-serviceproduct IS NOT INITIAL.
            READ TABLE lt_procctrl ASSIGNING <ls_procctrl> WITH KEY    sysid       = <ls_result>-sysid
                                                                       ryear         = <ls_result>-ryear
                                                                       fplv          = <ls_result>-fplv
                                                                       legalentity = <ls_result>-legalentity
                                                                       ccode      = <ls_result>-ccode
                                                                       costobject = <ls_result>-costobject
                                                                       costcenter = <ls_result>-costcenter
                                                                       billingfreq = <ls_result>-billingfreq
                                                                       billingperiod = <ls_result>-billingperiod
                                                                       process    = 'SCM'.
            IF sy-subrc = 0 AND <ls_procctrl>-status = '05'.  "Stewardship Finalized
              <ls_result>-chargeout_status = '01'.  "Calculate Charge-Out

              READ TABLE lt_procctrl ASSIGNING <ls_procctrl> WITH KEY  sysid       = <ls_result>-sysid
                                                                       ryear         = <ls_result>-ryear
                                                                       fplv          = <ls_result>-fplv
                                                                       legalentity = <ls_result>-legalentity
                                                                       ccode      = <ls_result>-ccode
                                                                       costobject = <ls_result>-costobject
                                                                       costcenter = <ls_result>-costcenter
                                                                       billingfreq = <ls_result>-billingfreq
                                                                       billingperiod = <ls_result>-billingperiod
                                                                       process    = 'CHR'
                                                                       serviceproduct = <ls_result>-serviceproduct BINARY SEARCH.
              IF sy-subrc = 0.
                <ls_result>-chargeout_status = <ls_procctrl>-status.     "Charge-Out In Approval Pending, Charge-Out Approved, Charge-Out Finalized
*        Read from tables and check if workflow is updated.
                IF <ls_result>-chargeout_status = '02' OR <ls_result>-chargeout_status = '03'.  " In Process
                  READ TABLE lt_rec_cost TRANSPORTING NO FIELDS WITH KEY sysid       = <ls_result>-sysid
                                                                         ryear         = <ls_result>-ryear
                                                                         fplv          = <ls_result>-fplv
                                                                         legalentity = <ls_result>-legalentity
                                                                               ccode = <ls_result>-ccode
                                                                          costobject = <ls_result>-costobject
                                                                          costcenter = <ls_result>-costcenter
                                                                          serviceproduct = <ls_result>-serviceproduct
                                                                              status = 'R' BINARY SEARCH.
                  IF sy-subrc = 0.
                    <ls_result>-chargeout_status = '06'.  " Reject
                  ELSE.
                    READ TABLE lt_rec_cost TRANSPORTING NO FIELDS WITH KEY  sysid       = <ls_result>-sysid
                                                                            ryear         = <ls_result>-ryear
                                                                            fplv          = <ls_result>-fplv
                                                                            legalentity = <ls_result>-legalentity
                                                                                 ccode = <ls_result>-ccode
                                                                            costobject = <ls_result>-costobject
                                                                            costcenter = <ls_result>-costcenter
                                                                            serviceproduct = <ls_result>-serviceproduct
                                                                                status = 'W' BINARY SEARCH.
                    IF sy-subrc = 0.
                      <ls_result>-chargeout_status = '03'.   "Approval Pending
                    ELSE.
*        Read from tables and check if workflow is updated.
                      READ TABLE lt_rec_cost TRANSPORTING NO FIELDS WITH KEY sysid       = <ls_result>-sysid
                                                                             ryear         = <ls_result>-ryear
                                                                              fplv          = <ls_result>-fplv
                                                                              legalentity = <ls_result>-legalentity
                                                                                   ccode = <ls_result>-ccode
                                                                              costobject = <ls_result>-costobject
                                                                              costcenter = <ls_result>-costcenter
                                                                              serviceproduct = <ls_result>-serviceproduct
                                                                                  status = 'A' BINARY SEARCH.
                      IF sy-subrc = 0.
                        <ls_result>-chargeout_status = '04'.   "Approved
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ELSE.
              <ls_result>-chargeout_status = '00'.  "Not Possible
            ENDIF.

*    perform validations to check if required data is maintained
            IF <ls_result>-chargeout_status = '01'.  "Calculate Charge-Out
              READ TABLE lt_srv_alloc ASSIGNING <ls_srv_alloc> WITH KEY serviceproduct = <ls_result>-serviceproduct
                                                                     BINARY SEARCH.
              IF sy-subrc <> 0.
                MESSAGE e002(/esrcc/execcockpit) INTO <ls_result>-messagechargeout.
                <ls_result>-messagetypechargeout = 'E'.
                <ls_result>-chargeout_status = '00'.  "Not Possible
              ELSEIF <ls_srv_alloc>-chargeout = 'I'.
                READ TABLE lt_srv_allocwght ASSIGNING FIELD-SYMBOL(<ls_srv_allocwght>) WITH KEY  serviceproduct = <ls_result>-serviceproduct.
*                                                                                              BINARY SEARCH.
                IF sy-subrc <> 0.
                  MESSAGE e003(/esrcc/execcockpit) INTO <ls_result>-messagechargeout.
                  <ls_result>-messagetypechargeout = 'E'.
                  <ls_result>-chargeout_status = '00'.  "Not Possible
                ENDIF.
              ENDIF.
              READ TABLE lt_srv_receivers ASSIGNING FIELD-SYMBOL(<ls_srv_receivers>) WITH KEY sysid       = <ls_result>-sysid
                                                                                              legalentity = <ls_result>-legalentity
                                                                                              ccode       = <ls_result>-ccode
                                                                                              costobject  = <ls_result>-costobject
                                                                                              costcenter  = <ls_result>-costcenter
                                                                                              serviceproduct = <ls_result>-serviceproduct.
*                                                                                           BINARY SEARCH.
              IF sy-subrc <> 0.
                MESSAGE e004(/esrcc/execcockpit) INTO <ls_result>-messagechargeout.
                <ls_result>-messagetypechargeout = 'E'.
                <ls_result>-chargeout_status = '00'.  "Not Possible
              ENDIF.
            ENDIF..


*        legal entity status
            READ TABLE lt_legal_status ASSIGNING <ls_legal_status> WITH KEY       sysid       = <ls_result>-sysid
                                                                                  ryear       = <ls_result>-ryear
                                                                                  fplv        = <ls_result>-fplv
                                                                                  legalentity = <ls_result>-legalentity
                                                                                  ccode = <ls_result>-ccode
                                                                                  process = 'CHR'.
            IF sy-subrc = 0.
              IF <ls_result>-chargeout_status = '05'. "cost base finalized

                <ls_legal_status>-finalizedcount = <ls_legal_status>-finalizedcount + 1.
                <ls_legal_status>-totalcount = <ls_legal_status>-totalcount + 1.
              ELSE.
                <ls_legal_status>-totalcount = <ls_legal_status>-totalcount + 1.
              ENDIF.
            ELSE.
              IF <ls_result>-chargeout_status = '05'. "cost base finalized
                APPEND VALUE #( sysid = <ls_result>-sysid fplv = <ls_result>-fplv ryear = <ls_result>-ryear legalentity = <ls_result>-legalentity
                                ccode = <ls_result>-ccode finalizedcount = 1 totalcount = 1 process = 'CHR' ) TO lt_legal_status.
              ELSE.
                APPEND VALUE #( sysid = <ls_result>-sysid fplv = <ls_result>-fplv ryear = <ls_result>-ryear legalentity = <ls_result>-legalentity
                                ccode = <ls_result>-ccode finalizedcount = 0  totalcount = 1 process = 'CHR' ) TO lt_legal_status.
              ENDIF.
            ENDIF.

*        Cost Center status
            READ TABLE lt_costcenter_status ASSIGNING <ls_costcenter_status> WITH KEY sysid       = <ls_result>-sysid
                                                                                      ryear       = <ls_result>-ryear
                                                                                      fplv        = <ls_result>-fplv
                                                                                      legalentity = <ls_result>-legalentity
                                                                                            ccode = <ls_result>-ccode
                                                                                       costcenter = <ls_result>-costcenter
                                                                                       costobject = <ls_result>-costobject
                                                                                          process = 'CHR'.
            IF sy-subrc = 0.
              IF <ls_result>-chargeout_status = '05'. "charge out finalized

                <ls_costcenter_status>-finalizedcount = <ls_costcenter_status>-finalizedcount + 1.
                <ls_costcenter_status>-totalcount = <ls_costcenter_status>-totalcount + 1.
              ELSE.
                <ls_costcenter_status>-totalcount = <ls_costcenter_status>-totalcount + 1.
              ENDIF.
            ELSE.
              IF <ls_result>-chargeout_status = '05'. "charge out finalized
                APPEND VALUE #( sysid = <ls_result>-sysid fplv = <ls_result>-fplv ryear = <ls_result>-ryear legalentity = <ls_result>-legalentity
                                ccode = <ls_result>-ccode costcenter = <ls_result>-costcenter costobject = <ls_result>-costobject
                                finalizedcount = 1 totalcount = 1 process = 'CHR' ) TO lt_costcenter_status.
              ELSE.
                APPEND VALUE #( sysid = <ls_result>-sysid fplv = <ls_result>-fplv ryear = <ls_result>-ryear legalentity = <ls_result>-legalentity
                                ccode = <ls_result>-ccode costcenter = <ls_result>-costcenter costobject = <ls_result>-costobject
                                finalizedcount = 0  totalcount = 1 process = 'CHR' ) TO lt_costcenter_status.
              ENDIF.
            ENDIF.

*            map text description
            READ TABLE lt_processstatus ASSIGNING <ls_processstatus> WITH KEY  application = 'CHR'
                                                                               status = <ls_result>-chargeout_status.
            IF sy-subrc = 0.
              <ls_result>-chargeoutstatusdescr = <ls_processstatus>-description.
              <ls_result>-chargeoutcriticality = <ls_processstatus>-color.
            ENDIF.

            AUTHORITY-CHECK OBJECT '/ESRCC/LE'
                ID '/ESRCC/LE' FIELD <ls_result>-legalentity
                ID 'ACTVT'  FIELD '01'.
            IF sy-subrc = 0.
              AUTHORITY-CHECK OBJECT '/ESRCC/CO'
                  ID '/ESRCC/OBJ' FIELD <ls_result>-costobject
                  ID '/ESRCC/CN'  FIELD <ls_result>-costcenter
                  ID 'ACTVT'  FIELD '01'.
              IF sy-subrc = 0.
*            map status color
                IF ( _action = '08' OR _action = '07' ) AND <ls_result>-chargeout_status = '04'.
                  <ls_result>-selectionallowed = abap_true.
                ELSEIF _action = '09' AND <ls_result>-chargeout_status = '05'.
                  <ls_result>-selectionallowed = abap_true.
                ENDIF.
                IF _action = '07' AND ( <ls_result>-chargeout_status = '01' OR <ls_result>-chargeout_status = '06' ).
                  <ls_result>-selectionallowed = abap_true.
                ENDIF.
              ELSE.
                MESSAGE e008(/esrcc/execcockpit) INTO <ls_result>-messagechargeout.
                <ls_result>-messagetypechargeout = 'E'.
              ENDIF.
            ELSE.
              MESSAGE e008(/esrcc/execcockpit) INTO <ls_result>-messagechargeout.
              <ls_result>-messagetypechargeout = 'E'.
            ENDIF.

            IF <ls_result>-chargeout_status = '03' OR <ls_result>-chargeout_status = '02'.  " Approval Pending
              <ls_result>-selectionallowed = abap_false.
              READ TABLE lt_result ASSIGNING <ls_result_costobject> WITH KEY sysid       = <ls_result>-sysid
                                                                    ryear       = <ls_result>-ryear
                                                                    fplv        = <ls_result>-fplv
                                                                    legalentity = <ls_result>-legalentity
                                                                    ccode = <ls_result>-ccode
                                                                    costcenter = <ls_result>-costcenter
                                                                    costobject = <ls_result>-costobject
                                                                    selectionallowed = abap_true.
              IF sy-subrc = 0.
                <ls_result_costobject>-selectionallowed = abap_false.
              ENDIF.
            ENDIF.
          ENDIF.

        ENDLOOP.



*Aggregated statuses---------------------------------------------------------------------------
        LOOP AT lt_result ASSIGNING <ls_result> WHERE serviceproduct IS INITIAL.

          IF <ls_result>-costcenter IS INITIAL.
            READ TABLE lt_legal_status ASSIGNING <ls_legal_status> WITH KEY sysid       = <ls_result>-sysid
                                                                            ryear       = <ls_result>-ryear
                                                                            fplv        = <ls_result>-fplv
                                                                            legalentity = <ls_result>-legalentity
                                                                                  ccode = <ls_result>-ccode
                                                                                process = 'CBS'.
            IF sy-subrc = 0.
              <ls_result>-costbase_status = '08'.
*            map text description
              READ TABLE lt_processstatus ASSIGNING <ls_processstatus> WITH KEY  application = 'CBS'
                                                                                 status = '08'.
              IF sy-subrc = 0.
                CONCATENATE <ls_processstatus>-description ' (' <ls_legal_status>-finalizedcount '/' <ls_legal_status>-totalcount ')' INTO <ls_result>-costbasestatusdescr.
              ENDIF.
*            map status color
              IF <ls_legal_status>-finalizedcount = 0.
                <ls_result>-costbasecriticallity = 0.
              ELSEIF <ls_legal_status>-finalizedcount > 0 AND <ls_legal_status>-finalizedcount < <ls_legal_status>-totalcount.
                <ls_result>-costbasecriticallity = 2.
              ELSEIF <ls_legal_status>-finalizedcount > 0 AND <ls_legal_status>-finalizedcount = <ls_legal_status>-totalcount.
                <ls_result>-costbasecriticallity = 3.
              ENDIF.
              READ TABLE lt_result TRANSPORTING NO FIELDS WITH KEY sysid       = <ls_result>-sysid
                                                                   ryear       = <ls_result>-ryear
                                                                   fplv        = <ls_result>-fplv
                                                                   legalentity = <ls_result>-legalentity
                                                                   ccode = <ls_result>-ccode
                                                                   selectionallowed = abap_true.

              IF sy-subrc = 0 AND ( _action = '01' OR _action = '02' OR _action = '03' ).
                <ls_result>-selectionallowed = abap_true.
              ENDIF.
            ENDIF.


            READ TABLE lt_legal_status ASSIGNING <ls_legal_status> WITH KEY sysid       = <ls_result>-sysid
                                                                            ryear       = <ls_result>-ryear
                                                                            fplv        = <ls_result>-fplv
                                                                            legalentity = <ls_result>-legalentity
                                                                                  ccode = <ls_result>-ccode
                                                                                process = 'SCM'.
            IF sy-subrc = 0.
              <ls_result>-stewardship_status = '05'.
*            map text description
              READ TABLE lt_processstatus ASSIGNING <ls_processstatus> WITH KEY application = 'SCM'
                                                                                status = '05'.
              IF sy-subrc = 0.
                CONCATENATE <ls_processstatus>-description ' (' <ls_legal_status>-finalizedcount '/' <ls_legal_status>-totalcount ')' INTO <ls_result>-stewardshipstatusdescr.
              ENDIF.
*            map status color
              IF <ls_legal_status>-finalizedcount = 0.
                <ls_result>-stewardshipcriticality = 0.
              ELSEIF <ls_legal_status>-finalizedcount > 0 AND <ls_legal_status>-finalizedcount < <ls_legal_status>-totalcount.
                <ls_result>-stewardshipcriticality = 2.
              ELSEIF <ls_legal_status>-finalizedcount > 0 AND <ls_legal_status>-finalizedcount = <ls_legal_status>-totalcount.
                <ls_result>-stewardshipcriticality = 3.
              ENDIF.
              READ TABLE lt_result TRANSPORTING NO FIELDS WITH KEY sysid       = <ls_result>-sysid
                                                                   ryear       = <ls_result>-ryear
                                                                   fplv        = <ls_result>-fplv
                                                                   legalentity = <ls_result>-legalentity
                                                                   ccode = <ls_result>-ccode
                                                                   selectionallowed = abap_true.
              IF sy-subrc = 0 AND ( _action = '04' OR _action = '05' OR _action = '06' ).
                <ls_result>-selectionallowed = abap_true.
              ENDIF.
            ENDIF.


            READ TABLE lt_legal_status ASSIGNING <ls_legal_status> WITH KEY sysid       = <ls_result>-sysid
                                                                            ryear       = <ls_result>-ryear
                                                                            fplv        = <ls_result>-fplv
                                                                            legalentity = <ls_result>-legalentity
                                                                                  ccode = <ls_result>-ccode
                                                                                process = 'CHR'.
            IF sy-subrc = 0.
              <ls_result>-chargeout_status = '05'.
*            map text description
              READ TABLE lt_processstatus ASSIGNING <ls_processstatus> WITH KEY application = 'CHR'
                                                                                status = '05'.
              IF sy-subrc = 0.
                CONCATENATE <ls_processstatus>-description ' (' <ls_legal_status>-finalizedcount '/' <ls_legal_status>-totalcount ')' INTO <ls_result>-chargeoutstatusdescr.
              ENDIF.

*            map status color
              IF <ls_legal_status>-finalizedcount = 0.
                <ls_result>-chargeoutcriticality = 0.
              ELSEIF <ls_legal_status>-finalizedcount > 0 AND <ls_legal_status>-finalizedcount < <ls_legal_status>-totalcount.
                <ls_result>-chargeoutcriticality = 2.
              ELSEIF <ls_legal_status>-finalizedcount > 0 AND <ls_legal_status>-finalizedcount = <ls_legal_status>-totalcount.
                <ls_result>-chargeoutcriticality = 3.
              ENDIF.
              READ TABLE lt_result TRANSPORTING NO FIELDS WITH KEY sysid       = <ls_result>-sysid
                                                                   ryear       = <ls_result>-ryear
                                                                   fplv        = <ls_result>-fplv
                                                                   legalentity = <ls_result>-legalentity
                                                                   ccode = <ls_result>-ccode
                                                                   selectionallowed = abap_true.
              IF sy-subrc = 0 AND ( _action = '07' OR _action = '08' OR _action = '09' ).
                <ls_result>-selectionallowed = abap_true.
              ENDIF.
            ENDIF.
          ELSE.

*        Service Cost share & Markup
            READ TABLE lt_costcenter_status ASSIGNING <ls_costcenter_status> WITH KEY  sysid       = <ls_result>-sysid
                                                                                        ryear       = <ls_result>-ryear
                                                                                        fplv        = <ls_result>-fplv
                                                                                        legalentity = <ls_result>-legalentity
                                                                                            ccode = <ls_result>-ccode
                                                                                       costcenter = <ls_result>-costcenter
                                                                                       costobject = <ls_result>-costobject
                                                                                          process = 'SCM'.
            IF sy-subrc = 0.
              <ls_result>-chargeout_status = '05'.
*            map text description
              READ TABLE lt_processstatus ASSIGNING <ls_processstatus> WITH KEY application = 'SCM'
                                                                                status = '05'.
              IF sy-subrc = 0.
                CONCATENATE <ls_processstatus>-description ' (' <ls_costcenter_status>-finalizedcount '/' <ls_costcenter_status>-totalcount ')' INTO <ls_result>-stewardshipstatusdescr.
              ENDIF.

*            map status color
              IF <ls_costcenter_status>-finalizedcount = 0.
                <ls_result>-stewardshipcriticality = 0.   "Grey
              ELSEIF <ls_costcenter_status>-finalizedcount > 0 AND <ls_costcenter_status>-finalizedcount < <ls_costcenter_status>-totalcount.
                <ls_result>-stewardshipcriticality = 2.   "Yellow
              ELSEIF <ls_costcenter_status>-finalizedcount > 0 AND <ls_costcenter_status>-finalizedcount = <ls_costcenter_status>-totalcount.
                <ls_result>-stewardshipcriticality = 3.   "Green
              ENDIF.
              READ TABLE lt_result TRANSPORTING NO FIELDS WITH KEY sysid       = <ls_result>-sysid
                                                                   ryear       = <ls_result>-ryear
                                                                   fplv        = <ls_result>-fplv
                                                                   legalentity = <ls_result>-legalentity
                                                                   ccode = <ls_result>-ccode
                                                                   costcenter = <ls_result>-costcenter
                                                                   costobject = <ls_result>-costobject
                                                                   selectionallowed = abap_true.
              IF sy-subrc = 0 AND ( _action = '04' OR _action = '05' OR _action = '06' ).
                <ls_result>-selectionallowed = abap_true.
              ENDIF.
            ENDIF.

*         Charge-out receievers
            READ TABLE lt_costcenter_status ASSIGNING <ls_costcenter_status> WITH KEY sysid       = <ls_result>-sysid
                                                                                        ryear       = <ls_result>-ryear
                                                                                        fplv        = <ls_result>-fplv
                                                                                        legalentity = <ls_result>-legalentity
                                                                                            ccode = <ls_result>-ccode
                                                                                       costcenter = <ls_result>-costcenter
                                                                                       costobject = <ls_result>-costobject
                                                                                          process = 'CHR'.
            IF sy-subrc = 0.
              <ls_result>-chargeout_status = '05'.
*            map text description
              READ TABLE lt_processstatus ASSIGNING <ls_processstatus> WITH KEY application = 'CHR'
                                                                                status = '05'.
              IF sy-subrc = 0.
                CONCATENATE <ls_processstatus>-description ' (' <ls_costcenter_status>-finalizedcount '/' <ls_costcenter_status>-totalcount ')' INTO <ls_result>-chargeoutstatusdescr.
              ENDIF.

*            map status color
              IF <ls_costcenter_status>-finalizedcount = 0.
                <ls_result>-chargeoutcriticality = 0.
              ELSEIF <ls_costcenter_status>-finalizedcount > 0 AND <ls_costcenter_status>-finalizedcount < <ls_costcenter_status>-totalcount.
                <ls_result>-chargeoutcriticality = 2.
              ELSEIF <ls_costcenter_status>-finalizedcount > 0 AND <ls_costcenter_status>-finalizedcount = <ls_costcenter_status>-totalcount.
                <ls_result>-chargeoutcriticality = 3.
              ENDIF.
              READ TABLE lt_result TRANSPORTING NO FIELDS WITH KEY sysid       = <ls_result>-sysid
                                                                   ryear       = <ls_result>-ryear
                                                                   fplv        = <ls_result>-fplv
                                                                   legalentity = <ls_result>-legalentity
                                                                   ccode = <ls_result>-ccode
                                                                   costcenter = <ls_result>-costcenter
                                                                   costobject = <ls_result>-costobject
                                                                   selectionallowed = abap_true.
              IF sy-subrc = 0 AND ( _action = '07' OR _action = '08' OR _action = '09' ).
                <ls_result>-selectionallowed = abap_true.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.

***fill response
        io_response->set_data( lt_result ).
*        ENDIF.
**request count
        IF io_request->is_total_numb_of_rec_requested( ).
**select count
*
**fill response
          io_response->set_total_number_of_records( lines( lt_result ) ).
        ENDIF.
      CATCH cx_rap_query_provider.

    ENDTRY.
  ENDMETHOD.
ENDCLASS.
