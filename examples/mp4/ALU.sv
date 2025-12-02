// ALU.sv - SystemVerilog version
module ALU (
    input  logic [31:0] SrcA,
    input  logic [31:0] SrcB,
    input  logic [2:0]  ALUControl,
    output logic [31:0] ALUResult,
);

always_comb begin
    case (ALUControl)
        3'b000: ALUResult = SrcA + SrcB;
        default: ALUResult = 32'd0;
    endcase
end


endmodule