.section .data

leituras_umidade:
    .byte 72, 45, 30, 58, 20

quantidade_leituras:
    .word 5

threshold_baixo:
    .byte 35

threshold_alto:
    .byte 60

msg_irrigar:
    .ascii "Decisao: Irrigar\n"
    .equ   tam_irrigar, . - msg_irrigar

msg_ok:
    .ascii "Decisao: OK\n"
    .equ   tam_ok, . - msg_ok

msg_critico:
    .ascii "Decisao: Solo critico - irrigando\n"
    .equ   tam_critico, . - msg_critico

msg_leitura:
    .ascii "Leitura "
    .equ   tam_leitura, . - msg_leitura

separador:
    .ascii " -> "
    .equ   tam_separador, . - separador

digito_buffer:
    .byte 0, 0, 0, 10

.section .text
.global _start

_start:
    ldr x19, =leituras_umidade
    ldr x20, =quantidade_leituras
    ldr w20, [x20]
    mov x21, #0

    ldr x22, =threshold_baixo
    ldrb w22, [x22]

    ldr x23, =threshold_alto
    ldrb w23, [x23]

loop_leituras:
    cmp x21, x20
    b.ge fim_loop

    ldrb w24, [x19], #1

    mov x0, x21
    add x0, x0, #1
    bl imprimir_numero_leitura

    ldr x0, =separador
    mov x1, #tam_separador
    bl escrever_terminal

    cmp w24, w22
    b.lt solo_critico

    cmp w24, w23
    b.ge solo_umido

    ldr x0, =msg_irrigar
    mov x1, #tam_irrigar
    bl escrever_terminal
    b proxima_leitura

solo_critico:
    ldr x0, =msg_critico
    mov x1, #tam_critico
    bl escrever_terminal
    b proxima_leitura

solo_umido:
    ldr x0, =msg_ok
    mov x1, #tam_ok
    bl escrever_terminal

proxima_leitura:
    add x21, x21, #1
    b loop_leituras

fim_loop:
    mov x8, #93
    mov x0, #0
    svc #0

imprimir_numero_leitura:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    mov x9, x0
    mov x10, #10
    udiv x11, x9, x10
    msub x12, x11, x10, x9

    ldr x0, =msg_leitura
    mov x1, #tam_leitura
    bl escrever_terminal

    ldr x13, =digito_buffer
    add w12, w12, #48
    strb w12, [x13]

    cbz x11, digito_unico

    add w11, w11, #48
    strb w11, [x13, #-1]
    mov x0, x13
    sub x0, x0, #1
    mov x1, #2
    bl escrever_terminal
    b fim_imprimir

digito_unico:
    add x0, x13, #0
    mov x1, #1
    bl escrever_terminal

fim_imprimir:
    ldp x29, x30, [sp], #16
    ret

escrever_terminal:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    mov x2, x1
    mov x1, x0
    mov x0, #1
    mov x8, #64
    svc #0

    ldp x29, x30, [sp], #16
    ret
