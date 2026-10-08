#include      include/bios.inc
#include      include/kernel_api.inc
#include      include/asm02.inc

              proc      opend

              extrn     getarg
              extrn     save_rf
              extrn     startaddr

              call      getarg         ; get argument
              mov       rf,r7          ; move address to rf
              hlpr      save_rf,startaddr ; set start address
              rtn                      ; return to caller

              endp

