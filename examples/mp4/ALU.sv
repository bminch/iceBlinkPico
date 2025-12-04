// ALU.sv - SystemVerilog version
module ALU (
    input  logic [31:0] SrcA,
    input  logic [31:0] SrcB,
    input  logic [3:0]  ALUControl,
    output logic Zero,
    output logic [31:0] ALUResult
);

localparam ADD = 4'b0000;
localparam SUB = 4'b0001;
localparam AND = 4'b0010;
localparam OR = 4'b0011;
localparam XOR = 4'b0100;
localparam SLT = 4'b0101; // SET_LESS_THAN
localparam SRL = 4'b0110;
localparam SRA = 4'b0111;


always_comb begin // From what I understand if R type works, immediate type works too
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
        XOR: ALUResult = SrcA ^ SrcB;
        SRL: ALUResult = SrcA >> SrcB;
        SRA: ALUResult = SrcA >>> SrcB;

        default: begin
        end
    endcase
end


endmodule