.global converte_luz

.section .text

converte_luz:
    mov w1, #25
    mul w0, w0, w1
    mov w1, #3
    udiv w0, w0, w1
    ret