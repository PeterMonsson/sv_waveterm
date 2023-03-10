# Spend less time debugging with sv_waveterm - spend more time on fun work

SV Waveterm shows you a short waveform directly in your log like this:

            +-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+ +
    clk     + +-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+
                    +------------------------
    reset_b  -------+                        
            +-----------+---+---+---+---+---+
    counter |0          |1  |2  |3  |4  |5  |
            +-----------+---+---+---+---+---+

This waveform is a fast way to get more context on a failure than from an error message alone. Seeing the waveform directly in your log may save you a debug session with your waveform viewer, so that you can go back to the fun work faster.

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

# Save time with sv_waveterm

Here is how sv_waveterm saves time from the authors own experience: Nightly regression failed for some tests. Investigation starts:

## Without sv_waveterm

| Action | time |
| ------ | ---- |
| search log for error message | 25 seconds |
| realize that there is too little information to triage issue | (not timed) |
| git fetch, checkout, etc. | 1 minute 5 seconds | 
| compile, elab and wait until waveform viewer is ready | 4 minutes and 20 seconds | 
| add waves, start sim and zoom in on the error |  1 minute and 12 seconds | 
| triage issue | (not timed) | 
| Total | 7 minutes 2 seconds |

## With sv_waveterm

| Action | time |
| ------ | ---- |
| search log for error message | 25 seconds |
| triage issue | (not timed) |
| git fetch, checkout, etc. | 1 minute 5 seconds |
| Total | 1 minute 30 seconds |

## Conclusion

sv_waveterm saved 5 minutes of debugging time compared to the traditional workflow, by saving a compile, elaboration and simulation run with the waveform viewer open. This is just a single data-point, but it gives you an indication on what to expect for your own environment.

As the car ads say: Your mileage may vary.

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
