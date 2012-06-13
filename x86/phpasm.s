# A simple PHP extension
#
# Author: Felipe Pena <sigsegv>
# Date: 2011-05-09
#
# ld -shared -o phpasm phpasm.o
#

	.section .bss
	
# sizeof(zend_function_entry) = 20
.lcomm module_functions, 40

# sizeof(zend_module_entry) = 92
.lcomm module_entry 92

	.section .rodata	
extname: .string "asm"
phpbuild: .string "API20090626,TS,debug"
funcname: .string "helloworld"
str: .string "hello world from Assembly! :)"
	len = . - str - 1
	
	.section .text
.global get_module
.global zif_helloworld

zif_helloworld:
	# typedef union _zvalue_value {
    # 	long lval;
    # 	double dval;
    # 	struct {
    # 		char *val;
    # 		int len;
    # 	} str;
    # 	HashTable *ht;
    # 	zend_object_value obj;
    # } zvalue_value;
    
	# struct _zval_struct {
    # 	zvalue_value value;
    # 	zend_uint refcount__gc;
    # 	zend_uchar type;
    # 	zend_uchar is_ref__gc;
    # };
    
    # return_value zval
	movl 8(%esp), %ebx
	
	# Changing the zval type to IS_STRING
	movl $6, 12(%ebx)
		
	pushl $0
	pushl $0
	pushl $len
	pushl $str
	call _estrndup
	addl $16, %esp
	
	# Set the pointer for our alloc'ed string
	movl %eax, (%ebx)
	# Set the string length
	movl $len, 4(%ebx)
	ret

__initialize_functions:
	movl $0, %edi
	movl $funcname, module_functions(,%edi,4)
	
	movl $1, %edi
	movl $zif_helloworld, module_functions(,%edi,4)
	ret

get_module:
	call __initialize_functions

	# Zend API
	movl $1, %edi
	movl $20090626, module_entry(,%edi,4)
	
	# Module name
	movl $5, %edi
	movl $extname, module_entry(,%edi,4)
	
	# Functions
	movl $6, %edi
	movl $module_functions, module_entry(,%edi,4)
	
	# Build ID
	movl $22, %edi
	movl $phpbuild, module_entry(,%edi,4)

	movl $module_entry, %eax
	ret
