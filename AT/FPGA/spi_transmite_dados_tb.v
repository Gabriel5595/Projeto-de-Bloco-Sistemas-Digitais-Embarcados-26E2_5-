`timescale 1ns/1ps

module spi_transmite_dados_tb;

    localparam [7:0] COMANDO_VALIDO = 8'hA5;
    localparam [7:0] COMANDO_INVALIDO = 8'h00;
    localparam [7:0] STATUS_OK   = 8'h5A;
    localparam [7:0] STATUS_ERRO = 8'h00;

    reg         sclk = 1'b0;
    reg         cs_n = 1'b1;
    reg         mosi = 1'b0;
    wire        miso;
    reg  [95:0] dados_atuais;
    wire        comando_valido;

    reg  [7:0]  rx_frame [0:13];
    integer     erros;
    integer     i, b;
    reg  [7:0]  soma_recalculada;

    spi_transmite_dados dut (
        .sclk           (sclk),
        .cs_n           (cs_n),
        .mosi           (mosi),
        .miso           (miso),
        .dados_atuais   (dados_atuais),
        .comando_valido (comando_valido)
    );

    localparam MEIO_PERIODO = 50;

    task le_frame_como_rpi;
        input [7:0] comando;
        integer i, b;
        begin
            cs_n = 1'b0;
            #(MEIO_PERIODO);
            for (i = 0; i < 14; i = i + 1) begin
                rx_frame[i] = 8'd0;
                for (b = 0; b < 8; b = b + 1) begin
                    if (i == 0)
                        mosi = comando[7 - b];
                    else
                        mosi = 1'b0;
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

    task confere_status;
        input [7:0] esperado;
        begin
            if (rx_frame[0] !== esperado) begin
                $display("FALHA: status esperado=0x%02h obtido=0x%02h", esperado, rx_frame[0]);
                erros = erros + 1;
            end else begin
                $display("OK:    status = 0x%02h", rx_frame[0]);
            end
        end
    endtask

    task confere_checksum;
        integer k;
        reg [7:0] soma;
        begin
            soma = 8'd0;
            for (k = 1; k <= 12; k = k + 1)
                soma = soma + rx_frame[k];
            if (soma !== rx_frame[13]) begin
                $display("FALHA: checksum esperado=0x%02h obtido=0x%02h", soma, rx_frame[13]);
                erros = erros + 1;
            end else begin
                $display("OK:    checksum = 0x%02h", rx_frame[13]);
            end
        end
    endtask

    task confere_led;
        input [8*32-1:0] nome;
        input esperado;
        begin
            if (comando_valido !== esperado) begin
                $display("FALHA [%s]: led_azul esperado=%b obtido=%b", nome, esperado, comando_valido);
                erros = erros + 1;
            end else begin
                $display("OK    [%s]: led_azul=%b", nome, comando_valido);
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
        dados_atuais = 96'd0;

        confere_led("antes de qualquer transacao", 1'b0);

        le_frame_como_rpi(COMANDO_VALIDO);

        pressao_teste     = 24'h654321;
        temperatura_teste = 24'hABCDEF;
        umidade_teste     = 16'h1234;
        luz_teste         = 16'h05DC;
        solo_teste        = 16'h0288;

        dados_atuais = {pressao_teste, temperatura_teste,
                        umidade_teste, luz_teste, solo_teste};

        le_frame_como_rpi(COMANDO_VALIDO);
        le_frame_como_rpi(COMANDO_VALIDO);

        $display("--- Caso 1: comando valido, frame conhecido ---");
        confere_status(STATUS_OK);
        confere_byte(1,  pressao_teste[23:16]);
        confere_byte(2,  pressao_teste[15:8]);
        confere_byte(3,  pressao_teste[7:0]);
        confere_byte(4,  temperatura_teste[23:16]);
        confere_byte(5,  temperatura_teste[15:8]);
        confere_byte(6,  temperatura_teste[7:0]);
        confere_byte(7,  umidade_teste[15:8]);
        confere_byte(8,  umidade_teste[7:0]);
        confere_byte(9,  luz_teste[15:8]);
        confere_byte(10, luz_teste[7:0]);
        confere_byte(11, solo_teste[15:8]);
        confere_byte(12, solo_teste[7:0]);
        confere_checksum;

        le_frame_como_rpi(COMANDO_INVALIDO);
        le_frame_como_rpi(COMANDO_INVALIDO);
        $display("--- Caso 2: comando invalido (0x00 em vez de 0xA5) ---");
        confere_status(STATUS_ERRO);

        dados_atuais = 96'd0;
        le_frame_como_rpi(COMANDO_VALIDO);
        le_frame_como_rpi(COMANDO_VALIDO);
        $display("--- Caso 3a: frame todo zero ---");
        confere_status(STATUS_OK);
        confere_byte(1, 8'h00);
        confere_byte(6, 8'h00);
        confere_byte(12, 8'h00);
        confere_checksum;

        dados_atuais = {96{1'b1}};
        le_frame_como_rpi(COMANDO_VALIDO);
        le_frame_como_rpi(COMANDO_VALIDO);
        $display("--- Caso 3b: frame todo um ---");
        confere_status(STATUS_OK);
        confere_byte(1, 8'hFF);
        confere_byte(6, 8'hFF);
        confere_byte(12, 8'hFF);
        confere_checksum;

        $display("--- Caso 4: LED azul durante e depois de uma transacao valida ---");
        cs_n = 1'b0;
        #(MEIO_PERIODO);
        for (i = 7; i >= 0; i = i - 1) begin
            mosi = COMANDO_VALIDO[i];
            sclk = 1'b1;
            #(MEIO_PERIODO);
            sclk = 1'b0;
            #(MEIO_PERIODO);
        end
        confere_led("logo apos os 8 bits do comando", 1'b1);

        for (i = 0; i < 104; i = i + 1) begin
            mosi = 1'b0;
            sclk = 1'b1;
            #(MEIO_PERIODO);
            sclk = 1'b0;
            #(MEIO_PERIODO);
        end
        cs_n = 1'b1;
        #(MEIO_PERIODO);
        confere_led("logo depois que o CS subiu", 1'b0);

        #500;
        confere_led("no intervalo entre uma leitura e outra", 1'b0);

        dados_atuais = {pressao_teste, temperatura_teste,
                        umidade_teste, luz_teste, solo_teste};
        le_frame_como_rpi(8'hA4);
        le_frame_como_rpi(8'hA4);
        $display("--- Caso 5: comando quase certo (0xA4 em vez de 0xA5) ---");
        confere_status(STATUS_ERRO);

        le_frame_como_rpi(COMANDO_VALIDO);
        le_frame_como_rpi(COMANDO_VALIDO);
        $display("--- Caso 6: bit corrompido em transito -> checksum nao deve bater ---");
        rx_frame[6] = rx_frame[6] ^ 8'h01;
        soma_recalculada = 8'd0;
        for (i = 1; i <= 12; i = i + 1)
            soma_recalculada = soma_recalculada + rx_frame[i];
        if (soma_recalculada === rx_frame[13]) begin
            $display("FALHA: checksum deveria acusar corrupcao e nao acusou");
            erros = erros + 1;
        end else begin
            $display("OK:    checksum recalculado=0x%02h != recebido=0x%02h -> corrupcao detectada",
                        soma_recalculada, rx_frame[13]);
        end

        if (erros == 0)
            $display("\n=== TODOS OS TESTES PASSARAM (spi_transmite_dados) ===");
        else
            $display("\n=== %0d FALHA(S) (spi_transmite_dados) ===", erros);

        $finish;
    end

endmodule