#;
#; integer to string
#; Author: Felipe Pena <sigsegv>
#; as -o itoa.o itoa.s | ld --dynamic-linker /lib/ld-linux.so.2 -lc -o itoa itoa.o

	.section .data

fmt: .string "%s\n"

.lcomm converted, 10

.set NUMBER, 123

	.section .text

.global _start

_start:

	xorl %ecx, %ecx
	xorl %edi, %edi
	movl $NUMBER, %eax

itoa_loop:
	# Limpa para divisão
	xorl %edx, %edx
	
	movl $10, %esi
	
	# Agora nós temos o quociente em %eax
	# e o resto da divisão em %edx
	idiv %esi
		
	# Convertendo para a representação em ASCII
	addl $48, %edx
	
	pushl %edx
	incl %ecx
	
	xorl $0, %eax
	jnz itoa_loop

rev_loop:
	popl %eax
	movl %eax, converted(, %edi, 1)
	incl %edi
	decl %ecx

	cmpl $0, %ecx	
	jnz rev_loop
	
	pusha	
	pushl $converted
	pushl $fmt
	call printf
	addl $8, %esp	
	popa

	# Exiting
	movl $1, %eax
	int $0x80
