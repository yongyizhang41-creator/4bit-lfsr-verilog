# Project Learning Roadmap

Design requirements: `4bit_LFSR_Project_Specification.md`. Review one unit at a time before continuing. Repository documentation is written in English.

## Completed units

1. [Core] Module interface, ports, wire/reg, and bit width.
2. [Core] Clocked block, synchronous reset, and nonblocking assignment.
3. [Core] XOR feedback, concatenation, enable, and hold; taps corrected to q[3] / q[0].
4. [Core] Minimal testbench, DUT instance, clock stimulus, and reset sampling.
5. [Core] Reset synchrony, hold, mid-sequence reset, and reset priority checks.
6. [Core] Independent expected sequence, visited bitmap, 15-state period, and zero avoidance.
7. [Supporting] Actual Icarus Verilog compilation / simulation and nonzero failure status; existing TC-01 through TC-08 checks passed.
8. [Core] Actual VCD waveform analysis; the supplied GTKWave screenshot is saved as docs/simulation.png.
9. [Core] Verification review; five temporary RTL mutations were rejected. Coverage limits are documented in docs/verification-review.md.
10. [Supporting] Makefile, .gitignore, and generated artifact management.
11. [Core] README, architecture notes, actual test results, and screenshot integration.
12. [Supporting] English documentation and Git / GitHub repository setup.

## Architecture

Current state → XOR(q[3], q[0]) + concatenation → next_state → reset / enable / hold selection → 4-bit register → lfsr_out.

## Current status

- The single RTL source is rtl/lfsr_4bit.v; the duplicate reference folder has been removed.
- make sim reproduces the tests; .gitignore excludes build/.
- docs/simulation.png is an actual GTKWave screenshot; docs/vcd-reset-hold.svg is a plot of actual VCD data.
- Additional pause/resume, simultaneous reset/enable, and off-edge monitoring checks remain optional. Known coverage limits are retained.
- Published at https://github.com/yongyizhang41-creator/4bit-lfsr-verilog. Local main tracks origin/main.
- [Core] A formal independent understanding check has not been completed. Reviewing code does not by itself establish mastery.
