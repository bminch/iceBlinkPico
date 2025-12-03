module Mux3_to_1 (
    input  logic [1:0]  sel,
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic [31:0] C,
    output logic [31:0] Mux3_to_1_out
);
    always_comb begin
        case (sel)
            2'b00: Mux3_to_1_out = A;
            2'b01: Mux3_to_1_out = B;
            2'b10: Mux3_to_1_out = C;
            default: Mux3_to_1_out = A; // we need something ilke this in case the sel is b'11
            // but should never happen
        endcase
    end
endmodule