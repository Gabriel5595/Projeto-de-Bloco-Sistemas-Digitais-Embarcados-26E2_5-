`timescale 1ns/1ps

module media_amostras_tb;

    reg        clk;
    reg        rst;
    reg  [7:0] amostra_nova;
    wire [7:0] media;

    media_amostras uut (
        .clk         (clk),
        .rst         (rst),
        .amostra_nova(amostra_nova),
        .media       (media)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("media_amostras.vcd");
        $dumpvars(0, media_amostras_tb);

        clk          = 1'b0;
        rst          = 1'b1;
        amostra_nova = 8'b0;

        #20;
        rst = 1'b0;

        $display("Iniciando simulacao do modulo de media de duas amostras");
        $display("----------------------------------------------------------");

        amostra_nova = 8'd20;
        @(posedge clk); #1;
        $display("Amostra nova = %0d | Media = %0d", amostra_nova, media);

        amostra_nova = 8'd40;
        @(posedge clk); #1;
        $display("Amostra nova = %0d | Media = %0d", amostra_nova, media);

        amostra_nova = 8'd30;
        @(posedge clk); #1;
        $display("Amostra nova = %0d | Media = %0d", amostra_nova, media);

        amostra_nova = 8'd60;
        @(posedge clk); #1;
        $display("Amostra nova = %0d | Media = %0d", amostra_nova, media);

        amostra_nova = 8'd72;
        @(posedge clk); #1;
        $display("Amostra nova = %0d | Media = %0d", amostra_nova, media);

        amostra_nova = 8'd28;
        @(posedge clk); #1;
        $display("Amostra nova = %0d | Media = %0d", amostra_nova, media);

        $display("----------------------------------------------------------");
        $display("Simulacao concluida.");
        $finish;
    end

endmodule