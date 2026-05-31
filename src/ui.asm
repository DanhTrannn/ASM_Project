default rel
%include "common.inc"

global ui_main_loop

extern draw_base
extern print_line
extern attron
extern attroff
extern mvprintw
extern refresh
extern getch
extern show_cpu
extern show_memory
extern show_disk
extern show_bios
extern show_os
extern show_network
extern show_time
extern show_all
extern show_export_report

section .rodata
title_menu db "Main Menu", 0
main_title db "NASM SYSTEM INFO VIEWER", 0
hint_line db "Dung phim mui ten hoac j/k, Enter de chon, q de thoat.", 0
menu_fmt db " %-42s ", 0
item0 db "1. Thong tin CPU", 0
item1 db "2. Thong tin Memory", 0
item2 db "3. Thong tin Disk", 0
item3 db "4. Thong tin BIOS/Firmware", 0
item4 db "5. Thong tin OS", 0
item5 db "6. Thong tin Network Interface", 0
item6 db "7. Thoi gian he thong", 0
item7 db "8. Xem tat ca", 0
item8 db "9. Xuat bao cao", 0
item9 db "0. Thoat", 0
items dq item0, item1, item2, item3, item4, item5, item6, item7, item8, item9
handlers dq show_cpu, show_memory, show_disk, show_bios, show_os, show_network, show_time, show_all, show_export_report

section .bss
selected resq 1

section .text
draw_menu:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	sub rsp, 8

	lea rdi, [title_menu]
	call draw_base

	mov edi, 4
	mov esi, 26
	lea rdx, [main_title]
	call print_line

	xor r12d, r12d
	lea r13, [items]
.loop:
	cmp r12d, 10
	jge .done

	mov rbx, [selected]
	cmp r12, rbx
	jne .normal
	mov edi, A_REVERSE
	call attron
.normal:
	mov edi, r12d
	add edi, 6
	mov esi, 18
	lea rdx, [menu_fmt]
	mov rcx, [r13 + r12 * 8]
	xor eax, eax
	call mvprintw

	mov rbx, [selected]
	cmp r12, rbx
	jne .next
	mov edi, A_REVERSE
	call attroff
.next:
	inc r12d
	jmp .loop

.done:
	mov edi, 19
	mov esi, 4
	lea rdx, [hint_line]
	call print_line
	call refresh

	add rsp, 8
	pop r13
	pop r12
	pop rbx
	leave
	ret

ui_main_loop:
	push rbp
	mov rbp, rsp
	push rbx
	sub rsp, 8

	mov qword [selected], 0
.loop:
	call draw_menu
	call getch
	cmp eax, 'q'
	je .exit
	cmp eax, 'Q'
	je .exit
	cmp eax, KEY_UP
	je .up
	cmp eax, 'k'
	je .up
	cmp eax, 'K'
	je .up
	cmp eax, KEY_DOWN
	je .down
	cmp eax, 'j'
	je .down
	cmp eax, 'J'
	je .down
	cmp eax, 10
	je .enter
	cmp eax, 13
	je .enter
	jmp .loop

.up:
	mov rax, [selected]
	test rax, rax
	jnz .dec
	mov rax, 9
	mov [selected], rax
	jmp .loop
.dec:
	dec rax
	mov [selected], rax
	jmp .loop

.down:
	mov rax, [selected]
	cmp rax, 9
	jne .inc
	mov qword [selected], 0
	jmp .loop
.inc:
	inc rax
	mov [selected], rax
	jmp .loop

.enter:
	mov rbx, [selected]
	cmp rbx, 9
	je .exit
	lea rax, [handlers]
	call [rax + rbx * 8]
	cmp eax, 1
	je .exit
	jmp .loop

.exit:
	add rsp, 8
	pop rbx
	leave
	ret
