default rel

global show_os
global collect_os
global os_pretty
global os_kernel
global os_arch
global os_hostname

extern draw_base
extern print_kv
extern wait_back_or_quit
extern fopen
extern fgets
extern fclose
extern strncmp
extern strcpy
extern uname

section .rodata
title_os db "OS", 0
path_os_release db "/etc/os-release", 0
mode_r db "r", 0
not_available db "Not available", 0
pre_pretty db "PRETTY_NAME=", 0
label_os_name db "OS Name", 0
label_kernel db "Kernel Release", 0
label_arch db "Architecture", 0
label_hostname db "Hostname", 0
label_source db "Nguon", 0
source_value db "/etc/os-release, uname", 0

section .bss
os_pretty resb 128
os_kernel resb 128
os_arch resb 128
os_hostname resb 128
line_buf resb 256
uts_buf resb 390

section .text
copy_na:
	push rbp
	mov rbp, rsp
	lea rsi, [not_available]
	call strcpy
	leave
	ret

copy_pretty:
	push rbp
	mov rbp, rsp
	; rdi = destination, rsi = source line
	add rsi, 12
	cmp byte [rsi], '"'
	jne .copy
	inc rsi
.copy:
	mov rcx, 120
.loop:
	mov al, [rsi]
	cmp al, 0
	je .end
	cmp al, 10
	je .end
	cmp al, 13
	je .end
	cmp al, '"'
	je .end
	mov [rdi], al
	inc rdi
	inc rsi
	loop .loop
.end:
	mov byte [rdi], 0
	leave
	ret

collect_os:
	push rbp
	mov rbp, rsp
	push rbx
	sub rsp, 8

	lea rdi, [os_pretty]
	call copy_na
	lea rdi, [os_kernel]
	call copy_na
	lea rdi, [os_arch]
	call copy_na
	lea rdi, [os_hostname]
	call copy_na

	lea rdi, [path_os_release]
	lea rsi, [mode_r]
	call fopen
	test rax, rax
	jz .do_uname
	mov rbx, rax
.read_loop:
	lea rdi, [line_buf]
	mov esi, 256
	mov rdx, rbx
	call fgets
	test rax, rax
	jz .close_os
	lea rdi, [line_buf]
	lea rsi, [pre_pretty]
	mov edx, 12
	call strncmp
	test eax, eax
	jnz .read_loop
	lea rdi, [os_pretty]
	lea rsi, [line_buf]
	call copy_pretty
.close_os:
	mov rdi, rbx
	call fclose

.do_uname:
	lea rdi, [uts_buf]
	call uname
	test eax, eax
	jnz .done
	lea rdi, [os_hostname]
	lea rsi, [uts_buf + 65]
	call strcpy
	lea rdi, [os_kernel]
	lea rsi, [uts_buf + 130]
	call strcpy
	lea rdi, [os_arch]
	lea rsi, [uts_buf + 260]
	call strcpy

.done:
	add rsp, 8
	pop rbx
	leave
	ret

show_os:
	push rbp
	mov rbp, rsp
	call collect_os
	lea rdi, [title_os]
	call draw_base

	mov edi, 5
	lea rsi, [label_os_name]
	lea rdx, [os_pretty]
	call print_kv
	mov edi, 7
	lea rsi, [label_kernel]
	lea rdx, [os_kernel]
	call print_kv
	mov edi, 9
	lea rsi, [label_arch]
	lea rdx, [os_arch]
	call print_kv
	mov edi, 11
	lea rsi, [label_hostname]
	lea rdx, [os_hostname]
	call print_kv
	mov edi, 13
	lea rsi, [label_source]
	lea rdx, [source_value]
	call print_kv

	call wait_back_or_quit
	leave
	ret
