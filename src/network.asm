default rel

global show_network
global export_network
global collect_network_summary
global network_summary

extern draw_base
extern print_line
extern wait_back_or_quit
extern opendir
extern readdir
extern closedir
extern snprintf
extern strcpy
extern strcat
extern read_first_line
extern mvprintw
extern fprintf

section .rodata
title_network db "Network", 0
path_net db "/sys/class/net", 0
fmt_addr_path db "/sys/class/net/%s/address", 0
fmt_state_path db "/sys/class/net/%s/operstate", 0
header_line db "IFACE        MAC ADDRESS              OPERSTATE", 0
row_fmt db "%-12s %-24s %-12s", 0
not_available db "Khong doc duoc /sys/class/net", 0
report_section db 10, "[NETWORK]", 10, 0
report_header db "IFACE        MAC ADDRESS              OPERSTATE", 10, 0
report_row db "%-12s %-24s %-12s", 10, 0
report_na db "Not available", 10, 0
summary_na db "Not available", 0
summary_sep db " | ", 0
summary_more db " ...", 0
summary_item_fmt db "%.10s:%.8s", 0

section .bss
path_buf resb 256
addr_buf resb 128
state_buf resb 128
network_summary resb 256
network_summary_item resb 64

section .text
read_net_files:
	push rbp
	mov rbp, rsp
	push rbx
	sub rsp, 8
	mov rbx, rdi

	lea rdi, [path_buf]
	mov esi, 256
	lea rdx, [fmt_addr_path]
	mov rcx, rbx
	xor eax, eax
	call snprintf
	lea rdi, [path_buf]
	lea rsi, [addr_buf]
	mov edx, 128
	call read_first_line

	lea rdi, [path_buf]
	mov esi, 256
	lea rdx, [fmt_state_path]
	mov rcx, rbx
	xor eax, eax
	call snprintf
	lea rdi, [path_buf]
	lea rsi, [state_buf]
	mov edx, 128
	call read_first_line

	add rsp, 8
	pop rbx
	leave
	ret

collect_network_summary:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	sub rsp, 8

	lea rdi, [network_summary]
	lea rsi, [summary_na]
	call strcpy

	lea rdi, [path_net]
	call opendir
	test rax, rax
	jz .done
	mov rbx, rax
	mov byte [network_summary], 0
	xor r12d, r12d

.loop:
	mov rdi, rbx
	call readdir
	test rax, rax
	jz .close
	lea r13, [rax + 19]
	cmp byte [r13], '.'
	je .loop

	cmp r12d, 2
	jb .append_item
	lea rdi, [network_summary]
	lea rsi, [summary_more]
	call strcat
	jmp .close

.append_item:
	mov rdi, r13
	call read_net_files

	lea rdi, [network_summary_item]
	mov esi, 64
	lea rdx, [summary_item_fmt]
	mov rcx, r13
	lea r8, [state_buf]
	xor eax, eax
	call snprintf

	test r12d, r12d
	jz .copy_item
	lea rdi, [network_summary]
	lea rsi, [summary_sep]
	call strcat

.copy_item:
	lea rdi, [network_summary]
	lea rsi, [network_summary_item]
	call strcat
	inc r12d
	jmp .loop

.close:
	mov rdi, rbx
	call closedir
	test r12d, r12d
	jnz .done
	lea rdi, [network_summary]
	lea rsi, [summary_na]
	call strcpy

.done:
	add rsp, 8
	pop r13
	pop r12
	pop rbx
	leave
	ret

show_network:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	sub rsp, 8

	lea rdi, [title_network]
	call draw_base
	mov edi, 4
	mov esi, 4
	lea rdx, [header_line]
	call print_line

	lea rdi, [path_net]
	call opendir
	test rax, rax
	jz .show_na
	mov rbx, rax
	mov r12d, 0
.loop:
	cmp r12d, 12
	jge .close
	mov rdi, rbx
	call readdir
	test rax, rax
	jz .close
	lea r13, [rax + 19]
	cmp byte [r13], '.'
	je .loop

	mov rdi, r13
	call read_net_files

	mov edi, r12d
	add edi, 6
	mov esi, 4
	lea rdx, [row_fmt]
	mov rcx, r13
	lea r8, [addr_buf]
	lea r9, [state_buf]
	xor eax, eax
	call mvprintw

	inc r12d
	jmp .loop
.close:
	mov rdi, rbx
	call closedir
	jmp .wait
.show_na:
	mov edi, 6
	mov esi, 4
	lea rdx, [not_available]
	call print_line
.wait:
	call wait_back_or_quit
	add rsp, 8
	pop r13
	pop r12
	pop rbx
	leave
	ret

export_network:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	mov r14, rdi

	mov rdi, r14
	lea rsi, [report_section]
	xor eax, eax
	call fprintf
	mov rdi, r14
	lea rsi, [report_header]
	xor eax, eax
	call fprintf

	lea rdi, [path_net]
	call opendir
	test rax, rax
	jz .report_na
	mov rbx, rax
	mov r12d, 0
.rloop:
	cmp r12d, 20
	jge .rclose
	mov rdi, rbx
	call readdir
	test rax, rax
	jz .rclose
	lea r13, [rax + 19]
	cmp byte [r13], '.'
	je .rloop

	mov rdi, r13
	call read_net_files

	mov rdi, r14
	lea rsi, [report_row]
	mov rdx, r13
	lea rcx, [addr_buf]
	lea r8, [state_buf]
	xor eax, eax
	call fprintf

	inc r12d
	jmp .rloop
.rclose:
	mov rdi, rbx
	call closedir
	jmp .done
.report_na:
	mov rdi, r14
	lea rsi, [report_na]
	xor eax, eax
	call fprintf
.done:
	pop r14
	pop r13
	pop r12
	pop rbx
	leave
	ret
