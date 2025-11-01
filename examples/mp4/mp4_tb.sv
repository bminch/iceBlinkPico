`timescale 10ns/10ns
`include "top.sv"

module mp4_tb;

    logic clk = 0;
    logic LED, RGB_R, RGB_G, RGB_B;


    top u0 (
        .clk            (clk), 
        .LED            (LED), 
        .RGB_R          (RGB_R), 
        .RGB_G          (RGB_G), 
        .RGB_B          (RGB_B)
    );

    initial begin
        $dumpfile("mp4.vcd");
        $dumpvars(0, mp4_tb);
        #100000
        $finish;
    end

    always begin
        #4
        clk = ~clk;
    end

endmodule

