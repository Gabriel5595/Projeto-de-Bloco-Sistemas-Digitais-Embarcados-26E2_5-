module TP1_2(
    input a, b, c,
    output q
);
    assign q = a | (~b & c);
endmodule