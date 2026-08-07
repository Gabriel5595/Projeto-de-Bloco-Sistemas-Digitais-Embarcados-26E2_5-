.global _start

.extern gpio_map
.extern gpio_unmap
.extern gpio_set_output
.extern gpio_write

.equ TAG_SOLO,         1
.equ TAG_LUMINOSIDADE, 2

.equ GPIO_BOMBA, 23
.equ GPIO_LED,   24

.equ LIMIAR_SOLO_BAIXO,  35
.equ LIMIAR_SOLO_ALTO,   60
.equ LIMIAR_LUZ_ALTA,    200

.data
qtd_pacotes:
    .quad 4

pacotes:
    .byte TAG_SOLO,         28
    .byte TAG_LUMINOSIDADE, 210
    .byte TAG_SOLO,         50
    .byte TAG_LUMINOSIDADE, 90

solo_atual:
    .word 0

luz_atual:
    .word 0

tabela_tags:
    .xword rotina_solo
    .xword rotina_luz

.text

_start:
    ldr x1, =pacotes
    ldr x2, =qtd_pacotes
    ldr x2, [x2]
    mov x3, #0

processa_pacotes:
    cmp x3, x2
    b.ge fim_parsing

    ldrb w4, [x1]
    ldrb w5, [x1, #1]

    sub w6, w4, #1
    adr x7, tabela_tags
    ldr x8, [x7, x6, lsl #3]
    br x8

rotina_solo:
    ldr x9, =solo_atual
    str w5, [x9]
    b proximo_pacote

rotina_luz:
    ldr x9, =luz_atual
    str w5, [x9]
    b proximo_pacote

proximo_pacote:
    add x1, x1, #2
    add x3, x3, #1
    b processa_pacotes

fim_parsing:
    ldr x9, =solo_atual
    ldr w10, [x9]

    ldr x9, =luz_atual
    ldr w11, [x9]

    cmp w10, #LIMIAR_SOLO_BAIXO
    b.ge verifica_solo_alto
    cmp w11, #LIMIAR_LUZ_ALTA
    b.gt acao_irrigar_urgente
    b acao_irrigar

verifica_solo_alto:
    cmp w10, #LIMIAR_SOLO_ALTO
    b.gt acao_nao_irrigar
    b acao_manter

acao_irrigar_urgente:
    mov w20, #1
    mov w21, #1
    b aciona_atuadores

acao_irrigar:
    mov w20, #1
    mov w21, #0
    b aciona_atuadores

acao_nao_irrigar:
    mov w20, #0
    mov w21, #0
    b aciona_atuadores

acao_manter:
    mov w20, #0
    mov w21, #0
    b aciona_atuadores

aciona_atuadores:
    bl gpio_map
    cmp x1, #0
    b.ne erro

    mov x19, x0

    mov x0, x19
    mov w1, #GPIO_BOMBA
    bl gpio_set_output

    mov x0, x19
    mov w1, #GPIO_LED
    bl gpio_set_output

    mov x0, x19
    mov w1, #GPIO_BOMBA
    mov w2, w20
    bl gpio_write

    mov x0, x19
    mov w1, #GPIO_LED
    mov w2, w21
    bl gpio_write

    mov x0, x19
    bl gpio_unmap

    mov x0, #0
    mov x8, #93
    svc #0

erro:
    mov x0, #1
    mov x8, #93
    svc #0
