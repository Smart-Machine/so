get_cursor_pos:
    ; The function obtains the current cursor position 
    ; and the size/shape of the cursor for a specified video page.
    ; Parameters:
    ;   AH = 03H 
    ;   BH = video page number 
    ; Returns:
    ;   CH = cursor starting scan-line
    ;   CL = cursor ending scan-line
    ;   DH = current row
    ;   DL = current column

    mov ah, 0x03 
    mov bh, [page_num]
    int 0x10

    ret

read_input:
    ; The function reads the input and stores it into the `storage_buffer`,
    ; the user can edit the written input, by the use of backspace, and
    ; by typing enter, the input is read. The input shall be saved into 
    ; a another buffer.
    ; Parameters: None
    ; Returns:
    ;   The input is stored in the `storage_buffer`. 

    mov si, storage_buffer
    call get_cursor_pos

    .read_char:
        mov ah, 0x00
        int 0x16

        cmp al, 0x08
	    je .handle_backspace

	    cmp al, 0x0D
	    je .handle_enter

        cmp si, storage_buffer + 256
        je .read_char 

        mov [si], al
	    inc si

        mov ah, 0x0E
	    int 0x10

	    jmp .read_char 

    .handle_backspace:
	    cmp si, storage_buffer
	    je .read_char 

	    dec si
    	mov byte [si], 0

        call get_cursor_pos

	    cmp dl, 0
        je .previous_line

        mov ah, 0x02
        dec dl
        int 0x10

        mov ah, 0x0A
        mov al, 0x20
        int 0x10

	    jmp .read_char 

    .previous_line:
        mov ah, 0x02
        dec dh
        mov dl, 79
        int 0x10

        mov ah, 0x0A
        mov al, 0x20
        int 0x10
    
        jmp .read_char 

    .handle_enter:
        cmp si, storage_buffer
        je .read_char 

        mov byte [si], 0

        ret

atoi:
    ; The function converts a string to integer. For example,
    ;   "234" -> 234
    ;   iteration 1:
    ;   1.1)  "2" - "0" = 2 == ax
    ;   1.2)   0  * 10  = 0 == bx
    ;   1.3)   2  +  0  = 2 == bx 
    ;   iteration 2: 
    ;   2.1)  "3" - "0" = 3  == ax
    ;   2.2)   2  * 10  = 20 == bx
    ;   2.3)   3  + 20  = 23 == bx
    ;   iteration 3:
    ;   3.1)  "4" -  "0" = 4   == ax 
    ;   3.2)  23  *  10  = 230 == bx
    ;   3.3)   4  + 230  = 234 == bx  
    ; Parameters:
    ;   SI = src, buffer from where the string value is taken
    ;   DI = dst, buffer where integer value is stored
    ; Returns: None

    .atoi_loop:
        cmp byte [si], 0
        je .atoi_done

        xor ax, ax
        mov al, [si]
        sub al, '0'

        mov bx, [di]
        imul bx, 10
        add bx, ax
        mov [di], bx

        inc si
        jmp .atoi_loop

    .atoi_done:
        ret

atoh:
    ; The function converts a string to integer. For example,
    ;   "2C" -> 0x2C
    ;   iteration 1:
    ;   1.1)  "2" --dec--> 50
    ;   1.2)   50 is less than 65, thus jump to convertion of digit
    ;   1.3)   al = 50-48 = 2
    ;   1.4)   shift 0x0 to 0x00, and add 0x00 + 0x02 => 0x02
    ;   1.5)   inc si, thus move the pointer in the string
    ;   iteration 2:
    ;   2.1)   "C" --dec--> 67
    ;   2.2)   67 is greater than 65, thus jumpt to convertion of letter
    ;   2.3)   al = 67-55 = 12
    ;   2.4)   shift 0x02 to 0x20, and add 0x20 + 0x12 => 0x32
    ;   2.5)   inc si, thus move the pointer in the string
    ; Parameters:
    ;   SI = src, buffer from where the string value is taken
    ;   DI = dst, buffer where hexadecimal value is stored
    ; Returns: None

    .atoh_loop:
        cmp byte [si], 0
        je .atoh_done

        xor ax, ax
        mov al, [si]
        cmp al, 65
        jl .conv_digit  

        .conv_letter:
            sub al, 55
            jmp .atoh_finish_iteration

        .conv_digit:
            sub al, 48

        .atoh_finish_iteration:
            mov bx, [di]
            imul bx, 16
            add bx, ax
            mov [di], bx

            inc si

        jmp .atoh_loop

    .atoh_done:
        ret

read_hts:
    ; The function handling input for Heads, Treacks, Sectors
    ; Parameters: None
    ; Returns: None

    .read_h:
        ; display "H := "
        call get_cursor_pos
        inc dh
        mov dl, 0x00

        mov ax, 0x1301
        mov bl, 0x05            
        mov cx, H_param_len
        mov bp, H_param 
        int 0x10

        ; read user input `H`
        call read_input

        ; convert ascii read to integer
        ; and save to own buffer
        mov di, hts + 0
        mov si, storage_buffer
        call atoi

    .read_t:
        ; display "T := "
        call get_cursor_pos
        inc dh
        mov dl, 0x00

        mov ax, 0x1301
        mov bl, 0x05            
        mov cx, T_param_len
        mov bp, T_param 
        int 0x10

        ; read user input `T`
        call read_input

        ; convert ascii read to integer
        ; and save to own buffer
        mov di, hts + 2
        mov si, storage_buffer
        call atoi

    .read_s:
        ; display "S := "
        call get_cursor_pos
        inc dh
        mov dl, 0x00

        mov ax, 0x1301
        mov bl, 0x05            
        mov cx, S_param_len
        mov bp, S_param 
        int 0x10

        ; read user input `S`
        call read_input

        ; convert ascii read to integer
        ; and save to own buffer
        mov di, hts + 4
        mov si, storage_buffer
        call atoi

    ret

read_ram_address:
    ; display "segment (XXXX) := "
    call get_cursor_pos
    inc dh
    mov dl, 0x00

    mov ax, 0x1301
    mov bl, 0x05            
    mov cx, segment_param_len
    mov bp, segment_param 
    int 0x10

    ; read user input `segment`
    call read_input

    ; convert ascii read to hex 
    ; and save to own buffer
    mov di, ram_address 
    mov si, storage_buffer
    call atoh

    ; display "offset (YYYY) := "
    call get_cursor_pos
    inc dh
    mov dl, 0x00

    mov ax, 0x1301
    mov bl, 0x05            
    mov cx, offset_param_len
    mov bp, offset_param 
    int 0x10

    ; read user input `offset`
    call read_input

    ; convert ascii read to hex 
    ; and save to own buffer
    mov di, ram_address + 2
    mov si, storage_buffer
    call atoh

    ret

empty_buffer:
    ; The function clears the buffer set in SI register, by 
    ; assigning 0s into it.
    ; Parameters:
    ;   SI = buffer to be emptified
    ;   DI = the same buffer from the SI register
    ;        but with the desired offset.
    ; Returns: None
    pusha

    .empty_buffer_loop:
        mov byte[si], 0
        inc si
        cmp si, di
        jl .empty_buffer_loop
    
    popa
    ret

null_buffers:
    ; The function nulls out all the buffers used by the 
    ; menu. The indented use of it, is to emptify all the 
    ; buffers before their usage after a successful completion
    ; of an selected option. 
    ; Parameters: None
    ; Returns: None

    pusha

    mov si, hts
    mov di, hts + 6
    call empty_buffer

    mov si, ram_address
    mov di, ram_address + 4
    call empty_buffer

    mov si, storage_buffer
    mov di, storage_buffer + 256 
    call empty_buffer

    popa
    ret

print_loading_kernel:
    pusha

    call get_cursor_pos    
    inc dh
    mov dl, 0x00

    mov ax, 0x1301
    mov bl, 0x05
    mov cx, loading_kernel_msg_len
    mov bp, loading_kernel_msg
    int 0x10

    popa
    ret

print_error_code:
    push ax

    call get_cursor_pos
    inc dh
    mov dl, 0x00

    mov ax, 0x1301
    mov bl, 0x05            
    mov cx, error_msg_len 
    mov bp, error_msg 
    int 0x10

    pop ax

    mov al, '0'
    add al, ah
    mov ah, 0x0E
    int 0x10

    ret


page_num: dw 0
H_param: db "H := ", 0
H_param_len: equ $ - H_param
T_param: db "T := ", 0
T_param_len: equ $ - T_param
S_param: db "S := ", 0
S_param_len: equ $ - S_param
segment_param: db "segment := ", 0
segment_param_len: equ $ - segment_param
offset_param: db "offset := ", 0
offset_param_len: equ $ - offset_param
loading_kernel_msg: db "Loading the Kernel..."
loading_kernel_msg_len: equ $ - loading_kernel_msg
error_msg: db "error code := ", 0
error_msg_len: equ $ - error_msg


hts: resb 6
ram_address: resb 4
storage_buffer: resb 256 