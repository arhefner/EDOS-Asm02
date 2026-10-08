#include      include/bios.inc
#include      include/kernel_api.inc
#include      include/asm02.inc

              proc      checkeom

              extrn     o_inmsg
              extrn     abort
              extrn     defines
              extrn     load_r8
              extrn     nextlabel

              hlpr      load_r8,defines ; get defines table start
              ghi       r8             ; save this address
              stxd
              glo       r8
              stxd
              hlpr      load_r8,nextlabel ; get end of labels table
              irx                      ; subtract defines address
              glo       r8
              sm
              irx
              ghi       r8
              smb
              lbnf      good           ; jump if not collision
              call      o_inmsg        ; display error
              db        'Fatal error: Out of memory',13,10,0
              ldi       5
              lbr       abort

good:         adi       0              ; clear DF
              rtn                      ; return to caller
              

              endp

