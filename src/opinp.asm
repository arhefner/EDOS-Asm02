#include      include/bios.inc
#include      include/kernel_api.inc
#include      include/asm02.inc

; ********************************************
; ***** INP instruction, nybble argument *****
; ********************************************
              proc      opinp

              extrn     o_inmsg
              extrn     error
              extrn     getarg
              extrn     output

              call      getarg         ; get argument
              ghi       r7             ; high byte should be zero
              lbnz      opinp_bad      ; jump if not zero
              glo       r7             ; should be 0-7
              ani       0f8h
              lbnz      opinp_bad      ; jump if in range
              glo       r7
              ani       7
              lbnz      opinpgood      ; jump if 1-7
opinp_bad:    call      o_inmsg        ; display error
              db        'Error: Argument out of range',13,10,0
              call      error          ; call error routine
              rtn                      ; and return to caller
opinpgood:    glo       r7             ; get low byte of argument
              ani       7              ; create INP instruction
              ori       068h
              call      output         ; and output it
              rtn                      ; return to caller

              endp

