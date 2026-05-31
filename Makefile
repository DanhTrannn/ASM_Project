ASM := nasm
CC := gcc

SRC_DIR := src
BUILD_DIR := build
TARGET := system_info

ASMFLAGS := -f elf64 -g -F dwarf -Iinclude/
LDFLAGS := -no-pie
LDLIBS := -lncursesw

SRCS := \
	$(SRC_DIR)/main.asm \
	$(SRC_DIR)/ui.asm \
	$(SRC_DIR)/ui_helpers.asm \
	$(SRC_DIR)/utils.asm \
	$(SRC_DIR)/cpu.asm \
	$(SRC_DIR)/memory.asm \
	$(SRC_DIR)/bios.asm \
	$(SRC_DIR)/osinfo.asm \
	$(SRC_DIR)/timeinfo.asm \
	$(SRC_DIR)/disk.asm \
	$(SRC_DIR)/network.asm \
	$(SRC_DIR)/showall.asm \
	$(SRC_DIR)/report.asm

OBJS := $(SRCS:$(SRC_DIR)/%.asm=$(BUILD_DIR)/%.o)

.PHONY: all run clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.asm include/common.inc | $(BUILD_DIR)
	$(ASM) $(ASMFLAGS) -o $@ $<

$(BUILD_DIR):
	mkdir -p $@

run: $(TARGET)
	./$(TARGET)

clean:
	rm -rf $(BUILD_DIR) $(TARGET) system_report.txt
