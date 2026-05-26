.global _start

.section .data
msg:
	.ascii "Hello World!\n"

.section .text
_start:
	mov x0, #1	// argumento 1: stdout -> diz ao programa que o método de saída é terminal (1 = stdout)
	ldr x1, =msg	// argumento 2: endereço da string na RAM
	mov x2, #14	// argumento 3: tamnho da mensagem em bytes (13 letras + \n)
	mov x8, #64	// syscall write (ARM64 Linux)
	svc 0		// Chama o kernel para executar o write

	mov x0, #0	// Código de retorno -> 0 = sucesso
	mov x8, #93	// syscall exit
	svc 0		// Encerra o programa
