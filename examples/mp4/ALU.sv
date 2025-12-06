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
localparam SLL = 4'b1000;
localparam SLTU = 4'b1001;
localparam MUL =  4'b1010;
localparam MULH = 4'b1011;
localparam MULHSU = 4'b1100;
localparam MULHU = 4'b1101;
localparam DIV = 4'b1110;
localparam DIVU = 4'b1111;

logic[63:0] temp_64 = 64'd0;

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
        SLT: begin
            ALUResult = $signed(SrcA) < $signed(SrcB);
            Zero = ALUResult[0];
        end
        XOR: ALUResult = SrcA ^ SrcB;
        SRL: ALUResult = SrcA >> SrcB[4:0];
        SRA: ALUResult = $signed(SrcA) >>> SrcB[4:0];
        SLL: ALUResult = SrcA << SrcB[4:0];
        SLTU: begin
            ALUResult = $unsigned(SrcA) < $unsigned(SrcB);
            Zero = ALUResult[0];
        end
        // MUL
         MUL: begin
            logic signed [63:0] prod;
            prod = $signed(SrcA) * $signed(SrcB);
            ALUResult = prod[31:0];        // low 32 bits
        end
        MULH: begin // grab the 32 MSB, so need to make sure to keep all info as it becomes 64
            logic signed [63:0] a_ext;
            logic signed [63:0] b_ext;
            logic signed [63:0] prod; // it needs to be local for some reason 
            a_ext = $signed({{32{SrcA[31]}}, SrcA});
            b_ext = $signed({{32{SrcB[31]}}, SrcB});
            prod = a_ext * b_ext;
            ALUResult = prod[63:32];
        end

        MULHSU: begin
            temp_64 = $signed({{32{SrcA[31]}}, SrcA}) * $unsigned({32'b0, SrcB});
            ALUResult = temp_64[63:32]; // high 32 bits, signed × unsigned
        end

        MULHU: begin
            logic unsigned [63:0] prod;
            prod = $unsigned(SrcA) * $unsigned(SrcB);
            ALUResult = prod[63:32];  // high 32 bits, unsigned × unsigned
        end

        // DIV 
        DIV: begin
            if (SrcB != 0)
                ALUResult = $signed(SrcA) / $signed(SrcB); // signed division
            else
                ALUResult = 32'hFFFFFFFF; // divide by zero -1
        end

        DIVU: begin
            if (SrcB != 0)
                ALUResult = SrcA / SrcB;  // unsigned division
            else
                ALUResult = 32'hFFFFFFFF; // divide by zero, ff :(
        end
        default: begin
        end
    endcase
end


endmodule