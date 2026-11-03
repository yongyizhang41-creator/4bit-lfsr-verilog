// Complete RTL reference implementation (Verilog-2001).
// Corrected taps: q[3] XOR q[0] matches the specified 15-state sequence.
module lfsr_4bit (
    input  wire       clk,
    input  wire       rst,
    input  wire       enable,
    output reg  [3:0] lfsr_out //register state
);

    // Combinational logic: calculate a candidate next state continuously.
    wire       feedback;
    wire [3:0] next_state; //combinational logic state

    assign feedback   = lfsr_out[3] ^ lfsr_out[0];
    assign next_state = {lfsr_out[2:0], feedback};

    // Sequential logic: synchronous reset > enable > implicit hold.
    always @(posedge clk) begin
        if (rst) begin
            lfsr_out <= 4'b0001;
        end else if (enable) begin
            lfsr_out <= next_state;
        end
    end

endmodule
