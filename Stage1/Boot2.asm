;**********************************************
;	Boot2.asm
;		- A Simple Bootloader
;	Operating Systems Development Tutorial
;**********************************************
org	0x7C00		; We are loaded by BIOS at 0x7C00
bits	16		; We are still in 6 bit Real Mode
Start:	jmp Loader	; Jump over OEM block

;**********************************************
;	OEM Parameter Block
;**********************************************

times 0Bh-$+Start db 0			; space needed for oem block to work

bpbBytesPerSector:	dw 512
bpbSectorsPerCluster:	db 1
bpbReservedSectors:	dw 1
bpbNumberOfFATs:	db 2
bpbRootEntries:		dw 224
bpbTotalSectors:	dw 2880
bpbMedia:		db 0xF0
bpbSectorsPerFAT:	dw 9
bpbSectorsPerTrack:	dw 18
bpbHeadsPerCylinder:	dw 2
bpbHiddenSectors:	dd 0
bpbTotalSectorsBig:	dd 0
bsDriveNumber:		db 0
bsUnused:		db 0
bsExtBootSignature:	db 0x29
bsSerialNumber:		dd 0xa0a1a2a3
bsVolumeLabel:		db "MOS FLOPPY "
bsFileSystem:		db "FAT12   "

msg	db	"Welcome to My Operating System!", 0

;*********************************************
;	Prints a string
;	ds=>si: 0 terminated string
;*********************************************

Print:
	lodsb
	or	al, al
	jz	PrintDone
	mov	ah, 0Eh
	int	10h
	jmp	Print
PrintDone:
	ret

;*********************************************
;	Bootloader Entry Point
;*********************************************

Loader:
	xor	ax, ax	; Setup segments to insure they are 0. Remember that
	mov	ds, ax	; we have ORG 0x7C00. This means all addresses are based
	mov	es, ax	; from 0x7C00:0. Because the data segments are within the same
			; code segment, null em.
	mov	si, msg
	call	Print

	xor	ax, ax	; clear ax
	int	0x12	; get the amount of KB from the BIOS

	cli		; Clear all Interrupts
	hlt		; halt the system

times 510 - ($-$$) db 0	; We have to be 512 bytes. Clear the reof the bytes with 0
dw 0xAA55		; Boot Signature