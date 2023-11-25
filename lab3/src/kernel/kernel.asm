org 0


;;;;;;;;;;;;;;;
; ENTRY POINT ;
;;;;;;;;;;;;;;;

_start:
    call print_os_message

    call create_signature
    ; call print_signature

    call print_writing_to_disk_message_info

    mov ch, start_track
    mov cl, start_sector 
    call sign_sector

    mov ch, end_track
    mov cl, end_sector 
    call sign_sector

    call print_writing_to_disk_message_success

    mov dl, 0       ; column 
    mov dh, 5       ; row 
    jmp display_menu 



;;;;;;;;;;;
; IMPORTS ;
;;;;;;;;;;;

%include "src/kernel/utils/print.asm"
%include "src/kernel/utils/signature.asm"
%include "src/kernel/utils/window.asm"
%include "src/kernel/utils/menu.asm"
%include "src/kernel/utils/const.asm"

;;;;;;;;;;;;;;;;;
; MAGIC NUMBERS ;
;;;;;;;;;;;;;;;;;

; sector padding
; times 512-($-$$) db 0
times 1474048-($-$$) db 0
