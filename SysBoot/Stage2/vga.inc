bits 32
%define		VIDMEM		0xB8000		; video memory
%define		COLS		80		; width of screen
%define		LINES		25		; height of screen
%define		CHAR_ATTRIB	14		; character attribute (White text on black background)
_CurX db	0				; current x/y location
_CurY db	0
;************************************************
;	Putch32()
;		- Prints a character to screen
;	BL => Character to print
;************************************************
Putch32:
	pusha					; save registers
	mov	edi, VIDMEM			; get pointer to video memory

	;-------------------------------;
	;	Get current position	;
	;-------------------------------;
	xor	eax, eax			; clear eax
	;------------------
	; y * screen width
	;------------------
	mov	ecx, COLS * 2			; Mode 7 has 2 bytes per char, so its COLs * 2 bytes per line
	mov	al, byte [_CurY]		; get y pos
	mul	ecx				; multiply y * COLS
	push	eax				; save eax - the multiplication
	;------------------
	; x * y * screen width
	;------------------
	mov	al, byte [_CurX]		; multiply _CurX by 2 because it is 2 bytes
	mov	cl, 2
	mul	cl
	pop	ecx				; pop y * COLS result
	add eax, ecx
	;------------------
	; eax = offset
	;------------------
	xor	ecx, ecx
	add	edi, eax			; add it to the base address

	;-------------------------------;
	;	Watch for newline	;
	;-------------------------------;
	cmp	bl, 0x0A			; is it a newline character
	je	.Row				; yep, go to next row
	;-------------------------------;
	;	Print a character	;
	;-------------------------------;
	mov	dl, bl				; get character
	mov	dh, CHAR_ATTRIB			; the character attribute
	mov	word [edi], dx			; write to video display
	;-------------------------------;
	;	Update next position	;
	;-------------------------------;
	inc	byte [_CurX]			; go to next character
	cmp byte [_CurX], COLS			; are we at the end of the line?
	je	.Row				; yep, go to the next row
	jmp	.EndPutch32				; nope, bail out

	;-------------------------------;
	;	Go to next row		;
	;-------------------------------;
.Row:
	mov byte [_CurX], 0			; go back to col 0
	inc	byte [_CurY]			; go to next row
	;-------------------------------;
	;	Restore registers	;
	;	and return		;
	;-------------------------------;
.EndPutch32:
	popa					; restore registers
	ret					; return

Puts32:
	;-------------------------------;
	;	Store registers		;
	;-------------------------------;
	pusha					; save registers
	push	ebx				; copy the string address
	pop	edi

.loop:
	;-------------------------------;
	;	get character		;
	;-------------------------------;
	mov	bl, byte [edi]			; get t character
	cmp	bl, 0				; is it 0 (Null terminator)?
	je	.EndPuts32			; yep, bail out

	;-------------------------------;
	;	print the character	;
	;-------------------------------;
	call	Putch32				; Nope, print it out

	;-------------------------------;
	;	go to next character	;
	;-------------------------------;
.Next:
	inc	edi				; go to next character
	jmp	.loop

.EndPuts32:
	;-------------------------------;
	;	update hardware		;
	;	cursor			;
	;-------------------------------;
	; its more efficient to update the cursor after printing
	mov	bh, byte [_CurY]		; get current position
	mov	bl, byte [_CurX]
	;call	MovCur				; update cursor
	popa					; restore registers, and return
	ret