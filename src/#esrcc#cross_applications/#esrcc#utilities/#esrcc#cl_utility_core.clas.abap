CLASS /esrcc/cl_utility_core DEFINITION PUBLIC FINAL CREATE PRIVATE .

  PUBLIC SECTION.
    CLASS-METHODS:
      "! <p class="shorttext synchronized" lang="en">Get UTC date and time from UTC time stamp</p>
      "!
      "! @parameter time_stamp | <p class="shorttext synchronized" lang="en">UTC Time Stamp</p>
      "! @parameter date | <p class="shorttext synchronized" lang="en">UTC Date</p>
      "! @parameter time | <p class="shorttext synchronized" lang="en">UTC Time</p>
      get_utc_date_time_ts EXPORTING time_stamp TYPE timestampl
                                     date       TYPE datn
                                     time       TYPE timn,
      "! <p class="shorttext synchronized" lang="en">Get the last day of the month</p>
      "! Get the last day of the month for the date provided as input in the format YYYYMMDD.
      "! @parameter date | <p class="shorttext synchronized" lang="en">Input Date: YYYYMMDD</p>
      "! @parameter end_date | <p class="shorttext synchronized" lang="en">End Date</p>
      get_last_day_of_month IMPORTING date            TYPE datn
                            RETURNING VALUE(end_date) TYPE datn,

      get_group_configuration RETURNING VALUE(group) TYPE /esrcc/group.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /ESRCC/CL_UTILITY_CORE IMPLEMENTATION.


  METHOD get_last_day_of_month.
    IF date IS NOT INITIAL.
      end_date = |{ date+0(6) }{ SWITCH #( date+4(2)
                                   WHEN 1  THEN 31
                                   WHEN 2  THEN COND #( WHEN date+0(4) MOD 4 EQ 0 THEN 29 ELSE 28 )
                                   WHEN 3  THEN 31
                                   WHEN 4  THEN 30
                                   WHEN 5  THEN 31
                                   WHEN 6  THEN 30
                                   WHEN 7  THEN 31
                                   WHEN 8  THEN 31
                                   WHEN 9  THEN 30
                                   WHEN 10 THEN 31
                                   WHEN 11 THEN 30
                                   WHEN 12 THEN 31 ) }|.
    ENDIF.
  ENDMETHOD.


  METHOD get_utc_date_time_ts.
    " Get timestamp value in the UTC format.
    GET TIME STAMP FIELD time_stamp.
    " Provide date and time interpreting the UTC timestamp for central use.
    CONVERT TIME STAMP time_stamp
    TIME ZONE 'UTC' INTO DATE date TIME time.
  ENDMETHOD.


  METHOD get_group_configuration.
    SELECT SINGLE * FROM /esrcc/group INTO @group.
  ENDMETHOD.
ENDCLASS.
