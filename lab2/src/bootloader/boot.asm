org  0x7C00
bits 16

%define ENDL 0x0D, 0x0A



; FAT12 Headers
; docs: https://wiki.osdev.org/FAT

jmp short start
nop

; BPB (BIOS Parameter Block)
bpb_oem: 			db "MSWIN4.1" 	; 8 bytes
bpb_bytes_per_sector:		dw 512
bpb_sectors_per_cluster:	db 1
bpb_reserved_sectors:		dw 1
bpb_fat_count:			db 2
bpb_dir_entries_count:		dw 0xE0
bpb_total_sectors:		dw 2880	; 2880 * 512 = 1.44MB
bpb_media_descriptor_type:	db 0xF0	; F0 = 3.5" floppy disk
bpb_sectors_per_fat:		dw 9		; 9 sectors/fat
bpb_sectors_per_track:		dw 18
bpb_heads:			dw 2
bpb_hidden_sectors:		dd 0
bpb_large_sector_count:	dd 0

; Extended boot record
ebr_drive_number:		db 0 		; 0x00 flopyy, 0x80 hdd
				db 0		; reserved
ebr_signature:			db 0x29
ebr_volume_id:			db 0x12, 0x34, 0x56, 0x78 ; serial number; the value doesn't matter, as it is used only for tracking volumes between computers
ebr_volume_label:		db 'COOL OS    '	  ; 11 bytes, any value is valid for the label, but it should be padded with spaces
ebr_system_id:			db 'FAT12   '		  ; 8 bytes



; Entry point of the program
start:
	jmp main



;
; Helper functions
;
puts:
	; Prints a string on the screen
	; Params:
	; - ds:si string's offset

	push si
	push ax

.loop:
	lodsb			; loads next character in al
	or al, al		; verify if next character is null
	jz .done

	mov ah, 0x0e		; call bios interrupt
	int 0x10

	jmp .loop

.done:
	pop ax
	pop si
	ret



;
; Main of the program
;
main:
	; setup data segments
	mov ax, 0		; can't write to ds/es directly
	mov ds, ax
	mov es, ax

	; setup stack
	mov ss, ax
	mov sp, 0x7C00		; stack grows downwards from where we are loaded in memory

	; read something from disk
	; BIOS should set dl to drive number
	mov [ebr_drive_number], dl

	mov ax, 1		; LBA = 1, second sector from disk
	mov cl, 1		; 1 sector to read
	mov bx, 0x7E00		; data should be after the bootloader
	call disk_read

	; print message
	mov  si, msg_hello
	call puts

	hlt


;
; Error handling functions
;
disk_error:
	mov si, msg_read_failed
	call puts
	jmp wait_key_and_reboot

wait_key_and_reboot:
	mov ah, 0
	int 16h			; wait for keypress
	jmp 0xFFFF:0			; jump to beginning of BIOS, should reboot

.halt:
	cli				; disable interrupts, this way CPU can't get out of `halt` state
	hlt



;
; Disk routines functions
;
lba_to_chs:
	; Make the conversation from the Logical Block Addressing (LBA) address
	; to Cylinder Head Sector (CHS) scheme address.
	; Params:
	; 	- ax: LBA address
	; Returns:
	;	- cx: [bits 0-5]  sector number
	;	- cx: [bits 6-15] cylinder
	;	- dh: head

	push ax
	push dx

	xor dx, dx
	div word [bpb_sectors_per_track] 	; ax = LBA / SectorsPerTrack
						; dx = LBA % SectorsPerTrack
	inc dx					; dx = LBA % SectorsPerTrack + 1 = sector
	mov cx, dx				; cx = sector

	xor dx, dx
	div word [bpb_heads]			; ax = (LBA / SectorsPerTrack) / Heads = cylinder
						; dx = (LBA / SectorsPerTrack) % Heads = head

	mov dh, dl				; dh = head
	mov ch, al				; ch = cylinder (lower 8 bits)
	shl ah, 6
	or cl, ah				; put upper 2 bits of cylinder in cl

	pop ax
	mov dl, al
	pop ax
	ret


disk_read:
	; Reads sectors from a disk
	; Params:
	; 	- ax: LBA address
	;	- cl: number of sectors to read (up to 128)
	;	- dl: drive number
	;	- es:bx: memory address where to store read data

	push ax
	push bx
	push cx
	push dx
	push di

	push cx				; temporarily save CL (number of sectors to read)
	call lba_to_chs			; compute CHS
	pop ax					; AL = number of sectors to read

	mov ah, 0x02				; Read Sectors (BIOS interrupt)
	mov di, 3				; Retry counter

.retry_loop:
	pusha					; save all registers
	stc 					; set carry flag, some BIOS'es don't set it up
	int 0x13				; carry flag cleared == success
	jnc .done				; jump if carry flag not set

	; read failed
	popa
	call disk_reset

	dec di
	test di, di
	jnz .retry_loop

.fail:
	; failed after all possible attempts of reading
	jmp disk_error

.done:
	popa

	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	ret


disk_reset:
	; Resets disk controller
	; Params:
	; 	- dl: drive number

	pusha

	mov ah, 0
	stc
	int 0x13
	jc disk_error

	popa
	ret



msg_hello: 		db "Hello, world!", ENDL, 0
msg_read_failed:	db "Read from disk failed!", ENDL, 0

times 510-($-$$) db 0
dw    0xAA55
