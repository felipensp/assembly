# Signal handling
# Author: Felipe Pena <sigsegv>
# Date: 2011-05-09
#
# $ as -o sigaction.o sigaction.s
# $ ld --dynamic-linker /lib/ld-linux.so.2 -lc -o sigaction sigaction.o
# $ ./sigaction 
# ^CExiting...
# $ echo $?

	.section .data

.set SIGINT, 2
.set SA_SIGINFO, 4
str:	.string "Exiting...\n"
		len = . - str

	.section .bss
	
# The sigaction structure
# sizeof(struct sigaction) = 140 
# (this might be different on your system, see sigaction.h)
#
# struct sigaction {
#	sighandler_t sa_handler (4 bytes)
#	sigset_t sa_mask (128 bytes)
#	int sa_flags (4 bytes)
#   void (*sa_restorer) (void); (4 bytes)
# }
.lcomm struct_sigaction, 140

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
	movl $3, %ebx
	addl $128, 4(%esp)
	movl 4(%esp), %ebx 	
	int $0x80
	
_start:
	# Writing the sa_handler field
	# offsetof(struct sigaction, sa_handler) == 0
	movl $__sigint_handler, struct_sigaction
	
	# Writing the sa_flags field
	# offsetof(struct sigaction, sa_flags) == 132
	movl $132, %edi
	movl $SA_SIGINFO, struct_sigaction(,%edi,1)
	
	# Calling sigaction(int, const struct sigaction *, struct sigaction *)
	pushl $0
	pushl $struct_sigaction
	pushl $SIGINT
	call sigaction
	addl $12, %esp
	
	# Infinite loop
	jmp .

	movl $1, %eax
	movl $0, %ebx
	int $0x80 
