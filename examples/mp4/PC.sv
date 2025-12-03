// SystemVerilog version of PC with explicit logic types and always_ff
module PC (
    input  logic        clk,
    input logic PCWrite,
    input  logic [31:0] PC_in,
    output logic [31:0] PC_out
);

// for some reason it doesn't like initial begin 
// actual fpgas have different reactions to initial, so just use reset
// there is no reset

always_ff @(posedge clk) begin
    //  we need to add a reset in the program counter, we cant do initial begin
    // that will always set it to 9
    if (PCWrite) begin
        PC_out <= PC_in + 31'h1000; // in this implementation, instruction memory starts at 31'h1000
    end
    else begin
        PC_out = 31'h1000;
    end
end

endmodule