`timescale 1ns/1ps

module mux_sensores_tb;

    reg  [7:0]  umidade_solo;
    reg  [7:0]  temperatura;
    reg  [15:0] luminosidade;
    reg  [7:0]  umidade_ar;
    reg  [1:0]  sel;
    wire [15:0] canal_selecionado;

    mux_sensores uut (
        .umidade_solo     (umidade_solo),
        .temperatura      (temperatura),
        .luminosidade     (luminosidade),
        .umidade_ar       (umidade_ar),
        .sel              (sel),
        .canal_selecionado(canal_selecionado)
    );

    initial begin
        $dumpfile("mux_sensores.vcd");
        $dumpvars(0, mux_sensores_tb);

        umidade_solo = 8'd28;
        temperatura  = 8'd24;
        luminosidade = 16'd1800;
        umidade_ar   = 8'd72;

        $display("Dados mockados dos sensores:");
        $display("  Umidade Solo : %0d%%", umidade_solo);
        $display("  Temperatura  : %0d C", temperatura);
        $display("  Luminosidade : %0d lux", luminosidade);
        $display("  Umidade Ar   : %0d%%", umidade_ar);
        $display("-------------------------------------------");

        sel = 2'b00;
        #10;
        $display("sel=00 (Umidade Solo) | canal_selecionado = %0d", canal_selecionado);

        sel = 2'b01;
        #10;
        $display("sel=01 (Temperatura)  | canal_selecionado = %0d", canal_selecionado);

        sel = 2'b10;
        #10;
        $display("sel=10 (Luminosidade) | canal_selecionado = %0d", canal_selecionado);

        sel = 2'b11;
        #10;
        $display("sel=11 (Umidade Ar)   | canal_selecionado = %0d", canal_selecionado);

        $display("-------------------------------------------");
        $display("Simulacao concluida.");
        $finish;
    end

endmodule