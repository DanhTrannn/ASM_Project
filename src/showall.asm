default rel

global show_all

extern draw_base
extern print_line
extern wait_back_or_quit
extern collect_cpu
extern collect_memory
extern collect_bios
extern collect_os
extern collect_time
extern cpu_vendor
extern cpu_brand
extern cpu_features
extern mem_total
extern mem_available
extern swap_free
extern bios_vendor
extern os_pretty
extern os_kernel
extern time_text
extern timezone_text
extern mvprintw

section .rodata
title_showall db "Show All", 0
fmt_cpu db "[CPU] %s | %s", 0
fmt_cpu2 db "      Flags: %s", 0
fmt_mem db "[MEMORY] Total %s | Available %s | SwapFree %s", 0
fmt_bios db "[BIOS] %s", 0
fmt_os db "[OS] %s | Kernel %s", 0
fmt_time db "[TIME] %s | %s", 0
hint db "Chi tiet Disk/Network xem trong menu rieng; PgUp/PgDn co the bo sung sau.", 0

section .text
show_all:
	push rbp
	mov rbp, rsp

	call collect_cpu
	call collect_memory
	call collect_bios
	call collect_os
	call collect_time

	lea rdi, [title_showall]
	call draw_base

	mov edi, 5
	mov esi, 4
	lea rdx, [fmt_cpu]
	lea rcx, [cpu_vendor]
	lea r8, [cpu_brand]
	xor eax, eax
	call mvprintw

	mov edi, 6
	mov esi, 4
	lea rdx, [fmt_cpu2]
	lea rcx, [cpu_features]
	xor eax, eax
	call mvprintw

	mov edi, 8
	mov esi, 4
	lea rdx, [fmt_mem]
	lea rcx, [mem_total]
	lea r8, [mem_available]
	lea r9, [swap_free]
	xor eax, eax
	call mvprintw

	mov edi, 10
	mov esi, 4
	lea rdx, [fmt_bios]
	lea rcx, [bios_vendor]
	xor eax, eax
	call mvprintw

	mov edi, 12
	mov esi, 4
	lea rdx, [fmt_os]
	lea rcx, [os_pretty]
	lea r8, [os_kernel]
	xor eax, eax
	call mvprintw

	mov edi, 14
	mov esi, 4
	lea rdx, [fmt_time]
	lea rcx, [time_text]
	lea r8, [timezone_text]
	xor eax, eax
	call mvprintw

	mov edi, 18
	mov esi, 4
	lea rdx, [hint]
	call print_line

	call wait_back_or_quit
	leave
	ret
