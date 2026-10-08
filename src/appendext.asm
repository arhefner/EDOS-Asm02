#include      include/bios.inc
#include      include/kernel_api.inc
#include      include/asm02.inc

; ***************************************************
; ***** Set the extension of a filename         *****
; ***** RF - Filename                           *****
; ***** The extension follows the call, and     *****
; ***** replaces one the name already has.  A   *****
; ***** dot only starts an extension when it is *****
; ***** in the last part of a path.             *****
; ***************************************************
              proc      appendext

              push      r7             ; save consumed register
              ldi       0              ; no extension found yet
              phi       r7
loop:         lda       rf             ; get next byte of filename
              lbz       found          ; jump if terminator
              smi       '.'            ; check for dot
              lbnz      notdot         ; jump if not
              mov       r7,rf          ; remember where the dot is
              dec       r7
              lbr       loop
notdot:       smi       1              ; check for /
              lbz       newpart
              smi       11             ; check for :
              lbz       newpart
              smi       34             ; check for \
              lbnz      loop           ; loop if none of them
newpart:      ldi       0              ; extension must come after this
              phi       r7
              lbr       loop
found:        dec       rf             ; move back to terminator
              ghi       r7             ; was there an extension
              lbz       copyext        ; jump if not
              mov       rf,r7          ; otherwise replace it
copyext:      lda       r6             ; read byte from inline extension
              str       rf             ; write to filename
              inc       rf
              lbnz      copyext        ; loop until terminator copied
              pop       r7             ; recover consumed register
              rtn                      ; return to caller

              endp
