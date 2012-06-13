#; 
#; Iterando numeros
#; Author: Felipe Pena <sigsegv>
#;

	.section .data
	
numeros: .long 10, 20, 30, 0

	.section .text
.global _start

_start:
	xorl %edi, %edi
	xorl %ebx, %ebx
	
loop:
	movl numeros(, %edi, 4), %eax
	incl %edi
	cmpl $0, %eax
	je exit
	addl %eax, %ebx
	jmp loop

exit:
	movl $1, %eax
	int $0x80
