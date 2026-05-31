default rel

global show_memory
global collect_memory
global mem_total
global mem_free
global mem_available
global swap_total
global swap_free

extern draw_base
extern print_kv
extern print_line
extern wait_back_or_quit
extern fopen
extern fgets
extern fclose
extern strncmp
extern strcpy
extern sscanf
extern snprintf

section .rodata
title_memory db "Memory", 0
path_meminfo db "/proc/meminfo", 0
mode_r db "r", 0
not_available db "Not available", 0
scan_mem db "%*s %llu", 0
fmt_mb db "%llu MB", 0
pre_memtotal db "MemTotal:", 0
pre_memfree db "MemFree:", 0
pre_memavailable db "MemAvailable:", 0
pre_swaptotal db "SwapTotal:", 0
pre_swapfree db "SwapFree:", 0
label_memtotal db "MemTotal", 0
label_memfree db "MemFree", 0
label_memavailable db "MemAvailable", 0
label_swaptotal db "SwapTotal", 0
label_swapfree db "SwapFree", 0
source_text db "Nguon: /proc/meminfo | don vi hien thi MB", 0

section .bss
mem_total resb 32
mem_free resb 32
mem_available resb 32
swap_total resb 32
swap_free resb 32
line_buf resb 256
tmp_value resq 1

section .text
set_na:
	push rbp
	mov rbp, rsp
	lea rsi, [not_available]
	call strcpy
	leave
	ret

format_mem_line:
	push rbp
	mov rbp, rsp
	push rbx
	sub rsp, 8
	mov rbx, rdi

	mov rdi, rsi
	lea rsi, [scan_mem]
	lea rdx, [tmp_value]
	xor eax, eax
	call sscanf
	cmp eax, 1
	jne .bad

	mov rax, [tmp_value]
	xor edx, edx
	mov rcx, 1024
	div rcx
	mov rcx, rax
	mov rdi, rbx
	mov esi, 32
	lea rdx, [fmt_mb]
	xor eax, eax
	call snprintf
	jmp .done
.bad:
	mov rdi, rbx
	call set_na
.done:
	add rsp, 8
	pop rbx
	leave
	ret

collect_memory:
	push rbp
	mov rbp, rsp
	push rbx
	sub rsp, 8

	lea rdi, [mem_total]
	call set_na
	lea rdi, [mem_free]
	call set_na
	lea rdi, [mem_available]
	call set_na
	lea rdi, [swap_total]
	call set_na
	lea rdi, [swap_free]
	call set_na

	lea rdi, [path_meminfo]
	lea rsi, [mode_r]
	call fopen
	test rax, rax
	jz .done
	mov rbx, rax

.read_loop:
	lea rdi, [line_buf]
	mov esi, 256
	mov rdx, rbx
	call fgets
	test rax, rax
	jz .close

	lea rdi, [line_buf]
	lea rsi, [pre_memtotal]
	mov edx, 9
	call strncmp
	test eax, eax
	jnz .memfree
	lea rdi, [mem_total]
	lea rsi, [line_buf]
	call format_mem_line
	jmp .read_loop

.memfree:
	lea rdi, [line_buf]
	lea rsi, [pre_memfree]
	mov edx, 8
	call strncmp
	test eax, eax
	jnz .memavail
	lea rdi, [mem_free]
	lea rsi, [line_buf]
	call format_mem_line
	jmp .read_loop

.memavail:
	lea rdi, [line_buf]
	lea rsi, [pre_memavailable]
	mov edx, 13
	call strncmp
	test eax, eax
	jnz .swaptotal
	lea rdi, [mem_available]
	lea rsi, [line_buf]
	call format_mem_line
	jmp .read_loop

.swaptotal:
	lea rdi, [line_buf]
	lea rsi, [pre_swaptotal]
	mov edx, 10
	call strncmp
	test eax, eax
	jnz .swapfree
	lea rdi, [swap_total]
	lea rsi, [line_buf]
	call format_mem_line
	jmp .read_loop

.swapfree:
	lea rdi, [line_buf]
	lea rsi, [pre_swapfree]
	mov edx, 9
	call strncmp
	test eax, eax
	jnz .read_loop
	lea rdi, [swap_free]
	lea rsi, [line_buf]
	call format_mem_line
	jmp .read_loop

.close:
	mov rdi, rbx
	call fclose
.done:
	add rsp, 8
	pop rbx
	leave
	ret

show_memory:
	push rbp
	mov rbp, rsp
	call collect_memory
	lea rdi, [title_memory]
	call draw_base

	mov edi, 5
	lea rsi, [label_memtotal]
	lea rdx, [mem_total]
	call print_kv
	mov edi, 7
	lea rsi, [label_memfree]
	lea rdx, [mem_free]
	call print_kv
	mov edi, 9
	lea rsi, [label_memavailable]
	lea rdx, [mem_available]
	call print_kv
	mov edi, 11
	lea rsi, [label_swaptotal]
	lea rdx, [swap_total]
	call print_kv
	mov edi, 13
	lea rsi, [label_swapfree]
	lea rdx, [swap_free]
	call print_kv
	mov edi, 17
	mov esi, 4
	lea rdx, [source_text]
	call print_line

	call wait_back_or_quit
	leave
	ret
