// Modified Mux3_to_1 to allow supplying 0 for out
module Mux_ALUSrcA (
    input  logic [1:0]  sel,
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic [31:0] C,
    output wire  [31:0] Mux3_to_1_out
);
    assign Mux3_to_1_out = (sel == 2'b11) ? 32'b0 : (sel[1] ? C : (sel[0] ? B : A));
endmodule
