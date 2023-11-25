disk_load:
    ; The function reads DH number of sectors
    ; into ES:BX memory location from drive DL
    ; Parameters:
    ;   es:bx - buffer memory address 

    push dx             ; store dx on stack for error handling later 

    mov ah, 0x02        ; INT 13H 02H, BIOS read disk sectors into memory
    mov al, dh          ; number of sectors
    mov ch, 0x00        ; cylinder  
    mov dh, 0x00        ; head
    mov cl, 0x02        ; start reading sector (2 is the sector after the bootloader)
    int 0x13            ; BIOS interrupt for disk functions 

    jc disk_error       ; checks if CF (carry flag) set to 1

    pop dx              ; restore dx value from stack
    cmp dh, al          ; checks dh (number of read sectors) vs al (number of desired read sectors) 
    jne disk_error      ; if not the desired amount of sectors were read, then error 

    jmp disk_success
    ; ret                 ; return to caller

disk_error:

    mov si, DISK_ERROR_MESSAGE
    call print_string_buffer

	; move cursor
	mov ah, 0x02
    inc dh
	mov dl, 0
	int 0x10

    jmp disk_load 

disk_success:

    mov si, DISK_SUCCESS_MESSAGE
    call print_string_buffer

	; move cursor
	mov ah, 0x02
    inc dh
	mov dl, 0
	int 0x10

    ret

DISK_ERROR_MESSAGE: db "ERROR: could not read from disk", 0
DISK_SUCCESS_MESSAGE: db "INFO: successfully loaded the disk", 0