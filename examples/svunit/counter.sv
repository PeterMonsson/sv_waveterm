module counter (input wire clk,
		input wire reset_b,
		output reg [3:0] counter);

  always @(posedge clk or negedge reset_b) begin
    if (!reset_b) begin
      counter <= '0;
    end else begin
      counter <= counter + 1'b1;
    end
  end
endmodule
