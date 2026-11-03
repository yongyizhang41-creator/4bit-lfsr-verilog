`timescale 1ns/1ps

module tb_lfsr_4bit;
    reg        clk;
    reg        rst;
    reg        enable;
    wire [3:0] lfsr_out;
    reg  [3:0] held_state;
    reg  [3:0] expected [0:15];
    reg [15:0] visited;
    integer i;

    lfsr_4bit dut (
        .clk      (clk),
        .rst      (rst),
        .enable   (enable),
        .lfsr_out (lfsr_out)
    );

    // A 10 ns clock period: rising edges at 5, 15, 25, ... ns.
    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("build/lfsr_wave.vcd");
        $dumpvars(0, tb_lfsr_4bit);

        rst    = 1'b0;
        enable = 1'b0;

        // Apply reset between clock edges.
        #2;
        rst = 1'b1;

        // Allow the DUT's nonblocking update to settle before sampling.
        @(posedge clk);
        #1;
        if (lfsr_out !== 4'b0001) begin
            $display("FAIL TC-01: reset expected 0001, got %b", lfsr_out);
            $fatal(1, "Self-checking test failed");
        end

        $display("PASS TC-01: reset sampled at rising edge; state = %b", lfsr_out);

        // Move away from the seed so hold/reset bugs are observable.
        @(negedge clk);
        rst    = 1'b0;
        enable = 1'b1;
        repeat (2) begin
            @(posedge clk);
            #1;
        end
        if (lfsr_out !== 4'b0111) begin
            $display("FAIL setup: expected 0111 after two updates, got %b", lfsr_out);
            $fatal(1, "Self-checking test failed");
        end

        // TC-04: hold a nonseed state over three rising edges.
        @(negedge clk);
        enable = 1'b0;
        held_state = lfsr_out;
        repeat (3) begin
            @(posedge clk);
            #1;
            if (lfsr_out !== held_state) begin
                $display("FAIL TC-04: expected hold %b, got %b", held_state, lfsr_out);
                $fatal(1, "Self-checking test failed");
            end
        end
        $display("PASS TC-04: nonseed state held for three clock cycles");

        // TC-02: asserting reset must not change state before a rising edge.
        @(negedge clk);
        rst = 1'b1;
        #1;
        if (lfsr_out !== held_state) begin
            $display("FAIL TC-02: state changed before rising edge; got %b", lfsr_out);
            $fatal(1, "Self-checking test failed");
        end
        $display("PASS TC-02: reset did not immediately change state");

        // TC-07 / TC-08: reset a nonseed state even with enable low.
        @(posedge clk);
        #1;
        if (lfsr_out !== 4'b0001) begin
            $display("FAIL TC-07/TC-08: reset with enable=0 expected 0001, got %b", lfsr_out);
            $fatal(1, "Self-checking test failed");
        end
        $display("PASS TC-07/TC-08: mid-sequence reset overrides enable=0");

        // Independent oracle: enumerate the specification, not the DUT equation.
        expected[0]  = 4'b0001;
        expected[1]  = 4'b0011;
        expected[2]  = 4'b0111;
        expected[3]  = 4'b1111;
        expected[4]  = 4'b1110;
        expected[5]  = 4'b1101;
        expected[6]  = 4'b1010;
        expected[7]  = 4'b0101;
        expected[8]  = 4'b1011;
        expected[9]  = 4'b0110;
        expected[10] = 4'b1100;
        expected[11] = 4'b1001;
        expected[12] = 4'b0010;
        expected[13] = 4'b0100;
        expected[14] = 4'b1000;
        expected[15] = 4'b0001;

        // The preceding reset check established that the current state is 0001.
        visited = 16'b0;
        visited[expected[0]] = 1'b1;
        @(negedge clk);
        rst    = 1'b0;
        enable = 1'b1;

        for (i = 1; i <= 15; i = i + 1) begin
            @(posedge clk);
            #1;
            // Reject unknowns before using the output as a bitmap index.
            if ((^lfsr_out) === 1'bx) begin
                $display("FAIL TC-03: unknown state at update %0d: %b", i, lfsr_out);
                $fatal(1, "Self-checking test failed");
            end
            if (lfsr_out === 4'b0000) begin
                $display("FAIL TC-06: zero state at update %0d", i);
                $fatal(1, "Self-checking test failed");
            end
            if (lfsr_out !== expected[i]) begin
                $display("FAIL TC-03: update %0d expected %b, got %b", i, expected[i], lfsr_out);
                $fatal(1, "Self-checking test failed");
            end

            // Updates 1..14 must add new states; update 15 must return to seed.
            if (i < 15) begin
                if (visited[lfsr_out] === 1'b1) begin
                    $display("FAIL TC-05: early repeat at update %0d: %b", i, lfsr_out);
                    $fatal(1, "Self-checking test failed");
                end
                visited[lfsr_out] = 1'b1;
            end else if (lfsr_out !== expected[0]) begin
                $display("FAIL TC-05: did not return to seed at update 15");
                $fatal(1, "Self-checking test failed");
            end
        end

        if (visited !== 16'hfffe) begin
            $display("FAIL TC-05: incomplete nonzero-state coverage: %h", visited);
            $fatal(1, "Self-checking test failed");
        end
        $display("PASS TC-03: all 15 enabled transitions match expected sequence");
        $display("PASS TC-05: 15 distinct nonzero states; return to seed at update 15");
        $display("PASS TC-06: no zero state in the cycle");
        $display("PASS: all implemented TC-01 through TC-08 checks completed");
        $finish;
    end
endmodule
