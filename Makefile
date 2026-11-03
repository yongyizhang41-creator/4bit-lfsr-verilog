# Include common macOS tool locations; command-line overrides remain available.
export PATH := /opt/homebrew/bin:/usr/local/bin:$(PATH)
IVERILOG ?= $(or $(shell command -v iverilog 2>/dev/null),$(firstword $(wildcard /opt/homebrew/bin/iverilog /usr/local/bin/iverilog)),iverilog)
VVP ?= $(or $(shell command -v vvp 2>/dev/null),$(firstword $(wildcard /opt/homebrew/bin/vvp /usr/local/bin/vvp)),vvp)
GTKWAVE ?= $(or $(shell command -v gtkwave 2>/dev/null),$(firstword $(wildcard /opt/homebrew/bin/gtkwave /usr/local/bin/gtkwave)),gtkwave)

.PHONY: sim wave clean

build/lfsr_sim.vvp: rtl/lfsr_4bit.v tb/tb_lfsr_4bit.v
	mkdir -p build
	$(IVERILOG) -g2005 -Wall -s tb_lfsr_4bit -o $@ $^

sim: build/lfsr_sim.vvp
	@if $(VVP) $< > build/simulation.log 2>&1; then cat build/simulation.log; else cat build/simulation.log; exit 1; fi

wave: sim
	$(GTKWAVE) build/lfsr_wave.vcd

clean:
	rm -rf build
