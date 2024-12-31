CLASS zcl_com_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS matnr_zero_in
      IMPORTING
        VALUE(input)  TYPE any
      EXPORTING
        VALUE(output) TYPE any .
    CLASS-METHODS get_eml_msg
      IMPORTING ls_failed    TYPE any
                ls_reported  TYPE any
                lv_component TYPE string
      EXPORTING msg          TYPE bapi_msg.
    CLASS-METHODS get_taxrate_by_code
      IMPORTING VALUE(taxcode) TYPE string
      RETURNING VALUE(taxrate) TYPE string.
    CLASS-METHODS get_javatimestamp
      RETURNING VALUE(ts) TYPE string.
    CLASS-METHODS convert_abap_timestamp_to_java
      IMPORTING
        !iv_date      TYPE sydate
        !iv_time      TYPE syuzeit
        !iv_msec      TYPE znum3 DEFAULT 000
      EXPORTING
        !ev_timestamp TYPE string .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_com_util IMPLEMENTATION.


  METHOD get_eml_msg.
    DATA:lv_msg     TYPE bapi_msg,
         ls_t100key TYPE scx_t100key,
         lv_msgid   TYPE symsgid,
         lv_msgno   TYPE symsgno,
         lv_msgv1   LIKE sy-msgv1,
         lv_msgv2   LIKE sy-msgv2,
         lv_msgv3   LIKE sy-msgv3,
         lv_msgv4   LIKE sy-msgv4.

    FIELD-SYMBOLS:<fs_tab>     TYPE STANDARD TABLE,
                  <fs>         TYPE any,
                  <fs_msg>     TYPE REF TO if_abap_behv_message,
                  <fs_t100key> TYPE any.

    ASSIGN COMPONENT lv_component OF STRUCTURE ls_reported TO <fs_tab>.
    IF <fs_tab> IS ASSIGNED AND <fs_tab> IS NOT INITIAL.

      LOOP AT <fs_tab> ASSIGNING <fs>.
        CLEAR:lv_msgid,lv_msgno,lv_msgv1,lv_msgv2,lv_msgv3,lv_msgv3.
        ASSIGN COMPONENT '%MSG' OF STRUCTURE <fs> TO <fs_msg>.
        IF <fs_msg> IS ASSIGNED AND <fs_msg> IS NOT INITIAL.
          ASSIGN <fs_msg>->('IF_T100_MESSAGE~T100KEY') TO <fs_t100key>.
          IF <fs_t100key> IS ASSIGNED AND <fs_t100key> IS NOT INITIAL.
            ASSIGN COMPONENT 'MSGID' OF STRUCTURE <fs_t100key> TO FIELD-SYMBOL(<fs_msgid>).
            ASSIGN COMPONENT 'MSGNO' OF STRUCTURE <fs_t100key> TO FIELD-SYMBOL(<fs_msgno>).
          ENDIF.
          ASSIGN <fs_msg>->('IF_T100_DYN_MSG~MSGV1') TO FIELD-SYMBOL(<fs_msgv1>).
          ASSIGN <fs_msg>->('IF_T100_DYN_MSG~MSGV2') TO FIELD-SYMBOL(<fs_msgv2>).
          ASSIGN <fs_msg>->('IF_T100_DYN_MSG~MSGV3') TO FIELD-SYMBOL(<fs_msgv3>).
          ASSIGN <fs_msg>->('IF_T100_DYN_MSG~MSGV4') TO FIELD-SYMBOL(<fs_msgv4>).
          IF <fs_msgid> IS ASSIGNED AND <fs_msgid> IS NOT INITIAL.
            lv_msgid = <fs_msgid>.
          ENDIF.
          IF <fs_msgno> IS ASSIGNED AND <fs_msgno> IS NOT INITIAL.
            lv_msgno = <fs_msgno>.
          ENDIF.
          IF <fs_msgv1> IS ASSIGNED AND <fs_msgv1> IS NOT INITIAL.
            lv_msgv1 = <fs_msgv1>.
          ENDIF.
          IF <fs_msgv2> IS ASSIGNED AND <fs_msgv2> IS NOT INITIAL.
            lv_msgv2 = <fs_msgv2>.
          ENDIF.
          IF <fs_msgv3> IS ASSIGNED AND <fs_msgv3> IS NOT INITIAL.
            lv_msgv3 = <fs_msgv3>.
          ENDIF.
          IF <fs_msgv4> IS ASSIGNED AND <fs_msgv4> IS NOT INITIAL.
            lv_msgv4 = <fs_msgv4>.
          ENDIF.
          IF lv_msgid IS NOT INITIAL
            AND lv_msgno IS NOT INITIAL.
            MESSAGE ID lv_msgid TYPE 'S' NUMBER lv_msgno
              INTO FINAL(mtext1)
              WITH lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
            IF msg IS INITIAL.
              msg = mtext1.
            ELSE.
              msg = |{ msg }/{ mtext1 }|.
            ENDIF.
          ENDIF.
          UNASSIGN:<fs_msgid>,<fs_msgno>,<fs_msgv1>,<fs_msgv2>,<fs_msgv3>,<fs_msgv4>.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD get_taxrate_by_code.
*J0    0%
*J1   16%
*J2   13%
*J3   10%
*J4    9%
*J5    1%
*JB    6%
*JC    4%
*R1   2%
*R2   3%
*R3   5%
*R4   12%
*R5   10%
    CASE taxcode.
      WHEN 'J0'.
        taxrate = '0'.
      WHEN 'J1'.
        taxrate = '16'.
      WHEN 'J2'.
        taxrate = '13'.
      WHEN 'J3'.
        taxrate = '10'.
      WHEN 'J4'.
        taxrate = '9'.
      WHEN 'J5'.
        taxrate = '1'.
      WHEN 'JB'.
        taxrate = '6'.
      WHEN 'JC'.
        taxrate = '4'.
      WHEN 'R1'.
        taxrate = '2'.
      WHEN 'R2'.
        taxrate = '3'.
      WHEN 'R3'.
        taxrate = '5'.
      WHEN 'R4'.
        taxrate = '12'.
      WHEN 'R5'.
        taxrate = '10'.
    ENDCASE.
  ENDMETHOD.

  METHOD matnr_zero_in.
    DATA:lv_matnr TYPE char18.
    lv_matnr = input.
    lv_matnr = |{ lv_matnr ALPHA = IN }|.
    output = lv_matnr.
  ENDMETHOD.

  METHOD get_javatimestamp.
    DATA: date          TYPE sy-datum,
          time          TYPE sy-uzeit,
          saptimestamp  TYPE timestamp,
          javatimestamp TYPE string,
          lv_ts         TYPE string.

    DATA:lv_date TYPE sy-datum,   "日期
         lv_time TYPE sy-uzeit.   "时间

*获取sap时间戳(格林威治时间)
    GET TIME STAMP FIELD saptimestamp .

*TTZZ可以查看时区
*将时间戳转换为日期时间(此时的日期是格林威治日期时间)
    CONVERT TIME STAMP saptimestamp TIME ZONE 'UTC'
         INTO DATE date
              TIME time .

*时间戳是指格林威治时间1970年01月01日00时00分00秒(北京时间1970年01月01日08时00分00秒)起至现在的总秒数。
    CALL METHOD zcl_com_util=>convert_abap_timestamp_to_java
      EXPORTING
        iv_date      = date
        iv_time      = time
      IMPORTING
        ev_timestamp = ts.    "JAVA时间戳

  ENDMETHOD.

  METHOD convert_abap_timestamp_to_java.

    DATA:
      lv_date           TYPE sy-datum,
      lv_days_timestamp TYPE timestampl,
      lv_secs_timestamp TYPE timestampl,
      lv_days_i         TYPE i,
      lv_sec_i          TYPE i,
      lv_timestamp      TYPE timestampl,
      lv_dummy          TYPE string.                        "#EC NEEDED

    CONSTANTS:
       lc_day_in_sec TYPE i VALUE 86400.

* Milliseconds for the days since January 1, 1970, 00:00:00 GMT
* one day has 86400 seconds
    lv_date            = '19700101'.
    lv_days_i          = iv_date - lv_date.
* Timestamp for passed days until today in seconds
    lv_days_timestamp  = lv_days_i * lc_day_in_sec.

    lv_sec_i          = iv_time.
* Timestamp for time at present day
    lv_secs_timestamp = lv_sec_i.

    lv_timestamp = ( lv_days_timestamp + lv_secs_timestamp ).
    ev_timestamp = lv_timestamp.

    SPLIT ev_timestamp AT '.' INTO ev_timestamp lv_dummy.
*    ev_timestamp = ev_timestamp + iv_msec.

    SHIFT ev_timestamp RIGHT DELETING TRAILING space.
    SHIFT ev_timestamp LEFT  DELETING LEADING space.



  ENDMETHOD.
ENDCLASS.
