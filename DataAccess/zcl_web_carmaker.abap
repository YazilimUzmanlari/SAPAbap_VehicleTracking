class ZCL_WEB_CARMAKER definition
  public
  final
  create public .

public section.

  methods CREATE
    importing
      value(IV_CARMAKER) type ZWEB_ST_CARMAKER optional
    returning
      value(EX_RESULT) type ZWEB_ST_RESULT .
  methods READ
    importing
      value(IV_SEARCH) type ZWEB_ST_SEARCH optional
    returning
      value(RV_RESULT) type ZWEB_ST_RESULT .
  methods UPDATE
    importing
      value(IV_CARMAKER) type ZWEB_ST_CARMAKER optional
    returning
      value(RV_RESULT) type ZWEB_ST_RESULT .
  methods DELETE
    importing
      value(IV_CMKRID) type ZWEB_EL_CMKRID optional
    returning
      value(RV_RESULT) type ZWEB_ST_RESULT .
protected section.
private section.
ENDCLASS.



CLASS ZCL_WEB_CARMAKER IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_WEB_CARMAKER->CREATE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_CARMAKER                    TYPE        ZWEB_ST_CARMAKER(optional)
* | [<-()] EX_RESULT                      TYPE        ZWEB_ST_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method CREATE.
    Data: gv_carmaker type zweb_st_carmaker.
    FIELD-SYMBOLS <row> type zweb_st_carmaker.
    if iv_carmaker-cname is initial.
      ex_result-rtype = 3.
      ex_result-rmess = 'Marka Adı Boş Geçilemez.'.
      return.
    endif.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr                   = '01'
        object                        = 'ZCARMAKER'
     IMPORTING
       NUMBER                        = iv_carmaker-cmkrid.
    IF sy-subrc <> 0.
      ex_result-rtype = 3.
      ex_result-rmess = 'Id Numarası alınırken hata oluştu. '.
      return.
    ENDIF.

    insert into zweb_t_carmaker values iv_carmaker.
    create data ex_result-rdata type zweb_st_carmaker.
    assign ex_result-rdata->* to <row>.
    <row> = iv_carmaker.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_WEB_CARMAKER->DELETE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_CMKRID                      TYPE        ZWEB_EL_CMKRID(optional)
* | [<-()] RV_RESULT                      TYPE        ZWEB_ST_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method DELETE.
    FIELD-SYMBOLS <row> type zweb_el_cmkrid.
    create data rv_result-rdata type zweb_el_cmkrid.
    assign rv_result-rdata->* to <row>.
    <row> = iv_cmkrid.



    Delete from zweb_t_carmaker where cmkrid eq iv_cmkrid.
    if sy-subrc <> 0.
      rv_result-rtype = 3.
      rv_result-rmess = 'Silerken hata oluştu. '.
    endif.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_WEB_CARMAKER->READ
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_SEARCH                      TYPE        ZWEB_ST_SEARCH(optional)
* | [<-()] RV_RESULT                      TYPE        ZWEB_ST_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method READ.
    data: lv_top  type zweb_el_pagesize,
          lv_name TYPE zweb_el_cmkrname.
    FIELD-SYMBOLS: <row>    type zweb_st_carmaker,
                   <table>  type any table.
    assign iv_search-search->* to <row>.
    create data rv_result-rdata type zweb_tt_carmaker.
    assign rv_result-rdata->* to <table>.

    lv_top = iv_search-psize * ( iv_search-currp - 1 ).

    if <row>-cmkrid is initial.
      concatenate <row>-cname '%' into lv_name.

      select  *
      from    zweb_t_carmaker
      where   cname like @lv_name
      order by cname
      into table @<table>
      offset @lv_top
      up to @iv_search-psize rows.

      select count( * )
        into rv_result-rcount
      from    zweb_t_carmaker
      where   cname like lv_name.


    else.
      select  *
      from    zweb_t_carmaker
        into table <table>
      where   cmkrid eq <row>-cmkrid.

      select count( * )
        into rv_result-rcount
      from    zweb_t_carmaker.

    endif.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_WEB_CARMAKER->UPDATE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_CARMAKER                    TYPE        ZWEB_ST_CARMAKER(optional)
* | [<-()] RV_RESULT                      TYPE        ZWEB_ST_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method UPDATE.
    FIELD-SYMBOLS <row> type zweb_st_carmaker.
    if iv_carmaker-cname is initial.
      rv_result-rtype = 3.
      rv_result-rmess = 'Marka adı boş geçilemez. '.
      return.
    endif.
    modify zweb_t_carmaker from iv_carmaker.
    if sy-subrc <> 0.
      rv_result-rtype = 3.
      rv_result-rmess = 'Hata oluştu. '.
      return.
    endif.

    create data rv_result-rdata type zweb_st_carmaker.
    assign rv_result-rdata->* to <row>.
    <row> = iv_carmaker.
  endmethod.
ENDCLASS.