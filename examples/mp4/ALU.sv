// ALU.sv - SystemVerilog version
module ALU (
    input  logic [31:0] SrcA,
    input  logic [31:0] SrcB,
    input  logic [2:0]  ALUControl,
    output logic Zero,
    output logic [31:0] ALUResult
);

always_comb begin
    ALUResult = 32'b0;
    Zero = 0;
    case (ALUControl)
        3'b000: begin
            ALUResult = SrcA + SrcB;
            Zero = 0;
        end
        3'b001: begin
            ALUResult = SrcA - SrcB;
            if (SrcA == SrcB) begin
                Zero = 1;
            end
            else begin
                Zero = 0;
            end
        end
        // and, or, slt
        default: begin
        end
    endcase
end


endmodule