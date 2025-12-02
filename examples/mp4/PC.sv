// SystemVerilog version of PC with explicit logic types and always_ff
module PC (
    input  logic        clk,
    input logic PCWrite,
    input  logic [31:0] PC_in,
    output logic [31:0] PC_out
);

initial begin
    PC_out <= 32'b00;
end

// there is no reset
always_ff @(posedge clk) begin
    if (PCWrite) begin
        PC_out <= PC_in;
    end
end

endmodule