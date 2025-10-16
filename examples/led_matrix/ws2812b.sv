
module ws2812b(
    input logic clk, 
    input logic serial_in, 
    input logic transmit, 
    output logic ws2812b_out, 
    output logic shift
);

    localparam IDLE = 1'b0;
    localparam TRANSMITTING = 1'b1;

    localparam T0_CYCLE_COUNT = 4'd5;
    localparam T1_CYCLE_COUNT = 4'd10;
    localparam MAX_CYCLE_COUNT = 4'd15;

    logic state = IDLE;
    logic [3:0] cycle_count = 4'd0;
    logic bit_being_sent = 1'b0;

    always_ff @(posedge clk) begin
        unique case (state)
            IDLE:
                if (transmit == 1'b1) begin
                    state <= TRANSMITTING;
                    cycle_count <= 4'd0;
                    bit_being_sent <= serial_in;
                end
            TRANSMITTING:
                if (transmit == 1'b0) begin
                    state <= IDLE;
                end
                else if (cycle_count == MAX_CYCLE_COUNT - 1) begin
                    cycle_count <= 4'd0;
                    bit_being_sent <= serial_in;
                end
                else begin
                    cycle_count <= cycle_count + 1;
                end
        endcase
    end

    always_comb begin
        if (state == TRANSMITTING)
            if (bit_being_sent == 1'b0)
                ws2812b_out = (cycle_count < T0_CYCLE_COUNT);
            else
                ws2812b_out = (cycle_count < T1_CYCLE_COUNT);
        else
            ws2812b_out = 1'b0;
    end

    assign shift = (state == TRANSMITTING) && (cycle_count == 4'd0);

endmodule
