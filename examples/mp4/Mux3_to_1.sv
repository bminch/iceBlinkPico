module Mux3_to_1 (
    input  logic [2:0]  sel,
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic [31:0] C,
    output logic [31:0] Mux3_to_1_out
);
    unique case (sel)
        2'b00: Mux3_to_1_out = A;
        2'b01: Mux3_to_1_out = B;
        2'b10: Mux3_to_1_out = C;
        default: Mux3_to_1_out = 32'h0;
    endcase
endmodule