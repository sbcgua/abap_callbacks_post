
interface lif_lambda_result.

  methods str returning value(r_val) type string.
  methods int returning value(r_val) type i.
  methods obj returning value(r_val) type ref to object.
  methods struc changing cs_struc type any.
  methods tab changing ct_tab type any table.
  methods raw_ref returning value(r_data) type ref to data.
  methods tab_deref changing ct_tab type standard table. " redo to hashed/sorted

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
        iv_tab_of_refs type abap_bool default abap_false
      returning
        value(ri_result) type ref to lif_lambda_result.

  private section.
    data mr_data type ref to data.
    data mv_tab_of_refs type abap_bool.

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

    lo_result->mv_tab_of_refs = iv_tab_of_refs.
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

    if l_type ca 'Ifp'. " fp ?
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

    if mv_tab_of_refs = abap_true.
      lif_lambda_result~tab_deref( changing ct_tab = ct_tab ).
    else.

      assign mr_data->* to <val>.
      describe field <val> type l_type.

      if l_type ca 'h'.
        ct_tab = <val>.
      else.
        clear ct_tab. " Or raise an exception ?
      endif.

    endif.

  endmethod.

  method lif_lambda_result~raw_ref.
    r_data = mr_data.
  endmethod.

  method lif_lambda_result~tab_deref.

    data lo_type type ref to cl_abap_typedescr.
    lo_type = cl_abap_typedescr=>describe_by_data_ref( mr_data ).
    if lo_type->type_kind <> lo_type->typekind_table.
      return.
    endif.

    field-symbols <tab> type any table.
    field-symbols <ref> type ref to data.
    field-symbols <val> type any.
    field-symbols <dst> type any.

    clear ct_tab.
    assign mr_data->* to <tab>.
    loop at <tab> assigning <ref>.
      append initial line to ct_tab assigning <dst>. " will not work with sorted/hashed
      assign <ref>->* to <val>.
      <dst> = <val>.
    endloop.

  endmethod.

endclass.
