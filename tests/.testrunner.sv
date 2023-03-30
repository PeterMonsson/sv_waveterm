`ifdef RUN_SVUNIT_WITH_UVM
  import uvm_pkg::*;
`endif

module testrunner();
  import svunit_pkg::svunit_testrunner;
`ifdef RUN_SVUNIT_WITH_UVM
  import svunit_uvm_mock_pkg::svunit_uvm_test_inst;
  import svunit_uvm_mock_pkg::uvm_report_mock;
`endif

  string name = "testrunner";
  svunit_testrunner svunit_tr;


  //==================================
  // These are the test suites that we
  // want included in this testrunner
  //==================================
  __testsuite __ts();


  //===================================
  // Main
  //===================================
  initial
  begin

    `ifdef RUN_SVUNIT_WITH_UVM_REPORT_MOCK
      uvm_report_cb::add(null, uvm_report_mock::reports);
    `endif

    build();

    `ifdef RUN_SVUNIT_WITH_UVM
      svunit_uvm_test_inst("svunit_uvm_test");
    `endif

    run();
    $finish();
  end


  //===================================
  // Build
  //===================================
  function void build();
    svunit_tr = new(name);
    __ts.build();
    svunit_tr.add_testsuite(__ts.svunit_ts);
  endfunction


  //===================================
  // Run
  //===================================
  task run();
    __ts.run();
    svunit_tr.report();
  endtask


endmodule
