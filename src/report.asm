default rel

global show_export_report
global export_report

extern draw_base
extern print_kv
extern print_line
extern wait_back_or_quit
extern fopen
extern fclose
extern fprintf
extern collect_cpu
extern collect_memory
extern collect_bios
extern collect_os
extern collect_time
extern export_disk
extern export_network
extern cpu_vendor
extern cpu_brand
extern cpu_features
extern cpu_tsc
extern mem_total
extern mem_free
extern mem_available
extern swap_total
extern swap_free
extern bios_vendor
extern bios_version
extern bios_date
extern board_vendor
extern board_name
extern product_name
extern os_pretty
extern os_kernel
extern os_arch
extern os_hostname
extern time_text
extern timezone_text

section .rodata
title_export db "Export Report", 0
report_path db "system_report.txt", 0
mode_w db "w", 0
header db "NASM System Info Viewer Report", 10, "================================", 10, 0
section_cpu db 10, "[CPU]", 10, 0
section_mem db 10, "[MEMORY]", 10, 0
section_bios db 10, "[BIOS/FIRMWARE]", 10, 0
section_os db 10, "[OS]", 10, 0
section_time db 10, "[TIME]", 10, 0
fmt_kv db "%-20s : %s", 10, 0
status_ok db "Da tao bao cao thanh cong", 0
status_fail db "Khong tao duoc system_report.txt", 0
label_file db "File", 0
label_status db "Trang thai", 0
label_vendor db "CPU Vendor", 0
label_brand db "CPU Brand", 0
label_features db "Feature Flags", 0
label_tsc db "Time Stamp Counter", 0
label_memtotal db "MemTotal", 0
label_memfree db "MemFree", 0
label_memavailable db "MemAvailable", 0
label_swaptotal db "SwapTotal", 0
label_swapfree db "SwapFree", 0
label_bios_vendor db "BIOS Vendor", 0
label_bios_version db "BIOS Version", 0
label_bios_date db "BIOS Date", 0
label_board_vendor db "Board Vendor", 0
label_board_name db "Board Name", 0
label_product_name db "Product Name", 0
label_os_name db "OS Name", 0
label_kernel db "Kernel Release", 0
label_arch db "Architecture", 0
label_hostname db "Hostname", 0
label_datetime db "Datetime", 0
label_timezone db "Timezone", 0

section .text
report_section:
	push rbp
	mov rbp, rsp
	; rdi = FILE*, rsi = section string
	xor eax, eax
	call fprintf
	leave
	ret

report_kv:
	push rbp
	mov rbp, rsp
	; rdi = FILE*, rsi = label, rdx = value
	mov rcx, rdx
	mov rdx, rsi
	lea rsi, [fmt_kv]
	xor eax, eax
	call fprintf
	leave
	ret

export_report:
	push rbp
	mov rbp, rsp
	push rbx
	sub rsp, 8

	lea rdi, [report_path]
	lea rsi, [mode_w]
	call fopen
	test rax, rax
	jz .fail
	mov rbx, rax

	call collect_cpu
	call collect_memory
	call collect_bios
	call collect_os
	call collect_time

	mov rdi, rbx
	lea rsi, [header]
	xor eax, eax
	call fprintf

	mov rdi, rbx
	lea rsi, [section_cpu]
	call report_section
	mov rdi, rbx
	lea rsi, [label_vendor]
	lea rdx, [cpu_vendor]
	call report_kv
	mov rdi, rbx
	lea rsi, [label_brand]
	lea rdx, [cpu_brand]
	call report_kv
	mov rdi, rbx
	lea rsi, [label_features]
	lea rdx, [cpu_features]
	call report_kv
	mov rdi, rbx
	lea rsi, [label_tsc]
	lea rdx, [cpu_tsc]
	call report_kv

	mov rdi, rbx
	lea rsi, [section_mem]
	call report_section
	mov rdi, rbx
	lea rsi, [label_memtotal]
	lea rdx, [mem_total]
	call report_kv
	mov rdi, rbx
	lea rsi, [label_memfree]
	lea rdx, [mem_free]
	call report_kv
	mov rdi, rbx
	lea rsi, [label_memavailable]
	lea rdx, [mem_available]
	call report_kv
	mov rdi, rbx
	lea rsi, [label_swaptotal]
	lea rdx, [swap_total]
	call report_kv
	mov rdi, rbx
	lea rsi, [label_swapfree]
	lea rdx, [swap_free]
	call report_kv

	mov rdi, rbx
	lea rsi, [section_bios]
	call report_section
	mov rdi, rbx
	lea rsi, [label_bios_vendor]
	lea rdx, [bios_vendor]
	call report_kv
	mov rdi, rbx
	lea rsi, [label_bios_version]
	lea rdx, [bios_version]
	call report_kv
	mov rdi, rbx
	lea rsi, [label_bios_date]
	lea rdx, [bios_date]
	call report_kv
	mov rdi, rbx
	lea rsi, [label_board_vendor]
	lea rdx, [board_vendor]
	call report_kv
	mov rdi, rbx
	lea rsi, [label_board_name]
	lea rdx, [board_name]
	call report_kv
	mov rdi, rbx
	lea rsi, [label_product_name]
	lea rdx, [product_name]
	call report_kv

	mov rdi, rbx
	lea rsi, [section_os]
	call report_section
	mov rdi, rbx
	lea rsi, [label_os_name]
	lea rdx, [os_pretty]
	call report_kv
	mov rdi, rbx
	lea rsi, [label_kernel]
	lea rdx, [os_kernel]
	call report_kv
	mov rdi, rbx
	lea rsi, [label_arch]
	lea rdx, [os_arch]
	call report_kv
	mov rdi, rbx
	lea rsi, [label_hostname]
	lea rdx, [os_hostname]
	call report_kv

	mov rdi, rbx
	call export_disk
	mov rdi, rbx
	call export_network

	mov rdi, rbx
	lea rsi, [section_time]
	call report_section
	mov rdi, rbx
	lea rsi, [label_datetime]
	lea rdx, [time_text]
	call report_kv
	mov rdi, rbx
	lea rsi, [label_timezone]
	lea rdx, [timezone_text]
	call report_kv

	mov rdi, rbx
	call fclose
	mov eax, 1
	jmp .done
.fail:
	xor eax, eax
.done:
	add rsp, 8
	pop rbx
	leave
	ret

show_export_report:
	push rbp
	mov rbp, rsp
	push rbx
	sub rsp, 8

	call export_report
	mov ebx, eax

	lea rdi, [title_export]
	call draw_base

	mov edi, 8
	lea rsi, [label_file]
	lea rdx, [report_path]
	call print_kv
	mov edi, 10
	lea rsi, [label_status]
	test ebx, ebx
	jz .bad
	lea rdx, [status_ok]
	jmp .status
.bad:
	lea rdx, [status_fail]
.status:
	call print_kv
	mov edi, 14
	mov esi, 4
	test ebx, ebx
	jz .bad_line
	lea rdx, [status_ok]
	jmp .line
.bad_line:
	lea rdx, [status_fail]
.line:
	call print_line

	call wait_back_or_quit
	add rsp, 8
	pop rbx
	leave
	ret
