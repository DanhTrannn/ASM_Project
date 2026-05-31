default rel
%include "common.inc"

global draw_base
global print_kv
global print_line
global wait_back_or_quit
global pause_message

extern clear
extern refresh
extern mvprintw
extern getch
extern attron
extern attroff

section .rodata
fmt_top db " system_info > %s", 0
fmt_title db "[ %s ]", 0
fmt_str db "%s", 0
fmt_kv db "%-20s : %s", 0
border_top db "+------------------------------------------------------------------------------+", 0
border_mid db "|                                                                              |", 0
border_bot db "+------------------------------------------------------------------------------+", 0
footer_text db " b Back   r Refresh   q Quit                                                   ", 0
pause_text db "Nhan phim bat ky de tiep tuc...", 0

section .text
draw_base:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	mov rbx, rdi

	call clear

	xor edi, edi
	xor esi, esi
	lea rdx, [fmt_top]
	mov rcx, rbx
	ccall mvprintw

	mov edi, 2
	xor esi, esi
	lea rdx, [border_top]
	ccall mvprintw

	mov r12d, 3
.mid_loop:
	cmp r12d, 21
	jge .mid_done
	mov edi, r12d
	xor esi, esi
	lea rdx, [border_mid]
	ccall mvprintw
	inc r12d
	jmp .mid_loop

.mid_done:
	mov edi, 21
	xor esi, esi
	lea rdx, [border_bot]
	ccall mvprintw

	mov edi, 2
	mov esi, 32
	lea rdx, [fmt_title]
	mov rcx, rbx
	ccall mvprintw

	mov edi, 23
	xor esi, esi
	lea rdx, [footer_text]
	ccall mvprintw

	pop r12
	pop rbx
	leave
	ret

print_kv:
	push rbp
	mov rbp, rsp
	; rdi = row, rsi = label, rdx = value
	mov rcx, rsi
	mov r8, rdx
	mov esi, 4
	lea rdx, [fmt_kv]
	ccall mvprintw
	leave
	ret

print_line:
	push rbp
	mov rbp, rsp
	; rdi = row, rsi = col, rdx = text
	mov rcx, rdx
	lea rdx, [fmt_str]
	ccall mvprintw
	leave
	ret

wait_back_or_quit:
	push rbp
	mov rbp, rsp

	call refresh
.loop:
	call getch
	cmp eax, 'q'
	je .quit
	cmp eax, 'Q'
	je .quit
	cmp eax, 'b'
	je .back
	cmp eax, 'B'
	je .back
	cmp eax, 27
	je .back
	jmp .loop

.quit:
	mov eax, 1
	leave
	ret
.back:
	xor eax, eax
	leave
	ret

pause_message:
	push rbp
	mov rbp, rsp
	mov edi, 22
	mov esi, 3
	lea rdx, [pause_text]
	call print_line
	call refresh
	call getch
	xor eax, eax
	leave
	ret
