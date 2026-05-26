`include "TP1_2.v"
`timescale 10s/1ms

module TP1_2_tb;
    reg a0, b0, c0;
    wire q0;
    TP1_2 uut (.a(a0), .b(b0), .c(c0));

    initial begin
        $dumpfile("TP1_2.vcd");
        $dumpvars(0,TP1_2_tb);
        a0 = 0; b0 = 0; c0 = 0; #10;
        a0 = 0; b0 = 0; c0 = 1; #10;
        a0 = 0; b0 = 1; c0 = 0; #10;
        a0 = 0; b0 = 1; c0 = 1; #10;
        a0 = 1; b0 = 0; c0 = 0; #10;
        a0 = 1; b0 = 0; c0 = 1; #10;
        a0 = 1; b0 = 1; c0 = 0; #10;
        a0 = 1; b0 = 1; c0 = 1; #10;
        $finish;
    end
endmodule