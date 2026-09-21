`timescale 1ns/1ps

module bme280_slave_bfm (
    inout wire sda,
    input wire scl
);
    localparam [6:0] ENDERECO = 7'h76;

    reg [7:0] regfile [0:255];
    reg       sda_oe;
    reg       sda_out;
    assign sda = sda_oe ? sda_out : 1'bz;

    event ev_start, ev_stop;
    reg   flag_start, flag_stop;

    always @(negedge sda) if (scl === 1'b1) begin
        flag_start = 1'b1;
        -> ev_start;
    end
    always @(posedge sda) if (scl === 1'b1) begin
        flag_stop = 1'b1;
        -> ev_stop;
    end

    task proximo_bit;
        output bit_amostrado;
        begin
            @(posedge scl);
            bit_amostrado = sda;
            @(negedge scl);
        end
    endtask

    task recebe_byte;
        output [7:0] byte_lido;
        integer i;
        reg     b;
        begin
            byte_lido = 8'd0;
            for (i = 0; i < 8; i = i + 1) begin
                sda_oe = 1'b0;
                proximo_bit(b);
                byte_lido = {byte_lido[6:0], b};
            end
        end
    endtask

    task envia_ack;
        reg descarte;
        begin
            sda_oe  = 1'b1;
            sda_out = 1'b0;
            proximo_bit(descarte);
            sda_oe  = 1'b0;
        end
    endtask

    task envia_byte;
        input [7:0] valor;
        integer i;
        reg     descarte;
        begin
            for (i = 7; i >= 0; i = i - 1) begin
                sda_oe  = 1'b1;
                sda_out = valor[i];
                proximo_bit(descarte);
            end
        end
    endtask

    task le_ack_do_mestre;
        output ack_recebido;
        begin
            sda_oe = 1'b0;
            proximo_bit(ack_recebido);
        end
    endtask

    task decide_pos_ponteiro;
        output tipo;
        output bit7_amostrado;
        reg    venceu_negedge;
        begin
            @(posedge scl);
            bit7_amostrado = sda;
            fork
                begin : fecha_bit_dp
                    @(negedge scl);
                    venceu_negedge = 1'b1;
                    disable detecta_restart_dp;
                end
                begin : detecta_restart_dp
                    @(ev_start);
                    venceu_negedge = 1'b0;
                    disable fecha_bit_dp;
                end
            join
            tipo = venceu_negedge ? 1'b0 : 1'b1;
        end
    endtask

    reg [7:0] endereco_rw;
    reg [7:0] byte_recebido_1;
    reg [7:0] byte_dado;
    reg [7:0] ponteiro;
    reg       ack_mestre;
    reg       tipo_pos;
    reg       bit7_pos;
    integer   k;
    reg       bk;
    integer   i;

    initial begin
        sda_oe   = 1'b0;
        sda_out  = 1'b0;
        ponteiro = 8'd0;
        for (i = 0; i < 256; i = i + 1) regfile[i] = 8'h00;

        forever begin
            @(ev_start);
            recebe_byte(endereco_rw);

            if (endereco_rw[7:1] == ENDERECO) begin
                envia_ack;

                if (endereco_rw[0] == 1'b0) begin
                    recebe_byte(byte_recebido_1);
                    envia_ack;

                    decide_pos_ponteiro(tipo_pos, bit7_pos);

                    if (tipo_pos == 1'b0) begin
                        byte_dado = {7'd0, bit7_pos};
                        for (k = 6; k >= 0; k = k - 1) begin
                            sda_oe = 1'b0;
                            proximo_bit(bk);
                            byte_dado = {byte_dado[6:0], bk};
                        end
                        regfile[byte_recebido_1] = byte_dado;
                        envia_ack;
                    end else begin
                        ponteiro = byte_recebido_1;
                        recebe_byte(endereco_rw);
                        if (endereco_rw[7:1] == ENDERECO) begin
                            envia_ack;
                            ack_mestre = 1'b0;
                            while (ack_mestre == 1'b0) begin
                                envia_byte(regfile[ponteiro]);
                                ponteiro = ponteiro + 8'd1;
                                le_ack_do_mestre(ack_mestre);
                            end
                        end
                    end
                end else begin
                    ack_mestre = 1'b0;
                    while (ack_mestre == 1'b0) begin
                        envia_byte(regfile[ponteiro]);
                        ponteiro = ponteiro + 8'd1;
                        le_ack_do_mestre(ack_mestre);
                    end
                end
            end
        end
    end
endmodule

module bh1750_slave_bfm (
    inout wire sda,
    input wire scl
);
    localparam [6:0] ENDERECO = 7'h23;

    reg sda_oe;
    reg sda_out;
    assign sda = sda_oe ? sda_out : 1'bz;

    event ev_start;
    reg   flag_start;

    always @(negedge sda) if (scl === 1'b1) begin
        flag_start = 1'b1;
        -> ev_start;
    end

    task proximo_bit;
        output bit_amostrado;
        begin
            @(posedge scl);
            bit_amostrado = sda;
            @(negedge scl);
        end
    endtask

    task recebe_byte;
        output [7:0] byte_lido;
        integer i;
        reg     b;
        begin
            byte_lido = 8'd0;
            for (i = 0; i < 8; i = i + 1) begin
                sda_oe = 1'b0;
                proximo_bit(b);
                byte_lido = {byte_lido[6:0], b};
            end
        end
    endtask

    task envia_ack;
        reg descarte;
        begin
            sda_oe  = 1'b1;
            sda_out = 1'b0;
            proximo_bit(descarte);
            sda_oe  = 1'b0;
        end
    endtask

    task envia_byte;
        input [7:0] valor;
        integer i;
        reg     descarte;
        begin
            for (i = 7; i >= 0; i = i - 1) begin
                sda_oe  = 1'b1;
                sda_out = valor[i];
                proximo_bit(descarte);
            end
        end
    endtask

    task le_ack_do_mestre;
        output ack_recebido;
        begin
            sda_oe = 1'b0;
            proximo_bit(ack_recebido);
        end
    endtask

    reg [7:0]  endereco_rw;
    reg [7:0]  comando_recebido;
    reg [15:0] luz_bruta_teste;
    reg        ack_mestre;

    initial begin
        sda_oe          = 1'b0;
        sda_out         = 1'b0;
        luz_bruta_teste = 16'h05DC;

        forever begin
            @(ev_start);
            recebe_byte(endereco_rw);

            if (endereco_rw[7:1] == ENDERECO) begin
                envia_ack;

                if (endereco_rw[0] == 1'b0) begin
                    recebe_byte(comando_recebido);
                    envia_ack;
                    if (comando_recebido !== 8'h10)
                        $display("AVISO [BH1750 BFM]: comando inesperado 0x%02h (esperado 0x10)",
                                  comando_recebido);
                end else begin
                    envia_byte(luz_bruta_teste[15:8]);
                    le_ack_do_mestre(ack_mestre);
                    envia_byte(luz_bruta_teste[7:0]);
                    le_ack_do_mestre(ack_mestre);
                end
            end
        end
    end
endmodule

module top_fpga_tb;

    localparam [7:0] COMANDO_VALIDO   = 8'hA5;
    localparam [7:0] COMANDO_INVALIDO = 8'h00;
    localparam [7:0] STATUS_OK        = 8'h5A;
    localparam [7:0] STATUS_ERRO      = 8'h00;

    real CLK_PERIODO = 37.037;

    reg  clk_pino     = 1'b0;
    reg  sclk_pino    = 1'b0;
    reg  cs_pino      = 1'b1;
    reg  mosi_pino    = 1'b0;
    wire miso_pino;
    wire led_status;
    wire led_azul;
    wire sda_i2c;
    wire scl_i2c;
    wire sclk_adc_pino;
    wire cs_adc_pino;
    wire din_adc_pino;
    reg  dout_adc_pino = 1'b0;

    pullup(sda_i2c);

    top_fpga dut (
        .clk_pino       (clk_pino),
        .sclk_pino      (sclk_pino),
        .cs_pino        (cs_pino),
        .mosi_pino      (mosi_pino),
        .miso_pino      (miso_pino),
        .led_status     (led_status),
        .led_azul       (led_azul),
        .sda_i2c        (sda_i2c),
        .scl_i2c        (scl_i2c),
        .sclk_adc_pino  (sclk_adc_pino),
        .cs_adc_pino    (cs_adc_pino),
        .din_adc_pino   (din_adc_pino),
        .dout_adc_pino  (dout_adc_pino)
    );

    bme280_slave_bfm u_bme280 (.sda(sda_i2c), .scl(scl_i2c));
    bh1750_slave_bfm  u_bh1750 (.sda(sda_i2c), .scl(scl_i2c));

    reg [4:0] neg_count;
    reg [9:0] valor_adc_teste;

    always @(negedge cs_adc_pino) begin
        neg_count     <= 5'd0;
        dout_adc_pino <= 1'b0;
    end

    always @(negedge sclk_adc_pino) begin
        if (!cs_adc_pino) begin
            neg_count <= neg_count + 5'd1;
            if ((neg_count + 5'd1) >= 5'd7 && (neg_count + 5'd1) <= 5'd16)
                dout_adc_pino <= valor_adc_teste[16 - (neg_count + 5'd1)];
            else
                dout_adc_pino <= 1'b0;
        end
    end

    always #(CLK_PERIODO/2) clk_pino = ~clk_pino;

    reg [7:0] rx_frame [0:13];
    localparam MEIO_PERIODO_SPI = 50;

    task le_frame_como_rpi;
        input [7:0] comando;
        integer i, b;
        begin
            cs_pino = 1'b0;
            #(MEIO_PERIODO_SPI);
            for (i = 0; i < 14; i = i + 1) begin
                rx_frame[i] = 8'd0;
                for (b = 0; b < 8; b = b + 1) begin
                    if (i == 0)
                        mosi_pino = comando[7 - b];
                    else
                        mosi_pino = 1'b0;
                    sclk_pino = 1'b1;
                    #(MEIO_PERIODO_SPI);
                    rx_frame[i] = {rx_frame[i][6:0], miso_pino};
                    sclk_pino = 1'b0;
                    #(MEIO_PERIODO_SPI);
                end
            end
            cs_pino = 1'b1;
            #(MEIO_PERIODO_SPI);
        end
    endtask

    integer erros;

    task confere_byte;
        input [8*16-1:0] nome;
        input [3:0]      indice;
        input [7:0]      esperado;
        begin
            if (rx_frame[indice] !== esperado) begin
                $display("FALHA [%s] byte %0d: esperado=0x%02h obtido=0x%02h",
                          nome, indice, esperado, rx_frame[indice]);
                erros = erros + 1;
            end else begin
                $display("OK    [%s] byte %0d = 0x%02h", nome, indice, rx_frame[indice]);
            end
        end
    endtask

    task confere_status;
        input [7:0] esperado;
        begin
            if (rx_frame[0] !== esperado) begin
                $display("FALHA [status]: esperado=0x%02h obtido=0x%02h", esperado, rx_frame[0]);
                erros = erros + 1;
            end else begin
                $display("OK    [status] = 0x%02h", rx_frame[0]);
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
                $display("FALHA [checksum]: esperado=0x%02h obtido=0x%02h", soma, rx_frame[13]);
                erros = erros + 1;
            end else begin
                $display("OK    [checksum] = 0x%02h", rx_frame[13]);
            end
        end
    endtask

    localparam [23:0] PRESSAO_TESTE     = 24'h548A10;
    localparam [23:0] TEMPERATURA_TESTE = 24'h7F3C20;
    localparam [15:0] UMIDADE_TESTE     = 16'h6B90;
    localparam [15:0] LUZ_TESTE         = 16'h1A2B;
    localparam [15:0] SOLO_TESTE        = 16'h0284;

    initial begin
        $dumpfile("top_fpga_tb.vcd");
        $dumpvars(0, top_fpga_tb);

        erros           = 0;
        neg_count       = 5'd0;
        valor_adc_teste = SOLO_TESTE[9:0];

        u_bme280.regfile[8'hF7] = PRESSAO_TESTE[23:16];
        u_bme280.regfile[8'hF8] = PRESSAO_TESTE[15:8];
        u_bme280.regfile[8'hF9] = PRESSAO_TESTE[7:0];
        u_bme280.regfile[8'hFA] = TEMPERATURA_TESTE[23:16];
        u_bme280.regfile[8'hFB] = TEMPERATURA_TESTE[15:8];
        u_bme280.regfile[8'hFC] = TEMPERATURA_TESTE[7:0];
        u_bme280.regfile[8'hFD] = UMIDADE_TESTE[15:8];
        u_bme280.regfile[8'hFE] = UMIDADE_TESTE[7:0];
        u_bh1750.luz_bruta_teste = LUZ_TESTE;

        repeat (17) @(posedge dut.leitura_concluida_ambiente);

        #(CLK_PERIODO * 5);

        le_frame_como_rpi(COMANDO_VALIDO);

        #(CLK_PERIODO * 5);

        le_frame_como_rpi(COMANDO_VALIDO);

        $display("\n--- Caso 1: comando valido, pipeline completo (sensores -> FPGA -> SPI) ---");
        confere_status(STATUS_OK);
        confere_byte("pressao",     1,  PRESSAO_TESTE[23:16]);
        confere_byte("pressao",     2,  PRESSAO_TESTE[15:8]);
        confere_byte("pressao",     3,  PRESSAO_TESTE[7:0]);
        confere_byte("temperatura", 4,  TEMPERATURA_TESTE[23:16]);
        confere_byte("temperatura", 5,  TEMPERATURA_TESTE[15:8]);
        confere_byte("temperatura", 6,  TEMPERATURA_TESTE[7:0]);
        confere_byte("umidade",     7,  UMIDADE_TESTE[15:8]);
        confere_byte("umidade",     8,  UMIDADE_TESTE[7:0]);
        confere_byte("luz",         9,  LUZ_TESTE[15:8]);
        confere_byte("luz",         10, LUZ_TESTE[7:0]);
        confere_byte("solo",        11, SOLO_TESTE[15:8]);
        confere_byte("solo",        12, 8'h7B);
        confere_checksum;

        le_frame_como_rpi(COMANDO_INVALIDO);
        le_frame_como_rpi(COMANDO_INVALIDO);
        $display("\n--- Caso 2: comando invalido (0x00 em vez de 0xA5) ---");
        confere_status(STATUS_ERRO);

        $display("\n--- Caso 3: led_azul durante e depois de uma transacao valida ---");
        cs_pino = 1'b0;
        #(MEIO_PERIODO_SPI);
        for (integer i = 7; i >= 0; i = i - 1) begin
            mosi_pino = COMANDO_VALIDO[i];
            sclk_pino = 1'b1;
            #(MEIO_PERIODO_SPI);
            sclk_pino = 1'b0;
            #(MEIO_PERIODO_SPI);
        end
        if (led_azul !== 1'b1) begin
            $display("FALHA [led_azul]: esperado=1 obtido=%b logo apos o comando", led_azul);
            erros = erros + 1;
        end else begin
            $display("OK    [led_azul] = 1 logo apos o comando");
        end

        for (integer i = 0; i < 104; i = i + 1) begin
            mosi_pino = 1'b0;
            sclk_pino = 1'b1;
            #(MEIO_PERIODO_SPI);
            sclk_pino = 1'b0;
            #(MEIO_PERIODO_SPI);
        end
        cs_pino = 1'b1;
        #(MEIO_PERIODO_SPI);
        if (led_azul !== 1'b0) begin
            $display("FALHA [led_azul]: esperado=0 obtido=%b apos o fim da transacao", led_azul);
            erros = erros + 1;
        end else begin
            $display("OK    [led_azul] = 0 apos o fim da transacao");
        end

        if (erros == 0)
            $display("\n=== TODOS OS TESTES PASSARAM (top_fpga - pipeline completo) ===");
        else
            $display("\n=== %0d FALHA(S) (top_fpga) ===", erros);

        $finish;
    end

    initial begin
        #(CLK_PERIODO * 15000000);
        $display("FALHA: watchdog estourou - simulacao travada");
        $finish;
    end

endmodule