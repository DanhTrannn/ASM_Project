default rel

global read_first_line
global trim_newline
global append_token

extern fopen
extern fgets
extern fclose
extern snprintf

section .rodata
mode_r db "r", 0
fmt_s db "%s", 0
not_available db "Not available", 0

section .text
read_first_line:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	sub rsp, 8

	mov r12, rdi
	mov r13, rsi
	mov rbx, rdx

	mov rdi, r13
	mov rsi, rbx
	lea rdx, [fmt_s]
	lea rcx, [not_available]
	xor eax, eax
	call snprintf

	mov rdi, r12
	lea rsi, [mode_r]
	call fopen
	test rax, rax
	jz .fail
	mov r12, rax

	mov rdi, r13
	mov rsi, rbx
	mov rdx, r12
	call fgets
	test rax, rax
	jz .close_fail

	mov rdi, r13
	call trim_newline

	mov rdi, r12
	call fclose
	mov eax, 1
	jmp .done

.close_fail:
	mov rdi, r12
	call fclose
.fail:
	xor eax, eax
.done:
	add rsp, 8
	pop r13
	pop r12
	pop rbx
	leave
	ret

trim_newline:
	push rbp
	mov rbp, rsp
	mov rax, rdi
.loop:
	mov dl, [rax]
	test dl, dl
	jz .done
	cmp dl, 10
	je .cut
	cmp dl, 13
	je .cut
	inc rax
	jmp .loop
.cut:
	mov byte [rax], 0
.done:
	leave
	ret

append_token:
	push rbp
	mov rbp, rsp
	; rdi = destination buffer, rsi = token
	cmp byte [rsi], 0
	je .done
	mov rax, rdi
.find_end:
	cmp byte [rax], 0
	je .at_end
	inc rax
	jmp .find_end
.at_end:
	cmp rax, rdi
	je .copy
	mov byte [rax], ' '
	inc rax
.copy:
	mov dl, [rsi]
	mov [rax], dl
	test dl, dl
	jz .done
	inc rax
	inc rsi
	jmp .copy
.done:
	leave
	ret
