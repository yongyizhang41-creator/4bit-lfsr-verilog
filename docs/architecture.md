# Architecture

The design is a 4-bit Fibonacci LFSR, implemented in Verilog-2001. It contains a 4-bit state register and combinational feedback / next-state logic.

```text
                         +--------------------+
 q[3], q[0] ------------>| XOR                |---- feedback
                         +--------------------+       |
 q[2:0] ---------------------------------------------+-- concatenate
                                                        |
                                                   next_state
                                                        |
 seed 0001 ------------> reset / enable / hold selection |
 current state -------->                                |
                                                        v
 clk ------------------------------------------> 4-bit register
                                                        |
                                                     q[3:0]
                                                        |
                                                     lfsr_out
```

## Interface

| Port | Direction | Width | Meaning |
|---|---|---:|---|
| clk | input | 1 | Rising-edge clock |
| rst | input | 1 | Active-high synchronous reset |
| enable | input | 1 | Advance when reset is inactive |
| lfsr_out | output | 4 | Current state |

## Combinational logic

```verilog
assign feedback   = lfsr_out[3] ^ lfsr_out[0];
assign next_state = {lfsr_out[2:0], feedback};
```

Thus next[3]=q[2], next[2]=q[1], next[1]=q[0], and next[0]=q[3] XOR q[0]. All right-hand-side bits belong to the current state. Concatenation shifts the three low bits toward higher positions and inserts feedback into bit 0.

The taps are bit 3 and bit 0. An earlier specification used bit 1 and bit 0, which did not match the required sequence; the specification and RTL now use the corrected equation.

## Sequential logic

At each rising edge, reset has priority over enable:

1. rst=1: load 0001, regardless of enable.
2. rst=0 and enable=1: load next_state.
3. Otherwise: retain current state.

The register uses nonblocking assignments. Reset changes between rising edges do not immediately change state. No power-up initialization is specified; simulation begins with unknown state until a valid reset edge.

## Verification boundary

The testbench drives inputs on falling edges (apart from initial reset stimulus), samples outputs 1 ns after rising edges, and compares against an enumerated sequence independent of the RTL equation. Delays and waveform dumping belong to the testbench, not the synthesizable RTL. This is functional RTL simulation, not synthesis, physical timing analysis, or a security evaluation.
