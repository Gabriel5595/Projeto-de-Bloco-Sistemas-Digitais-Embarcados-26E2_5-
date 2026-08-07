module fsm_controle_leitura (
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire dado_pronto,
    output reg  canal_sel,
    output reg  amostrar,
    output reg  transmitir
);

    localparam OCIOSO    = 2'b00;
    localparam AMOSTRA   = 2'b01;
    localparam TRANSMITE = 2'b10;

    localparam SOLO         = 1'b0;
    localparam LUMINOSIDADE = 1'b1;

    reg [1:0] estado;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            estado     <= OCIOSO;
            canal_sel  <= SOLO;
            amostrar   <= 1'b0;
            transmitir <= 1'b0;
        end else begin
            case (estado)
                OCIOSO: begin
                    amostrar   <= 1'b0;
                    transmitir <= 1'b0;
                    if (start) begin
                        estado <= AMOSTRA;
                    end else begin
                        estado <= OCIOSO;
                    end
                end

                AMOSTRA: begin
                    amostrar   <= 1'b1;
                    transmitir <= 1'b0;
                    if (dado_pronto) begin
                        estado <= TRANSMITE;
                    end else begin
                        estado <= AMOSTRA;
                    end
                end

                TRANSMITE: begin
                    amostrar   <= 1'b0;
                    transmitir <= 1'b1;
                    if (canal_sel == SOLO) begin
                        canal_sel <= LUMINOSIDADE;
                        estado    <= AMOSTRA;
                    end else begin
                        canal_sel <= SOLO;
                        estado    <= OCIOSO;
                    end
                end

                default: begin
                    estado <= OCIOSO;
                end
            endcase
        end
    end

endmodule