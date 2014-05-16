; We are still pure binary. We will fix this in the next few tutorials :)

org 0x10000				; Kernel starts at 1MB
bits 32					; 32 bit code

jmp Stage3								; jump to stage 3

%include "stdio.inc"					; Our stdio.inc file we developed from the previous tutorials

msg db  0x0A, 0x0A, "                       - OS Development Series -"
    db  0x0A, 0x0A, "                     MOS 32 Bit Kernel Executing", 0x0A, 0

Stage3:
	
	;-----------------------------------;
	;	Set registers					;
	;-----------------------------------;
	
	mov	ax, 0x10						; set data segments to data selector (0x10)
	mov	ds, ax
	mov ss, ax
	mov es, ax
	mov esp, 90000h						; stack begins from 90000h
	
	;-----------------------------------;
	; Clear screen and print success 	;
	;-----------------------------------;
	
	call	ClrScr32
	mov		ebx, msg
	call	Puts32
	
	;-----------------------------------;
	; Stop execution					;
	;-----------------------------------;
	
	cli
	hlt