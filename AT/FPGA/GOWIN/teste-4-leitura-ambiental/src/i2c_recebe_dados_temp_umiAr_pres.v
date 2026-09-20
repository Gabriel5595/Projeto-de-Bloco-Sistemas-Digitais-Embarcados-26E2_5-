module i2c_recebe_dados_temp_umiAr_pres (
    input  wire        clk,
    input  wire        reset,
    input  wire [23:0] pressao_bruta,
    input  wire [23:0] temperatura_bruta,
    input  wire [15:0] umidade_bruta,
    input  wire        leitura_concluida,

    output reg  [23:0] pressao_bruta_saida,
    output reg  [23:0] temperatura_bruta_saida,
    output reg  [15:0] umidade_bruta_saida,
    output reg         leitura_concluida_saida
);
    reg [63:0] buffer_amostras [0:15];
    reg [3:0]  ponteiro_escrita = 4'd0;

    localparam OCIOSO      = 2'd0;
    localparam VARRENDO    = 2'd1;
    localparam FINALIZANDO = 2'd2;

    reg  [1:0]  estado = OCIOSO;
    reg  [3:0]  ponteiro_leitura = 4'd0;
    reg  [31:0] soma_pressao = 32'd0;
    reg  [31:0] soma_temp    = 32'd0;
    reg  [31:0] soma_umidade = 32'd0;

    wire [63:0] amostra_lida = buffer_amostras[ponteiro_leitura];

    always @(posedge clk) begin
        leitura_concluida_saida <= leitura_concluida;

        if (reset) begin
            ponteiro_escrita        <= 4'd0;
            estado                  <= OCIOSO;
            pressao_bruta_saida     <= 24'd0;
            temperatura_bruta_saida <= 24'd0;
            umidade_bruta_saida     <= 16'd0;
        end else begin
            case (estado)
                OCIOSO: begin
                    if (leitura_concluida) begin
                        buffer_amostras[ponteiro_escrita] <= {pressao_bruta, temperatura_bruta, umidade_bruta};
                        ponteiro_escrita <= ponteiro_escrita + 4'd1;
                        ponteiro_leitura <= 4'd0;
                        soma_pressao     <= 32'd0;
                        soma_temp        <= 32'd0;
                        soma_umidade     <= 32'd0;
                        estado           <= VARRENDO;
                    end
                end

                VARRENDO: begin
                    soma_pressao     <= soma_pressao + amostra_lida[63:40];
                    soma_temp        <= soma_temp    + amostra_lida[39:16];
                    soma_umidade     <= soma_umidade + amostra_lida[15:0];
                    ponteiro_leitura <= ponteiro_leitura + 4'd1;
                    if (ponteiro_leitura == 4'd15)
                        estado <= FINALIZANDO;
                end

                FINALIZANDO: begin
                    pressao_bruta_saida     <= soma_pressao[27:4];
                    temperatura_bruta_saida <= soma_temp[27:4];
                    umidade_bruta_saida     <= soma_umidade[19:4];
                    estado                  <= OCIOSO;
                end

                default: estado <= OCIOSO;
            endcase
        end
    end
endmodule