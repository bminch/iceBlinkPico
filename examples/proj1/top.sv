`include "memory.sv"

module top (
    input logic clk, 
    output logic LED, 
    output logic RGB_R, 
    output logic RGB_G, 
    output logic RGB_B
);

    localparam [3:0] INIT       = 4'd0;
    localparam [3:0] RED        = 4'd1;
    localparam [3:0] YELLOW     = 4'd2;
    localparam [3:0] GREEN      = 4'd3;
    localparam [3:0] CYAN       = 4'd4;
    localparam [3:0] BLUE       = 4'd5;
    localparam [3:0] MAGENTA    = 4'd6;

    localparam [21:0] STATE_DWELL_CYCLES = 22'd3000000;

    logic [2:0] funct3 = 3'b010;
    logic dmem_wren = 1'b0;
    logic [31:0] dmem_address = 31'd0;
    logic [31:0] dmem_data_in = 31'd0;
    logic [31:0] dmem_data_out;
    logic [31:0] imem_address = 31'h1000;
    logic [31:0] imem_data_out;

    logic reset;
    logic led;
    logic red;
    logic green;
    logic blue;

    logic [3:0] state = INIT;
    logic [21:0] count = 22'd0;

    always_ff @(negedge clk) begin
        imem_address <= imem_address + 1;
    end

    always_ff @(negedge clk) begin
        case (state)
            INIT: begin
                dmem_address <= 32'hFFFFFFFC;
                dmem_data_in <= 32'hFFFF0000;
                dmem_wren <= 1'b1;
                count <= STATE_DWELL_CYCLES;
                state <= RED;
            end
            RED: begin
                if (count > 22'd0) begin
                    count <= count - 1;
                end
                else begin
                    dmem_data_in <= 32'hFFFFFF00;
                    count <= STATE_DWELL_CYCLES;
                    state <= YELLOW;
                end
            end
            YELLOW: begin
                if (count > 22'd0) begin
                    count <= count - 1;
                end
                else begin
                    dmem_data_in <= 32'hFF00FF00;
                    count <= STATE_DWELL_CYCLES;
                    state <= GREEN;
                end
            end
            GREEN: begin
                if (count > 22'd0) begin
                    count <= count - 1;
                end
                else begin
                    dmem_data_in <= 32'h0000FFFF;
                    count <= STATE_DWELL_CYCLES;
                    state <= CYAN;
                end
            end
            CYAN: begin
                if (count > 22'd0) begin
                    count <= count - 1;
                end
                else begin
                    dmem_data_in <= 32'h000000FF;
                    count <= STATE_DWELL_CYCLES;
                    state <= BLUE;
                end
            end
            BLUE: begin
                if (count > 22'd0) begin
                    count <= count - 1;
                end
                else begin
                    dmem_data_in <= 32'h00FF00FF;
                    count <= STATE_DWELL_CYCLES;
                    state <= MAGENTA;
                end
            end
            MAGENTA: begin
                if (count > 22'd0) begin
                    count <= count - 1;
                end
                else begin
                    dmem_data_in <= 32'hFFFF0000;
                    count <= STATE_DWELL_CYCLES;
                    state <= RED;
                end
            end
        endcase
    end

    memory #(
        .IMEM_INIT_FILE_PREFIX  ("rv32i_test")
    ) u1 (
        .clk            (clk), 
        .funct3         (funct3), 
        .dmem_wren      (dmem_wren), 
        .dmem_address   (dmem_address), 
        .dmem_data_in   (dmem_data_in), 
        .imem_address   (imem_address), 
        .imem_data_out  (imem_data_out), 
        .dmem_data_out  (dmem_data_out), 
        .reset          (reset), 
        .led            (led), 
        .red            (red), 
        .green          (green), 
        .blue           (blue)
    );

    assign LED = ~led;
    assign RGB_R = ~red;
    assign RGB_G = ~green;
    assign RGB_B = ~blue;

endmodule
