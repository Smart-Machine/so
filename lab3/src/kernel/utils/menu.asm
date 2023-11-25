display_menu:

	; read character
	mov ah, 0x00
	int 0x16

	cmp al, 0x20 
	je .cleared_screen

	.clear_screen:
		call clear_display
		jmp display_menu

	.cleared_screen:
		xor ax, ax
		xor dx, dx 
		call get_cursor_pos  

	mov ah, 0x02
	inc dh
	mov dl, 0
	int 0x10

	mov si, menu_prompt_option1
	call print_string_buffer

	mov ah, 0x02
	inc dh
	mov dl, 0
	int 0x10

	mov si, menu_prompt_option2
	call print_string_buffer

	mov ah, 0x02
	inc dh
	mov dl, 0
	int 0x10

	mov si, menu_prompt_option3
	call print_string_buffer

	mov ah, 0x02
	inc dh
	mov dl, 0
	int 0x10

	mov si, menu_prompt_option4
	call print_string_buffer

	; read character
	mov ah, 0x00
	int 0x16

	; display character
	mov ah, 0x0A
	mov bh, 0x00
	mov cx, 1
	int 0x10

	; move cursor
	mov ah, 0x02
	inc dl
	int 0x10

	cmp al, "1" 
	je handle_first_option

    cmp al, "2"
    je handle_second_option

    cmp al, "3"
    je handle_third_option

	jmp handle_invalid_option


handle_first_option:
	mov ah, 0x02
	inc dh
	mov dl, 0
	int 0x10

    call first_option

	jmp display_menu	

handle_second_option:
	mov ah, 0x02
	inc dh
	mov dl, 0
	int 0x10

	call second_option

	jmp display_menu	

handle_third_option:
	mov ah, 0x02
	inc dh
	mov dl, 0
	int 0x10

	call third_option

	jmp display_menu	

handle_invalid_option:
	mov ah, 0x02
	inc dh
	mov dl, 0
	int 0x10

	mov si, opt_invalid
	call print_string_buffer

	jmp display_menu 


%include "src/kernel/utils/menu_options/common.asm"
%include "src/kernel/utils/menu_options/first_option.asm"
%include "src/kernel/utils/menu_options/second_option.asm"
%include "src/kernel/utils/menu_options/third_option.asm"