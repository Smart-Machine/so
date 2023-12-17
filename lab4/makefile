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
	@echo "${bold}${green}[INFO]${reset} Compiling First Stage Bootloader"
	@nasm -f bin src/bootloader/first_stage.asm -o bin/first_boot.bin

	@echo "${bold}${green}[INFO]${reset} Compiling Second Stage Bootloader"
	@nasm -f bin src/bootloader/second_stage.asm -o bin/second_boot.bin

	@echo "${bold}${green}[INFO]${reset} Compiling Kernel"
	@nasm -f bin src/kernel/kernel.asm -o bin/kernel.bin

	@echo "${bold}${green}[INFO]${reset} Compiling the OS"
	@cat bin/first_boot.bin bin/second_boot.bin bin/kernel.bin > bin/os.bin

	@echo "${bold}${green}[INFO]${reset} Compiled."

build-test:
	@echo "${bold}${green}[INFO]${reset} Compiling First Stage Bootloader"
	@nasm src/bootloader/first_stage.asm -o bin/first_boot.bin

	@echo "${bold}${green}[INFO]${reset} Compiling Second Stage Bootloader"
	@nasm src/bootloader/second_stage.asm -o bin/second_boot.bin

	@echo "${bold}${green}[INFO]${reset} Compiling Kernel"
	@nasm src/kernel/kernel.asm -o bin/kernel.bin

	@echo "${bold}${green}[INFO]${reset} Compiling the OS"
	@cat bin/first_boot.bin bin/second_boot.bin bin/kernel.bin > bin/os.bin

	@echo "${bold}${green}[INFO]${reset} Compiled."



run:
	@echo "${bold}${green}[INFO]${reset} Launching the VM:"
	@qemu-system-x86_64 -enable-kvm -drive format=raw,file=bin/os.bin,index=0,if=floppy -m 4G -cpu host -smp 2 -vga virtio -display sdl,gl=on 

hex-os:
	@echo "${bold}${green}[INFO]${reset} Hexadecimal value of os"
	@hexdump -C bin/os.bin

hex-boot:
	@echo "${bold}${green}[INFO]${reset} Hexadecimal value of boot"
	@hexdump -C bin/boot.bin

clean:
	@echo "${bold}${green}[INFO]${reset} Cleaning..."
	@rm -rfv bin/*.bin bin/*.img
	@echo "${bold}${green}[INFO]${reset} Cleaned"
