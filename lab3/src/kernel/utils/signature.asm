create_signature:
    ; The function creates the signature, which 
    ; is the given string (from SI) repeated 10 
    ; times and written in the given buffer (from DI)
    ; The following register are set at the runtime
    ;   SI = src (string, part of the signature)
    ;   DI = dst (buffer where the signature will be written)
    ;   CX = number of characters from signature
    ; Parameters:
    ;   The function expects `buffer` and `signature` to be
    ;   declared out of its scope.
    ;   `buffer` = reserved bytes for the storage of the created signature
    ;   `signature` = string that is part of the signature
    ; Returns: None 

    mov di, buffer
    times 10 call .copy_signature   ; copies the signature to the buffer 10 times
    ret                             ; returns to out of scope caller

    ; subroutine
    .copy_signature:
        mov si, signature
        mov cx, 25 

        .copy_string:
            dec cx
            jz .done

            mov al, [si]
            mov [di], al

            inc si
            inc di

            jmp .copy_string

        .done:
            ret


sign_sector:
    ; The function write the signature to the 
    ; desired address based on the CHS scheme
    ; Paramaters:
    ;   Int 13H
	;   AH = 03h
	;   AL = sector count 
    ;   CH = track (cylinder) number 
    ;   CL = sector number
    ;   DH = head number
    ;   DL = drive: 0-3=diskette; 80H-81H=hard disk
    ;   ES:BX = caller's buffer, containing data to write
    ; Returns:
    ;   AH = BIOS disk error code if CF is set to CY

    pusha 

    mov ah, 0x03
    mov al, 0x01
    mov dh, 0x01 
    mov dl, 0x00 
    mov bx, buffer 
    int 0x13

    jc print_io_error       ; if CF is set

    popa
    ret

print_signature:

	pusha

	; move cursor
	mov ah, 0x02
    inc dh
	mov dl, 0
	int 0x10

    mov si, buffer 
    call print_string_buffer

	popa
	ret
