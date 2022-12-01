class ZCL_WEB_CARMODEL definition
  public
  final
  create public .

public section.

  methods CREATE
    importing
      value(IV_CARMODEL) type ZWEB_ST_CARMODEL optional
    returning
      value(RV_RESULT) type ZWEB_ST_RESULT .
  methods READ
    importing
      value(IV_SEARCH) type ZWEB_ST_SEARCH optional
    returning
      value(RV_RESULT) type ZWEB_ST_RESULT .
  methods UPDATE
    importing
      value(IV_CARMODEL) type ZWEB_ST_CARMODEL optional
    returning
      value(RV_RESULT) type ZWEB_ST_RESULT .
  methods DELETE
    importing
      value(IV_CMDLID) type ZWEB_DE_CMDLID optional
    returning
      value(RV_RESULT) type ZWEB_ST_RESULT .
protected section.
private section.
ENDCLASS.



CLASS ZCL_WEB_CARMODEL IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_WEB_CARMODEL->CREATE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_CARMODEL                    TYPE        ZWEB_ST_CARMODEL(optional)
* | [<-()] RV_RESULT                      TYPE        ZWEB_ST_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method CREATE.
    FIELD-SYMBOLS: <row> type zweb_st_carmodel.
    if iv_carmodel-cmkrid is initial.
      rv_result-rtype = 3.
      rv_result-rmess = 'Marka Id box geçilemez. '.
      return.
    endif.
    if iv_carmodel-cname is initial.
      rv_result-rtype = 3.
      rv_result-rmess = 'Model adı boş geçilemez.'.
      return.
    endif.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr                   = '01'
        object                        = 'ZCARMODEL'
     IMPORTING
       NUMBER                        = iv_carmodel-cmdlid.
    IF sy-subrc <> 0.
      rv_result-rtype = 3.
      rv_result-rmess = 'Car Model Id Numarası alınırken hata oluştu. '.
      return.
    ENDIF.
    insert into zweb_t_carmodel values @( value #(
      cmdlid = iv_carmodel-cmdlid
      cmkrid = iv_carmodel-cmkrid
      cname = iv_carmodel-cname
      prntid = iv_carmodel-prntid
    ) ).
    IF sy-subrc <> 0.
      rv_result-rtype = 3.
      rv_result-rmess = 'Car Model eklenirken hata oluştu. '.
      return.
    ENDIF.
    create data rv_result-rdata type zweb_st_carmodel.
    assign rv_result-rdata->* to <row>.
    <row> = iv_carmodel.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_WEB_CARMODEL->DELETE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_CMDLID                      TYPE        ZWEB_DE_CMDLID(optional)
* | [<-()] RV_RESULT                      TYPE        ZWEB_ST_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method DELETE.
    FIELD-SYMBOLS <row> type zweb_de_cmdlid.
    create data rv_result-rdata type zweb_de_cmdlid.
    assign rv_result-rdata->* to <row>.
    <row> = iv_cmdlid.

    Delete from zweb_t_carmodel where cmdlid eq iv_cmdlid.
    if sy-subrc ne 0.
      rv_result-rtype = 3.
      rv_result-rmess = 'Silerken hata oluştu. '.
    endif.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_WEB_CARMODEL->READ
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_SEARCH                      TYPE        ZWEB_ST_SEARCH(optional)
* | [<-()] RV_RESULT                      TYPE        ZWEB_ST_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method READ.
    data: lv_name type zweb_de_cmdlname,
          lv_carmodel type zweb_st_carmodel.
    FIELD-SYMBOLS: <row> type zweb_st_carmodel,
                   <table>  type zweb_tt_carmodel." any table.
    assign iv_search-search->* to <row>.
    create data rv_result-rdata type zweb_tt_carmodel.

    assign rv_result-rdata->* to <table>.

    if <row>-cmkrid is initial.
      rv_result-rtype = 3.
      rv_result-rmess = 'Car Maker Id boş olamaz. '.
      return.
    endif.

    concatenate <row>-cname '%' into lv_name.
    if <row>-cmdlid is initial.
      select  carmodel~cmdlid
              carmodel~cmkrid
              carmodel~prntid
              carmodel~cname
              count( distinct child~cmdlid ) as ccount
      from    zweb_t_carmodel as carmodel
        left outer join zweb_t_carmodel as child
            on child~prntid eq carmodel~cmdlid
        into CORRESPONDING FIELDS OF lv_carmodel
      where carmodel~CMKRID eq <row>-cmkrid and
            carmodel~prntid eq <row>-prntid
      group by carmodel~cmdlid
                carmodel~cmkrid
                carmodel~prntid
                carmodel~cname
      order by carmodel~cname.
        if lv_carmodel-ccount gt 0.
          data: lv_search type zweb_st_search,
                cl_carmodel type ref to ZCL_WEB_CARMODEL.

          FIELD-SYMBOLS: <nestedrow> type zweb_st_carmodel,
                         <nestedtable> type zweb_tt_carmodel.

          create object cl_carmodel.

          create data lv_search-search type zweb_st_carmodel.
          assign lv_search-search->* to <nestedrow>.

          lv_search-psize = iv_search-psize.
          lv_search-currp = iv_search-currp.
          <nestedrow>-prntid = lv_carmodel-cmdlid.
          <nestedrow>-cmkrid = <row>-cmkrid.
          Data(lv_result) = cl_carmodel->read( iv_search = lv_search ).
          if lv_result-rtype eq 0.

            lv_carmodel-child = lv_result-rdata.
          endif.
        endif.
        APPEND lv_carmodel to <table>.
        clear lv_carmodel.
      endselect.
    else.

    endif.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_WEB_CARMODEL->UPDATE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_CARMODEL                    TYPE        ZWEB_ST_CARMODEL(optional)
* | [<-()] RV_RESULT                      TYPE        ZWEB_ST_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method UPDATE.
    FIELD-SYMBOLS <row> type zweb_st_carmodel.

    if iv_carmodel-cname is initial.
      rv_result-rtype = 3.
      rv_result-rmess = 'Model adı boş geçilemez. '.
      return.
    endif.
    if iv_carmodel-cmkrid is initial.
      rv_result-rtype = 3.
      rv_result-rmess = 'Marka Id boş geçilemez. '.
      return.
    endif.
    if iv_carmodel-cmdlid is initial.
      rv_result-rtype = 3.
      rv_result-rmess = 'Model Id boş geçilemez. '.
      return.
    endif.

    update  zweb_t_carmodel
    set   cmkrid = @iv_carmodel-cmkrid ,
          cname = @iv_carmodel-cname
    where cmdlid = @iv_carmodel-cmdlid.
    IF sy-subrc <> 0.
      rv_result-rtype = 3.
      rv_result-rmess = 'Car Model güncellenirken hata oluştu. '.
      return.
    ENDIF.
    create data rv_result-rdata type zweb_st_carmodel.
    assign rv_result-rdata->* to <row>.
    <row> = iv_carmodel.
  endmethod.
ENDCLASS.