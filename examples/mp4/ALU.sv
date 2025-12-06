// ALU.sv - SystemVerilog version
module ALU (
    input  logic [31:0] SrcA,
    input  logic [31:0] SrcB,
    input  logic [4:0]  ALUControl,
    output logic Zero,
    output logic [31:0] ALUResult
);

localparam ADD = 5'b00000;
localparam SUB = 5'b00001;
localparam AND = 5'b00010;
localparam OR = 5'b00011;
localparam XOR = 5'b00100;
localparam SLT = 5'b00101; // SET_LESS_THAN
localparam SRL = 5'b00110;
localparam SRA = 5'b00111;
localparam SLL = 5'b01000;
localparam SLTU = 5'b01001;
localparam MUL =  5'b01010;
localparam MULH = 5'b01011;
localparam MULHSU = 5'b01100;
localparam MULHU = 5'b01101;
localparam DIV = 5'b01110;
localparam DIVU = 5'b01111;
localparam REM = 5'b10000;
localparam REMU = 5'b10001;

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
        // REM
        REM: begin 
            ALUResult = ($signed(SrcA) % $signed(SrcB)); //rem
        end
        REMU: begin
            ALUResult = SrcA % SrcB;
        end

    endcase
end

endmodule