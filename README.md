# NASM System Info Viewer

Terminal User Interface (TUI) xem thong tin he thong Linux x86-64 bang NASM,
libc va ncursesw. Project nay bam theo SRS trong `SRS_NASM_PROJECT_G7.docx`
va tao giao dien thuc te de chup man hinh demo.

## Yeu cau

Ubuntu/Debian/WSL:

```sh
sudo apt update
sudo apt install -y nasm gcc make libncursesw5-dev
```

## Build va chay

```sh
make
./system_info
```

Hoac:

```sh
make run
```

## Chuc nang

- Menu TUI bang ncursesw
- CPU: CPUID, brand string, feature flags co ban, RDTSC
- Memory: doc `/proc/meminfo`
- Disk: doc `/proc/partitions`
- BIOS/Firmware: doc `/sys/class/dmi/id`
- OS: doc `/etc/os-release` va `uname`
- Network: doc `/sys/class/net`
- Time: goi `time`, `localtime`, `strftime`
- Export report: ghi `system_report.txt`

## Phim dieu khien

- `Up/Down` hoac `k/j`: di chuyen menu
- `Enter`: chon chuc nang
- `b`: quay lai menu
- `q`: thoat

## Chup man hinh

Chay `./system_info` trong terminal co kich thuoc toi thieu 80x24, sau do dung
cong cu screenshot cua he dieu hanh. Neu dung GNOME Terminal, nen phong to font
monospace vua phai de khung 80 cot hien day du.
