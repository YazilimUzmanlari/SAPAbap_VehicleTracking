class ZCL_API_CARMODEL definition
  public
  final
  create public .

public section.

  interfaces IF_HTTP_EXTENSION .
protected section.
private section.
ENDCLASS.



CLASS ZCL_API_CARMODEL IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_API_CARMODEL->IF_HTTP_EXTENSION~HANDLE_REQUEST
* +-------------------------------------------------------------------------------------------------+
* | [--->] SERVER                         TYPE REF TO IF_HTTP_SERVER
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method IF_HTTP_EXTENSION~HANDLE_REQUEST.
    Data:   lv_verb     type string,
          lv_carmodel   type zweb_st_carmodel,
          cl_carmodel   type ref to zweb_cl_carmodel,
          lv_result     type zweb_st_result,
          lv_search     type zweb_st_search,
          lv_json       type /ui2/cl_json=>json.
    create object cl_carmodel.
    FIELD-SYMBOLS: <row>    type zweb_st_carmodel.

    lv_verb = server->request->get_header_field( name = '~request_method' ).

    Data(lv_request_cdata) = server->request->get_cdata( ).

    case lv_verb.
      when 'GET'.
        create data lv_search-search type zweb_st_carmodel.
        assign lv_search-search->* to <row>.
        lv_search-psize = server->request->get_form_field( 'psize' ).
        lv_search-currp = server->request->get_form_field( 'currp' ).
        <row>-cmkrid = server->request->get_form_field( 'cmkrid' ).
        <row>-cmdlid = server->request->get_form_field( 'cmdlid' ).
        <row>-cname = server->request->get_form_field( 'cname' ).
        lv_result = cl_carmodel->read( iv_search = lv_search ).

      when 'POST'.
        try.
          /ui2/cl_json=>deserialize(  EXPORTING json = lv_request_cdata
                                      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                      CHANGING data = lv_carmodel
                                   ).
          lv_result = cl_carmodel->create( iv_carmodel = lv_carmodel ).
        catch cx_root into data(e_txt).
          lv_result-rtype = 3.
          lv_result-rmess = 'Post methodunda Create işlemi deserialize edilirken hata oluştu. '.
        endtry.

      when 'PUT'.
        try.
          /ui2/cl_json=>deserialize(  EXPORTING json = lv_request_cdata
                                      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                      CHANGING data = lv_carmodel
                                   ).
          lv_result = cl_carmodel->update( iv_carmodel = lv_carmodel ).
        catch cx_root into data(e_txt1).
          lv_result-rtype = 3.
          lv_result-rmess = 'Post methodunda Create işlemi deserialize edilirken hata oluştu. '.
        endtry.

      when 'PATCH'.
      when 'DELETE'.
        lv_carmodel-cmdlid = server->request->get_form_field( 'cmdlid' ).
        lv_result = cl_carmodel->delete( iv_cmdlid = lv_carmodel-cmdlid ).
      WHEN OTHERS.
        call method server->response->set_status( code = '405'
                                                  reason = 'Method not allowed' ).
        call method server->response->set_header_field( name = 'Allow'
                                value = 'POST, GET, PUT, PATCH, DELETE' ).
    endcase.

  endmethod.
ENDCLASS.