default rel

global show_disk
global export_disk

extern draw_base
extern print_line
extern wait_back_or_quit
extern fopen
extern fgets
extern fclose
extern sscanf
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

section .bss
line_buf resb 256
dev_name resb 64
major_no resq 1
minor_no resq 1
blocks_no resq 1

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
