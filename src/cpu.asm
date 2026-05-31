default rel
%include "common.inc"

global show_cpu
global collect_cpu
global cpu_vendor
global cpu_brand
global cpu_features
global cpu_tsc

extern draw_base
extern print_kv
extern print_line
extern wait_back_or_quit
extern append_token
extern strcpy
extern snprintf

section .rodata
title_cpu db "CPU", 0
label_vendor db "CPU Vendor", 0
label_brand db "CPU Brand", 0
label_support db "CPUID Support", 0
label_features db "Feature Flags", 0
label_tsc db "Time Stamp Counter", 0
value_yes db "Co", 0
source_text db "Nguon: CPUID leaf 0/1/0x80000002-4 va RDTSC", 0
fmt_llu db "%llu", 0
unavailable db "Unavailable", 0
tok_none db "None", 0
tok_sse db "SSE", 0
tok_sse2 db "SSE2", 0
tok_sse3 db "SSE3", 0
tok_ssse3 db "SSSE3", 0
tok_sse41 db "SSE4.1", 0
tok_sse42 db "SSE4.2", 0
tok_aes db "AES", 0
tok_avx db "AVX", 0
tok_fma db "FMA", 0

section .bss
cpu_vendor resb 16
cpu_brand resb 64
cpu_features resb 160
cpu_tsc resb 32

section .text
collect_cpu:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	sub rsp, 8

	mov eax, 0
	cpuid
	mov [cpu_vendor], ebx
	mov [cpu_vendor + 4], edx
	mov [cpu_vendor + 8], ecx
	mov byte [cpu_vendor + 12], 0

	mov eax, 0x80000000
	cpuid
	cmp eax, 0x80000004
	jb .no_brand

	lea rdi, [cpu_brand]
	mov eax, 0x80000002
	cpuid
	mov [rdi], eax
	mov [rdi + 4], ebx
	mov [rdi + 8], ecx
	mov [rdi + 12], edx
	mov eax, 0x80000003
	cpuid
	mov [rdi + 16], eax
	mov [rdi + 20], ebx
	mov [rdi + 24], ecx
	mov [rdi + 28], edx
	mov eax, 0x80000004
	cpuid
	mov [rdi + 32], eax
	mov [rdi + 36], ebx
	mov [rdi + 40], ecx
	mov [rdi + 44], edx
	mov byte [rdi + 48], 0
	jmp .features

.no_brand:
	lea rdi, [cpu_brand]
	lea rsi, [unavailable]
	call strcpy

.features:
	mov byte [cpu_features], 0
	mov eax, 1
	cpuid
	mov r12d, ecx
	mov r13d, edx

	test r13d, 1 << 25
	jz .sse2
	lea rdi, [cpu_features]
	lea rsi, [tok_sse]
	call append_token
.sse2:
	test r13d, 1 << 26
	jz .sse3
	lea rdi, [cpu_features]
	lea rsi, [tok_sse2]
	call append_token
.sse3:
	test r12d, 1 << 0
	jz .ssse3
	lea rdi, [cpu_features]
	lea rsi, [tok_sse3]
	call append_token
.ssse3:
	test r12d, 1 << 9
	jz .sse41
	lea rdi, [cpu_features]
	lea rsi, [tok_ssse3]
	call append_token
.sse41:
	test r12d, 1 << 19
	jz .sse42
	lea rdi, [cpu_features]
	lea rsi, [tok_sse41]
	call append_token
.sse42:
	test r12d, 1 << 20
	jz .aes
	lea rdi, [cpu_features]
	lea rsi, [tok_sse42]
	call append_token
.aes:
	test r12d, 1 << 25
	jz .avx
	lea rdi, [cpu_features]
	lea rsi, [tok_aes]
	call append_token
.avx:
	test r12d, 1 << 28
	jz .fma
	lea rdi, [cpu_features]
	lea rsi, [tok_avx]
	call append_token
.fma:
	test r12d, 1 << 12
	jz .feature_done
	lea rdi, [cpu_features]
	lea rsi, [tok_fma]
	call append_token
.feature_done:
	cmp byte [cpu_features], 0
	jne .tsc
	lea rdi, [cpu_features]
	lea rsi, [tok_none]
	call strcpy

.tsc:
	rdtsc
	shl rdx, 32
	or rax, rdx
	lea rdi, [cpu_tsc]
	mov esi, 32
	lea rdx, [fmt_llu]
	mov rcx, rax
	xor eax, eax
	call snprintf

	add rsp, 8
	pop r13
	pop r12
	pop rbx
	leave
	ret

show_cpu:
	push rbp
	mov rbp, rsp

	call collect_cpu
	lea rdi, [title_cpu]
	call draw_base

	mov edi, 5
	lea rsi, [label_vendor]
	lea rdx, [cpu_vendor]
	call print_kv
	mov edi, 7
	lea rsi, [label_brand]
	lea rdx, [cpu_brand]
	call print_kv
	mov edi, 9
	lea rsi, [label_support]
	lea rdx, [value_yes]
	call print_kv
	mov edi, 11
	lea rsi, [label_features]
	lea rdx, [cpu_features]
	call print_kv
	mov edi, 13
	lea rsi, [label_tsc]
	lea rdx, [cpu_tsc]
	call print_kv
	mov edi, 17
	mov esi, 4
	lea rdx, [source_text]
	call print_line

	call wait_back_or_quit
	leave
	ret
