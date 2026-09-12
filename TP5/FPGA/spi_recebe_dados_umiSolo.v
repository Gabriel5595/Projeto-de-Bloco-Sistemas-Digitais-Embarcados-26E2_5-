module spi_recebe_dados_umiSolo (
    input  wire        clk,
    input  wire        reset,
    input  wire [15:0] umidade_solo_bruta,
    input  wire        leitura_concluida,

    output reg  [15:0] umidade_solo_bruta_saida,
    output reg         leitura_concluida_saida
);
    localparam [15:0] ALPHA = 16'd6554;

    reg  [15:0] media_atual = 16'd0;

    wire        umidade_maior  = (umidade_solo_bruta > media_atual);
    wire [15:0] diferenca_abs  = umidade_maior ? (umidade_solo_bruta - media_atual)
                                                : (media_atual - umidade_solo_bruta);
    wire [31:0] produto_abs    = diferenca_abs * ALPHA;
    wire [15:0] incremento_abs = produto_abs[31:16];

    always @(posedge clk) begin
        leitura_concluida_saida <= leitura_concluida;

        if (reset) begin
            media_atual <= 16'd0;
        end else if (leitura_concluida) begin
            if (umidade_maior)
                media_atual <= media_atual + incremento_abs;
            else
                media_atual <= media_atual - incremento_abs;
        end

        umidade_solo_bruta_saida <= media_atual;
    end
endmodule