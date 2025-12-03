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
        // $dumpvars(0, u0.mem.);

        // Manually dump each register
        $dumpvars(0, u0.Reg_File.Registers[0]);
        $dumpvars(0, u0.Reg_File.Registers[1]);
        $dumpvars(0, u0.Reg_File.Registers[2]);
        $dumpvars(0, u0.Reg_File.Registers[3]);
        $dumpvars(0, u0.Reg_File.Registers[4]);
        $dumpvars(0, u0.Reg_File.Registers[5]);
        $dumpvars(0, u0.Reg_File.Registers[6]);
        $dumpvars(0, u0.Reg_File.Registers[7]);
        $dumpvars(0, u0.Reg_File.Registers[8]);
        $dumpvars(0, u0.Reg_File.Registers[9]);
        $dumpvars(0, u0.Reg_File.Registers[10]);
        $dumpvars(0, u0.Reg_File.Registers[11]);
        $dumpvars(0, u0.Reg_File.Registers[12]);
        $dumpvars(0, u0.Reg_File.Registers[13]);
        $dumpvars(0, u0.Reg_File.Registers[14]);
        $dumpvars(0, u0.Reg_File.Registers[15]);
        $dumpvars(0, u0.Reg_File.Registers[16]);
        $dumpvars(0, u0.Reg_File.Registers[17]);
        $dumpvars(0, u0.Reg_File.Registers[18]);
        $dumpvars(0, u0.Reg_File.Registers[19]);
        $dumpvars(0, u0.Reg_File.Registers[20]);
        $dumpvars(0, u0.Reg_File.Registers[21]);
        $dumpvars(0, u0.Reg_File.Registers[22]);
        $dumpvars(0, u0.Reg_File.Registers[23]);
        $dumpvars(0, u0.Reg_File.Registers[24]);
        $dumpvars(0, u0.Reg_File.Registers[25]);
        $dumpvars(0, u0.Reg_File.Registers[26]);
        $dumpvars(0, u0.Reg_File.Registers[27]);
        $dumpvars(0, u0.Reg_File.Registers[28]);
        $dumpvars(0, u0.Reg_File.Registers[29]);
        $dumpvars(0, u0.Reg_File.Registers[30]);
        $dumpvars(0, u0.Reg_File.Registers[31]);
        #100000
        $finish;
    end

    always begin
        #4
        clk = ~clk;
    end

endmodule

