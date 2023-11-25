print_string_buffer:
    ; The function prints a string from the buffer 
    ; stored in the SI register, it expects a 
    ; null symbol to be found in the buffer.  
    ; Parameters:
    ;   si - memory offset to the buffer 

	pusha

.loop:
	lodsb
	or al, al
	jz .done

	; display character
	mov ah, 0x0A
	mov bh, 0x00
	mov cx, 1
	int 0x10

	; move cursor
	mov ah, 0x02
	inc dl
	int 0x10

	jmp .loop

.done:
	popa
	ret

; bootloader start-up message
print_start_up_message:
	pusha 
	mov dh, 0
	mov dl, 0

    mov si, start_up_message 
    call print_string_buffer

	; move cursor
	mov ah, 0x02
    inc dh
	mov dl, 0
	int 0x10

	popa
	ret

