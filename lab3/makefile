bold=`tput bold`

black=`tput setaf 0`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
magenta=`tput setaf 5`
cyan=`tput setaf 6`
white=`tput setaf 7`

reset=`tput sgr0`


default: build run

build:
	@echo "${bold}${green}[INFO]${reset} Compiling Bootloader"
	@nasm -f bin src/bootloader/bootloader.asm -o bin/boot.bin

	@echo "${bold}${green}[INFO]${reset} Compiling Kernel"
	@nasm -f bin src/kernel/kernel.asm -o bin/kernel.bin

	@echo "${bold}${green}[INFO]${reset} Compiling the OS"
	@cat bin/boot.bin bin/kernel.bin > bin/os.bin

	@echo "${bold}${green}[INFO]${reset} Compiling the Floppy image"
	@dd if=/dev/zero of=bin/floppy.img bs=1024 count=1440
	@dd conv=notrunc if=bin/os.bin of=bin/floppy.img

	@echo "${bold}${green}[INFO]${reset} Compiled."

run:
	@echo "${bold}${green}[INFO]${reset} Launching the VM:"
	@qemu-system-x86_64 -enable-kvm -drive format=raw,file=bin/os.bin,index=0,if=floppy -m 4G -cpu host -smp 2 -vga virtio -display sdl,gl=on -full-screen

hex-floppy:
	@echo "${bold}${green}[INFO]${reset} Hexadecimal value of floppy image"
	@hexdump -C bin/floppy.img

hex-os:
	@echo "${bold}${green}[INFO]${reset} Hexadecimal value of os"
	@hexdump -C bin/os.bin

clean:
	@echo "${bold}${green}[INFO]${reset} Cleaning..."
	@rm -rfv bin/*.bin bin/*.img
	@echo "${bold}${green}[INFO]${reset} Cleaned"
