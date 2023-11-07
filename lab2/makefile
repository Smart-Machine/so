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


default: compile build run

compile:
	@echo "${bold}${green}[INFO]${reset} Compiling..."

	#
	# Bootloader
	#
	@nasm -f bin src/bootloader/boot.asm -o bin/bootloader.bin
	@echo "${bold}${green}[INFO]${reset} Bootloader compiled."

	#
	# Kernel
	#
	@nasm -f bin src/kernel/main.asm -o bin/kernel.bin
	@echo "${boot}${green}[INFO]${reset} Kernel compiled."

	@echo "${bold}${green}[INFO]${reset} Compilation done."

build:
	@echo "${bold}${green}[INFO]${reset} Building the OS image..."

	@dd if=/dev/zero of=bin/image.img bs=512 count=2880
	@mkfs.fat -F 12 -n "root" bin/image.img
	@dd if=bin/bootloader.bin of=bin/image.img conv=notrunc
	@mcopy -i bin/image.img bin/kernel.bin "::kernel.bin"

run:
	@echo "${bold}${green}[INFO]${reset} Launching the VM:"
	@sudo qemu-system-x86_64 -d strace,int,pcall -drive format=raw,file=bin/boot.bin -usb -device usb-host,hostbus=1,hostaddr=1 -display sdl,show-cursor=on

clean:
	@echo "${bold}${green}[INFO]${reset} Cleaning..."
	@rm -rfv bin/*.bin
	@echo "${bold}${green}[INFO]${reset} Cleaned"
