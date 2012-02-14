%include "constants.inc"

extern interrupt_handler
extern syscall_handle_interrupt
extern kernel_stack

global enable_interrupts
global disable_interrupts
global handle_syscall
global switch_to_kernel_stack

%macro no_error_code_handler 1
global interrupt_handler_%1
interrupt_handler_%1:
	push	dword 0
	push	dword %1
	jmp		common_interrupt_handler
%endmacro

%macro error_code_handler 1
global interrupt_handler_%1
interrupt_handler_%1:
	push	dword %1
	jmp		common_interrupt_handler
%endmacro

section .text:

common_interrupt_handler:
	push	eax
	push	ecx
	push	edx
	push	ebx
	push	esp
	push	ebp
	push	esi
	push	edi
	call	interrupt_handler
	pop	edi
	pop	esi
	pop	ebp
	pop	esp
	pop	ebx
	pop	edx
	pop	ecx
	pop	eax
	add	esp, 8
	iret

enable_interrupts:
    sti
    ret

disable_interrupts:
    cli
    ret

; protected mode exceptions
no_error_code_handler 0
no_error_code_handler 1
no_error_code_handler 2
no_error_code_handler 3
no_error_code_handler 4
no_error_code_handler 5
no_error_code_handler 6
no_error_code_handler 7
error_code_handler 8
no_error_code_handler 9
error_code_handler 10
error_code_handler 11
error_code_handler 12
error_code_handler 13
error_code_handler 14
no_error_code_handler 15
no_error_code_handler 16
error_code_handler 17
no_error_code_handler 18
no_error_code_handler 19

; irqs
no_error_code_handler 32
no_error_code_handler 33
no_error_code_handler 34
no_error_code_handler 35
no_error_code_handler 36
no_error_code_handler 37
no_error_code_handler 38
no_error_code_handler 39
no_error_code_handler 40
no_error_code_handler 41
no_error_code_handler 42
no_error_code_handler 43
no_error_code_handler 44
no_error_code_handler 45
no_error_code_handler 46
no_error_code_handler 47

; system call interrupt
handle_syscall:
	push	eax
	push	ecx
	push	edx
	push	ebx
	push	esp
	push	ebp
	push	esi
	push	edi
	call	syscall_handle_interrupt
	pop		edi
	pop		esi
	pop		ebp
	pop		esp
	pop		ebx
	pop		edx
	pop		ecx
    add		esp, 4			; don't pop eax since eax contains return value
    iret

switch_to_kernel_stack:
    mov     eax, [esp+4]	; load address of continuation into eax
    mov     ebx, [esp+8]    ; load the data into ebx
    mov	    esp, kernel_stack + KERNEL_STACK_SIZE
    push    ebx             ; push the data on the new stack
    call    eax             ; use call instead of jmp since C expects ret addr
    jmp     $
