#;
#; Iterando cadeia de caracters
#; Author: Felipe Pena <sigsegv>
#;

	.section .data
	
texto: .ascii "foo\0"

	.section .text
.global _start

_start:
	xorl %edi, %edi	
	xorl %ebx, %ebx
	
loop:
	leal texto(, %edi, 1), %ecx

	cmpb $0, (%ecx)
	je exit

	movl $4, %eax
	movl $1, %ebx	
	movl $1, %edx
	int $0x80
	
	incl %edi
	jmp loop
exit:
	movl $1, %eax
	movl $0, %ebx
	int $0x80
