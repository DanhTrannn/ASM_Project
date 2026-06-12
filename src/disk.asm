default rel

global show_disk
global export_disk
global collect_disk_summary
global disk_summary

extern draw_base
extern print_line
extern wait_back_or_quit
extern fopen
extern fgets
extern fclose
extern sscanf
extern snprintf
extern strcpy
extern strcat
extern mvprintw
extern fprintf

section .rodata
title_disk db "Disk", 0
path_partitions db "/proc/partitions", 0
mode_r db "r", 0
scan_part db "%llu %llu %llu %63s", 0
header_line db "DEVICE             SIZE(MB)     MAJ:MIN", 0
row_fmt db "%-16s %10llu     %3llu:%-3llu", 0
not_available db "Khong doc duoc /proc/partitions", 0
report_section db 10, "[DISK]", 10, 0
report_header db "DEVICE             SIZE(MB)     MAJ:MIN", 10, 0
report_row db "%-16s %10llu     %3llu:%-3llu", 10, 0
report_na db "Not available", 10, 0
summary_na db "Not available", 0
summary_sep db " | ", 0
summary_more db " ...", 0
summary_item_fmt db "%.10s:%lluM", 0

section .bss
line_buf resb 256
dev_name resb 64
major_no resq 1
minor_no resq 1
blocks_no resq 1
disk_summary resb 256
summary_item resb 64

section .text
parse_partition:
	push rbp
	mov rbp, rsp
	lea rdi, [line_buf]
	lea rsi, [scan_part]
	lea rdx, [major_no]
	lea rcx, [minor_no]
	lea r8, [blocks_no]
	lea r9, [dev_name]
	xor eax, eax
	call sscanf
	cmp eax, 4
	sete al
	movzx eax, al
	leave
	ret

collect_disk_summary:
	push rbp
	mov rbp, rsp
	push rbx
	push r12

	lea rdi, [disk_summary]
	lea rsi, [summary_na]
	call strcpy

	lea rdi, [path_partitions]
	lea rsi, [mode_r]
	call fopen
	test rax, rax
	jz .done
	mov rbx, rax
	mov byte [disk_summary], 0
	xor r12d, r12d

.loop:
	lea rdi, [line_buf]
	mov esi, 256
	mov rdx, rbx
	call fgets
	test rax, rax
	jz .close
	call parse_partition
	test eax, eax
	jz .loop

	cmp r12d, 2
	jb .append_item
	lea rdi, [disk_summary]
	lea rsi, [summary_more]
	call strcat
	jmp .close

.append_item:
	mov rax, [blocks_no]
	xor edx, edx
	mov rcx, 1024
	div rcx

	lea rdi, [summary_item]
	mov esi, 64
	lea rdx, [summary_item_fmt]
	lea rcx, [dev_name]
	mov r8, rax
	xor eax, eax
	call snprintf

	test r12d, r12d
	jz .copy_item
	lea rdi, [disk_summary]
	lea rsi, [summary_sep]
	call strcat

.copy_item:
	lea rdi, [disk_summary]
	lea rsi, [summary_item]
	call strcat
	inc r12d
	jmp .loop

.close:
	mov rdi, rbx
	call fclose
	test r12d, r12d
	jnz .done
	lea rdi, [disk_summary]
	lea rsi, [summary_na]
	call strcpy

.done:
	pop r12
	pop rbx
	leave
	ret

show_disk:
	push rbp
	mov rbp, rsp
	push rbx
	push r12

	lea rdi, [title_disk]
	call draw_base
	mov edi, 4
	mov esi, 4
	lea rdx, [header_line]
	call print_line

	lea rdi, [path_partitions]
	lea rsi, [mode_r]
	call fopen
	test rax, rax
	jz .show_na
	mov rbx, rax
	mov r12d, 0
.loop:
	cmp r12d, 12
	jge .close
	lea rdi, [line_buf]
	mov esi, 256
	mov rdx, rbx
	call fgets
	test rax, rax
	jz .close
	call parse_partition
	test eax, eax
	jz .loop

	mov rax, [blocks_no]
	xor edx, edx
	mov rcx, 1024
	div rcx

	mov edi, r12d
	add edi, 6
	mov esi, 4
	lea rdx, [row_fmt]
	lea rcx, [dev_name]
	mov r8, rax
	mov r9, [major_no]
	sub rsp, 8
	push qword [minor_no]
	xor eax, eax
	call mvprintw
	add rsp, 16

	inc r12d
	jmp .loop
.close:
	mov rdi, rbx
	call fclose
	jmp .wait
.show_na:
	mov edi, 6
	mov esi, 4
	lea rdx, [not_available]
	call print_line
.wait:
	call wait_back_or_quit
	pop r12
	pop rbx
	leave
	ret

export_disk:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	sub rsp, 8
	mov r13, rdi

	mov rdi, r13
	lea rsi, [report_section]
	xor eax, eax
	call fprintf
	mov rdi, r13
	lea rsi, [report_header]
	xor eax, eax
	call fprintf

	lea rdi, [path_partitions]
	lea rsi, [mode_r]
	call fopen
	test rax, rax
	jz .report_na
	mov rbx, rax
	mov r12d, 0
.rloop:
	cmp r12d, 20
	jge .rclose
	lea rdi, [line_buf]
	mov esi, 256
	mov rdx, rbx
	call fgets
	test rax, rax
	jz .rclose
	call parse_partition
	test eax, eax
	jz .rloop

	mov rax, [blocks_no]
	xor edx, edx
	mov rcx, 1024
	div rcx

	mov rdi, r13
	lea rsi, [report_row]
	lea rdx, [dev_name]
	mov rcx, rax
	mov r8, [major_no]
	mov r9, [minor_no]
	xor eax, eax
	call fprintf

	inc r12d
	jmp .rloop
.rclose:
	mov rdi, rbx
	call fclose
	jmp .done
.report_na:
	mov rdi, r13
	lea rsi, [report_na]
	xor eax, eax
	call fprintf
.done:
	add rsp, 8
	pop r13
	pop r12
	pop rbx
	leave
	ret
