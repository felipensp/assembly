#; Tausworthe 
#; Author: Felipe Pena <sigsegv>
#; Date: 2011-05-08

	.section .data
	
.set n1, 69069 * 13
.set n2, 69069 * 14
.set n3, 69069 * 15

.set s1, 4294967294
.set s2, 4294967288
.set s3, 4294967280

str:  .string "seed: %u\n"

	.section .bss
	
.macro tausworthe s, a, b, c, d
#	(s&c) << d
	movl \c, %ebx
	andl \s, %ebx
	sall \d, %ebx
#	((s << a) ^ s) >> b
	movl \s, %eax
	sall \a, %eax
	movl \s, %ecx
	xorl %eax, %ecx
	sarl \b, %ecx
	
	xorl %ebx, %ecx
.endm

	.section .text
.global _start

_start:	
	tausworthe $n1, $13, $19, $s1, $12
	pushl %ecx
	pushl $str
	call printf
	addl $8, %esp

	tausworthe $n2, $2, $25, $s2, $4
	pushl %ecx
	pushl $str
	call printf	
	addl $8, %esp
	
	tausworthe $n3, $3, $11, $s3, $17
	pushl %ecx
	pushl $str
	call printf
	addl $8, %esp

	movl $1, %eax
	movl $0, %ebx
	int $0x80
