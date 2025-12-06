module Mux2_to_1 (
    input  logic        sel,
    input  logic [31:0] A,
    input  logic [31:0] B,
    output logic [31:0] Mux2_to_1_out
);
    assign Mux2_to_1_out = (sel == 1'b0) ? A : B;
endmodule