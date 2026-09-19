module spi_transmite_dados (
    input  wire        sclk,
    input  wire        cs_n,
    input  wire        mosi,
    output wire        miso,
    input  wire [95:0] dados_atuais,
    output reg         comando_valido = 1'b0
);
    localparam [7:0] COMANDO_ESPERADO = 8'hA5;
    localparam [7:0] STATUS_OK        = 8'h5A;
    localparam [7:0] STATUS_ERRO      = 8'h00;

    reg  [7:0]   comando_recebido  = 8'd0;
    reg  [2:0]   contagem_comando  = 3'd0;
    reg          comando_capturado = 1'b0;
    reg  [111:0] registrador_saida = 112'd0;

    wire [7:0] checksum = dados_atuais[95:88] + dados_atuais[87:80] + dados_atuais[79:72] +
                            dados_atuais[71:64] + dados_atuais[63:56] + dados_atuais[55:48] +
                            dados_atuais[47:40] + dados_atuais[39:32] + dados_atuais[31:24] +
                            dados_atuais[23:16] + dados_atuais[15:8]  + dados_atuais[7:0];

    always @(posedge sclk or posedge cs_n) begin
        if (cs_n) begin
            comando_capturado <= 1'b0;
            contagem_comando  <= 3'd0;
            comando_valido    <= 1'b0;
        end else if (!comando_capturado) begin
            comando_recebido <= {comando_recebido[6:0], mosi};
            if (contagem_comando == 3'd7) begin
                comando_capturado <= 1'b1;
                comando_valido    <= ({comando_recebido[6:0], mosi} == COMANDO_ESPERADO);
            end else begin
                contagem_comando <= contagem_comando + 3'd1;
            end
        end
    end

    always @(negedge sclk or posedge cs_n) begin
        if (cs_n) begin
            registrador_saida <= { (comando_recebido == COMANDO_ESPERADO) ? STATUS_OK : STATUS_ERRO,
                                    dados_atuais,
                                    checksum };
        end else begin
            registrador_saida <= registrador_saida << 1;
        end
    end

    assign miso = registrador_saida[111];

endmodule