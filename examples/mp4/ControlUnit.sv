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
    output logic [2:0]  ALUControl,
    output logic [1:0]  ALUSrcA,
    output logic [1:0]  ALUSrcB,
    output logic [1:0]  ImmSrc,
    output logic        RegWrite
);


    // Define state variable values
    localparam [3:0] FETCH      = 4'd0;
    localparam [3:0] DECODE     = 4'd1;
    localparam [3:0] MEM_ADR    = 4'd2;
    localparam [3:0] MEM_READ   = 4'd3;
    localparam [3:0] MEM_WB     = 4'd4;
    localparam [3:0] MEM_WRITE  = 4'd5;
    localparam [3:0] EXECUTE_R  = 4'd6;
    localparam [3:0] ALU_WB     = 4'd7;
    localparam [3:0] BEQ        = 4'd8;
    localparam [3:0] JAL        = 4'd9;
    localparam [3:0] EXECUTE_I   = 4'd10;

    // intermediate wires in the Control Unit
    logic Branch;
    logic PCUpdate;
    logic [1:0] ALUOp;

    // Declare state variables
    logic [3:0] current_state = FETCH; // starts with FETCH
    logic [3:0] next_state;

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
                    7'b1100011: next_state = BEQ;       // beq
                    7'b0010011: next_state = EXECUTE_I;  // I-type ALU (addi, etc.)
                    7'b1101111: next_state = JAL;       // jal
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
                next_state = FETCH;
            end
            EXECUTE_I: begin
                ALUSrcA = 2'b10;
                ALUSrcB = 2'b01;
                ALUOp = 2'b10;
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
            2'b00: ALUControl = 3'b000; // addition
            2'b01: ALUControl = 3'b001; // subtraction
            default: begin
                case(funct3) // R–type or I–type ALU
                3'b000: if (RtypeSub)
                            ALUControl = 3'b001; // sub
                        else
                            ALUControl = 3'b000; // add, addi
                        3'b010: ALUControl = 3'b101; // slt, slti
                        3'b100: ALUControl = 3'b100; // xor
                        3'b110: ALUControl = 3'b011; // or, ori
                        3'b111: ALUControl = 3'b010; // and, andi
                        default: ALUControl = 3'bxxx; // ???
                endcase
            end
        endcase
    end

    // Instr Decoder
    always_comb begin
        case (op)
            7'b0000011: ImmSrc = 2'b00; // lw
            7'b0010011: ImmSrc = 2'b00; // I-type (load, ALU immediate)
            7'b0100011: ImmSrc = 2'b01; // S-type (store)
            7'b1100011: ImmSrc = 2'b10; // B-type (branch)
            7'b1101111: ImmSrc = 2'b11; // J-type (jal)
            default:    ImmSrc = 2'b00; // default to I-type
        endcase
    end

endmodule