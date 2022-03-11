# Kernel Development Tools

This repo serves to house information about the tooling and workflow for working with and working on, the MOS Micro Kernel.

## Layout

* UEFI

### UEFI

For booting with uefi using qemu.

#### process

From the root directory, running `make` will:

* clean all previously built files (if any)
* build OVMF
* build gnu-efi
* build the uefi program
* build the kernel
* create the image for booting
* boot qemu with the specified image and OVMF firmware

``
