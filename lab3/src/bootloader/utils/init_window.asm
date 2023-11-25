%define color_black   0
%define color_blue    1
%define color_green   2
%define color_cyan    3
%define color_red     4
%define color_magenta 5
%define color_orange  6
%define color_gray    7
%define color_yellow  14
%define color_white   15

init_window:
    pusha
    .clear_screen:
        ; Int 0x10
        ; AH = 06h
        ; AL = number of lines by which to scroll up (00h = clear entire window)
        ; BH = attribute used to write blank lines at bottom of window
        ; CH, CL = row, column of window's upper left corner
        ; DH, DL = row, column of window's lower right corner

        mov ax, 0x0600								; AH = 6 = Scroll Window Up, AL = 0 = clear window
        mov bh, color_black << 4 | color_magenta	; Attribute to clear screen with (White on Red)
        xor cx, cx									; Clear window from 0, 0
        mov dx, 25 << 8 | 80						; Clear window to 24, 80
        int 0x10									; Clear the screen

        mov ah, 0x02								; Set cursor
        mov bh, 0x00								; Page 0
        mov dx, 0x00								; Row = 0, col = 0
        int 0x10

    .set_custom_cursor:
        ; Int 0x10
        ; AH = 01h
        ; CH = start scan line of character matrix (0-1fH; 20H=no cursor)
        ; CL = end scan line of character matrix (0-1fH)

        mov ax, 0x0100								; AH = 1 = Set Cursor Shape & Size, AL = 0 = nothing
        mov ch, 0x1									; Sets the width of the cursor, the higher the thicker
        mov cl, 0x10								; Sets the height of the cursor, the less the higher
        int 0x10
    popa
    ret
