# Macro para carregar o endereço da syscall setreuid em %rsi
.macro __get_setreuid_ptr
	movq $0xffffffff81307240, %rsi  # endereço da sys_call_table
	movq $113, %rcx                 # 113 = sys_setreuid
	leaq (%rsi, %rcx, 8), %rsi      # endereço da sys_setreuid
.endm

# Macro para desabilitar proteção de escrita (bit WP do cr0) em páginas de memória
.macro __disable_write_protection
	movq %cr0, %rdx
	movq $0x10000, %rcx
	notq %rcx
	andq %rcx, %rdx
	movq %rdx, %cr0
.endm

# Macro para habilitar a proteção de escrita (bit WP do cr0) em páginas de memória
.macro __enable_write_protection
	movq %cr0, %rdx
	orq $0x10000, %rdx
	movq %rdx, %cr0
.endm

	.section .rodata
init_msg:     .string "<1>Modulo inicializado!\n"
exit_msg:     .string "<1>Modulo finalizado!\n"
hijack:       .string "<1>setreuid hijacked!\n"
setreuid_msg: .string "<1>sys_setreuid addr = %lx\n"

	.section .bss
# Onde guardaremos o endereço original da sys_setreuid
.lcomm old_setreuid, 8

	.section .text
.global init_module
.global cleanup_module
.global my_setreuid

# Implementação da sys_setreuid que só mostra uma mensagem
my_setreuid:
	callq *old_setreuid
	movq %rax, %r12
	
	leaq hijack, %rdi
	callq printk

	xorq %rax, %rax
	ret	

init_module:
	leaq init_msg, %rdi
	callq printk
	
	__disable_write_protection
	
	__get_setreuid_ptr	
	
	leaq setreuid_msg, %rdi
	movq (%rsi), %rsi	
	# Guarda o antigo endereço
	movq %rsi, old_setreuid(%rip)	
	# Printa o endereço atual
	callq printk
	
	__get_setreuid_ptr	
	leaq my_setreuid(%rip), %rcx 
	# Altera o endereço para apontar para nossa setreuid
	movq %rcx, (%rsi)

	leaq setreuid_msg, %rdi
	movq (%rsi), %rsi
	# Printa o novo endereço
	callq printk
	
	__enable_write_protection
	
	xorq %rax, %rax
	ret
	
cleanup_module:
	leaq exit_msg, %rdi
	callq printk
	
	__get_setreuid_ptr

	leaq setreuid_msg, %rdi
	movq (%rsi), %rsi	
	# Printa o endereço atual na sys_call_table para setreuid
	callq printk

	__disable_write_protection
	
	__get_setreuid_ptr
	
	leaq setreuid_msg, %rdi
	# Coloca o antigo endereço (o original) devolta para a sys_call_table
	movq old_setreuid(%rip), %rax
	movq %rax, (%rsi)
	movq (%rsi), %rsi
	
	__enable_write_protection
	
	# Mostra o endereço que escrevemos devolta na sys_call_table
	callq printk
	
	xorq %rax, %rax
	ret

	.section .modinfo, "aS", @progbits
__kernel_version:     .string "kernel_version=2.6.32"
__module_license:     .string "license=GPL"
__module_author:      .string "author=Felipe Pena"
__module_depends:     .string "depends="
__module_description: .string "description=Modulo de teste"
