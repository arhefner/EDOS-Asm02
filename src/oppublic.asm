#include      include/bios.inc
#include      include/kernel_api.inc
#include      include/asm02.inc

              proc      oppublic

              extrn     o_inmsg
              extrn     error
              extrn     findlabel
              extrn     ltrimrf

              call      ltrimrf        ; move past any spaces
              call      findlabel      ; search for specified label
              lbnf      found          ; jump if label was found
              call      o_inmsg        ; display error
              db        'Error: Label not found',13,10,0
              call      error
              rtn                      ; return to caller
found:        ldn       ra             ; retrieve flags
              ori       2              ; set public flag
              str       ra             ; and put it back
              rtn                      ; return to caller

              endp

