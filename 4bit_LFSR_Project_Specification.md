# 4-bit LFSR Pseudorandom Sequence Generator

> **Project type:** Beginner RTL / Digital Logic Design  
> **Primary language:** Verilog HDL (Verilog-2001)  
> **Goal:** Design, simulate, verify, and explain a 4-bit Linear Feedback Shift Register (LFSR) as a foundational hardware-design project.

## 1. Background and Purpose

This is an independent educational project for a Computer Engineering student who has experience with Python, Java, data structures, and algorithms, and is beginning to study digital system design in Georgia Tech ECE 2020.

The project should demonstrate real understanding of:

- Clock-driven sequential circuits and registers
- XOR feedback and bit shifts
- Register Transfer Level (RTL) descriptions in Verilog
- Self-checking functional testbenches
- RTL simulation, waveform interpretation, and reproducible verification

It is relevant to the foundations of hardware sequence generation and secure hardware research. **A basic LFSR is predictable and is not a cryptographically secure random number generator.** Do not claim side-channel resistance or cryptographic security.

## 2. Technology Stack

| Component | Technology |
|---|---|
| RTL language | Verilog HDL (Verilog-2001) |
| Simulator | Icarus Verilog (`iverilog`, `vvp`) |
| Waveform viewing | GTKWave |
| Development | VS Code and Codex |
| Version control | Git / GitHub |
| Build automation | Makefile |
| Physical hardware | Not required |

## 3. Learning Objectives

1. Explain how Verilog describes hardware, rather than executing like a conventional Python/Java program.
2. Understand `module`, ports, `wire`, `reg`, `always @(posedge clk)` and nonblocking assignment (`<=`).
3. Explain synchronous reset, enable, and state hold behavior.
4. Implement an LFSR with a carefully specified feedback equation.
5. Write and run a **self-checking** testbench instead of only viewing printed outputs.
6. Interpret a VCD waveform and explain how clock edges cause state transitions.
7. Explain why a maximal-length 4-bit LFSR has a 15-state nonzero cycle.
8. Explain why LFSRs alone do not provide cryptographic security.

## 4. RTL Design Specification

### 4.1 Module and Interface

**Module name:** `lfsr_4bit`

| Signal | Direction | Width | Meaning |
|---|---|---:|---|
| `clk` | input | 1 | Rising-edge clock |
| `rst` | input | 1 | Active-high **synchronous** reset |
| `enable` | input | 1 | Permits LFSR advancement |
| `lfsr_out` | output | 4 | Current LFSR state |

### 4.2 Reset and State Rules

- Reset seed: `4'b0001`.
- All state changes occur on the **positive edge** of `clk`.
- Priority order: **reset > enable > hold**.
- At a rising clock edge:
  1. If `rst == 1`, set the state to `0001`, regardless of `enable`.
  2. Else if `enable == 1`, compute the next LFSR state.
  3. Else retain the current state.
- Because reset is synchronous, asserting `rst` between clock edges must **not immediately change** the state.

### 4.3 Feedback and Transition Equation

Use this exact 4-bit Fibonacci-style configuration:

```verilog
feedback   = lfsr_out[3] ^ lfsr_out[0];
next_state = {lfsr_out[2:0], feedback};
```

Equivalent mathematical description (current state `q[3:0]`):

- `next[3] = q[2]`
- `next[2] = q[1]`
- `next[1] = q[0]`
- `next[0] = q[3] XOR q[0]`

**Specification correction:** For the left-shift convention above, the feedback taps are bit 3 and bit 0. The earlier bit-1/bit-0 equation did not match the sequence in §4.4 and did not produce the required 15-state cycle. Keep this corrected equation, the RTL, the architecture diagram, and the expected-state model consistent. The listed sequence is unchanged. All right-hand-side bits refer to the current state before the enabled rising-edge update.

Use nonblocking assignments for clock-triggered state updates.

### 4.4 Expected State Sequence

Starting at the reset seed, each **enabled rising edge** produces the next state:

```text
0001 -> 0011 -> 0111 -> 1111 -> 1110 -> 1101 -> 1010 -> 0101
     -> 1011 -> 0110 -> 1100 -> 1001 -> 0010 -> 0100 -> 1000 -> 0001
```

The LFSR should visit **15 distinct nonzero states**, then return to `0001` after **15 enabled updates**. `0000` is a lock-up state for this simple XOR feedback rule and must not appear during normal operation from the nonzero reset seed.

## 5. Functional Requirements

| ID | Requirement | Acceptance condition |
|---|---|---|
| FR-01 | Rising-edge operation | State updates only on `posedge clk` |
| FR-02 | Synchronous reset | On a rising edge with `rst=1`, output becomes `0001` |
| FR-03 | XOR-feedback shifting | Enabled state transition matches the equation in §4.3 |
| FR-04 | Enable signal | With `enable=0` and no reset, state holds |
| FR-05 | Reset priority | Reset overrides enable |
| FR-06 | State output | `lfsr_out` continuously exposes the current 4-bit state |
| FR-07 | Sequence length | Exactly 15 unique nonzero states before repetition from seed |

## 6. Verification Requirements

Implement `tb/tb_lfsr_4bit.v` as a **self-checking Verilog testbench**. It must independently calculate or enumerate expected outputs, compare them against the DUT, and report failures. Avoid a testbench that only prints waveforms without assertions/comparisons.

| Test | Required check |
|---|---|
| TC-01 Reset | Set `rst=1`; confirm state becomes `0001` on the next rising edge |
| TC-02 Reset synchrony | Confirm reset does not alter the state before a rising edge |
| TC-03 Next-state correctness | Verify each enabled update matches expected sequence |
| TC-04 Hold | Set `enable=0`; confirm no advancement over several clock edges |
| TC-05 15-state period | Confirm all 15 states are distinct and state returns to `0001` after update 15 |
| TC-06 Zero-state avoidance | Confirm no visited state is `0000` |
| TC-07 Reset mid-sequence | Reset after some updates and verify return to seed |
| TC-08 Reset priority | Assert `rst=1` when `enable=0` and verify seed on rising edge |

**Testbench engineering rules:**

- Generate a VCD file with `$dumpfile` and `$dumpvars`.
- Avoid race conditions: check DUT outputs *after* the nonblocking assignments for a clock edge have settled (for example, with a small simulation delay or appropriately scheduled sampling).
- Report a clear **PASS** only if every required test passes; otherwise produce actionable failures and exit with a nonzero status where supported.
- Testbench can use Verilog simulation features that are not synthesizable; the RTL module itself should remain synthesizable.
- Record how the simulation was run and its observed output in the README.

## 7. Repository Structure

```text
4bit-lfsr-verilog/
├── rtl/
│   └── lfsr_4bit.v          # Synthesizable Verilog module
├── tb/
│   └── tb_lfsr_4bit.v       # Self-checking testbench
├── docs/
│   ├── architecture.md      # Block diagram / logic explanation
│   └── simulation.png       # GTKWave screenshot once generated
├── Makefile                 # Commands to compile, simulate and clean
├── .gitignore               # Ignore simulation outputs / generated files
└── README.md                # Explanation and reproducible instructions
```

`docs/simulation.png` should be added **only after a real waveform screenshot exists**; do not generate a fake screenshot. Keep build artifacts such as `.vvp` and `.vcd` outside version control unless intentionally needed.

## 8. Build and Simulation Workflow

The `Makefile` should have targets such as:

- `make sim`: compile with `iverilog`, execute with `vvp`, and run self-checking tests.
- `make wave`: open a generated VCD in GTKWave (if installed).
- `make clean`: delete generated simulation artifacts.

Example commands (adjust output paths to the Makefile):

```bash
mkdir -p build
iverilog -g2005 -o build/lfsr_sim.vvp rtl/lfsr_4bit.v tb/tb_lfsr_4bit.v
vvp build/lfsr_sim.vvp
gtkwave build/lfsr_wave.vcd
```

The final VCD filename should match what the actual testbench creates. If tools are unavailable, state that clearly; do not claim a successful run without execution.

## 9. Documentation Requirements

The `README.md` should explain:

1. What an LFSR is, in beginner-friendly language.
2. The exact 4-bit register update rule and why XOR feedback is used.
3. The meaning of the clock, synchronous reset, and enable signals.
4. The expected 15-state sequence and zero-state lock-up.
5. How to install Icarus Verilog and GTKWave, compile, simulate and inspect waveforms.
6. All tests performed, with **actual** test results once executed.
7. What was learned and what could be improved.
8. Security limitation: deterministic linear feedback is **not cryptographically secure**.
9. Acknowledgment of any tutorial or source code consulted and which parts were personally implemented or modified.

The `docs/architecture.md` should contain the register diagram or a clear textual block diagram, the feedback taps (`q[3]`, `q[0]`), and the transition equation.

## 10. Development Phases for Codex

> **Important collaboration rule:** Codex should work as a tutor and coding partner. Do **not** generate the entire finished project in one step. Explain, pause for understanding, and work incrementally. Do not claim any feature or test is complete until it is actually implemented and verified.

**Agreed learning workflow:** Codex implements one small unit, explains the changed code and its hardware meaning, lists the concepts and tools used, and reports the actual verification status. The learner reviews the code and studies unfamiliar concepts, then explicitly says “continue” before the next unit begins. Keep repository documentation in English; adapt spoken explanations to the learner's preferred language. Phase 1 concepts may be introduced alongside Phase 2 code; comprehension quizzes are optional rather than prerequisites. See `PROJECT_LEARNING_OUTLINE.md` for the curriculum and `PROJECT_LEARNING_ROADMAP.md` for progress.

### Phase 1 — Concepts

Explain, with small examples: clock and rising edge, flip-flop/register, synchronous reset, XOR, shifting, Verilog vs. Python, and blocking (`=`) vs. nonblocking (`<=`) assignments. Ask short comprehension questions.

### Phase 2 — RTL Implementation

Help write `rtl/lfsr_4bit.v` in small steps. Explain each line and what circuit it implies. Match the interface and transition rules exactly.

### Phase 3 — Testbench Implementation

Build an independent expected-state model and self-checking tests. Explain testbench scheduling and why checking immediately at `posedge clk` may read an old value.

### Phase 4 — Simulation

Install/check required tools as applicable, compile and simulate, inspect console results and actual waveforms. Debug any mismatches.

### Phase 5 — Verification Review

Confirm every TC-01 through TC-08 case. Show evidence from real test execution. Identify any untested assumptions or limitations.

### Phase 6 — Documentation & GitHub

Write clear `README.md` and `docs/architecture.md`, add `Makefile` and `.gitignore`, and include an actual waveform screenshot if available. Cite external code/tutorial references as appropriate.

### Phase 7 — Understanding Check

Ask the student to independently explain:

- Why HDL differs from Python/Java
- What changes at `posedge clk`
- Why synchronous reset has no immediate effect between clock edges
- How the XOR taps determine the next state
- Why the output repeats after 15 enabled updates
- Why ordinary LFSRs are not cryptographically secure

## 11. Definition of Done

The project is complete only when:

- [ ] The RTL module has the specified ports and behavior.
- [ ] The code compiles using Icarus Verilog.
- [ ] The self-checking testbench runs and passes TC-01 through TC-08.
- [ ] The 15-state sequence and reset/enable behavior are demonstrated.
- [ ] A real VCD waveform is generated and can be inspected.
- [ ] The repository includes the README, architecture notes, Makefile and `.gitignore`.
- [ ] The student can explain the design and tests without relying on Codex.

## 12. Resume Entry — Use Only After Verified Completion

**4-bit LFSR Pseudorandom Sequence Generator | Verilog, Icarus Verilog, GTKWave**  
*Independent RTL Design Project | November 2026*

- Designed a 4-bit linear feedback shift register in Verilog using clock-driven sequential logic and XOR feedback.
- Developed a self-checking testbench to verify synchronous reset, enable control, and a maximal-length 15-state sequence.
- Simulated the RTL using Icarus Verilog and analyzed the clock and state transitions with GTKWave.

**Resume integrity:** Only include bullets for work personally completed and validated. If adapting a publicly available implementation, credit the source and describe real modifications and testing. Do not represent tutorial code as wholly original.

## 13. Initial Instruction to Codex

> Please read this specification and help me implement the project **incrementally**. I am new to Verilog but have Python and Java experience and am studying digital logic. Start with Phase 1. Teach the key concepts with small examples and check that I understand them before writing the full RTL module. In later phases, make sure all implemented behavior and simulation results match this specification, and help me build a truthful, reproducible GitHub project.
