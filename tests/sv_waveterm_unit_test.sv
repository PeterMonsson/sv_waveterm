`include "svunit_defines.svh"
`include "sv_waveterm.sv"

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

  logic [31:0] big_counter_with_long_name;
   
  always @(posedge clk or negedge reset_b) begin
    if (!reset_b) begin
      big_counter_with_long_name <= '0;
    end else begin
      big_counter_with_long_name <= big_counter_with_long_name + 1'b1;
    end
  end

`sv_waveterm_begin(big_counter_waves, clk)
  `sv_waveterm_int(big_counter_with_long_name)
  `sv_waveterm_int(reset_b)
`sv_waveterm_end


  wire my_clk = clk; //To detect error in get_largest_name()

  logic [2:0] small_counter_with_long_name;
   
  always @(posedge clk or negedge reset_b) begin
    if (!reset_b) begin
      small_counter_with_long_name <= '0;
    end else begin
      small_counter_with_long_name <= small_counter_with_long_name + 1'b1;
    end
  end


`sv_waveterm_begin(small_counter_waves, my_clk)
  `sv_waveterm_int(reset_b)
  `sv_waveterm_int(small_counter_with_long_name)
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
    reset_b = '0;
    repeat (10) @(posedge clk);
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
    `SVTEST(display_3)
      string exp;
      exp = {
"        +-+ +-+ +-+ +-+ +-+ +-+ +", "\n",
"clk     + +-+ +-+ +-+ +-+ +-+ +-+", "\n",
"                +----------------", "\n",
"reset_b  -------+                ", "\n",
"        +-----------+---+---+---+", "\n",
"counter |0          |1  |2  |3  |", "\n",
"        +-----------+---+---+---+", "\n"
};
      repeat (4) @(posedge clk);
      $display(counter_waves.sprint());
      `FAIL_UNLESS_STR_EQUAL(counter_waves.sprint(), exp)
    `SVTEST_END

    `SVTEST(display_5)
      string exp;
      exp = {
"        +-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+ +", "\n",
"clk     + +-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+", "\n",
"                +------------------------", "\n",
"reset_b  -------+                        ", "\n",
"        +-----------+---+---+---+---+---+", "\n",
"counter |0          |1  |2  |3  |4  |5  |", "\n",
"        +-----------+---+---+---+---+---+", "\n"
};
   
      repeat (6) @(posedge clk);
      $display(counter_waves.sprint());
      `FAIL_UNLESS_STR_EQUAL(counter_waves.sprint(), exp)
    `SVTEST_END

    `SVTEST(display_10)
      string exp;
      exp = {
"        +-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+ +", "\n",
"clk     + +-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+", "\n",
"         --------------------------------", "\n",
"reset_b                                  ", "\n",
"        +---+---+---+---+---+---+---+---+", "\n",
"counter |3  |4  |5  |6  |7  |8  |9  |a  |", "\n",
"        +---+---+---+---+---+---+---+---+", "\n"
};
      repeat (11) @(posedge clk);
      $display(counter_waves.sprint());
      `FAIL_UNLESS_STR_EQUAL(counter_waves.sprint(), exp)
    `SVTEST_END

    `SVTEST(big_5)
      string exp;
      exp = {
"                           +---+    +---+    +---+    +---+    +---+    +---+    +---+    +---+    +", "\n",
"clk                        +   +----+   +----+   +----+   +----+   +----+   +----+   +----+   +----+", "\n",
"                           +--------------------------+--------+--------+--------+--------+--------+", "\n",
"big_counter_with_long_name |0                         |1       |2       |3       |4       |5       |", "\n",
"                           +--------------------------+--------+--------+--------+--------+--------+", "\n",
"                                             +------------------------------------------------------", "\n",
"reset_b                     -----------------+                                                      ", "\n"
};
      repeat (6) @(posedge clk);
      $display(big_counter_waves.sprint());
      `FAIL_UNLESS_STR_EQUAL(big_counter_waves.sprint(), exp)
    `SVTEST_END

    `SVTEST(small_5)
      string exp;
      exp = {
"                             +-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+ +", "\n",
"my_clk                       + +-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+", "\n",
"                                     +------------------------", "\n",
"reset_b                       -------+                        ", "\n",
"                             +-----------+---+---+---+---+---+", "\n",
"small_counter_with_long_name |0          |1  |2  |3  |4  |5  |", "\n",
"                             +-----------+---+---+---+---+---+", "\n"
};
   
      repeat (6) @(posedge clk);
      $display(small_counter_waves.sprint());
      `FAIL_UNLESS_STR_EQUAL(small_counter_waves.sprint(), exp)
   $display("hey world3");
    `SVTEST_END
      
  `SVUNIT_TESTS_END

endmodule
