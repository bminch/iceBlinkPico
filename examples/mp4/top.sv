`include "memory.sv"
`include "PC.sv"
`include "Register_File.sv"
`include "ALU.sv"
`include "Extend.sv"
`include "ControlUnit.sv"
`include "Mux2_to_1.sv"
`include "Mux3_to_1.sv"
`include "Mux_ALUSrcA.sv"


/*
Basically, memory.sv is implemented complpetely for us already, using all the inputs and ouputs we have passed into memory module, implmement processing for each instruction sets

We can manipulate dmem data in and out and what to write and the wren, as well as funct3 correspondingly. Colors are reflected as a result of all executions
*/

/*

Instructions currently supported: 

addi √
add √
sub √
and √
or √
slt √
xori √
lw lh lb √
sw sh sb √
auipic √

not checked but confident
xor
andi (not checked, but confident) 
ori (not checked, but confident)
slti (not checked, but confident)

# jal, jalr, beq, bltu, blt, 

*/
module top (
    input logic clk, 
    output logic LED, 
    output logic RGB_R, 
    output logic RGB_G, 
    output logic RGB_B
);

    // localparam [3:0] INIT       = 4'd0;
    // localparam [3:0] RED        = 4'd1;
    // localparam [3:0] YELLOW     = 4'd2;
    // localparam [3:0] GREEN      = 4'd3;
    // localparam [3:0] CYAN       = 4'd4;
    // localparam [3:0] BLUE       = 4'd5;
    // localparam [3:0] MAGENTA    = 4'd6;

    // localparam [21:0] STATE_DWELL_CYCLES = 22'd3000000; // defines how long the FSM stays in one state

    // logic [2:0] funct3 = 3'b010;
    // logic dmem_wren = 1'b0;
    // logic [31:0] dmem_address = 31'd0;
    // logic [31:0] dmem_data_in = 31'd0;
    logic [31:0] dmem_data_out;
    logic [31:0] imem_address;     // = 31'h1000; // h means hex, 1 hex bit is 4 bits, .... 0001 0000 0000 0000
    logic [31:0] imem_data_out; // IR (instruction register) storing instructions for future output

    logic led;
    logic reset;

    logic red;
    logic green;
    logic blue;

    // logic [3:0] state = INIT;
    // logic [21:0] count = 22'd0;

    // Wires, non-architectural 
    logic IRWrite, AdrSrc, PCWrite, MemWrite, RegWrite, Zero;
    logic [1:0] ALUSrcA, ResultSrc, ALUSrcB;
    logic [2:0] ImmSrc;
    logic [3:0] ALUControl;
    logic [31:0] Instr, A, RD1, RD2, RD2_out, ImmExt, ALUResult, ALUOut, Adr, Data, Result, ALUSrcA_out, ALUSrcB_out, WriteData, OldPC;

    ControlUnit ControlUnit (
        .clk       (clk),
        .op        (Instr[6:0]),
        .funct3    (Instr[14:12]),
        .funct7    (Instr[30]),
        .Zero      (Zero),
        .PCWrite   (PCWrite),
        .AdrSrc    (AdrSrc),
        .MemWrite  (MemWrite),
        .IRWrite   (IRWrite),
        .ResultSrc (ResultSrc),
        .ALUControl(ALUControl),
        .ALUSrcA   (ALUSrcA),
        .ALUSrcB   (ALUSrcB),
        .ImmSrc    (ImmSrc),
        .RegWrite  (RegWrite)
    );

    PC pc (
        .clk    (clk),
        .PCWrite(PCWrite),
        .PC_in  (Result), // PCNext, advanced by +4 every time
        .PC_out (imem_address)
    );

    Mux_ALUSrcA Mux_ALUSrcA (
        .sel(ALUSrcA),
        .A(imem_address),
        .B(OldPC),
        .C(A),
        .Mux3_to_1_out(ALUSrcA_out)
    );
    Mux3_to_1 Mux_ALUSrcB (
        .sel(ALUSrcB),
        .A(RD2_out),
        .B(ImmExt),
        .C(4),
        .Mux3_to_1_out(ALUSrcB_out)
    );

    // we dont need this????
    Mux2_to_1 Mux_AdrSrc (
        .sel(AdrSrc),
        .A(imem_address),
        .B(ALUOut),
        .Mux2_to_1_out(Adr)
    );

    Register_File Reg_File (
        .clk (clk),
        .WE3 (RegWrite),
        .A1 (Instr[19:15]),
        .A2 (Instr[24:20]),
        .A3 (Instr[11:7]),
        .WD3 (Result),
        .RD1 (RD1),
        .RD2 (RD2)
    );

    always_ff @(posedge clk)begin 
        A <= RD1;
        WriteData <= RD2;
        RD2_out <= RD2;
    end

    Extend Extend (
        .in(Instr[31:7]),
        .ImmSrc(ImmSrc),
        .ImmExt (ImmExt)
    );

    ALU ALU (
        .SrcA(ALUSrcA_out),
        .SrcB(ALUSrcB_out),
        .ALUControl(ALUControl),
        .Zero (Zero),
        .ALUResult(ALUResult)
    );

    always_ff @(posedge clk)begin 
        ALUOut <= ALUResult;
    end

    
    Mux3_to_1 Mux_ResultSrc (
        .sel(ResultSrc),
        .A(ALUOut),
        .B(Data),
        .C(ALUResult),
        .Mux3_to_1_out(Result)
    );


    // imem and dmem are being read at the same time always, but only one is being used at a time
    memory #(
        .IMEM_INIT_FILE_PREFIX  ("rv32i_test")
    ) mem (
        .clk            (clk), 
        .funct3         (Instr[14:12]), // funct3
        .dmem_wren      (MemWrite), 
        .dmem_address   (ALUOut), 
        .dmem_data_in   (WriteData), // LEDs and RGBs are displaying this value, what is being written into the dmem
        .imem_address   (imem_address), 
        .imem_data_out  (imem_data_out), 
        .dmem_data_out  (dmem_data_out), 
        // .reset          (reset), 
        .led            (led), 
        .red            (red), 
        .green          (green), 
        .blue           (blue)
    );

    always_ff @(posedge clk) begin
        if (IRWrite) begin
            Instr <= imem_data_out; 
            OldPC <= imem_address;
        end
    end

    // otherwise there is data cycle memory delay
    assign Data = dmem_data_out;

    // LED and RGB PWM values are purely dmem_in_data because we are writing only full word
    assign LED = ~led;
    assign RGB_R = ~red;
    assign RGB_G = ~green;
    assign RGB_B = ~blue;

endmodule
