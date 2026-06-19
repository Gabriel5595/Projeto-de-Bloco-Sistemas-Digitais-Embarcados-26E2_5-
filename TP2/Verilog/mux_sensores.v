module mux_sensores (
    input  [7:0]  umidade_solo,
    input  [7:0]  temperatura,
    input  [15:0] luminosidade,
    input  [7:0]  umidade_ar,
    input  [1:0]  sel,
    output reg [15:0] canal_selecionado
);

    always @(*) begin
        case (sel)
            2'b00: canal_selecionado = {8'b0, umidade_solo};
            2'b01: canal_selecionado = {8'b0, temperatura};
            2'b10: canal_selecionado = luminosidade;
            2'b11: canal_selecionado = {8'b0, umidade_ar};
            default: canal_selecionado = 16'b0;
        endcase
    end

endmodule