`timescale 1ns/1ps

module fsm_umiSolo_tb;

    real CLK_PERIODO = 37.037;

    reg  clk;
    reg  reset;
    wire sclk_adc;
    wire cs_adc;
    wire din_adc;
    reg  dout_adc;

    wire [15:0] umidade_solo_bruta;
    wire        leitura_concluida;

    fsm_umiSolo dut (
        .clk                (clk),
        .reset              (reset),
        .sclk_adc           (sclk_adc),
        .cs_adc             (cs_adc),
        .din_adc            (din_adc),
        .dout_adc           (dout_adc),
        .umidade_solo_bruta (umidade_solo_bruta),
        .leitura_concluida  (leitura_concluida)
    );

    always #(CLK_PERIODO/2) clk = ~clk;

    reg [4:0] neg_count;
    reg [9:0] valor_adc_atual;

    always @(negedge cs_adc) begin
        neg_count <= 5'd0;
        dout_adc  <= 1'b0;
    end

    always @(negedge sclk_adc) begin
        if (!cs_adc) begin
            neg_count <= neg_count + 5'd1;
            if ((neg_count + 5'd1) >= 5'd7 && (neg_count + 5'd1) <= 5'd16)
                dout_adc <= valor_adc_atual[16 - (neg_count + 5'd1)];
            else
                dout_adc <= 1'b0;
        end
    end

    integer erros;

    task programa_e_confere;
        input [9:0]        valor;
        input [8*24-1:0]   nome;
        begin
            @(posedge leitura_concluida);
            valor_adc_atual = valor;
            @(posedge leitura_concluida);
            #1;
            if (umidade_solo_bruta !== {6'd0, valor}) begin
                $display("FALHA [%s]: esperado=0x%03h obtido=0x%03h",
                            nome, valor, umidade_solo_bruta);
                erros = erros + 1;
            end else begin
                $display("OK    [%s]: umidade_solo_bruta = 0x%03h", nome, umidade_solo_bruta);
            end
        end
    endtask

    initial begin
        $dumpfile("fsm_umiSolo_tb.vcd");
        $dumpvars(0, fsm_umiSolo_tb);

        erros           = 0;
        clk             = 1'b0;
        reset           = 1'b1;
        dout_adc        = 1'b0;
        neg_count       = 5'd0;
        valor_adc_atual = 10'd0;

        #(CLK_PERIODO * 5);
        reset = 1'b0;

        @(posedge leitura_concluida);

        programa_e_confere(10'b0000000000, "zero");
        programa_e_confere(10'b1111111111, "todos_um");
        programa_e_confere(10'b1000000001, "extremos_msb_lsb");
        programa_e_confere(10'b0101010101, "alternado_1");
        programa_e_confere(10'b1010101010, "alternado_2");
        programa_e_confere(10'd595,        "solo_seco_tipico");
        programa_e_confere(10'd130,        "solo_molhado_tipico");

        if (erros == 0)
            $display("\n=== TODOS OS TESTES PASSARAM (fsm_umiSolo) ===");
        else
            $display("\n=== %0d FALHA(S) (fsm_umiSolo) ===", erros);

        $finish;
    end

    initial begin
        #(CLK_PERIODO * 200000);
        $display("FALHA: watchdog estourou - simulacao travada");
        $finish;
    end

endmodule