clear_display:
    pusha
    ; Int 0x10
    ; AH = 06h
    ; AL = number of lines by which to scroll up (00h = clear entire window)
    ; BH = attribute used to write blank lines at bottom of window
    ; CH, CL = row, column of window's upper left corner
    ; DH, DL = row, column of window's lower right corner

    mov ax, 0x0600			; AH = 6 = Scroll Window Up, AL = 0 = clear window
    mov bh, 0 << 4 | 5      ; Attribute to clear screen with (magenta on black)
    xor cx, cx				; Clear window from 0, 0
    mov dx, 25 << 8 | 80	; Clear window to 24, 80
    int 0x10				; Clear the screen

    mov ah, 0x02			; Set cursor
    mov bh, 0x00			; Page 0
    mov dx, 0x00			; Row = 0, col = 0
    int 0x10

    popa
    ret


