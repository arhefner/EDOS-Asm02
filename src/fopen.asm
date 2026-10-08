#include      include/bios.inc
#include      include/kernel_api.inc
#include      include/asm02.inc

; *******************************************
; ***** Open file                       *****
; ***** RF - Filename                   *****
; ***** RD - Source file block         *****
; ***** R7 - File flags, see o_open    *****
; ***** Returns: DF=0 - File was opened *****
; *****          DF=1 - Failed          *****
; *******************************************
              proc      fopen

              extrn     o_open

              push      r7             ; save consumed registers
              push      r8
              call      o_open         ; open the file
              lbnf      opened         ; jump if good
              plo       re
return:       pop       r8             ; recover consumed registers
              pop       r7
              glo       re
              rtn                      ; and return to caller
opened:       glo       rd             ; need to point to readln data
              adi       SRC_COUNT.0
              plo       r7
              ghi       rd
              adci      SRC_COUNT.1
              phi       r7
              glo       rd             ; and to the line buffer
              adi       SRC_BUFFER.0
              plo       r8
              ghi       rd
              adci      SRC_BUFFER.1
              phi       r8
              ldi       0              ; indicate no bytes remaining
              str       r7
              inc       r7
              ghi       r8             ; store buffer address
              str       r7
              inc       r7
              glo       r8
              str       r7
              adi       0              ; signal file was opened
              lbr       return         ; then return to caller

              endp

; The file block is laid out in asm02.inc

