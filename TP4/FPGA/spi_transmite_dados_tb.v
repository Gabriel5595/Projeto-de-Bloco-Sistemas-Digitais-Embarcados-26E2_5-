`timescale 1ns/1ps

module spi_transmite_dados_tb;

    reg         sclk;
    reg         cs_n;
    wire        miso;
    reg  [95:0] dados_atuais;

    reg  [7:0]  rx_frame [0:11];
    integer     erros;
    integer     i, b;

    spi_transmite_dados dut (
        .sclk         (sclk),
        .cs_n         (cs_n),
        .miso         (miso),
        .dados_atuais (dados_atuais)
    );

    localparam MEIO_PERIODO = 50;

    task prime_cs;
        begin
            cs_n = 1'b1;
            #(MEIO_PERIODO);
            cs_n = 1'b0;
            #(MEIO_PERIODO);
            cs_n = 1'b1;
            #(MEIO_PERIODO);
        end
    endtask

    task le_frame_como_rpi;
        integer i, b;
        begin
            cs_n = 1'b0;
            #(MEIO_PERIODO);
            for (i = 0; i < 12; i = i + 1) begin
                rx_frame[i] = 8'd0;
                for (b = 0; b < 8; b = b + 1) begin
                    sclk = 1'b1;
                    #(MEIO_PERIODO);
                    rx_frame[i] = {rx_frame[i][6:0], miso};
                    sclk = 1'b0;
                    #(MEIO_PERIODO);
                end
            end
            cs_n = 1'b1;
            #(MEIO_PERIODO);
        end
    endtask

    task confere_byte;
        input [3:0] indice;
        input [7:0] esperado;
        begin
            if (rx_frame[indice] !== esperado) begin
                $display("FALHA: byte %0d esperado=0x%02h obtido=0x%02h",
                          indice, esperado, rx_frame[indice]);
                erros = erros + 1;
            end else begin
                $display("OK:    byte %0d = 0x%02h", indice, rx_frame[indice]);
            end
        end
    endtask

    reg [23:0] pressao_teste;
    reg [23:0] temperatura_teste;
    reg [15:0] umidade_teste;
    reg [15:0] luz_teste;
    reg [15:0] solo_teste;

    initial begin
        $dumpfile("spi_transmite_dados_tb.vcd");
        $dumpvars(0, spi_transmite_dados_tb);

        erros        = 0;
        sclk         = 1'b0;
        cs_n         = 1'b1;
        dados_atuais = 96'd0;

        pressao_teste     = 24'h654321;
        temperatura_teste = 24'hABCDEF;
        umidade_teste     = 16'h1234;
        luz_teste         = 16'h05DC;
        solo_teste        = 16'h0288;

        dados_atuais = {pressao_teste, temperatura_teste,
                        umidade_teste, luz_teste, solo_teste};

        prime_cs;
        le_frame_como_rpi;

        $display("--- Caso 1: frame unico ---");
        confere_byte(0,  pressao_teste[23:16]);
        confere_byte(1,  pressao_teste[15:8]);
        confere_byte(2,  pressao_teste[7:0]);
        confere_byte(3,  temperatura_teste[23:16]);
        confere_byte(4,  temperatura_teste[15:8]);
        confere_byte(5,  temperatura_teste[7:0]);
        confere_byte(6,  umidade_teste[15:8]);
        confere_byte(7,  umidade_teste[7:0]);
        confere_byte(8,  luz_teste[15:8]);
        confere_byte(9,  luz_teste[7:0]);
        confere_byte(10, solo_teste[15:8]);
        confere_byte(11, solo_teste[7:0]);

        dados_atuais = 96'd0;
        prime_cs;
        le_frame_como_rpi;
        $display("--- Caso 2a: frame todo zero ---");
        confere_byte(0, 8'h00);
        confere_byte(5, 8'h00);
        confere_byte(11, 8'h00);

        dados_atuais = {96{1'b1}};
        prime_cs;
        le_frame_como_rpi;
        $display("--- Caso 2b: frame todo um ---");
        confere_byte(0, 8'hFF);
        confere_byte(5, 8'hFF);
        confere_byte(11, 8'hFF);

        dados_atuais = {24'h111111, 24'h222222, 16'h3333, 16'h4444, 16'h5555};
        prime_cs;
        cs_n = 1'b0;
        #(MEIO_PERIODO);

        for (i = 0; i < 4; i = i + 1) begin
            rx_frame[i] = 8'd0;
            for (b = 0; b < 8; b = b + 1) begin
                sclk = 1'b1; #(MEIO_PERIODO);
                rx_frame[i] = {rx_frame[i][6:0], miso};
                sclk = 1'b0; #(MEIO_PERIODO);
            end
        end

        dados_atuais = {24'h999999, 24'h888888, 16'h7777, 16'h6666, 16'h5555};

        for (i = 4; i < 12; i = i + 1) begin
            rx_frame[i] = 8'd0;
            for (b = 0; b < 8; b = b + 1) begin
                sclk = 1'b1; #(MEIO_PERIODO);
                rx_frame[i] = {rx_frame[i][6:0], miso};
                sclk = 1'b0; #(MEIO_PERIODO);
            end
        end

        cs_n = 1'b1;
        #(MEIO_PERIODO);

        $display("--- Caso 3: dados_atuais mudando no meio da transacao ---");
        confere_byte(0, 8'h11);
        confere_byte(3, 8'h22);
        confere_byte(6, 8'h33);
        confere_byte(8, 8'h44);
        confere_byte(10, 8'h55);

        le_frame_como_rpi;
        $display("--- Caso 3b: proxima transacao com valor atualizado ---");
        confere_byte(0, 8'h99);
        confere_byte(3, 8'h88);
        confere_byte(6, 8'h77);
        confere_byte(8, 8'h66);
        confere_byte(10, 8'h55);

        if (erros == 0)
            $display("\n=== TODOS OS TESTES PASSARAM (spi_transmite_dados) ===");
        else
            $display("\n=== %0d FALHA(S) (spi_transmite_dados) ===", erros);

        $finish;
    end

endmodule