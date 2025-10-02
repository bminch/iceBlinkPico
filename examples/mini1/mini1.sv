module top(
	input logic clk,
	output logic RGB_R,
	output logic RGB_G,
	output logic RGB_B
);
	// CLK frequency is 12MHz, so 6,000,000 cycles is 0.5s
	parameter int ONE_SEC_INTERVAL = 12000000; // 1s
    parameter int COLOR_CHANGE_INTERVAL = ONE_SEC_INTERVAL / 6;
	logic [$clog2(COLOR_CHANGE_INTERVAL)-1:0] time_counter = 0;
    logic [2:0] color_counter = 3'd0; // 3 bits enough to cover 6 colors

	// on/off states for RGB in ACTIVE HIGH logic space
	logic r_on, g_on, b_on;

    always_comb begin
		case (color_counter)
			3'd0: begin r_on = 1; g_on = 0; b_on = 0; end // Red
			3'd1: begin r_on = 1; g_on = 1; b_on = 0; end // Yellow
			3'd2: begin r_on = 0; g_on = 1; b_on = 0; end // Green
			3'd3: begin r_on = 0; g_on = 1; b_on = 1; end // Cyan
			3'd4: begin r_on = 0; g_on = 0; b_on = 1; end // Blue
			3'd5: begin r_on = 1; g_on = 0; b_on = 1; end // Magenta
			default: begin r_on = 0; g_on = 0; b_on = 0; end
        endcase
    end

	always_ff @(posedge clk) begin
		if (time_counter == COLOR_CHANGE_INTERVAL - 1) begin
			time_counter <= '0;
			if(color_counter == 3'd5) begin
				color_counter <= 3'd0;
			end else begin
            	color_counter <= color_counter + 3'd1;
			end
	    end 
		else begin
			time_counter <= time_counter + 1'b1;
		end
	end

	// invert the signals to match ACTIVE LOW design in the LED circuit
	assign RGB_R = ~r_on;
	assign RGB_G = ~g_on;
	assign RGB_B = ~b_on;

endmodule