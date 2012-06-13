#;
#; Author: Felipe Pena <sigsegv>
#;

	.section .data
.set pipe, 42
sfmt: .string "Fd: %d\n"
L1: .string "test\n"
	L1len = . - L1

	.section .bss
.lcomm fds, 4
.lcomm buff, 20

	.section .text
.global _start

# Escreve em um FD
write:
	movl $4, %eax
	movl 4(%esp), %ebx
	movl 8(%esp), %ecx
	movl 12(%esp), %edx
	
	int $0x80
	ret

# Lê de um FD
read:
	movl $3, %eax
	movl 4(%esp), %ebx
	movl $buff, %ecx
	movl $5, %edx
	
	int $0x80
	
	movl %ecx, %eax
	ret	

# Imprime o file descriptor
printfd:
	mov 4(%esp), %eax
	
	pushl %ebp
	movl %esp, %ebp
	
	pushl %eax
	pushl $sfmt
	call printf
	
	addl $8, %esp
	movl %ebp, %esp
	popl %ebp	
	ret

_start:	
	# Chama a syscall do pipe
	movl $pipe, %eax
	movl $fds, %ebx
	int $0x80
	
	# Imprime o fd do pipe
	pushl (%ebx)
	call printfd
	addl $4, %esp
	
	# Imprime o fd do pipe
	pushl 4(%ebx)
	call printfd
	addl $4, %esp
	
	pushl $L1len
	pushl $L1
	pushl 4(%ebx)     # Escrevendo no pipe
	call write
	addl $12, %esp
	
	leal fds, %eax
	pushl (%eax)
	call read         # Lendo do pipe
	movl %eax, %ebx
	addl $4, %esp
	
	leal fds, %eax
	pushl $L1len
	pushl %ebx
	pushl $1          # Escrevendo no STDOUT
	call write 
	addl $12, %esp
	
	# Exit
	movl $1, %eax
	xorl %ebx, %ebx
	int $0x80
