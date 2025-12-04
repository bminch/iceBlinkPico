`timescale 10ns/10ns
`include "top.sv"

module mp4_tb;

    logic clk = 0;
    logic LED, RGB_R, RGB_G, RGB_B;
    integer i;


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

        // Dumpvars for memory index 1023 for all four data memories
        $dumpvars(0, u0.mem.dmem0.memory[1023]);
        $dumpvars(0, u0.mem.dmem1.memory[1023]);
        $dumpvars(0, u0.mem.dmem2.memory[1023]);
        $dumpvars(0, u0.mem.dmem3.memory[1023]);
        #100000
        // Display memory index 1023 for all four data memories
        $display("dmem0[1023]=%0d", u0.mem.dmem0.memory[1023]);
        $display("dmem1[1023]=%0d", u0.mem.dmem1.memory[1023]);
        $display("dmem2[1023]=%0d", u0.mem.dmem2.memory[1023]);
        $display("dmem3[1023]=%0d", u0.mem.dmem3.memory[1023]);


        $display("\n=== Final Register Values ===");
        for (i = 0; i <= 23; i = i + 1) begin
            $display("x%0d = %0d (0x%08h)", i, u0.Reg_File.Registers[i], u0.Reg_File.Registers[i]);
        end
        $finish;
    end

    always begin
        #4
        clk = ~clk;
    end

endmodule

