CC=gcc
C_FLAGS := -m32 -fno-pie -ffreestanding

EDK2_DIR = ./edk2
OVMF_BUILD_DIR = $(EDK2_DIR)/Build
OVMF_DIR = $(OVMF_BUILD_DIR)/OvmfX64/DEBUG_GCC5/FV
UEFI_DIR = ./UEFI

all :
	make clean
	make ovmf
	make os
	make run

.PHONY: clean

ovmf:
	cd $(EDK2_DIR) && $(MAKE) -C ./BaseTools/Source/C
	cd $(EDK2_DIR) && bash ./OvmfPkg/build.sh -a X64 -b

%.o : %.asm
	nasm $< -f elf32 -o $@

%.o : %.c
	$(CC) ${C_FLAGS} -c $< -o $@

bin/kernel.bin : kernel/src/kernel.o kernel/src/kernel_entry.o
	mkdir bin
	ld -m elf_i386 -o $@ -Ttext 0x1000 $^
	#This should be in binary format but for some reason ld makes the binary ~140mb
	
os : bin/kernel.bin
	cd $(UEFI_DIR) && $(MAKE)
	
run : os
	sudo qemu-system-x86_64 -bios ${OVMF_DIR}/OVMF.fd UEFI/main.iso
	
debug: kernel/src/kernel.bin
	cd $(UEFI_DIR) && $(MAKE) debug
	sudo qemu-system-x86_64 -bios ${OVMF_DIR}/OVMF.fd UEFI/debug.iso

clean:
	rm -rf  kernel/src/kernel_entry.o kernel/src/kernel.o bin/*.bin bin/ $(OVMF_BUILD_DIR)/* $(OVMF_BUILD_DIR)
	cd $(UEFI_DIR) && $(MAKE) clean
