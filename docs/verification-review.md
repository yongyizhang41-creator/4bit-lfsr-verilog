# Verification Review

## Execution evidence

Compile with `iverilog -g2005 -Wall -s tb_lfsr_4bit -o build/lfsr_sim.vvp rtl/lfsr_4bit.v tb/tb_lfsr_4bit.v`, then execute `vvp build/lfsr_sim.vvp`. The actual run passed with exit status 0 and ended at 216 ns. The output is saved in build/simulation.log and waveform data in build/lfsr_wave.vcd. Use make sim to reproduce the run.

| TC | Scenario | Result |
|---|---|---|
| TC-01 | rst=1; check seed after the rising edge at 5 ns | PASS |
| TC-02 | Assert reset at 60 ns; verify state remains 0111 at 61 ns | PASS |
| TC-03 | Compare 15 enabled updates from 75–215 ns against an independent list | PASS |
| TC-04 | Hold 0111 with enable=0 across rising edges at 35/45/55 ns | PASS |
| TC-05 | Seed plus 14 new states; update 15 returns to seed; bitmap=fffe | PASS |
| TC-06 | Reject unknown and zero states through the full cycle; seed is known nonzero | PASS |
| TC-07 | Reset a nonseed state to 0001 at 65 ns | PASS |
| TC-08 | With rst=1 and enable=0 at 65 ns, output is the seed | PASS |

## Mutation testing

Errors were injected into temporary copies only; project RTL was not modified. Every mutant was recompiled and its simulation returned exit status 1:

| Injected error | First failing check |
|---|---|
| Seed changed to 0000 | TC-01 |
| Taps changed to q[1] XOR q[0] | Nonseed setup |
| Enable ignored | TC-04 |
| Asynchronous reset | TC-02 |
| Reset gated by enable | TC-01 |

These results show that the current suite rejects the listed faults. They do not establish independent execution of every checking branch. Temporary mutation artifacts are not delivered; the observed outcomes are recorded here.

## Limits and future work

- FR-01 rising-edge-only behavior is supported by RTL structure and waveform review; there is no continuous off-edge monitor.
- Hold is checked at 0111; pause followed by resumption is not separately checked.
- Reset priority is tested with enable=0; simultaneous rst=1 and enable=1 is not separately tested.
- TC-02 samples one pre-edge instant, rather than proving all inter-edge behavior.
- One full cycle is exercised from the required seed. This is not formal verification or exhaustive input-sequence testing.
- The RTL lacks a timescale directive and produces a warning. It contains no explicit delay, so current checks are unaffected.
- docs/simulation.png is the supplied actual GTKWave screenshot. The additional SVG is plotted from actual VCD data.

Existing required TC checks passed. Documentation, build automation, and the screenshot are present. Additional coverage is deferred; the independent understanding check remains a separate learning milestone.
