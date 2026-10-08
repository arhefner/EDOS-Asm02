# EDOS-Asm02 - the Asm/02 assembler for ELF-DOS.
#
# Needs Asm/02 and Link/02. "make" assembles everything in src/ and
# links the assembler as ./asm02, ready to copy onto an ELF-DOS volume.

ASM     ?= /opt/elfc/asm02
LINK    ?= /opt/elfc/link02

ASMFLAGS ?= -L -I../elfdos-sdk
LFLAGS   ?= -b -be

# main.prg must be first: it holds the program header at PROG_BASE.
# final.prg must be last: the label table starts where the program
# ends and grows upward from there.
MODULES = main adddefine addlabel appendext asmpass check1805 checkeom \
	checkrange convertnum defreplace directive div16 dopublics dosio \
	error finddefine findlabel fopen getarg initasm isrreg itoa16 \
	labelchar lookupop ltrim ltrimrf mdnorm16 mul16 nextline opdb opds \
	opdw opend opendp opequ opeever opever opextrn opinp opldn oporg \
	opout oppop opproc oppublic oppush output opver readln replace \
	showsymbols strcasecmpin strcmpin strstr tobcd16 tohex tolc touc \
	writeextrn writelocal writeln writelstfile writeoutput final

PRGS = $(patsubst %,src/%.prg,$(MODULES))

HEADERS = src/include/asm02.inc elfdos-sdk/include/bios.inc \
	elfdos-sdk/include/kernel_api.inc

.PHONY: all clean

all: asm02

asm02: $(PRGS)
	$(LINK) $(LFLAGS) -o asm02 $(PRGS)
	rm -f asm02.lkb

src/%.prg: src/%.asm $(HEADERS)
	cd src && $(ASM) $(ASMFLAGS) $*.asm

clean:
	rm -f asm02 asm02.lkb
	rm -f src/*.prg src/*.lst src/*.build
