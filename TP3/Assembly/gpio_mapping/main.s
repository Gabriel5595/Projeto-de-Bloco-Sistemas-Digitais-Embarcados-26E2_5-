.global _start

.extern gpio_map
.extern gpio_unmap
.extern gpio_set_output
.extern gpio_set_input
.extern gpio_write
.extern gpio_read

.text

_start:
    bl gpio_map
    cmp x1, #0
    b.ne erro

    mov x19, x0

    mov x0, x19
    mov w1, #18
    bl gpio_set_output

    mov x0, x19
    mov w1, #17
    bl gpio_set_input

    mov x0, x19
    mov w1, #17
    bl gpio_read
    mov w20, w0

    mov x0, x19
    mov w1, #18
    mov w2, w20
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
