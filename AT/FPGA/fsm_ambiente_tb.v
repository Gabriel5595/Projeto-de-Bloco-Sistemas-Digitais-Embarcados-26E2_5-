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

module fsm_ambiente_tb;

    real CLK_PERIODO = 37.037;

    reg  clk;
    reg  reset;
    wire scl;
    wire sda_saida;
    wire sda_direcao;
    wire sda_bus;

    wire [23:0] pressao_bruta;
    wire [23:0] temperatura_bruta;
    wire [15:0] umidade_bruta;
    wire [15:0] luminosidade_bruta;
    wire        leitura_concluida;

    pullup(sda_bus);
    assign sda_bus = sda_direcao ? sda_saida : 1'bz;

    fsm_ambiente dut (
        .clk                (clk),
        .reset              (reset),
        .scl                (scl),
        .sda_saida          (sda_saida),
        .sda_direcao        (sda_direcao),
        .sda_entrada        (sda_bus),
        .pressao_bruta      (pressao_bruta),
        .temperatura_bruta  (temperatura_bruta),
        .umidade_bruta      (umidade_bruta),
        .luminosidade_bruta (luminosidade_bruta),
        .leitura_concluida  (leitura_concluida)
    );

    bme280_slave_bfm u_bme280 (.sda(sda_bus), .scl(scl));
    bh1750_slave_bfm  u_bh1750 (.sda(sda_bus), .scl(scl));

    always #(CLK_PERIODO/2) clk = ~clk;

    integer erros;

    localparam [23:0] PRESSAO_TESTE     = 24'h548A10;
    localparam [23:0] TEMPERATURA_TESTE = 24'h7F3C20;
    localparam [15:0] UMIDADE_TESTE     = 16'h6B90;
    localparam [15:0] LUZ_TESTE         = 16'h1A2B;

    task confere;
        input [8*32-1:0] nome;
        input [31:0]     esperado;
        input [31:0]     obtido;
        begin
            if (esperado !== obtido) begin
                $display("FALHA [%s]: esperado=0x%08h obtido=0x%08h", nome, esperado, obtido);
                erros = erros + 1;
            end else begin
                $display("OK    [%s]: 0x%08h", nome, obtido);
            end
        end
    endtask

    initial begin
        $dumpfile("fsm_ambiente_tb.vcd");
        $dumpvars(0, fsm_ambiente_tb);

        erros = 0;
        clk   = 1'b0;
        reset = 1'b1;

        u_bme280.regfile[8'hF7] = PRESSAO_TESTE[23:16];
        u_bme280.regfile[8'hF8] = PRESSAO_TESTE[15:8];
        u_bme280.regfile[8'hF9] = PRESSAO_TESTE[7:0];
        u_bme280.regfile[8'hFA] = TEMPERATURA_TESTE[23:16];
        u_bme280.regfile[8'hFB] = TEMPERATURA_TESTE[15:8];
        u_bme280.regfile[8'hFC] = TEMPERATURA_TESTE[7:0];
        u_bme280.regfile[8'hFD] = UMIDADE_TESTE[15:8];
        u_bme280.regfile[8'hFE] = UMIDADE_TESTE[7:0];
        u_bh1750.luz_bruta_teste = LUZ_TESTE;

        #(CLK_PERIODO * 5);
        reset = 1'b0;

        @(posedge leitura_concluida);
        #1;

        $display("\n--- Configuracao do BME280 ---");
        confere("reg 0xF2 (ctrl_hum)",  8'h01, u_bme280.regfile[8'hF2]);
        confere("reg 0xF4 (ctrl_meas)", 8'h27, u_bme280.regfile[8'hF4]);
        confere("reg 0xF5 (config)",    8'hA0, u_bme280.regfile[8'hF5]);

        $display("\n--- Primeira leitura ambiental ---");
        confere("pressao_bruta",      PRESSAO_TESTE,     pressao_bruta);
        confere("temperatura_bruta",  TEMPERATURA_TESTE, temperatura_bruta);
        confere("umidade_bruta",      UMIDADE_TESTE,     umidade_bruta);
        confere("luminosidade_bruta", LUZ_TESTE,         luminosidade_bruta);

        u_bme280.regfile[8'hF7] = 8'h11;
        u_bme280.regfile[8'hF8] = 8'h22;
        u_bme280.regfile[8'hF9] = 8'h33;
        u_bme280.regfile[8'hFA] = 8'h44;
        u_bme280.regfile[8'hFB] = 8'h55;
        u_bme280.regfile[8'hFC] = 8'h66;
        u_bme280.regfile[8'hFD] = 8'h77;
        u_bme280.regfile[8'hFE] = 8'h88;
        u_bh1750.luz_bruta_teste = 16'h4321;

        @(posedge leitura_concluida);
        #1;

        $display("\n--- Segunda leitura ambiental (regime) ---");
        confere("pressao_bruta",      24'h112233, pressao_bruta);
        confere("temperatura_bruta",  24'h445566, temperatura_bruta);
        confere("umidade_bruta",      16'h7788,   umidade_bruta);
        confere("luminosidade_bruta", 16'h4321,   luminosidade_bruta);

        if (erros == 0)
            $display("\n=== TODOS OS TESTES PASSARAM (fsm_ambiente) ===");
        else
            $display("\n=== %0d FALHA(S) (fsm_ambiente) ===", erros);

        $finish;
    end

    initial begin
        #(CLK_PERIODO * 15000000);
        $display("FALHA: watchdog estourou - simulacao travada");
        $finish;
    end

endmodule