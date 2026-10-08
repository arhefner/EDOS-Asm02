#include      include/bios.inc
#include      include/kernel_api.inc
#include      include/asm02.inc

              proc      oporg

              extrn     address
              extrn     getarg
              extrn     outaddress
              extrn     save_rf
              extrn     writeoutput

              call      writeoutput    ; write and clear output
              call      getarg         ; get argument
              mov       rf,r7          ; move address to rf
              hlpr      save_rf,address ; and write new assembly address
              hlpr      save_rf,outaddress
              rtn                      ; return to caller

              endp

