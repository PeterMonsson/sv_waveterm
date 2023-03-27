// Basic example code showcasing how to use sv_waveterm with assertions
// License for example code: CC0 "No Rights Reserved"

module tb;

  `include "sv_waveterm.sv"  
  
  logic clk = 0;
  always #5 clk <= !clk;
  logic reset_b = '0;
  initial #17 reset_b = '1;
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

  a_not_9 : assert property(
      @(posedge clk) disable iff (!reset_b)
      counter != 9
   ) else $fatal(0, "Counter is 9\n%s", counter_waves.sprint());

   a_not_5 : assert property(
      @(posedge clk) disable iff (!reset_b)
      counter != 5
   ) else $error("Counter is 5\n%s", counter_waves.sprint());

   a_not_4 : assert property(
      @(posedge clk) disable iff (!reset_b)
      counter != 4
   ) else $error("Counter is 4\n%s", counter_waves.sprint());
     
endmodule // tb
