# NASM System Info Viewer

A Linux x86-64 Terminal User Interface (TUI) application written in NASM
Assembly and linked with libc and ncursesw. The project follows the
requirements described in `SRS_NASM_PROJECT_G7.docx` and provides a real
terminal UI that can be used for demos and screenshots.

## Requirements

On Ubuntu, Debian, or WSL:

```sh
sudo apt update
sudo apt install -y nasm gcc make libncursesw5-dev
```

## Build And Run

From the project directory:

```sh
make
./system_info
```

Or run it through Make:

```sh
make run
```

To rebuild from scratch:

```sh
make clean
make
./system_info
```

## Features

- ncursesw-based main menu
- CPU information using CPUID, CPU brand string, basic feature flags, and RDTSC
- Memory information from `/proc/meminfo`
- Disk information from `/proc/partitions`
- BIOS/Firmware information from `/sys/class/dmi/id`
- OS information from `/etc/os-release` and `uname`
- Network interface information from `/sys/class/net`
- System date, time, and timezone
- Report export to `system_report.txt`

## Timezone Detection

The Time screen first tries to read the configured IANA timezone from:

1. `/etc/timezone`
2. `/etc/localtime` if it is a symlink to `/usr/share/zoneinfo/...`

If neither source is available, it falls back to the libc timezone offset from
`strftime`, such as `+07 +0700`.

## Controls

- `Up` / `Down` or `k` / `j`: move through the menu
- `Enter`: open the selected screen
- `b`: go back to the main menu
- `q`: quit the application

## Report Export

Select `9. Xuat bao cao` in the menu to generate:

```text
system_report.txt
```

The report includes CPU, memory, disk, BIOS/Firmware, OS, network, time, and
timezone information.

## Taking Screenshots

Run the application in a terminal with a minimum size of 80 columns by 24 rows:

```sh
./system_info
```

Then use your operating system's screenshot tool. For a cleaner result, use a
monospace terminal font and keep the window wide enough for the 80-column UI.
