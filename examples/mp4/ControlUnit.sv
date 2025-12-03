module ControlUnit (
    input  logic        clk,
    input logic [6:0]  op,
    input logic [2:0]  funct3,
    input logic        funct7,
    input logic        Zero
    output logic        PCWrite,
    output logic        AdrSrc,
    output logic        MemWrite,
    output logic        IRWrite,
    output logic [1:0]  ResultSrc,
    output logic [2:0]  ALUControl,
    output logic [1:0]  ALUSrcA,
    output logic [1:0]  ALUSrcB,
    output logic [1:0]  ImmSrc,
    output logic        RegWrite,
);


    // Define state variable values
    localparam FETCH = 
    localparam DECODE = 
    localparam MEM_ADR = 
    localparam MEM_READ =
    localparam MEM_WB = 
    localparam MEM_WRITE = 
    localparam EXECUTE_R = 
    localparam ALU_WB = 
    localparam BEQ = 

    // intermediate wires in the Control Unit
    logic Branch;
    logic PCUpdate;
    logic [1:0] ALUOp;

    // Declare state variables
    logic [1:0] current_state = FETCH; // starts with FETCH
    logic [1:0] next_state;

/*
Enable signals (RegWrite, MemWrite,
IRWrite, PCUpdate, and Branch) are listed only when they are asserted;
otherwise, they are 0.
*/
    always_comb begin
        next_state = 2'bxx;
        case (current_state)
            FETCH:
                AdrSrc = 0;
                IRWrite = 1;
                ALUSrcA = 2'b00;
                ALUSrcB = 2'b10;
                ALUOp = 2'b00;
                ResultSrc = 2'b10;
                PCUpdate = 1;
                next_state = DECODE;
            DECODE:
                ALUSrcA = 2'b01;
                ALUSrcB = 2'b01;
                ALUOp = 2'b00;
                // lw and sw
                if (op == 7'b0000011 || op == 7'b0100011) begin
                    next_state = MEM_ADR;
                end
                else if(op == 7'b0110011) begin // R Type
                    next_state = EXECUTE_R;
                end
                else if(op == 7'b1100011) begin // beq
                    next_state = BEQ;
                end
            MEM_ADR:
                ALUSrcA = 2'b10;
                ALUSrcB = 2'b01;
                ALUOp = 2'b00;

                if (op == 7'b0000011) begin
                    next_state = MEM_READ;
                end
                else if( op == 7'b0100011) begin
                    next_state = MEM_WRITE
                end
            MEM_READ:
                ResultSrc = 2'b00;
                AdrSrc = 1;
                next_state = MEM_WB;

            MEM_WB:
                ResultSrc = 2'b01;
                RegWrite = 1;
                next_state = FETCH;

            MEM_WRITE:
                ResultSrc = 2'b00;
                AdrSrc = 1;
                MemWrite = 1;
                next_state = FETCH;

            EXECUTE_R:
                ALUSrcA = 2'b10;
                ALUSrcB = 2'b00;
                ALUOp = 2'b10;
                next_state = ALU_WB;

            ALU_WB:
                ResultSrc = 2'b00;
                RegWrite = 1;

                next_state = FETCH;

            BEQ:
                ALUSrcA = 2'b10;
                ALUSrcB = 2'b00;
                ALUOp = 2'b01;
                ResultSrc = 2'b00;
                next_state = FETCH;
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
                        3'b110: ALUControl = 3'b011; // or, ori
                        3'b111: ALUControl = 3'b010; // and, andi
                        default: ALUControl = 3'bxxx; // ???
                endcase
            end
        endcase
    end

    // Instr Decoder
    assign ImmSrc = op;

endmodule