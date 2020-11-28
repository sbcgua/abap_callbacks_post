
interface lif_lambda_result.

  methods str returning value(r_val) type string.
  methods int returning value(r_val) type i.
  methods obj returning value(r_val) type ref to object.
  methods struc changing cs_struc type any.
  methods tab changing ct_tab type any table.

endinterface.

interface lif_lambda.

  methods run
    importing
      i_workset type any optional
    returning
      value(ri_result) type ref to lif_lambda_result.

endinterface.

interface lif_lambda_perf.

  methods run
    importing
      i_workset type any optional
    changing
      c_result type any.

endinterface.

**********************************************************************

class lcl_lambda_result definition final.

  public section.
    interfaces lif_lambda_result.
    class-methods wrap
      importing
        i_result type any
      returning
        value(ri_result) type ref to lif_lambda_result.

  private section.
    data mr_data type ref to data.

endclass.

class lcl_lambda_result implementation.

  method wrap.

    data lo_result type ref to lcl_lambda_result.
    create object lo_result.

    data l_type type c.
    describe field i_result type l_type.

    if l_type = 'r'.
      create data lo_result->mr_data type ref to object.
    else.
      create data lo_result->mr_data like i_result.
    endif.

    field-symbols <val> type any.
    assign lo_result->mr_data->* to <val>.
    <val> = i_result.

    ri_result = lo_result.

  endmethod.

  method lif_lambda_result~str.

    field-symbols <val> type any.
    data l_type type c.

    assign mr_data->* to <val>.
    describe field <val> type l_type.

    if l_type ca 'cgNDT'. " bsIPaeF ? Xy ?
      r_val = <val>.
    endif.

  endmethod.

  method lif_lambda_result~int.

    field-symbols <val> type any.
    data l_type type c.

    assign mr_data->* to <val>.
    describe field <val> type l_type.

    if l_type ca 'i'. " fp ?
      r_val = <val>.
    endif.

  endmethod.

  method lif_lambda_result~struc.

    field-symbols <val> type any.
    data l_type type c.

    assign mr_data->* to <val>.
    describe field <val> type l_type.

    if l_type ca 'uv'.
      cs_struc = <val>.
    else.
      clear cs_struc. " Or raise an exception ?
    endif.

  endmethod.

  method lif_lambda_result~obj.

    field-symbols <val> type any.
    data l_type type c.

    assign mr_data->* to <val>.
    describe field <val> type l_type.

    if l_type ca 'r'.
      r_val = <val>.
    endif.

  endmethod.

  method lif_lambda_result~tab.

    field-symbols <val> type any.
    data l_type type c.

    assign mr_data->* to <val>.
    describe field <val> type l_type.

    if l_type ca 'h'.
      ct_tab = <val>.
    else.
      clear ct_tab. " Or raise an exception ?
    endif.

  endmethod.

endclass.
