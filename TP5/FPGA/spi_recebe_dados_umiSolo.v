module spi_recebe_dados_umiSolo (
    input  wire        clk,
    input  wire        reset,
    input  wire [15:0] umidade_solo_bruta,
    input  wire        leitura_concluida,

    output reg  [15:0] umidade_solo_bruta_saida,
    output reg         leitura_concluida_saida
);
    localparam [15:0] ALPHA = 16'd6554;

    reg signed [16:0] media_atual = 17'sd0;

    wire signed [16:0] diferenca  = $signed({1'b0, umidade_solo_bruta}) - media_atual;
    wire signed [33:0] produto    = diferenca * $signed({1'b0, ALPHA});
    wire signed [17:0] incremento = produto[33:16];

    always @(posedge clk) begin
        leitura_concluida_saida <= leitura_concluida;

        if (reset) begin
            media_atual <= 17'sd0;
        end else if (leitura_concluida) begin
            media_atual <= media_atual + incremento;
        end

        umidade_solo_bruta_saida <= media_atual[15:0];
    end
endmodule