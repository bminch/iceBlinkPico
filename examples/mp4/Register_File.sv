// Register File
module Register_File (
    input  logic        clk,
    input  logic        WE3,
    input  logic [4:0]  A1,
    input  logic [4:0]  A2,
    input  logic [4:0]  A3,
    input  logic [31:0] WD3,
    output logic [31:0] RD1,
    output logic [31:0] RD2
);

    logic [31:0] Registers [31:0];

    initial begin
        for (int k = 0; k < 32; k++) begin
            Registers[k] = 32'd0;
        end
        Registers[0] = 32'h00001000;
    end

    always_ff @(posedge clk) begin
        if (WE3) begin
            Registers[A3] <= WD3;
        end
    end

    assign RD1 = Registers[A1];
    assign RD2 = Registers[A2];

endmodule