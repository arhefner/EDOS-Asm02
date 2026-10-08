#include      include/bios.inc
#include      include/kernel_api.inc
#include      include/asm02.inc

; *******************************************************************
; ***** Console and file calls                                  *****
; *****                                                         *****
; ***** The assembler was written for the Elf/OS kernel calls,  *****
; ***** which hand back every register they are not documented  *****
; ***** to change.  The ELF-DOS calls promise much less, so     *****
; ***** each routine here saves what the rest of the assembler  *****
; ***** expects to keep, R9 (the helper page) included.         *****
; *******************************************************************

; *************************************
; ***** Display a character       *****
; ***** D - character             *****
; ***** Returns: D, DF unchanged  *****
; *************************************
              proc      o_type

              plo       re             ; keep character
              shlc                     ; save DF
              stxd
              glo       re             ; save character
              stxd
              push      r7             ; save everything else
              push      r8
              push      r9
              push      ra
              push      rb
              push      rc
              push      rd
              push      rf
              glo       re             ; recover character
              call      K_TYPE         ; and display it
              pop       rf             ; recover registers
              pop       rd
              pop       rc
              pop       rb
              pop       ra
              pop       r9
              pop       r8
              pop       r7
              irx                      ; recover character
              ldxa
              plo       re
              ldx                      ; recover DF
              shr
              glo       re
              rtn                      ; and return to caller

              endp

; *******************************************
; ***** Display a string                *****
; ***** RF - pointer to string          *****
; ***** Returns: RF - past terminator   *****
; *******************************************
              proc      o_msg

              extrn     o_type

loop:         lda       rf             ; get next byte of string
              lbz       done           ; jump if terminator
              call      o_type         ; otherwise display it
              lbr       loop           ; and keep going
done:         rtn                      ; return to caller

              endp

; *******************************************
; ***** Display the string that follows *****
; ***** the call                        *****
; *******************************************
              proc      o_inmsg

              extrn     o_type

loop:         lda       r6             ; get next byte of string
              lbz       done           ; jump if terminator
              call      o_type         ; otherwise display it
              lbr       loop           ; and keep going
done:         rtn                      ; return past the string

              endp

; *******************************************
; ***** Open file                       *****
; ***** RF - Filename                   *****
; ***** RD - File block                 *****
; ***** R7 - 0 to read an existing file *****
; *****      otherwise create the file, *****
; *****      or empty it if it exists   *****
; ***** Returns: DF=0 - File was opened *****
; *****          DF=1 - Failed          *****
; *******************************************
              proc      o_open

              push      r7             ; save registers
              push      r8
              push      r9
              push      ra
              push      rb
              push      rc
              push      rd
              push      rf
              glo       rd             ; sector buffer follows the
              adi       FCB_LEN        ; file control block
              plo       ra
              ghi       rd
              adci      0
              phi       ra
              glo       r7             ; get flags
              lbz       open           ; jump if only reading
              ldi       1              ; otherwise open for writing
open:         call      K_FILE_OPEN    ; open the file

o_return:     pop       rf             ; recover registers
              pop       rd
              pop       rc
              pop       rb
              pop       ra
              pop       r9
              pop       r8
              pop       r7
              rtn                      ; and return to caller

              public    o_return

              endp

; *******************************************
; ***** Close file                      *****
; ***** RD - File block                 *****
; ***** Returns: DF=0 - File was closed *****
; *****          DF=1 - Failed          *****
; *******************************************
              proc      o_close

              extrn     o_return

              push      r7             ; save registers
              push      r8
              push      r9
              push      ra
              push      rb
              push      rc
              push      rd
              push      rf
              call      K_FILE_CLOSE   ; close the file
              lbr       o_return       ; then clean up and return

              endp

; *******************************************
; ***** Write to file                   *****
; ***** RD - File block                 *****
; ***** RF - Bytes to write             *****
; ***** RC - Count of bytes             *****
; ***** Returns: DF=0 - Bytes written   *****
; *****          DF=1 - Failed          *****
; *******************************************
              proc      o_write

              extrn     o_return

              push      r7             ; save registers
              push      r8
              push      r9
              push      ra
              push      rb
              push      rc
              push      rd
              push      rf
              call      K_FILE_WRITE   ; write the bytes
              lbr       o_return       ; then clean up and return

              endp

; *******************************************
; ***** Read from file                  *****
; ***** RD - File block                 *****
; ***** RF - Where to put the bytes     *****
; ***** RC - Count of bytes wanted      *****
; ***** Returns: RC - Count of bytes    *****
; *****               read, 0 at end of *****
; *****               file or on error  *****
; *******************************************
              proc      o_read

              push      r7             ; save registers
              push      r8
              push      r9
              push      ra
              push      rb
              push      rd
              push      rf
              call      K_FILE_READ    ; read the bytes
              lbnf      good           ; jump if read worked
              ldi       0              ; otherwise nothing was read
              phi       rc
              plo       rc
good:         pop       rf             ; recover registers
              pop       rd
              pop       rb
              pop       ra
              pop       r9
              pop       r8
              pop       r7
              rtn                      ; and return to caller

              endp
