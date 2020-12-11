report zlambda_map_reduce_main.

include zlambda.
include zlambda_map_reduce.
include ztest_benchmark.

class lcl_l_map definition final.
  public section.
    interfaces lif_lambda.
endclass.

class lcl_l_map implementation.
  method lif_lambda~run.

    field-symbols <args> type lcl_lambda_map_reduce=>ty_map_item.
    field-symbols <item> type i.

    assign i_workset to <args>.
    assign <args>-item->* to <item>.
    ri_result = lcl_lambda_result=>wrap( |{ <item> } * { <args>-index } = { <item> * <args>-index }| ).

  endmethod.
endclass.

class lcl_l_reduce definition final.
  public section.
    interfaces lif_lambda.
endclass.

class lcl_l_reduce implementation.
  method lif_lambda~run.

    field-symbols <args> type lcl_lambda_map_reduce=>ty_reduce_item.
    field-symbols <prev> type i.
    field-symbols <item> type i.
    data lv_result type i.

    assign i_workset to <args>.
    assign <args>-prev->* to <prev>.
    assign <args>-item->* to <item>.
    lv_result = <prev> + <item>.
    ri_result = lcl_lambda_result=>wrap( lv_result ).

  endmethod.
endclass.

**********************************************************************

class lcl_main_map definition final.
  public section.
    class-methods main.
endclass.

class lcl_main_map implementation.
  method main.

    data lt_ints type table of i.
    data lt_strs type string_table.
    data lo_rnd type ref to cl_abap_random_int.
    data str type string.
    data sum type i.

    lo_rnd = cl_abap_random_int=>create(
      seed = 12345 " uzeit
      min  = 1
      max  = 10 ).

    do 5 times.
      append lo_rnd->get_next( ) to lt_ints.
    enddo.

    data li_mapper type ref to lcl_l_map.
    create object li_mapper.

    lcl_lambda_map_reduce=>map(
      it_list   = lt_ints
      ii_lambda = li_mapper )->tab( changing ct_tab = lt_strs ).
    str = concat_lines_of( table = lt_strs sep = `, ` ).
    write: / 'MAP:', str.

    data li_reducer type ref to lcl_l_reduce.
    create object li_reducer.

    sum = lcl_lambda_map_reduce=>reduce(
      it_list    = lt_ints
      iv_initial = 0
      ii_lambda  = li_reducer )->int( ).
    write: / 'REDUCE:', sum.

  endmethod.
endclass.

start-of-selection.

  lcl_main_map=>main( ).
