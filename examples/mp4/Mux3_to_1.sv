module Mux3_to_1 (
    input  logic [1:0]  sel,
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic [31:0] C,
    output wire  [31:0] Mux3_to_1_out
);
    assign Mux3_to_1_out = sel[1] ? C : (sel[0] ? B : A);
endmodule
