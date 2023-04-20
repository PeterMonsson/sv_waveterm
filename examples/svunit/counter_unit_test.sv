`include "svunit_defines.svh"
`include "counter.sv"
`include "sv_waveterm.sv"  

module counter_unit_test;
  import svunit_pkg::svunit_testcase;

  string name = "counter_ut";
  svunit_testcase svunit_ut;
  
  logic clk = 0;
  always #5 clk <= !clk;
  logic reset_b;
  logic [3:0] counter;

`sv_waveterm_begin(counter_waves, clk)
  `sv_waveterm_int(reset_b)
  `sv_waveterm_int(counter)
`sv_waveterm_end

  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  counter my_counter(.*);

  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();
    /* Place Setup Code Here */
    reset_b = '0;
    #17; 
    reset_b = '1;
  endtask


  //===================================
  // Here we deconstruct anything we 
  // need after running the Unit Tests
  //===================================
  task teardown();
    svunit_ut.teardown();
    /* Place Teardown Code Here */

  endtask


  //===================================
  // All tests are defined between the
  // SVUNIT_TESTS_BEGIN/END macros
  //
  // Each individual test must be
  // defined between `SVTEST(_NAME_)
  // `SVTEST_END
  //
  // i.e.
  //   `SVTEST(mytest)
  //     <test code>
  //   `SVTEST_END
  //===================================
  `SVUNIT_TESTS_BEGIN
    `SVTEST(not_5)
      repeat (6) @(posedge clk);
      `FAIL_IF_LOG(counter == 5, {"Unexpected 5 in counter:\n", counter_waves.sprint()})
    `SVTEST_END
  `SVUNIT_TESTS_END

endmodule
