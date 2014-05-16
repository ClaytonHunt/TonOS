bits 16

; Remember the memory map -- 0x500 through 0x7BFF is unused above the BIOS data areas.
; We are loaded at 0x500 ( 0x50:0)

org 0x500
jmp Main					; go to start

;************************************************************
;	Preprocessor directives
;************************************************************

%include "stdio.inc"				; basic I/O routines
%include "gdt.inc"				; GDT routines

;************************************************************
;	Data Section
;************************************************************

LoadingMsg	db	"Preparing to load operating system...", 0x0D, 0x0A, 0x00

;************************************************************
;	STAGE 2 ENTRY POINT
;
;		- Store BIOS information
;		- Load Kernel
;		- Install GDT; go into protected mode (pmode)
;		- Jump to State 3
;************************************************************

Main:
	;---------------------------------------;
	;	Setup segments and stack	;
	;---------------------------------------;

	cli					; clear interrupts
	xor	ax, ax				; null segments
	mov	ds, ax
	mov	es, ax
	mov	ax, 0x9000			; stack begins at 0x9000-0xFFFF
	mov	ss, ax
	mov	sp, 0xFFFF
	sti					; enable interrupts

	;---------------------------------------;
	;	Print loading message		;
	;---------------------------------------;

	mov	si, LoadingMsg
	call	Puts16
	
	;---------------------------------------;
	;	Install our GDT			;
	;---------------------------------------;

	call InstallGDT

	;---------------------------------------;
	;	Go into pmode			;
	;---------------------------------------;

	cli					; clear interrupts
	mov	eax, cr0			; set bit 0 in cr0 -- enter pmode
	or	eax, 1
	mov	cr0, eax
	jmp	08h:Stage3			; far jump to fix CS. Remember that the code selector is 0x8!
	; Note: Do NOT re-enable interrupts! Doing so will triple fault!
	; We will fix this in Stage 3.

;**************************************************************
;	ENTRY POINT FOR STAGE 3
;**************************************************************

bits 32						; Welcome to 32 bit world!

Stage3:
	;---------------------------------------;
	;	Set registers			;
	;---------------------------------------;
	mov	ax, 0x10			; set data segments to data selector (0x10)
	mov	ds, ax
	mov	ss, ax
	mov	es, ax
	mov	esp, 90000h			; stack begins from 90000h

;***************************************************************
;	Stop execution
;***************************************************************
STOP:
	cli
	hlt