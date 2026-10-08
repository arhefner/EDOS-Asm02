#include      include/bios.inc
#include      include/kernel_api.inc
#include      include/asm02.inc

              proc      ltrim

              lda       ra             ; get byte from command line
              smi       9              ; check for tab character
              lbz       ltrim          ; jump if so
              smi       23             ; check for space
              lbz       ltrim          ; jump if so
              dec       ra             ; move back to non-space
              rtn                      ; and return to caller

              endp

      
