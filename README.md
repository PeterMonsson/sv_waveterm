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

See a full example for assertions at [examples/basic](./examples/basic/tb.sv)

This could also be additional information in SVUnit error messages:

    `FAIL_IF_LOG(counter == 5, {"Unexpected 5 in counter:\n", counter_waves.sprint()})

See a full example for SVUnit at [examples/svunit](./examples/svunit/counter_unit_test.sv)


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

Licensed under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.    

# Maturity

SV Waveterm is currently low maturity and thus not ready for commercial use. If this is something that you would like to see then please contact me directly:

Twitter: https://twitter.com/SVAssertions

LinkedIn: https://www.linkedin.com/in/petermonsson/
