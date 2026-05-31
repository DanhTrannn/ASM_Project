default rel
%include "common.inc"

global main

extern setlocale
extern initscr
extern endwin
extern cbreak
extern noecho
extern keypad
extern curs_set
extern start_color
extern has_colors
extern init_pair
extern use_default_colors
extern stdscr
extern ui_main_loop

section .rodata
locale_empty db 0

section .text
main:
	push rbp
	mov rbp, rsp

	mov edi, LC_ALL
	lea rsi, [locale_empty]
	call setlocale

	call initscr
	call cbreak
	call noecho

	mov rdi, [stdscr]
	mov esi, TRUE
	call keypad

	xor edi, edi
	call curs_set

	call has_colors
	test eax, eax
	jz .colors_done
	call start_color
	call use_default_colors

	mov edi, 1
	mov esi, 6
	mov edx, -1
	call init_pair

	mov edi, 2
	mov esi, 3
	mov edx, -1
	call init_pair

	mov edi, 3
	mov esi, 2
	mov edx, -1
	call init_pair

	mov edi, 4
	mov esi, 1
	mov edx, -1
	call init_pair

.colors_done:
	call ui_main_loop
	call endwin

	xor eax, eax
	leave
	ret
