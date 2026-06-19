module media_amostras (
    input            clk,
    input            rst,
    input      [7:0] amostra_nova,
    output reg [7:0] media
);

    reg [7:0] amostra_atual;
    reg [7:0] amostra_anterior;

    always @(posedge clk) begin
        if (rst) begin
            amostra_atual    <= 8'b0;
            amostra_anterior <= 8'b0;
            media            <= 8'b0;
        end else begin
            amostra_anterior <= amostra_atual;
            amostra_atual    <= amostra_nova;
            media            <= (amostra_atual + amostra_anterior) >> 1;
        end
    end

endmodule