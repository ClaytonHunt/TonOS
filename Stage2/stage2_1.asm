; Note: Here, we are executed like a normal
; COM program, but we are still in Ring 0.
; We will use this loader to set up 32 bit
; mode and basic exception handling
; This loaded program will be our 32 bit Kernel.
; We do not have the limitation of 512 bytes here,
; so we can add anything we want here!
org 0x0		; offset to 0, we will set segments later
bits 16		; we are still in real mode
; we are loaded at linear address 0x10000
jmp Main	; jump to main
;****************************************
;	Prints a string
;	DS=>SI: 0 terminated string
;****************************************
Print:
	lodsb			; load next byte from string from SI to AL
	or	al, al		; if(al || al) {
 	jz	PrintDone	; 	return;
	mov	ah, 0Eh		; ah = 0Eh;
	int	10h		; Print();
	jmp	Print		; loop
PrintDone:
	ret			; we are done, so return
;****************************************
;	Second Stage Loader Entry Point
;****************************************
Main:
	cli			; clear interrupts
	push	cs		; Insure DS=CS
	pop	ds
	mov	si, Msg
	call	Print
	cli			; clear interrupts to prevent triple fault
	hlt			; halt the system
;****************************************
;	Data Section
;****************************************
	Msg	db "Preparing to load operating system...", 13, 10, 0