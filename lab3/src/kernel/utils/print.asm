print_string_buffer:
    ; The function prints a string from the buffer 
    ; stored in the SI register, it expects a 
    ; null symbol to be found in the buffer.  
    ; Parameters:
    ;   SI = memory offset to the buffer 
    ; Returns: 

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


print_os_message:
    ; The function prints the OS message
    ; and moves the cursor to the next line
    ; Parameters: None
    ; Returns: None

    pusha

	; move cursor
	mov ah, 0x02
	mov dh, 2
	mov dl, 0
	int 0x10

    mov si, KERNEL_MSG_SUCCESS 
    call print_string_buffer

	; move cursor
	mov ah, 0x02
    inc dh
	mov dl, 0
	int 0x10

    popa
    ret


print_writing_to_disk_message_info:
    pusha

	; move cursor
	mov ah, 0x02
	mov dh, 3
	mov dl, 0
	int 0x10

    mov si, WRITING_MSG_INFO 
    call print_string_buffer

	; move cursor
	mov ah, 0x02
	inc dh
	mov dl, 0
	int 0x10

    popa
	ret

print_writing_to_disk_message_success:
    pusha

	; move cursor
	mov ah, 0x02
	mov dh, 4
	mov dl, 0
	int 0x10

    mov si, WRITING_MSG_SUCCESS
    call print_string_buffer

	; move cursor
	mov ah, 0x02
	inc dh
	mov dl, 0
	int 0x10

    popa
	ret

print_io_error:
    pusha

	; move cursor
	mov ah, 0x02
	mov dh, 4
	mov dl, 0
	int 0x10

    mov si, IO_ERROR_MSG
    call print_string_buffer

	; move cursor
	mov ah, 0x02
	inc dh
	mov dl, 0
	int 0x10

    popa
	jmp $

