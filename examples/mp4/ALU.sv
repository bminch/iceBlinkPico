// ALU.sv - SystemVerilog version
module ALU (
    input  logic [31:0] SrcA,
    input  logic [31:0] SrcB,
    input  logic [2:0]  ALUControl,
    output logic Zero,
    output logic [31:0] ALUResult
);

localparam ADD = 3'b000;
localparam SUB = 3'b001;
localparam AND = 3'b010;
localparam OR = 3'b011;
localparam SLT = 3'b101; // SET_LESS_THAN

always_comb begin
    ALUResult = 32'b0;
    Zero = 0;
    case (ALUControl)
        ADD: begin
            ALUResult = SrcA + SrcB;
            Zero = 0;
        end
        SUB: begin
            ALUResult = SrcA - SrcB;
            if (SrcA == SrcB) begin
                Zero = 1;
            end
            else begin
                Zero = 0;
            end
        end
        AND: ALUResult = SrcA & SrcB;
        OR:  ALUResult = SrcA | SrcB;
        SLT: ALUResult = SrcA < SrcB;
        
        default: begin
        end
    endcase
end


endmodule