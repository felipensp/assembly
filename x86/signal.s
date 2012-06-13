# Signal handling
# Author: Felipe Pena <sigsegv>
# Date: 2011-05-09
#
# $ as -o signal.o signal.s 
# $ ld --dynamic-linker /lib/ld-linux.so.2 -lc -o signal signal.o
# $ ./signal 
# ^CExiting...
# $ echo $?

	.section .data

.set SIGINT, 2
str:	.string "Exiting...\n"
		len = . - str

	.section .text
.global _start

__sigint_handler:
	# Writing in STDOUT
 	movl $4, %eax
	movl $1, %ebx
	movl $str, %ecx
	movl $len, %edx	
	int $0x80
	
	# Exiting using the exit status that would be used by the system
	# without the signal handler  (i.e. 128 + signal number)
	movl $1, %eax
	addl $128, 4(%esp)
	movl 4(%esp), %ebx 	
	int $0x80

_start:
	# Calling signal( SIGINT, __sigint_handler) 
	pushl $__sigint_handler
	pushl $SIGINT
	call signal	
	addl $8, %esp
	
	# Infinite loop
	jmp .
	
	movl $1, %eax
	movl $0, %ebx
	int $0x80
