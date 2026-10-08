#include      include/bios.inc
#include      include/kernel_api.inc
#include      include/asm02.inc

              org       PROG_BASE

              extrn     o_inmsg
              extrn     o_msg
              extrn     o_open
              extrn     o_close
              extrn     o_write
              extrn     appendext
              extrn     asmpass
              extrn     dopublics
              extrn     initasm
              extrn     itoa16
              extrn     ltrim
              extrn     showsymbols
              extrn     writeoutput

F_SHOWLIST:   equ       1
F_LISTFILE:   equ       2
F_SHOWSYM:    equ       4
F_1805:       equ       8

begin:        db        'E','D','F'    ; ELF-DOS program signature
              db        0,2,0          ; program version
start:        lbr       setup          ; execution starts here
              db        'Written by Michael H. Riley',0

iaddr:        dw        0
action:       db        0
cldefines:    dw        0
defines:      dw        0
nests:        db        0,0,0,0,0,0,0,0,0,0
numnests:     db        0
flags:        db        0
pass:         db        0
errors:       dw        0
lines:        dw        0
bytes:        dw        0
address:      dw        0
nextlabel:    dw        0
linecount:    dw        0
outbytes:     ds        16
outcount:     db        0
outaddress:   dw        0
startaddr:    dw        0
nstack:       dw        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
ostack:       db        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
build:        dw        0
isextrn:      db        0
islocal:      db        0
extrntype:    db        0
extrnlabel:   dw        0
extrnlow:     db        0
scope:        dw        0
label:        ds        32
exitsp:       dw        0,0            ; stack and return address at entry
srcptr:       dw        0              ; file block of file being read
bmonth:       db        1              ; build date and time, as read
bday:         db        1              ; from the clock.  The year is
byear:        db        54             ; an offset from 1972.
bhour:        db        0
bminute:      db        0
bsecond:      db        0

; ***************************************
; ***** Helper functions tied to R9 *****
; ***************************************
              org       ($+255) & 0ff00h
              sep       r3
helpers:      plo       re             ; save D
              lda       r3             ; get instruction
              plo       r9             ; jump to instruction
save_d:       glo       rf             ; save rf
              stxd
              ghi       rf
              str       r2
              lda       r3             ; set rf to inline address
              phi       rf
              lda       r3
              plo       rf
              glo       re             ; get D
              str       rf             ; and save it
restore_rf:   ldxa                     ; recover rf
              phi       rf
              ldx
              plo       rf
              glo       re             ; recover D
              br        helpers-1      ; and return to caller

load_d:       glo       rf             ; save rf
              stxd
              ghi       rf
              str       r2
              lda       r3             ; set rf to inline address
              phi       rf
              lda       r3
              plo       rf
              ldn       rf             ; get value from address
              plo       re             ; save it
              br        restore_rf     ; and then clean up and return

save_rf:      glo       ra             ; save ra
              stxd
              ghi       ra
              str       r2
              lda       r3             ; get address from inline
              phi       ra
              lda       r3
              plo       ra
              ghi       rf             ; save rf at address
              str       ra
              inc       ra
              glo       rf
              str       ra
restore_ra:   ldxa                     ; restore ra
              phi       ra
              ldx
              plo       ra
              br        helpers-1      ; then return

save_r8:      glo       ra             ; save ra
              stxd
              ghi       ra
              str       r2
              lda       r3             ; get address from inline
              phi       ra
              lda       r3
              plo       ra
              ghi       r8             ; save rf at address
              str       ra
              inc       ra
              glo       r8
              str       ra
              br        restore_ra

save_ra:      glo       rf             ; save rf
              stxd
              ghi       rf
              str       r2
              lda       r3             ; get address from inline
              phi       rf
              lda       r3
              plo       rf
              ghi       ra             ; save rf at address
              str       rf
              inc       rf
              glo       ra
              str       rf
              ldxa
              phi       rf
              ldx
              plo       rf
              br        helpers-1

load_rf:      lda       r3             ; get address
              phi       rf
              lda       r3
              plo       rf
              lda       rf             ; retrieve the value
              plo       re
              lda       rf
              plo       rf
              glo       re
              phi       rf
              br        helpers-1

load_ra:      lda       r3             ; get address
              phi       ra
              lda       r3
              plo       ra
              lda       ra             ; retrieve the value
              plo       re
              lda       ra
              plo       ra
              glo       re
              phi       ra
              br        helpers-1

load_rb:      lda       r3             ; get address
              phi       rb
              lda       r3
              plo       rb
              lda       rb             ; retrieve the value
              plo       re
              lda       rb
              plo       rb
              glo       re
              phi       rb
              br        helpers-1

load_rc:      lda       r3             ; get address
              phi       rc
              lda       r3
              plo       rc
              lda       rc             ; retrieve the value
              plo       re
              lda       rc
              plo       rc
              glo       re
              phi       rc
              br        helpers-1

load_rd:      lda       r3             ; get address
              phi       rd
              lda       r3
              plo       rd
              lda       rd             ; retrieve the value
              plo       re
              lda       rd
              plo       rd
              glo       re
              phi       rd
              br        helpers-1

load_r8:      lda       r3             ; get address
              phi       r8
              lda       r3
              plo       r8
              lda       r8             ; retrieve the value
              plo       re
              lda       r8
              plo       r8
              glo       re
              phi       r8
              br        helpers-1

load_r7:      lda       r3             ; get address
              phi       r7
              lda       r3
              plo       r7
              lda       r7             ; retrieve the value
              plo       re
              lda       r7
              plo       r7
              glo       re
              phi       r7
              br        helpers-1

opush_in:     lda       r3
opush:        str       r8
              inc       r8
              glo       rb
              adi       1
              plo       rb
              br        helpers-1

opush_d:      glo       re
              br        opush
           
npush:        ghi       ra
              str       r7
              inc       r7
              glo       ra
              str       r7
              inc       r7
              ghi       rb
              adi       1
              phi       rb
              br        helpers-1
              
incopy:       lda       r3
              str       rf
              inc       rf
              bnz       incopy
              dec       rf
              br        helpers-1

addrf:        lda       r3
              str       r2
              glo       rf
              add
              plo       rf
              ghi       rf
              adci      0
              phi       rf
              br        helpers-1

andrf:        lda       r3
              str       r2
              glo       rf
              and
              plo       rf
              br        helpers-1

save:         lbr       lsave
restore:      lbr       lrestore

; ***************************************


; *****************************************************
; ***** Save and restore registers                *****
; ***** Reached through the helper page, so these *****
; ***** run with R9 as the program counter.  The  *****
; ***** inline byte is a mask of the registers.   *****
; *****************************************************
lsave:        ldn       r3
              ani       r7_
              lbz       save_1
              push      r7
save_1:       ldn       r3
              ani       r8_
              lbz       save_2
              push      r8
save_2:       ldn       r3
              ani       rA_
              lbz       save_3
              push      ra
save_3:       ldn       r3
              ani       rB_
              lbz       save_4
              push      rb
save_4:       ldn       r3
              ani       rC_
              lbz       save_5
              push      rc
save_5:       ldn       r3
              ani       rD_
              lbz       save_6
              push      rd
save_6:       lda       r3
              ani       rF_
              lbz       helpers-1
              push      rf
              lbr       helpers-1

lrestore:     ldn       r3
              ani       rF_
              lbz       restore_1
              pop       rf
restore_1:    ldn       r3
              ani       rD_
              lbz       restore_2
              pop       rd
restore_2:    ldn       r3
              ani       rC_
              lbz       restore_3
              pop       rc
restore_3:    ldn       r3
              ani       rB_
              lbz       restore_4
              pop       rb
restore_4:    ldn       r3
              ani       rA_
              lbz       restore_5
              pop       ra
restore_5:    ldn       r3
              ani       r8_
              lbz       restore_6
              pop       r8
restore_6:    lda       r3
              ani       r7_
              lbz       helpers-1
              pop       r7
              lbr       helpers-1

; *****************************************************
; ***** Program entry                             *****
; ***** RA - argument table, RC - argument count  *****
; *****************************************************
setup:        mov       rf,exitsp      ; remember how to get back
              ghi       r2
              str       rf
              inc       rf
              glo       r2
              str       rf
              inc       rf
              ghi       r6
              str       rf
              inc       rf
              glo       r6
              str       rf
              mov       rf,line        ; join the arguments back into a
              inc       ra             ; command line, without the
              inc       ra             ; program name.  The shell's own
argloop:      dec       rc             ; line is far shorter than this
              glo       rc             ; buffer.
              lbz       argdone        ; jump if no more arguments
              lda       ra             ; get address of next argument
              phi       r7
              lda       ra
              plo       r7
argcopy:      lda       r7             ; copy argument
              lbz       argnext        ; jump if end of argument
              str       rf
              inc       rf
              lbr       argcopy        ; loop until argument copied
argnext:      ldi       ' '            ; arguments are separated by a space
              str       rf
              inc       rf
              lbr       argloop        ; loop back for next argument
argdone:      ldi       0              ; terminate command line
              str       rf
              mov       rf,LOADER_ARGS+2 ; the system stack is small, so
              lda       rf             ; use the top of free memory for
              phi       r2             ; the stack instead
              ldn       rf
              plo       r2
              mov       ra,line        ; point to command line
              call      asmmain        ; run the assembler

; *****************************************************
; ***** Return to ELF-DOS, from any call depth    *****
; ***** D - return code                           *****
; *****************************************************
abort:        plo       re             ; keep return code
              mov       rf,exitsp      ; recover stack and return address
              lda       rf
              phi       r2
              lda       rf
              plo       r2
              lda       rf
              phi       r6
              ldn       rf
              plo       r6
              glo       re             ; recover return code
              rtn                      ; and return to ELF-DOS

asmmain:      call      initasm        ; initialize
              lbnf      initgood       ; jump if initialization was good
              ldi       09h            ; set return code
              rtn                      ; and return to caller
initgood:     ldn       ra             ; get byte from cl
              lbnz      havename       ; jump if name given
              call      o_inmsg        ; display usage message
              db        'Usage: asm02 [options] srcname',13,10,0
              ldi       0ah            ; set return code
              rtn                      ; and return to caller
havename:     mov       r7,srcfile     ; point to filenames
              mov       r8,objfile
              mov       rb,lstfile
fnloop:       lda       ra             ; get next byte from cl
              plo       re             ; keep a copy
              smi       33             ; must be 33 or higher
              lbnf      donenames      ; jump if done with names
              glo       re
              str       r7             ; store byte into names
              str       r8
              str       rb
              inc       r7             ; increment pointers
              inc       r8
              inc       rb
              lbr       fnloop         ; loop until done copying name
donenames:    ldi       0              ; terminate names
              str       r7
              str       r8
              str       rb
              mov       rf,objfile     ; point to output file
              call      appendext      ; append .obj
              db        '.obj',0
              mov       rf,lstfile     ; point to list file
              call      appendext      ; append .lst
              db        '.lst',0

              call      o_inmsg
              db        'File: ',0
              mov       rf,srcfile
              call      o_msg
              call      o_inmsg
              db        13,10,13,10,0

              ldi       1
              hlpr      save_d,pass    ; set assembly pass
              call      asmpass        ; assembly pass
              lbnf      pass1done      ; jump if source file was read
              ldi       0bh            ; set return code
              rtn                      ; and return to os

pass1done:    hlpr      load_rf,errors ; need to see if errors in pass 1
              glo       rf
              str       r2
              ghi       rf
              or
              lbz       do_pass2       ; do pass 2 if no errors in pass 1
              call      o_inmsg        ; display abort message
              db        'Aborting due to errors in pass 1',13,10,0
              ldi       0ffh           ; set error return
              rtn                      ; and return to os
             
do_pass2:     mov       rf,objfile
              mov       rd,objfildes
              mov       r7,3
              call      o_open
              lbdf      openerr        ; jump if file was not created
              hlpr      load_d,flags   ; get flags
              ani       F_LISTFILE     ; check for list file
              lbz       nolstfile      ; jump if no lst file
              mov       rf,lstfile     ; point to lst filename
              mov       rd,lstfildes   ; point to lst fildes
              mov       r7,3           ; create/truncate
              call      o_open
              lbnf      nolstfile      ; jump if file was created
              mov       rd,objfildes   ; otherwise close output file
              call      o_close
openerr:      call      o_inmsg        ; display error
              db        'Error: Could not create output file',13,10,0
              ldi       0ch            ; set return code
              rtn                      ; and return to os

nolstfile:    ldi       2
              hlpr      save_d,pass    ; set assembly pass
              call      asmpass        ; assembly pass
              call      writeoutput    ; output any remaining bytes

              call      dopublics      ; output any defined publics

              hlpr      load_rf,startaddr ; get start address
              ghi       rf             ; check for -1
              smi       0ffh
              lbnz      write_start    ; write start if not -1
              glo       rf
              smi       0ffh
              lbz       no_start
write_start:  mov       rf,buffer      ; point to buffer
              ldi       '@'            ; write start record
              str       rf
              inc       rf
              hlpr      load_rd,startaddr
              call      f_hexout4
              ldi       13
              str       rf
              inc       rf
              ldi       10
              str       rf
              mov       rf,buffer
              mov       rc,7
              mov       rd,objfildes
              call      o_write
no_start:     mov       rd,objfildes
              call      o_close

              hlpr      load_d,flags   ; get flags
              ani       F_LISTFILE     ; what there a .lst file
              lbz       nolstclose     ; jump if no need to close lst file
              mov       rd,lstfildes   ; point to .lst fildes
              call      o_close        ; and close it

nolstclose:   call      o_inmsg
              db        13,10,'Lines Assembled   : ',0
              hlpr      load_rc,lines
              mov       rd,buffer
              call      itoa16
              mov       rf,buffer
              call      o_msg

              call      o_inmsg
              db        13,10,'Code Generated    : ',0
              hlpr      load_rc,bytes
              mov       rd,buffer
              call      itoa16
              mov       rf,buffer
              call      o_msg

              call      o_inmsg
              db        13,10,'Errors            : ',0
              hlpr      load_rc,errors
              mov       rd,buffer
              call      itoa16
              mov       rf,buffer
              call      o_msg
              call      o_inmsg
              db        13,10,13,10,0
              ldi       0

              hlpr      load_d,flags   ; get flags
              ani       F_SHOWSYM      ; see if symbols were requested
              lbz       return         ; jump if not
              call      showsymbols    ; otherwise display symbols

return:       hlpr      load_rc,errors ; get error count
              glo       rc             ; zero check
              str       r2
              ghi       rc
              or
              lsz
              ldi       0ffh           ; singal errors occured
              lskp
              ldi       0              ; signal no errors
              rtn
              
buffer:       ds        64
srcfile:      ds        128
objfile:      ds        128
lstfile:      ds        128
line:         ds        256
lstline:      ds        256
outline:      ds        256
lstpos:       dw        0
lstbytes:     db        0
inccount:     db        0

; ***** File blocks, see asm02.inc.  An ELF-DOS file control block
; ***** may not cross a page boundary, so they are aligned.  The first
; ***** source block is the file named on the command line; each level
; ***** of include file uses the block after the one that included it.
              .align    32
objfildes:    ds        FIL_SIZE
lstfildes:    ds        FIL_SIZE
srcfildes:    ds        SRC_SIZE*(MAX_INCLUDE+1)

              public    abort
              public    action
              public    address
              public    addrf
              public    andrf
              public    buffer
              public    bday
              public    bhour
              public    bminute
              public    bmonth
              public    bsecond
              public    build
              public    byear
              public    bytes
              public    cldefines
              public    defines
              public    errors
              public    extrnlabel
              public    extrnlow
              public    extrntype
              public    flags
              public    helpers
              public    iaddr
              public    inccount
              public    incopy
              public    isextrn
              public    islocal
              public    label
              public    load_d
              public    load_r7
              public    load_r8
              public    load_ra
              public    load_rb
              public    load_rd
              public    load_rf
              public    line
              public    lines
              public    linecount
              public    lstbytes
              public    lstfildes
              public    lstline
              public    lstpos
              public    nests
              public    nextlabel
              public    npush
              public    nstack
              public    numnests
              public    objfildes
              public    opush_in
              public    opush_d
              public    ostack
              public    outaddress
              public    outbytes
              public    outcount
              public    outline
              public    pass
              public    save_d
              public    save_r8
              public    save_ra
              public    save_rf
              public    scope
              public    srcfile
              public    srcfildes
              public    srcptr
              public    startaddr
              public    F_1805
              public    F_LISTFILE
              public    F_SHOWLIST
              public    F_SHOWSYM
              public    save
              public    restore

              end       start



