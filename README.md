# sv_waveterm

SV Waveterm shows you a short waveform directly in your log like this:

            +-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+ +
    clk     + +-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+
                    +------------------------
    reset_b  -------+                        
            +-----------+---+---+---+---+---+
    counter |0          |1  |2  |3  |4  |5  |
            +-----------+---+---+---+---+---+

You display the waveform by defining what signals you want to track with macros:

    `include "sv_waveterm.sv"  
    
    `sv_waveterm_begin(counter_waves, clk)
      `sv_waveterm_int(reset_b)
      `sv_waveterm_int(counter)
    `sv_waveterm_end

And printing the the waves in your error messages:

    $error("Counter is 5\n%s", counter_waves.sprint());

This could for example be an assertion:

    a_not_5 : assert property(
      @(posedge clk) disable iff (!reset_b)
      counter != 5
    ) else $error("Counter is 5\n%s", counter_waves.sprint());

See a full example under [examples/basic](./examples/basic/tb.sv)

# Install

Add <sv_waveterm>/src to your include directory list.

# License

## Example code

All example code is licensed under CC0 "No Rights Reserved" so that you can use the examples freely for anything.

## Source code

sv_waveterm (c) by Peter Monsson

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA. 

# Maturity

SV Waveterm is currently low maturity and thus not ready for commercial use. If this is something that you would like to see then please contact me directly:

Twitter: https://twitter.com/SVAssertions

LinkedIn: https://www.linkedin.com/in/petermonsson/
