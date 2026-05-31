default rel

global show_time
global collect_time
global time_text
global timezone_text

extern draw_base
extern print_kv
extern wait_back_or_quit
extern time
extern localtime
extern strftime
extern strcpy
extern read_first_line
extern readlink

section .rodata
title_time db "Time", 0
label_datetime db "Datetime", 0
label_timezone db "Timezone", 0
label_source db "Nguon", 0
source_value db "/etc/localtime, libc time/localtime/strftime", 0
fmt_time db "%d/%m/%Y %H:%M:%S", 0
fmt_timezone db "%Z %z", 0
path_timezone db "/etc/timezone", 0
path_localtime db "/etc/localtime", 0
needle_zoneinfo db "zoneinfo/", 0
not_available db "Not available", 0

section .bss
time_text resb 64
timezone_text resb 64
timezone_offset_text resb 64
time_value resq 1
timezone_file_buf resb 128
localtime_link_buf resb 256

section .text
collect_time:
	push rbp
	mov rbp, rsp
	push rbx
	sub rsp, 8

	lea rdi, [time_text]
	lea rsi, [not_available]
	call strcpy
	lea rdi, [timezone_text]
	lea rsi, [not_available]
	call strcpy
	lea rdi, [timezone_offset_text]
	lea rsi, [not_available]
	call strcpy

	lea rdi, [time_value]
	call time
	lea rdi, [time_value]
	call localtime
	test rax, rax
	jz .done
	mov rbx, rax
	lea rdi, [time_text]
	mov esi, 64
	lea rdx, [fmt_time]
	mov rcx, rbx
	call strftime
	lea rdi, [timezone_text]
	mov esi, 64
	lea rdx, [fmt_timezone]
	mov rcx, rbx
	call strftime
	lea rdi, [timezone_offset_text]
	lea rsi, [timezone_text]
	call strcpy

	lea rdi, [path_timezone]
	lea rsi, [timezone_file_buf]
	mov edx, 128
	call read_first_line
	test eax, eax
	jz .try_localtime_link
	cmp byte [timezone_file_buf], 0
	je .try_localtime_link
	lea rdi, [timezone_text]
	lea rsi, [timezone_file_buf]
	call strcpy
	jmp .done

.try_localtime_link:
	lea rdi, [path_localtime]
	lea rsi, [localtime_link_buf]
	mov edx, 255
	call readlink
	test rax, rax
	jle .use_offset
	mov byte [localtime_link_buf + rax], 0

	lea rsi, [localtime_link_buf]
.search_zoneinfo:
	cmp byte [rsi], 0
	je .use_offset
	mov r8, rsi
	lea r9, [needle_zoneinfo]
.match_zoneinfo:
	mov al, [r9]
	test al, al
	jz .copy_zone_name
	cmp [r8], al
	jne .next_char
	inc r8
	inc r9
	jmp .match_zoneinfo
.next_char:
	inc rsi
	jmp .search_zoneinfo

.copy_zone_name:
	lea rdi, [timezone_text]
	mov rcx, 63
.copy_loop:
	mov al, [r8]
	test al, al
	jz .copy_done
	mov [rdi], al
	inc rdi
	inc r8
	loop .copy_loop
.copy_done:
	mov byte [rdi], 0
	jmp .done

.use_offset:
	lea rdi, [timezone_text]
	lea rsi, [timezone_offset_text]
	call strcpy

.done:
	add rsp, 8
	pop rbx
	leave
	ret

show_time:
	push rbp
	mov rbp, rsp
	call collect_time
	lea rdi, [title_time]
	call draw_base

	mov edi, 8
	lea rsi, [label_datetime]
	lea rdx, [time_text]
	call print_kv
	mov edi, 11
	lea rsi, [label_timezone]
	lea rdx, [timezone_text]
	call print_kv
	mov edi, 13
	lea rsi, [label_source]
	lea rdx, [source_value]
	call print_kv

	call wait_back_or_quit
	leave
	ret
