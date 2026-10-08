#include      include/bios.inc
#include      include/kernel_api.inc
#include      include/asm02.inc

              proc      touc

              plo       re             ; save character
              smi       'a'            ; check for below lowercase
              lbnf      done           ; jump if not
              smi       26             ; see if above lowercase
              lbdf      done           ; jump if so
              glo       re             ; recover character
              smi       32             ; convert to uc
              rtn                      ; and return
done:         glo       re             ; recover character
              rtn                      ; and return

              endp

