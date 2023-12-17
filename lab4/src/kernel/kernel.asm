org 0 
mov [error_code], ah

init_ram_kernel:
    mov ax, 0x3000
    mov ds, ax      ; data segment
    mov es, ax      ; extra segment
    mov fs, ax       
    mov gs, ax
    mov ss, ax      ; stack segment
    mov sp, 0x0

main:
    pusha

    mov ah, [error_code]
    call print_error_code

    ; get cursor position
    mov ah, 0x03
    mov bh, 0
    int 0x10

    ; update cursor position
    inc dh
    mov dl, 0x00

    ; print success message
    mov ax, 0x1301
    mov bl, 0x05
    mov cx, kernel_loaded_msg_len 
    mov bp, kernel_loaded_msg 
    int 0x10

    .wait_for_enter:
    mov ah, 0x00 
    int 0x16

    cmp al, 0x0D
    jne .wait_for_enter 

    mov bx, 5
    call draw_gradient
    popa

    .wait_for_space:
    mov ah, 0x00 
    int 0x16

    cmp al, 0x20
    jne .wait_for_space 

    .set_video_mode:
        push bx
        mov ah, 0x00 
        mov bh, 0x00
        mov al, 0x13
        int 0x10
        pop bx

    jmp 0x1000:0x0 

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

get_cursor_pos:
    mov ah, 0x03 
    int 0x10
    ret

draw_gradient:
    pusha
    .set_video_mode:
        push bx
        mov ah, 0x00 
        mov bh, 0x00
        mov al, 0x13
        int 0x10
        pop bx

    ; boundaries :: w 0..320 && h 0..199
    mov cx, 0       ; width
    mov dx, 0       ; height
    mov al, 1
    .loop_width:
        cmp cx, 320 
        jz .done_width 

        inc cx
        .loop_height:
            cmp dx, 199
            jz .done_height
            
            inc dx
            call draw_pixel

            inc al
            cmp al, 255 
            jz .reset
            jmp .loop_height

            .reset:
                mov al, 1
                jmp .loop_height

            .done_height:
                mov dx, 0 
        jmp .loop_width 

        .done_width:
            mov cx, 0 
            dec bx
            cmp bx, 0
            jne .loop_width

    popa
    ret

draw_pixel:
    pusha
    mov ah, 0x0C 
    int 0x10
    .done_draw:
        popa
        ret

;; Var
kernel_loaded_msg db "Press Enter to continue...", 0
kernel_loaded_msg_len equ $ - kernel_loaded_msg
error_msg: db "error code := ", 0
error_msg_len: equ $ - error_msg
error_code db 0

times 1474560-(512+1024+1304576)-($-$$) db 0
;               ^    ^     ^
;               |    |     |
;               |    |     |> kernel offset
;               |    |> second stage bootloader disk space
;               |> first stage bootloader disk space

