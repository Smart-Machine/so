;;;;;;;;;
; CONST ;
;;;;;;;;;


; signature.asm consts
signature: db "@@@FAF-213 Calin RADU###", 0

KERNEL_MSG_SUCCESS: db "INFO: Kernel loaded.", 0
IO_ERROR_MSG: db "ERROR: could not write to disk.", 0
WRITING_MSG_INFO: db "INFO: writing to disk the signature...", 0
WRITING_MSG_SUCCESS: db "INFO: data has been written to the disk.", 0

; 2551 / 18 = 141 (tracks) + 13 (sectors)
start_track: equ 61             ; 141 (tracks) - 80 (tracks per side) 
start_sector: equ 14            ; 13 + 1, since enumeration start with 1  

; 2580 / 18 = 143 (tracks) + 6 (sectors)
end_track: equ 63               ; 143 (tracks) - 80 (tracks per side) 
end_sector: equ 7               ; 6 + 1, since enumeration start with 1


; menu.asm consts
menu_prompt_option1: db "1. stdio to disk", 0
menu_prompt_option2: db "2. disk  to ram",  0
menu_prompt_option3: db "3. ram   to disk", 0
menu_prompt_option4: db "option := ", 0

opt_invalid: db "invalid", 0




;;;;;;;
; VAR ;
;;;;;;;

; signature.asm vars
buffer: resb 100

