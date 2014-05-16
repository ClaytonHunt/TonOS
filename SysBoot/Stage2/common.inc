%ifndef _COMMON_INC_INCLUDED
%define _COMMON_INC_INCLUDED

; where the kernel is to be loaded to in protected mode
%define KERNEL_PMODE_BASE 0x100000

; where the kernel is to be loaded to in real mode
%define KERNEL_RMODE_BASE 0x3000

; kernel name (Must be 11 bytes)
KernelName	db "KRNL32  EXE"

; size of kernel image in bytes
KernelSize	db 0

%endif