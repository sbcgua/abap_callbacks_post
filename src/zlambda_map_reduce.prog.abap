class lcl_lambda_map_reduce definition final.
  public section.

    types:
      begin of ty_map_item,
        item type ref to data,
        index type i,
      end of ty_map_item.

    types:
      begin of ty_reduce_item,
        prev type ref to data,
        item type ref to data,
        index type i,
      end of ty_reduce_item.

    class-methods map
      importing
        it_list type any table
        ii_lambda type ref to lif_lambda
      returning
        value(ri_result) type ref to lif_lambda_result.

    class-methods reduce
      importing
        it_list    type any table
        ii_lambda  type ref to lif_lambda
        iv_initial type any
      returning
        value(ri_result) type ref to lif_lambda_result.

endclass.

class lcl_lambda_map_reduce implementation.

  method map.

    field-symbols <i> type any.
    field-symbols <result> type ref to data.
    data ls_item type ty_map_item.
    data lt_result type standard table of ref to data.

    loop at it_list assigning <i>.
      append initial line to lt_result assigning <result>.
      ls_item-index = sy-tabix.
      get reference of <i> into ls_item-item. " read only
      <result> = ii_lambda->run( ls_item )->raw_ref( ).
    endloop.

    ri_result = lcl_lambda_result=>wrap(
      i_result = lt_result
      iv_tab_of_refs = abap_true ).

  endmethod.

  method reduce.

    field-symbols <i> type any.
    field-symbols <result> type ref to data.

    field-symbols <accum> type any.
    field-symbols <tmp> type any.

    data ls_item type ty_reduce_item.
    data lr_accum type ref to data.
    data lr_tmp type ref to data.

    create data ls_item-prev like iv_initial.
    assign ls_item-prev->* to <accum>.

    loop at it_list assigning <i>.
      ls_item-index = sy-tabix.
      get reference of <i> into ls_item-item. " read only
      lr_tmp = ii_lambda->run( ls_item )->raw_ref( ).
      assign lr_tmp->* to <tmp>.
      <accum> = <tmp>.
    endloop.

    ri_result = lcl_lambda_result=>wrap( <accum> ).

  endmethod.

endclass.
