org 0x7C00

;;;;;;;;
; INIT ;
;;;;;;;;

; save DL (drive number) value from the BIOS
mov [drive_number], dl

call init_window
call print_start_up_message

; set up DX for disk loading
mov dh, 0x10                  ; number of sectors that will be loaded into memory
mov dl, [drive_number]       ; drive number to load (0 = boot disk)

; set up ES:BX memory address to load sectors into
mov bx, 0x1000  ; load sector to memory address 0x1000
mov es, bx      ; ES = 0x1000 
mov bx, 0x0       ; ES:BX = 0x1000:0 (segment:offset)

; set up segment registers for RAM
mov ax, 0x1000
mov ds, ax      ; data segment
mov es, ax      ; extra segment
mov fs, ax       
mov gs, ax
mov ss, ax      ; stack segment


;;;;;;;;;;;;;;;;;;;;;;;;;;
; BOOTLOADER ENTRY POINT ; 
;;;;;;;;;;;;;;;;;;;;;;;;;;
call disk_load  ; loads kernel into memory
jmp 0x1000:0x0


;;;;;;;;;;;
; IMPORTS ;
;;;;;;;;;;;

%include "src/bootloader/utils/print.asm"
%include "src/bootloader/utils/disk.asm"
%include "src/bootloader/utils/init_window.asm"


;;;;;;;
; VAR ;
;;;;;;;

start_up_message: db "INFO: Loading the kernel...", 0
drive_number: resb 8


;;;;;;;;;;;;;;;;;
; MAGIC NUMBERS ;
;;;;;;;;;;;;;;;;;

times 510-($-$$) db 0
dw 0xAA55

