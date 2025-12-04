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
    localparam [3:0] EXECUTE_U   = 4'd11;
    localparam [3:0] EXECUTE_UPC = 4'd12;
    localparam [3:0] WAIT        = 4'd13;

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
                next_state = WAIT; // what it should be 
               // IRWrite = 1; // should be 0;
               // next_state = DECODE; 
            end
            WAIT: begin
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
                3'b110: ALUControl = 4'b0011; // or, ori
                3'b100: ALUControl = 4'b0100; // xor, xori
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
            7'b0110111: ImmSrc = 3'b100; // U-type (lui)
            7'b0010111: ImmSrc = 3'b100; // U-type (auipc)
            default:    ImmSrc = 3'b000; // default to I-type
        endcase
    end

endmodule