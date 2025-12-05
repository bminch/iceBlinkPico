module ControlUnit (
    input  logic        clk,
    input logic [6:0]  op,
    input logic [2:0]  funct3,
    input logic        funct7,
    input logic        Zero,
    output logic        PCWrite,
    output logic        AdrSrc,
    output logic        MemWrite,
    output logic        IRWrite,
    output logic [1:0]  ResultSrc,
    output logic [3:0]  ALUControl,
    output logic [1:0]  ALUSrcA,
    output logic [1:0]  ALUSrcB,
    output logic [2:0]  ImmSrc,
    output logic        RegWrite
);


    // Define state variable values
    localparam [4:0] FETCH      = 5'd0;
    localparam [4:0] DECODE     = 5'd1;
    localparam [4:0] MEM_ADR    = 5'd2;
    localparam [4:0] MEM_READ   = 5'd3;
    localparam [4:0] MEM_WB     = 5'd4;
    localparam [4:0] MEM_WRITE  = 5'd5;
    localparam [4:0] EXECUTE_R  = 5'd6;
    localparam [4:0] ALU_WB     = 5'd7;
    localparam [4:0] BEQ        = 5'd8;
    localparam [4:0] JAL        = 5'd9;
    localparam [4:0] EXECUTE_I   = 5'd10;
    localparam [4:0] EXECUTE_U   = 5'd11;
    localparam [4:0] EXECUTE_UPC = 5'd12;
    localparam [4:0] JALR        = 5'd13;
    localparam [4:0] JALR_EXEC   = 5'd14;
    localparam [4:0] WAIT        = 5'd15;
    localparam [4:0] EXECUTE_BLT = 5'd16;


    // intermediate wires in the Control Unit
    logic Branch;
    logic PCUpdate;
    logic [1:0] ALUOp;

    // Declare state variables
    logic [4:0] current_state = FETCH; // starts with FETCH
    logic [4:0] next_state;

/*
Enable signals (RegWrite, MemWrite,
IRWrite, PCUpdate, and Branch) are listed only when they are asserted;
otherwise, they are 0.
*/

    always_comb begin
        // all values need to always be explicitly defined inside of a combinational
        AdrSrc = 0;
        MemWrite = 0;
        IRWrite = 0;
        ResultSrc = 0;
        ALUControl = 0;
        ALUSrcA = 0;
        ALUSrcB = 0;
        RegWrite = 0;
        PCUpdate = 0;
        ALUOp = 0;
        Branch = 0;

        // has to be 0 for the beginning since all other variables might not be initialized yet
        next_state = 0;
        case (current_state)
            FETCH: begin
                AdrSrc = 0;
                IRWrite = 1;
                ALUSrcA = 2'b00;
                ALUSrcB = 2'b10;
                ALUOp = 2'b00;
                ResultSrc = 2'b10;
                PCUpdate = 1;
                next_state = DECODE;
            end
            DECODE: begin
                ALUSrcA = 2'b01;
                ALUSrcB = 2'b01;
                ALUOp = 2'b00;
                // use case instead of if/else
                case (op)
                    7'b0000011: next_state = MEM_ADR;   // lw
                    7'b0100011: next_state = MEM_ADR;   // sw
                    7'b0110011: next_state = EXECUTE_R; // R-type
                    7'b1100011: next_state = funct3[2] ? EXECUTE_BLT : BEQ; // beq or blt
                    7'b0010011: next_state = EXECUTE_I;  // I-type ALU (addi, etc.)
                    7'b1101111: next_state = JAL;       // jal
                    7'b1100111: next_state = JALR;      // jalr
                    7'b0110111: next_state = EXECUTE_U; // lui
                    7'b0010111: next_state = EXECUTE_UPC; // auipc
                    // no default to preserve original behavior
                endcase
            end
            MEM_ADR: begin
                ALUSrcA = 2'b10;
                ALUSrcB = 2'b01;
                ALUOp = 2'b00;

                if (op == 7'b0000011) begin
                    next_state = MEM_READ;
                end
                else if( op == 7'b0100011) begin
                    next_state = MEM_WRITE;
                end
            end
            MEM_READ: begin
                ResultSrc = 2'b00;
                AdrSrc = 1;
                next_state = MEM_WB;
            end
            MEM_WB: begin
                ResultSrc = 2'b01;
                RegWrite = 1;
                next_state = FETCH;
            end
            MEM_WRITE: begin
                ResultSrc = 2'b00;
                AdrSrc = 1;
                MemWrite = 1;
                next_state = FETCH;
            end
            EXECUTE_R: begin
                ALUSrcA = 2'b10;
                ALUSrcB = 2'b00;
                ALUOp = 2'b10;
                next_state = ALU_WB;
            end
            ALU_WB: begin
                ResultSrc = 2'b00;
                RegWrite = 1;
                next_state = FETCH;
            end
            BEQ: begin
                ALUSrcA = 2'b10;
                ALUSrcB = 2'b00;
                ALUOp = 2'b01;
                ResultSrc = 2'b00;
                Branch = 1;
                next_state = WAIT;
            end
            EXECUTE_BLT: begin
                ALUSrcA = 2'b10;
                ALUSrcB = 2'b00;
                ALUOp = 2'b11; // thus ALU instruciton will be based on funct3
                ResultSrc = 2'b00;
                Branch = 1;
                next_state = WAIT;
            end
            WAIT: begin // helps with a clock cycle so the offset instruction can catch up
                next_state = FETCH;
            end
            EXECUTE_I: begin
                ALUSrcA = 2'b10;
                ALUSrcB = 2'b01;
                ALUOp = 2'b10;
                next_state = ALU_WB;
            end
            EXECUTE_U: begin
                ALUSrcA = 2'b11; // supply 0
                ALUSrcB = 2'b01;
                ALUOp = 2'b00; // force to just simply add
                next_state = ALU_WB;
            end
            EXECUTE_UPC: begin
                ALUSrcA = 2'b01; // supply the PC
                ALUSrcB = 2'b01;
                ALUOp = 2'b00;
                next_state = ALU_WB;
            end
            JAL: begin
                ALUSrcA = 2'b01;
                ALUSrcB = 2'b10;
                ALUOp = 2'b00;
                ResultSrc = 2'b00;
                PCUpdate = 1;
                next_state = ALU_WB;
            end
            JALR: begin
                ALUSrcA = 2'b01;
                ALUSrcB = 2'b10; 
                ALUOp = 2'b00;
                ResultSrc = 2'b10; 
                RegWrite = 1;      
                next_state = JALR_EXEC;
            end
            JALR_EXEC: begin
                ALUSrcA = 2'b10;   // rs1
                ALUSrcB = 2'b01;   // Imm
                ALUOp = 2'b00;     // add
                ResultSrc = 2'b10; 
                PCUpdate = 1;      // update PC
                next_state = WAIT;
            end
        endcase
    end

    always_ff @(posedge clk)
        current_state <= next_state;

    assign PCWrite = Branch & Zero | PCUpdate;

    // ALU Decoder (same as single cycle)
    logic RtypeSub;
    assign RtypeSub = funct7 & op[5]; // TRUE for R–type subtract
    always_comb begin
        case(ALUOp)
            2'b00: ALUControl = 4'b0000; // addition
            2'b01: ALUControl = 4'b0001; // subtraction
            default: begin
                case(funct3) // R–type or I–type ALU
                3'b000: begin
                    if (RtypeSub) ALUControl = 4'b0001; // sub
                    else ALUControl = 4'b0000; // add, addi
                end
                3'b111: ALUControl = 4'b0010; // and, andi
                3'b110: begin
                    if (op == 7'b1100011) ALUControl = 4'b1001; // slt for bltu
                    else ALUControl = 4'b0011; // or, ori
                end
                3'b100: begin
                    if (op == 7'b1100011) ALUControl = 4'b0101; // slt for blt
                    else ALUControl = 4'b0100; // xor, xori
                end
                3'b010: ALUControl = 4'b0101; // slt, slti
                3'b011: ALUControl = 4'b1001; //sltu

                3'b101: begin
                    if (funct7) ALUControl = 4'b0111; // sra/srai
                    else ALUControl = 4'b0110;// srl, srli
                end
                3'b001: ALUControl = 4'b1000;

                default: ALUControl = 4'bxxx; // ???
                endcase
            end
        endcase
    end

    // Instr Decoder
    always_comb begin
        case (op)
            7'b0000011: ImmSrc = 3'b000; // lw (I-type)
            7'b0010011: ImmSrc = 3'b000; // I-type (ALU immediate)
            7'b0100011: ImmSrc = 3'b001; // S-type (store)
            7'b1100011: ImmSrc = 3'b010; // B-type (branch)
            7'b1101111: ImmSrc = 3'b011; // J-type (jal)
            7'b1100111: ImmSrc = 3'b000; // I-type (jalr)
            7'b0110111: ImmSrc = 3'b100; // U-type (lui)
            7'b0010111: ImmSrc = 3'b100; // U-type (auipc)
            default:    ImmSrc = 3'b000; // default to I-type
        endcase
    end

endmodule