default rel

global show_bios
global collect_bios
global bios_vendor
global bios_version
global bios_date
global board_vendor
global board_name
global product_name

extern draw_base
extern print_kv
extern print_line
extern wait_back_or_quit
extern read_first_line

section .rodata
title_bios db "BIOS/Firmware", 0
path_bios_vendor db "/sys/class/dmi/id/bios_vendor", 0
path_bios_version db "/sys/class/dmi/id/bios_version", 0
path_bios_date db "/sys/class/dmi/id/bios_date", 0
path_board_vendor db "/sys/class/dmi/id/board_vendor", 0
path_board_name db "/sys/class/dmi/id/board_name", 0
path_product_name db "/sys/class/dmi/id/product_name", 0
label_bios_vendor db "BIOS Vendor", 0
label_bios_version db "BIOS Version", 0
label_bios_date db "BIOS Date", 0
label_board_vendor db "Board Vendor", 0
label_board_name db "Board Name", 0
label_product_name db "Product Name", 0
source_text db "Nguon: /sys/class/dmi/id | fallback: Not available", 0

section .bss
bios_vendor resb 128
bios_version resb 128
bios_date resb 128
board_vendor resb 128
board_name resb 128
product_name resb 128

section .text
collect_bios:
	push rbp
	mov rbp, rsp

	lea rdi, [path_bios_vendor]
	lea rsi, [bios_vendor]
	mov edx, 128
	call read_first_line
	lea rdi, [path_bios_version]
	lea rsi, [bios_version]
	mov edx, 128
	call read_first_line
	lea rdi, [path_bios_date]
	lea rsi, [bios_date]
	mov edx, 128
	call read_first_line
	lea rdi, [path_board_vendor]
	lea rsi, [board_vendor]
	mov edx, 128
	call read_first_line
	lea rdi, [path_board_name]
	lea rsi, [board_name]
	mov edx, 128
	call read_first_line
	lea rdi, [path_product_name]
	lea rsi, [product_name]
	mov edx, 128
	call read_first_line

	leave
	ret

show_bios:
	push rbp
	mov rbp, rsp
	call collect_bios
	lea rdi, [title_bios]
	call draw_base

	mov edi, 5
	lea rsi, [label_bios_vendor]
	lea rdx, [bios_vendor]
	call print_kv
	mov edi, 7
	lea rsi, [label_bios_version]
	lea rdx, [bios_version]
	call print_kv
	mov edi, 9
	lea rsi, [label_bios_date]
	lea rdx, [bios_date]
	call print_kv
	mov edi, 11
	lea rsi, [label_board_vendor]
	lea rdx, [board_vendor]
	call print_kv
	mov edi, 13
	lea rsi, [label_board_name]
	lea rdx, [board_name]
	call print_kv
	mov edi, 15
	lea rsi, [label_product_name]
	lea rdx, [product_name]
	call print_kv
	mov edi, 18
	mov esi, 4
	lea rdx, [source_text]
	call print_line

	call wait_back_or_quit
	leave
	ret
