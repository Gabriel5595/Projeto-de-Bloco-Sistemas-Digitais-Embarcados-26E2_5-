.global calcula_media
.global calcula_media_benchmark
.extern converte_num_para_string

.equ SYS_WRITE, 64
.equ SYS_CLOCK_GETTIME, 113
.equ CLOCK_MONOTONIC, 1
.equ BENCH_TAMANHO, 150
.equ BENCH_REPETICOES, 200000

.macro zera_acumulador_vetorial reg
    movi \reg\().4s, #0
.endm

.macro carrega_vetor_generico registro_dst, registro_ptr, offset=16
    ld1 {\registro_dst\().4s}, [\registro_ptr], #\offset
.endm

.section .data
.align 4
bench_buffer: .skip (BENCH_TAMANHO * 4)

.align 8
bench_ts_inicio:
    .quad 0
    .quad 0
bench_ts_fim:
    .quad 0
    .quad 0

msg_bench_titulo: .asciz "\n=== Benchmark calcula_media (150 amostras, 200000 repeticoes) ===\n"
msg_bench_titulo_fim = . - msg_bench_titulo - 1

msg_verificacao_ok: .asciz "Verificacao: os tres metodos produziram a mesma soma (OK)\n"
msg_verificacao_ok_fim = . - msg_verificacao_ok - 1

msg_verificacao_falha: .asciz "Verificacao: DIVERGENCIA entre os metodos\n"
msg_verificacao_falha_fim = . - msg_verificacao_falha - 1

msg_bench_escalar: .asciz "Escalar:            "
msg_bench_escalar_fim = . - msg_bench_escalar - 1

msg_bench_vet_int: .asciz "Vetorial (inteiro): "
msg_bench_vet_int_fim = . - msg_bench_vet_int - 1

msg_bench_vet_float: .asciz "Vetorial (float):   "
msg_bench_vet_float_fim = . - msg_bench_vet_float - 1

msg_bench_ns: .asciz " ns totais\n"
msg_bench_ns_fim = . - msg_bench_ns - 1

.section .text

calcula_media:
    stp x29, x30, [sp, -16]!
    mov x29, sp

    ldr w9, [x1]
    cmp w9, #0
    beq media_vazia

    bl soma_vetorial_inteira

    sxtw x9, w9
    sdiv x0, x10, x9
    b zera_indice_media

media_vazia:
    mov x0, #0

zera_indice_media:
    mov w9, #0
    str w9, [x1]

    ldp x29, x30, [sp], 16
    ret

soma_escalar:
    mov x10, #0
    mov w11, #0

soma_escalar_loop:
    cmp w11, w9
    bge fim_soma_escalar
    ldr w12, [x0, x11, lsl #2]
    sxtw x12, w12
    add x10, x10, x12
    add w11, w11, #1
    b soma_escalar_loop

fim_soma_escalar:
    ret

soma_vetorial_inteira:
    zera_acumulador_vetorial v1
    lsr w13, w9, #2
    mov w11, #0

grupo_vetorial_inteira:
    cbz w13, fim_grupo_vetorial_inteira
    carrega_vetor_generico v0, x0
    add v1.4s, v1.4s, v0.4s
    sub w13, w13, #1
    add w11, w11, #4
    b grupo_vetorial_inteira

fim_grupo_vetorial_inteira:
    addv s1, v1.4s
    fmov w10, s1

resto_vetorial_inteira:
    cmp w11, w9
    bge fim_soma_vetorial_inteira
    ldr w12, [x0], #4
    add w10, w10, w12
    add w11, w11, #1
    b resto_vetorial_inteira

fim_soma_vetorial_inteira:
    sxtw x10, w10
    ret

soma_vetorial_float:
    zera_acumulador_vetorial v1
    lsr w13, w9, #2
    mov w11, #0

grupo_vetorial_float:
    cbz w13, fim_grupo_vetorial_float
    carrega_vetor_generico v0, x0
    scvtf v0.4s, v0.4s
    fadd v1.4s, v1.4s, v0.4s
    sub w13, w13, #1
    add w11, w11, #4
    b grupo_vetorial_float

fim_grupo_vetorial_float:
    faddp v2.4s, v1.4s, v1.4s
    faddp s0, v2.2s

resto_vetorial_float:
    cmp w11, w9
    bge fim_soma_vetorial_float
    ldr w12, [x0], #4
    scvtf s3, w12
    fadd s0, s0, s3
    add w11, w11, #1
    b resto_vetorial_float

fim_soma_vetorial_float:
    ret

calcula_delta_ns:
    ldr x9, [x0]
    ldr x10, [x0, 8]
    ldr x11, [x1]
    ldr x12, [x1, 8]
    sub x13, x11, x9
    sub x14, x12, x10
    ldr x15, =1000000000
    mul x13, x13, x15
    add x0, x13, x14
    ret

calcula_media_benchmark:
    stp x29, x30, [sp, -64]!
    mov x29, sp
    stp x19, x20, [sp, 16]
    stp x21, x22, [sp, 32]
    str x23, [sp, 48]

    ldr x19, =bench_buffer
    mov w11, #0
bench_preenche_loop:
    cmp w11, #BENCH_TAMANHO
    bge bench_preenche_fim
    mov w12, w11
    mov w13, #7
    mul w12, w12, w13
    sub w12, w12, #350
    str w12, [x19, x11, lsl #2]
    add w11, w11, #1
    b bench_preenche_loop
bench_preenche_fim:

    mov x0, #1
    ldr x1, =msg_bench_titulo
    mov x2, #msg_bench_titulo_fim
    mov x8, #SYS_WRITE
    svc #0

    mov x0, x19
    mov w9, #BENCH_TAMANHO
    bl soma_escalar
    mov x21, x10

    mov x0, x19
    mov w9, #BENCH_TAMANHO
    bl soma_vetorial_inteira
    mov x22, x10

    mov x0, x19
    mov w9, #BENCH_TAMANHO
    bl soma_vetorial_float
    fcvtzs x23, s0

    cmp x21, x22
    bne verificacao_falhou
    cmp x21, x23
    bne verificacao_falhou

    mov x0, #1
    ldr x1, =msg_verificacao_ok
    mov x2, #msg_verificacao_ok_fim
    mov x8, #SYS_WRITE
    svc #0
    b verificacao_fim

verificacao_falhou:
    mov x0, #1
    ldr x1, =msg_verificacao_falha
    mov x2, #msg_verificacao_falha_fim
    mov x8, #SYS_WRITE
    svc #0

verificacao_fim:

    mov x0, #CLOCK_MONOTONIC
    ldr x1, =bench_ts_inicio
    mov x8, #SYS_CLOCK_GETTIME
    svc #0
    mov w20, #0
bench_loop_escalar:
    ldr w14, =BENCH_REPETICOES
    cmp w20, w14
    bge bench_fim_loop_escalar
    mov x0, x19
    mov w9, #BENCH_TAMANHO
    bl soma_escalar
    add w20, w20, #1
    b bench_loop_escalar
bench_fim_loop_escalar:
    mov x0, #CLOCK_MONOTONIC
    ldr x1, =bench_ts_fim
    mov x8, #SYS_CLOCK_GETTIME
    svc #0
    ldr x0, =bench_ts_inicio
    ldr x1, =bench_ts_fim
    bl calcula_delta_ns
    mov x21, x0
    mov x0, #1
    ldr x1, =msg_bench_escalar
    mov x2, #msg_bench_escalar_fim
    mov x8, #SYS_WRITE
    svc #0
    mov x0, x21
    bl converte_num_para_string
    mov x2, x1
    mov x1, x0
    mov x0, #1
    mov x8, #SYS_WRITE
    svc #0
    mov x0, #1
    ldr x1, =msg_bench_ns
    mov x2, #msg_bench_ns_fim
    mov x8, #SYS_WRITE
    svc #0

    mov x0, #CLOCK_MONOTONIC
    ldr x1, =bench_ts_inicio
    mov x8, #SYS_CLOCK_GETTIME
    svc #0
    mov w20, #0
bench_loop_vetorial:
    ldr w14, =BENCH_REPETICOES
    cmp w20, w14
    bge bench_fim_loop_vetorial
    mov x0, x19
    mov w9, #BENCH_TAMANHO
    bl soma_vetorial_inteira
    add w20, w20, #1
    b bench_loop_vetorial
bench_fim_loop_vetorial:
    mov x0, #CLOCK_MONOTONIC
    ldr x1, =bench_ts_fim
    mov x8, #SYS_CLOCK_GETTIME
    svc #0
    ldr x0, =bench_ts_inicio
    ldr x1, =bench_ts_fim
    bl calcula_delta_ns
    mov x21, x0
    mov x0, #1
    ldr x1, =msg_bench_vet_int
    mov x2, #msg_bench_vet_int_fim
    mov x8, #SYS_WRITE
    svc #0
    mov x0, x21
    bl converte_num_para_string
    mov x2, x1
    mov x1, x0
    mov x0, #1
    mov x8, #SYS_WRITE
    svc #0
    mov x0, #1
    ldr x1, =msg_bench_ns
    mov x2, #msg_bench_ns_fim
    mov x8, #SYS_WRITE
    svc #0

    mov x0, #CLOCK_MONOTONIC
    ldr x1, =bench_ts_inicio
    mov x8, #SYS_CLOCK_GETTIME
    svc #0
    mov w20, #0
bench_loop_float:
    ldr w14, =BENCH_REPETICOES
    cmp w20, w14
    bge bench_fim_loop_float
    mov x0, x19
    mov w9, #BENCH_TAMANHO
    bl soma_vetorial_float
    add w20, w20, #1
    b bench_loop_float
bench_fim_loop_float:
    mov x0, #CLOCK_MONOTONIC
    ldr x1, =bench_ts_fim
    mov x8, #SYS_CLOCK_GETTIME
    svc #0
    ldr x0, =bench_ts_inicio
    ldr x1, =bench_ts_fim
    bl calcula_delta_ns
    mov x21, x0
    mov x0, #1
    ldr x1, =msg_bench_vet_float
    mov x2, #msg_bench_vet_float_fim
    mov x8, #SYS_WRITE
    svc #0
    mov x0, x21
    bl converte_num_para_string
    mov x2, x1
    mov x1, x0
    mov x0, #1
    mov x8, #SYS_WRITE
    svc #0
    mov x0, #1
    ldr x1, =msg_bench_ns
    mov x2, #msg_bench_ns_fim
    mov x8, #SYS_WRITE
    svc #0

    ldr x23, [sp, 48]
    ldp x21, x22, [sp, 32]
    ldp x19, x20, [sp, 16]
    ldp x29, x30, [sp], 64
    ret
