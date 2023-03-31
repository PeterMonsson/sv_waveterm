`include "svunit_defines.svh"
`include "sv_waveterm.sv"

module sv_waveterm_element_unit_test;
  import svunit_pkg::svunit_testcase;

  string name = "sv_waveterm_element_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  sv_waveterm_element my_sv_waveterm_element;


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

    my_sv_waveterm_element = new("counter", 32);
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();
    /* Place Setup Code Here */

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



  `SVUNIT_TESTS_END

endmodule

module sv_waveterm_unit_test;
  import svunit_pkg::svunit_testcase;

  string name = "sv_waveterm_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  logic clk = 0;
  always #5 clk <= !clk;
  logic reset_b;
   
  logic [3:0] counter;

  always @(posedge clk or negedge reset_b) begin
    if (!reset_b) begin
      counter <= '0;
    end else begin
      counter <= counter + 1'b1;
    end
  end

`sv_waveterm_begin(counter_waves, clk)
  `sv_waveterm_int(reset_b)
  `sv_waveterm_int(counter)
`sv_waveterm_end

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
    `SVTEST(display_4)
      repeat (4) @(posedge clk);
      $display(counter_waves.sprint());
      `FAIL_IF(0)
    `SVTEST_END


  `SVUNIT_TESTS_END

endmodule
