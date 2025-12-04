module Extend (
    input logic [31:7] in,
    input logic [2:0] ImmSrc,
    output logic [31:0] ImmExt
);

    always_comb begin
        case (ImmSrc)
            // I-type
            3'b000: ImmExt = {{20{in[31]}}, in[31:20]};
            // S-type (stores)
            3'b001: ImmExt = {{20{in[31]}}, in[31:25], in[11:7]};
            // B-type (branches)
            3'b010: ImmExt = {{20{in[31]}}, in[7], in[30:25], in[11:8], 1'b0};
            // J-type (jal)
            3'b011: ImmExt = {{12{in[31]}}, in[19:12], in[20], in[30:21], 1'b0};
            // U-type (lui)
            3'b100: ImmExt = {in[31:12], 12'b0};
            default: ImmExt = 32'bx; // undefined
        endcase
    end

endmodule