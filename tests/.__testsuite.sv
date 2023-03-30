module __testsuite;
  import svunit_pkg::svunit_testsuite;

  string name = "__ts";
  svunit_testsuite svunit_ts;
  
  
  //===================================
  // These are the unit tests that we
  // want included in this testsuite
  //===================================
  sv_waveterm_element_unit_test sv_waveterm_element_ut();
  sv_waveterm_unit_test sv_waveterm_ut();


  //===================================
  // Build
  //===================================
  function void build();
    sv_waveterm_element_ut.build();
    sv_waveterm_ut.build();
    svunit_ts = new(name);
    svunit_ts.add_testcase(sv_waveterm_element_ut.svunit_ut);
    svunit_ts.add_testcase(sv_waveterm_ut.svunit_ut);
  endfunction


  //===================================
  // Run
  //===================================
  task run();
    svunit_ts.run();
    sv_waveterm_element_ut.run();
    sv_waveterm_ut.run();
    svunit_ts.report();
  endtask

endmodule
