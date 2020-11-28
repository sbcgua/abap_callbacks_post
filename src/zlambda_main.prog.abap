report zlambda_main.

types:
  begin of ty_dummy,
    str type string,
    chr type c length 255,
    int type i,
    dat type d,
  end of ty_dummy.

include zlambda.

**********************************************************************
* dummy

class lcl_dummy definition final.
  public section.
    data mv_val type string.
    class-methods new
      importing
        i_val type string
      returning
        value(ro_inst) type ref to lcl_dummy.
    methods say
      returning
        value(r_val) type string.
endclass.

class lcl_dummy implementation.
  method new.
    create object ro_inst.
    ro_inst->mv_val = i_val.
  endmethod.

  method say.
    r_val = mv_val.
  endmethod.
endclass.

**********************************************************************
* lambdas

class lcl_l_str definition final.
  public section.
    interfaces lif_lambda.
endclass.

class lcl_l_str implementation.
  method lif_lambda~run.
    ri_result = lcl_lambda_result=>wrap( `Hello world` ).
  endmethod.
endclass.

class lcl_l_chr definition final.
  public section.
    interfaces lif_lambda.
endclass.

class lcl_l_chr implementation.
  method lif_lambda~run.
    ri_result = lcl_lambda_result=>wrap( 'Hello world' ).
  endmethod.
endclass.

class lcl_l_int definition final.
  public section.
    interfaces lif_lambda.
endclass.

class lcl_l_int implementation.
  method lif_lambda~run.
    ri_result = lcl_lambda_result=>wrap( 1234 ).
  endmethod.
endclass.

class lcl_l_struc definition final.
  public section.
    interfaces lif_lambda.
endclass.

class lcl_l_struc implementation.
  method lif_lambda~run.
    data ls type ty_dummy.
    ls-str = 'This is struct'.
    ls-chr = 'This is struct'.
    ri_result = lcl_lambda_result=>wrap( ls ).
  endmethod.
endclass.

class lcl_l_say definition final.
  public section.
    interfaces lif_lambda.
endclass.

class lcl_l_say implementation.
  method lif_lambda~run.
    data lo_dummy type ref to lcl_dummy.
    lo_dummy ?= i_workset.
    ri_result = lcl_lambda_result=>wrap( lcl_dummy=>new( |CURRIED: { lo_dummy->say( ) }| ) ).
  endmethod.
endclass.

class lcl_l_tab definition final.
  public section.
    interfaces lif_lambda.
endclass.

class lcl_l_tab implementation.
  method lif_lambda~run.
    data lt_strs type string_table.
    append 'Hello' to lt_strs.
    append 'World' to lt_strs.
    append 'And' to lt_strs.
    append 'Abap' to lt_strs.
    ri_result = lcl_lambda_result=>wrap( lt_strs ).
  endmethod.
endclass.

**********************************************************************
* lambdas PERF

class lcl_lp_str definition final.
  public section.
    interfaces lif_lambda_perf.
endclass.

class lcl_lp_str implementation.
  method lif_lambda_perf~run.
    c_result = `Hello world`.
  endmethod.
endclass.

class lcl_lp_chr definition final.
  public section.
    interfaces lif_lambda_perf.
endclass.

class lcl_lp_chr implementation.
  method lif_lambda_perf~run.
    c_result = 'Hello world'.
  endmethod.
endclass.

class lcl_lp_int definition final.
  public section.
    interfaces lif_lambda_perf.
endclass.

class lcl_lp_int implementation.
  method lif_lambda_perf~run.
    c_result = 1234.
  endmethod.
endclass.

class lcl_lp_struc definition final.
  public section.
    interfaces lif_lambda_perf.
endclass.

class lcl_lp_struc implementation.
  method lif_lambda_perf~run.
    field-symbols <struc> type ty_dummy.
    assign c_result to <struc>.
*    clear <struc>.
    <struc>-str = 'This is struct'.
    <struc>-chr = 'This is struct'.
  endmethod.
endclass.

class lcl_lp_say definition final.
  public section.
    interfaces lif_lambda_perf.
endclass.

class lcl_lp_say implementation.
  method lif_lambda_perf~run.
    data lo_dummy type ref to lcl_dummy.
    lo_dummy ?= i_workset.
    lo_dummy = lcl_dummy=>new( |CURRIED: { lo_dummy->say( ) }| ).
    c_result = lo_dummy.
  endmethod.
endclass.

class lcl_lp_tab definition final.
  public section.
    interfaces lif_lambda_perf.
endclass.

class lcl_lp_tab implementation.
  method lif_lambda_perf~run.
    field-symbols <strs> type string_table.
    assign c_result to <strs>.
    append 'Hello' to <strs>.
    append 'World' to <strs>.
    append 'And'   to <strs>.
    append 'Abap'  to <strs>.
  endmethod.
endclass.

**********************************************************************

class lcl_main definition final.
  public section.
    class-methods main.
    class-methods main_perf.
endclass.

class lcl_main implementation.

  method main.

    data li_lambda type ref to lif_lambda.

    data str type string.
    create object li_lambda type lcl_l_str.
    str = li_lambda->run( )->str( ).
    write: / str.

    data int type i.
    create object li_lambda type lcl_l_int.
    int = li_lambda->run( )->int( ).
    write: / int.

    data lo_dummy type ref to lcl_dummy.
    create object li_lambda type lcl_l_say.
    lo_dummy ?= li_lambda->run( lcl_dummy=>new( 'It works !' ) )->obj( ).
    str = lo_dummy->say( ).
    write: / str.

    data struc type ty_dummy.
    create object li_lambda type lcl_l_struc.
    li_lambda->run( )->struc( changing cs_struc = struc ).
    write: / struc-str.

    data tab type string_table.
    create object li_lambda type lcl_l_tab.
    li_lambda->run( )->tab( changing ct_tab = tab ).
    str = concat_lines_of( table = tab sep = `, ` ).
    write: / str.

  endmethod.

  method main_perf.

    data li_lambda type ref to lif_lambda_perf.

    data str type string.
    create object li_lambda type lcl_lp_str.
    li_lambda->run( changing c_result = str ).
    write: / str.

    data int type i.
    create object li_lambda type lcl_lp_int.
    li_lambda->run( changing c_result = int ).
    write: / int.

    data lo_dummy type ref to lcl_dummy.
    create object li_lambda type lcl_lp_say.
    li_lambda->run(
      exporting
        i_workset = lcl_dummy=>new( 'It works !' )
      changing
        c_result = lo_dummy ).
    str = lo_dummy->say( ).
    write: / str.

    data struc type ty_dummy.
    create object li_lambda type lcl_lp_struc.
    li_lambda->run( changing c_result = struc ).
    write: / struc-str.

    data tab type string_table.
    create object li_lambda type lcl_lp_tab.
    li_lambda->run( changing c_result = tab ).
    str = concat_lines_of( table = tab sep = `, ` ).
    write: / str.

  endmethod.

endclass.

**********************************************************************
* BENCHMARK
**********************************************************************

include ztest_benchmark.
" https://github.com/sbcgua/benchmarks/blob/master/src/ztest_benchmark.prog.abap

class lcl_benchmark_app definition final.
  public section.

    methods run
      importing
        iv_method type string.

    methods char_w_wrapper.
    methods string_w_wrapper.
    methods int_w_wrapper.
    methods obj_w_wrapper.
    methods struc_w_wrapper.
    methods tab_w_wrapper.

    methods char_wo_wrapper.
    methods string_wo_wrapper.
    methods int_wo_wrapper.
    methods obj_wo_wrapper.
    methods struc_wo_wrapper.
    methods tab_wo_wrapper.

    class-methods main.

    data mv_num_rounds type i.
    data mv_xml type xstring.

endclass.

class lcl_benchmark_app implementation.

  method string_w_wrapper.

    data li_lambda type ref to lif_lambda.
    data str type string.
    create object li_lambda type lcl_l_str.
    str = li_lambda->run( )->str( ).

  endmethod.

  method char_w_wrapper.

    data li_lambda type ref to lif_lambda.
    data chr type c length 255.
    create object li_lambda type lcl_l_chr.
    chr = li_lambda->run( )->str( ).

  endmethod.

  method int_w_wrapper.

    data li_lambda type ref to lif_lambda.
    data int type i.
    create object li_lambda type lcl_l_int.
    int = li_lambda->run( )->int( ).

  endmethod.

  method obj_w_wrapper.

    data li_lambda type ref to lif_lambda.
    data lo_dummy type ref to lcl_dummy.
    create object li_lambda type lcl_l_say.
    lo_dummy ?= li_lambda->run( lcl_dummy=>new( 'It works !' ) )->obj( ).

  endmethod.

  method struc_w_wrapper.

    data li_lambda type ref to lif_lambda.
    data struc type ty_dummy.
    create object li_lambda type lcl_l_struc.
    li_lambda->run( )->struc( changing cs_struc = struc ).

  endmethod.

  method tab_w_wrapper.

    data li_lambda type ref to lif_lambda.
    data tab type string_table.
    create object li_lambda type lcl_l_tab.
    li_lambda->run( )->tab( changing ct_tab = tab ).

  endmethod.

  method string_wo_wrapper.

    data li_lambda type ref to lif_lambda_perf.
    data str type string.
    create object li_lambda type lcl_lp_str.
    li_lambda->run( changing c_result = str ).

  endmethod.

  method char_wo_wrapper.

    data li_lambda type ref to lif_lambda_perf.
    data chr type c length 255.
    create object li_lambda type lcl_lp_chr.
    li_lambda->run( changing c_result = chr ).

  endmethod.

  method int_wo_wrapper.

    data li_lambda type ref to lif_lambda_perf.
    data int type i.
    create object li_lambda type lcl_lp_int.
    li_lambda->run( changing c_result = int ).

  endmethod.

  method obj_wo_wrapper.

    data li_lambda type ref to lif_lambda_perf.
    data lo_dummy type ref to lcl_dummy.
    create object li_lambda type lcl_lp_say.
    li_lambda->run(
      exporting
        i_workset = lcl_dummy=>new( 'It works !' )
      changing
        c_result = lo_dummy ).

  endmethod.

  method struc_wo_wrapper.

    data li_lambda type ref to lif_lambda_perf.
    data struc type ty_dummy.
    create object li_lambda type lcl_lp_struc.
    li_lambda->run( changing c_result = struc ).

  endmethod.

  method tab_wo_wrapper.

    data li_lambda type ref to lif_lambda_perf.
    data tab type string_table.
    create object li_lambda type lcl_lp_tab.
    li_lambda->run( changing c_result = tab ).

  endmethod.

  method run.

    data lo_benchmark type ref to lcl_benchmark.

    create object lo_benchmark
      exporting
        io_object = me
        iv_method = iv_method
        iv_times  = mv_num_rounds.

    lo_benchmark->run( ).
    lo_benchmark->print( ).

  endmethod.

  method main.

    data lo_app type ref to lcl_benchmark_app.
    create object lo_app.

    lo_app->mv_num_rounds = 10000.

    lo_app->run( 'char_w_wrapper' ).
    lo_app->run( 'char_wo_wrapper' ).

    lo_app->run( 'string_w_wrapper' ).
    lo_app->run( 'string_wo_wrapper' ).

    lo_app->run( 'int_w_wrapper' ).
    lo_app->run( 'int_wo_wrapper' ).

    lo_app->run( 'obj_w_wrapper' ).
    lo_app->run( 'obj_wo_wrapper' ).

    lo_app->run( 'struc_w_wrapper' ).
    lo_app->run( 'struc_wo_wrapper' ).

    lo_app->run( 'tab_w_wrapper' ).
    lo_app->run( 'tab_wo_wrapper' ).

  endmethod.

endclass.

start-of-selection.

  lcl_main=>main( ).
  uline.
  write: / 'PERF version'.
  uline.
  lcl_main=>main_perf( ).
  uline.
  write: / 'BENCHMARK'.
  uline.
  lcl_benchmark_app=>main( ).
