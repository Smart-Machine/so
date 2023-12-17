org 0x7C00


;; Initial set up
init_ram_first_stage:
    xor  ax, ax
    mov  ds, ax
    mov  es, ax
    mov  ss, ax             
    mov  sp, 0x7C00         
    cld                     ; For LODSB functions allright
mov [drive_number], dl      ; save DL (drive number) value from the BIOS
call init_window


print_greetings:
    pusha

    ; get cursor position
    mov ah, 0x03
    mov bh, 0
    int 0x10

    ; update cursor position
    inc dh
    mov dl, 0x00

    ; print success message
    mov ax, 0x1301
    mov bl, 0x05
    mov cx, greetings_msg_len 
    mov bp, greetings_msg 
    int 0x10

    popa


load_second_stage:
    mov bx, 0x1000
    mov es, bx
    mov bx, 0x0

    pusha
    mov ah, 0x02                    ; INT 13H 02H, BIOS read disk sectors into memory
    mov al, 0x02                    ; number of sectors
    mov ch, 0x00                    ; cylinder  
    mov cl, 0x02                    ; start reading sector (2 is the sector after the bootloader)
    mov dh, 0x00                    ; head
    mov dl, [drive_number]          ; drive number: 0-3=diskette; 80H-81H=hard disk
    int 0x13                        ; BIOS interrupt for disk functions 
    popa

    jc load_second_stage            ; checks if CF (carry flag) set to 1
    jmp 0x1000:0x0                  ; far jump to second stage bootloader 


;; Imports
%include "src/common/window.asm"

;; Var
greetings_msg db "Welcome, Radu Calin", 0
greetings_msg_len equ $ - greetings_msg
drive_number db 0

;; Signing the sector for bootability identification
times 510-($-$$) db 0
dw 0xAA55

