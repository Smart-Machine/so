third_option:
    pusha
    call null_buffers

    ; read user input `ram address`
    call read_ram_address

    ; read user input `N`, `H`, `T`, `S`
    call read_nhts

    ; print ram data 
    push es
    push bp
    
    call get_cursor_pos
    mov ah, 0x02
    inc dh
    mov dl, 0x00
	int 0x10

    mov ax, 0x1301
    mov bl, 0x05 
    mov cx, [nhts] 
    mov es, [ram_address]
    mov bp, [ram_address + 2]
    int 0x10

    pop bp
    pop es

    ; calculate number of sectors to write
    xor dx, dx
    mov ax, [nhts]
    mov bx, 512
    div bx

    ; write data to floppy
    push es
    push bx

    mov es, [ram_address]
    mov bx, [ram_address + 2]

    mov ah, 0x03
    inc al 
    mov ch, [nhts + 4]
    mov cl, [nhts + 6]
    mov dh, [nhts + 2]
    mov dl, 0x00
    int 0x13

    pop bx
    pop es

    ; print error code
    call print_error_code

    popa
    ret