first_option:
    pusha
    call null_buffers

    ; display "string := "
    call get_cursor_pos
    inc dh
    mov dl, 0x00

    mov ax, 0x1301
    mov bl, 0x05             ; magenta color
    mov cx, string_param_len 
    mov bp, string_param 
    int 0x10

    ; read user input `string`
    call read_input

    ; save the `string` to its own buffer
    mov si, storage_buffer
    mov di, string
    .copy_string_loop:
        mov al, [si]
        mov [di], al
        inc si
        inc di

        cmp byte [si], 0
        jne .copy_string_loop
    
    ; read user input `N`, `H`, `T`, `S`
    call read_nhts

    ; prepare writing buffer
    mov si, string
    mov di, string_buffer
    call duplicate_string
        
    ; calculate the number of sectors to write
    xor dx, dx
    mov ax, [string_buffer_size]
    mov bx, 512
    div bx

    ; write to the floppy
    mov ah, 0x03
    ; mov al, 2 
    inc al
    mov ch, [nhts + 4]
    mov cl, [nhts + 6]
    mov dh, [nhts + 2]
    mov dl, 0x00
    mov bx, string_buffer 
    int 0x13

    ; print error code
    call print_error_code

    ; print writing buffer
    call get_cursor_pos
    mov ah, 0x02
    inc dh
    mov dl, 0x00
	int 0x10

    mov si, string_buffer 
    call print_string_buffer

    popa
    ret