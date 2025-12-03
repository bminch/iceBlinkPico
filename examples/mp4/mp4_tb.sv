`timescale 10ns/10ns
`include "top.sv"

module mp4_tb;

    logic clk = 0;
    logic resetPC = 0;
    logic LED, RGB_R, RGB_G, RGB_B;


    top u0 (
        .clk            (clk), 
        .resetPC          (resetPC),
        .LED            (LED), 
        .RGB_R          (RGB_R), 
        .RGB_G          (RGB_G), 
        .RGB_B          (RGB_B)
    );

    initial begin
        $dumpfile("mp4.vcd");
        $dumpvars(0, mp4_tb);

        clk = 0;
        resetPC = 1;
        #10;
        resetPC = 0;
        #100000
        $finish;
    end

    always begin
        #4
        clk = ~clk;
    end

endmodule

