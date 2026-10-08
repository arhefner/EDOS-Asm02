; *******************************************************************
; ***** Asm/02 for ELF-DOS - macros and shared definitions      *****
; *****                                                         *****
; ***** The extended opcodes below are the ones the Elf/OS      *****
; ***** version of the assembler was written against.  They are *****
; ***** kept, rather than replaced by the ELF-DOS SDK's         *****
; ***** opcodes.def, because the two differ in byte order and   *****
; ***** so in what is left in D afterwards.  16-bit operations  *****
; ***** work low byte first.                                    *****
; *******************************************************************

.op "PUSH","N","8$1 73 9$1 73"
.op "POP","N","60 72 B$1 F0 A$1"
.op "CALL","W","D4 H1 L1"
.op "RTN","","D5"
.op "MOV","NR","8$2 A$1 9$2 B$1"
.op "MOV","NW","F8 L2 A$1 F8 H2 B$1"

; ***** Inline calls to the helper routines in main.asm through R9.
; ***** HLPR passes an inline address, OP2 one inline argument byte.
.op "HLPR","WW","D9 L1 H2 L2"
.op "OP","W","D9 L1"
.op "OP2","WB","D9 L1 L2"

; ***** Register masks for the save and restore helpers
r7_:          equ       1
r8_:          equ       2
rA_:          equ       4
rB_:          equ       8
rC_:          equ       16
rD_:          equ       32
rF_:          equ       64

; ***** BIOS character tests, not listed in the SDK's bios.inc
f_isalpha:    equ       0ff72h         ; DF=1 if D is a letter
f_ishex:      equ       0ff75h         ; DF=1 if D is a hex digit

; ***** File blocks
; ***** Every file has an ELF-DOS file control block followed directly
; ***** by its sector buffer, which is where o_open looks for it.  A
; ***** source file block carries the readln state as well, and is
; ***** padded to a multiple of 32 bytes so that a row of them keeps
; ***** every control block aligned.
; *****
; *****   0- 31 - File control block
; *****  32-543 - Sector buffer
; ***** 544     - Bytes remaining in line buffer
; ***** 545-546 - Line buffer pointer
; ***** 547-626 - Line buffer (80 bytes)
; ***** 627-628 - Line number reached, while an include file is read
FIL_SIZE:     equ       FCB_LEN+FCB_IOBUF_LEN
SRC_COUNT:    equ       FIL_SIZE
SRC_BUFFER:   equ       SRC_COUNT+3
SRC_LINES:    equ       SRC_BUFFER+80
SRC_SIZE:     equ       640

MAX_INCLUDE:  equ       4              ; depth of nested include files
STACK_SIZE:   equ       512            ; must be a multiple of 256
