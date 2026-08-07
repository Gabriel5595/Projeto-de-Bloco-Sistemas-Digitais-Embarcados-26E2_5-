module fsm_controle_leitura_tb;

    reg clk;
    reg rst;
    reg start;
    reg dado_pronto;
    wire canal_sel;
    wire amostrar;
    wire transmitir;

    fsm_controle_leitura uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .dado_pronto(dado_pronto),
        .canal_sel(canal_sel),
        .amostrar(amostrar),
        .transmitir(transmitir)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("fsm_controle_leitura.vcd");
        $dumpvars(0, fsm_controle_leitura_tb);

        clk = 0;
        rst = 1;
        start = 0;
        dado_pronto = 0;
        #10;
        rst = 0;

        #10 start = 1;
        #10 start = 0;

        #10 dado_pronto = 1;
        #10 dado_pronto = 0;

        #10 dado_pronto = 1;
        #10 dado_pronto = 0;

        #10 start = 1;
        #10 start = 0;

        #10 dado_pronto = 1;
        #10 dado_pronto = 0;

        #10 dado_pronto = 1;
        #10 dado_pronto = 0;

        #20 $finish;
    end

endmodule