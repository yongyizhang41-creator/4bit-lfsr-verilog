# 4-bit LFSR Project Learning Outline

## 1. Learning goals and workflow

Use a small RTL project to learn how to derive hardware from requirements, write Verilog, build a self-checking testbench, and verify a design using actual simulation results.

For each unit:

1. Implement a small change and identify its purpose and affected files.
2. Show the code and explain syntax, hardware meaning, concepts, and tools.
3. Describe expected behavior and report checks actually performed.
4. Review the code and study unfamiliar concepts or ask questions.
5. Continue only after the learner explicitly requests the next unit.

Repository files are in English. Introduce concepts alongside code, rather than generating the entire project at once. Code presentation is not evidence of mastery; hand calculations are not simulation results.

## 2. Design flow

```text
Specification → interface and state → next-state rule
              → block diagram → Verilog RTL
              → testbench → simulation / waveform
              → verification review → documentation / GitHub
```

The specification defines required behavior. The next-state rule defines state transitions. A block diagram identifies hardware components and connections. RTL describes their behavior. Diagrams and rules may evolve together; a complete gate-level diagram is not a prerequisite.

Unified design requirements:

- State: a 4-bit register directly exposed through lfsr_out.
- Update event: posedge clk.
- Priority: reset > enable > hold.
- Reset: active-high synchronous reset, seed 4'b0001.
- Feedback: q[3] XOR q[0].
- Enabled next state: {q[2:0], feedback}.
- Goal: return to the seed after 15 enabled updates, visiting 15 distinct nonzero states.

The earlier bit-1/bit-0 taps conflicted with the listed sequence. The specification and RTL now use bit-3/bit-0 taps. Independent calculations and actual RTL simulation confirmed the sequence; existing TC-01 through TC-08 checks passed.

## 3. Technology stack

| Tool or language | Purpose | Stage |
|---|---|---|
| Verilog-2001 | Synthesizable RTL and testbench | RTL / verification |
| Icarus Verilog: iverilog | Compile and elaborate design and testbench | Simulation |
| Icarus Verilog: vvp | Execute simulation | Simulation |
| VCD | Record signals over simulation time | Testbench / simulation |
| GTKWave | Inspect actual waveforms | Waveform review |
| Makefile | Automate compilation, simulation, waveform viewing, cleanup | Build workflow |
| Git / GitHub | Version control and project presentation | Delivery |
| Editor | Read and edit source code | Throughout |

Physical hardware is not required. Synthesis helps explain hardware mapping, but FPGA deployment and chip implementation are outside the project scope.

## 4. Units

Phase 1 concepts and Phase 2 implementation are interleaved. This is the curriculum order, not an assertion that every concept has been mastered.

| Unit | Classification / Phase | Implementation | Review focus |
|---|---|---|---|
| 1. Module interface | Core / 1–2 | RTL ports and declarations | Module vs. instance, input/output, wire/reg, width, HDL vs. software |
| 2. Clocked reset | Core / 1–2 | Synchronous reset block | Flip-flop/register, posedge, active-high reset, nonblocking assignment, unknown initial state, implicit hold |
| 3. Enabled transition | Core / 1–2 | Feedback and enable branch | Bit-select, part-select, continuous assignment, concatenation, current/next state, priority |
| 4. Minimal testbench | Core / 3 | DUT instance and clock/reset stimulus | Named connections, initial/always, timescale, delay, stimulus timing, blocking vs. nonblocking |
| 5. Reset and hold checks | Core / 3 | Comparisons and failures | Independent expected values, case inequality, unknowns, sampling after nonblocking updates |
| 6. Sequence and period | Core / 3 | Expected list, state tracking, count | Loops, arrays, 15 enabled updates, unique states, zero avoidance, independent oracle |
| 7. Tools and simulation | Supporting / 4 | Check tools, compile and execute | iverilog vs. vvp, paths, exit status, compile errors vs. functional failures |
| 8. Waveform review | Core / 4 | VCD and GTKWave inspection | Dump tasks, clock alignment, reset synchrony, hold interval |
| 9. Verification review | Core / 5 | Check TC-01 through TC-08 | Acceptance criteria, actual logs, failure diagnosis, coverage limits |
| 10. Build automation | Supporting / 6 | Makefile and .gitignore | sim/wave/clean targets, generated artifacts, reproducibility |
| 11. Documentation | Core / 6 | README, architecture, actual screenshot | Hardware explanation, actual results, references, security limits |
| 12. Understanding check | Core / 7 | Explain code and evidence independently | Derive next state; explain reset, enable, period, and limitations |

Core units directly concern behavior, architecture, or verification. Supporting units concern tools and configuration. Both require explanation and review.

## 5. Verification checklist

| Test | Required check |
|---|---|
| TC-01 | Reset to 0001 on a rising edge |
| TC-02 | Reset does not change a known nonseed state before a rising edge |
| TC-03 | Each enabled update matches the independent expected sequence |
| TC-04 | Hold over multiple clock edges when enable=0 and rst=0 |
| TC-05 | 15 distinct nonzero states; update 15 returns to seed |
| TC-06 | No 0000 in the normal sequence |
| TC-07 | Reset mid-sequence returns to seed |
| TC-08 | Reset works with enable=0 |

Report PASS only after all required checks succeed. Failures must provide useful diagnostics and nonzero exit status where supported. Waveform inspection does not replace self-checking comparisons.

## 6. Deliverables and completion criteria

- rtl/lfsr_4bit.v: synthesizable RTL matching the corrected specification.
- tb/tb_lfsr_4bit.v: self-checking TC-01 through TC-08 tests.
- Makefile and .gitignore: reproducible execution and artifact management.
- README.md: explanation, commands, actual results, references, limitations.
- docs/architecture.md: block diagram, taps, transition equation.
- docs/simulation.png: an actual waveform screenshot, never a fabricated one.

Completion requires successful compilation, passing simulation, actual VCD output, and the learner's ability to explain the code and evidence. An ordinary LFSR is deterministic and linear, not cryptographically secure.

## 7. Current position

Units 1–9 have been implemented and reviewed through simulation and verification review. Build automation, documentation, and an actual GTKWave screenshot are present. Additional coverage is deferred. Independent understanding checks remain pending; GitHub publication is the current delivery step.

See PROJECT_LEARNING_ROADMAP.md for progress.
