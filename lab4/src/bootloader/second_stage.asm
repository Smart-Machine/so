org 0

init_ram_second_stage:
    mov ax, 0x1000
    mov ds, ax      ; data segment
    mov es, ax      ; extra segment
    mov fs, ax       
    mov gs, ax
    mov ss, ax      ; stack segment
    mov sp, 0x0

main:
    ;; Null out the buffers
    call null_buffers 
    
    ;; User io
    ; input Head, Track, Sector
    call read_hts
    ; input RAM address
    call read_ram_address

    ;; Loading the kernel
    call print_loading_kernel

    .load_kernel:
        mov bx, [ram_address]                         
        mov es, bx
        mov bx, [ram_address + 2]                     

        pusha
        mov ah, 0x02                    ; INT 13H 02H, BIOS read disk sectors into memory
        mov al, 0x01                    ; number of sectors
        mov ch, [hts + 2]               ; cylinder  
        mov cl, [hts + 4]               ; sector 
        mov dh, [hts + 0]               ; head
        mov dl, 0x00                    ; drive number: 0-3=diskette; 80H-81H=hard disk
        int 0x13                        ; BIOS interrupt for disk functions 
        popa

        jc .load_kernel                 ; checks if CF (carry flag) set to 1

        push es
        push bx
        retf


;; Imports
%include "src/common/window.asm"
%include "src/common/io.asm"

; padding for second stage bootloader
times 1024-($-$$) db 0

; padding for kernel location
times 1304576 db 0
