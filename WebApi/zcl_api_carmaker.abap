class ZCL_API_CARMAKER definition
  public
  final
  create public .

public section.

  interfaces IF_HTTP_EXTENSION .
protected section.
private section.
ENDCLASS.



CLASS ZCL_API_CARMAKER IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_API_CARMAKER->IF_HTTP_EXTENSION~HANDLE_REQUEST
* +-------------------------------------------------------------------------------------------------+
* | [--->] SERVER                         TYPE REF TO IF_HTTP_SERVER
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method IF_HTTP_EXTENSION~HANDLE_REQUEST.
    Data: lv_verb     Type string,
          lv_carmaker type zweb_st_carmaker,
          cl_carmaker type ref to zcl_web_carmaker,
          lv_result   type zweb_st_result,
          lv_search   type zweb_st_search,
          lv_json     type /ui2/cl_json=>json.
    create object cl_carmaker.
    FIELD-SYMBOLS: <row> type zweb_st_carmaker.

    lv_verb = server->request->get_header_field( name = '~request_method' ).

    DATA(lv_request_cdata) = server->request->get_cdata( ).

    case lv_verb.
      when 'GET'.
        create data lv_search-filter type zweb_st_carmaker.
        assign lv_search-filter->* to <row>.


        lv_search-psize = server->request->get_form_field( 'psize' ).
        lv_search-currp = server->request->get_form_field( 'currp' ).
        <row>-cmkrid  = server->request->get_form_field( 'cmkrid' ).
        <row>-cname = server->request->get_form_field( 'cname' ).
        lv_result = cl_carmaker->read( iv_search = lv_search ).

      when 'POST'.
        try.
          /ui2/cl_json=>deserialize( EXPORTING json = lv_request_cdata
                                      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                      CHANGING data = lv_carmaker ).

        catch cx_root into data(e_txt).
        endtry.
        lv_result = cl_carmaker->create( iv_carmaker = lv_carmaker ).
      when 'PUT'.
        try.
          /ui2/cl_json=>deserialize( EXPORTING json = lv_request_cdata
                                      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                      CHANGING data = lv_carmaker ).

        catch cx_root into data(e_txt1).
        endtry.
        lv_result = cl_carmaker->update( iv_carmaker = lv_carmaker ).
      when 'DELETE'.
        lv_carmaker-cmkrid = server->request->get_form_field( 'cmkrid' ).
        lv_result = cl_carmaker->delete( iv_cmkrid = lv_carmaker-cmkrid ).
      when OTHERS.
        call method server->response->set_status( code = '405'
                                                reason = 'Method not allowed'
                                                 ).
        call method server->response->set_header_field( name = 'Allow'
                                                  value = 'POST, GET, PUT, DELETE' ).
    endcase.

    lv_json = /ui2/cl_json=>serialize( data = lv_result ).
    call method server->response->set_cdata( data = lv_json ).

  endmethod.
ENDCLASS.