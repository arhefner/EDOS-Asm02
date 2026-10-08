# EDOS-Asm02
An 1802 assembler that runs on [ELF-DOS](https://github.com/arhefner/ELF-DOS), written in 1802 Assembly language. It is a port of the reduced version of Mike Riley's Asm/02 assembler that runs on Elf/OS 5.

Platform
--------
The assembler runs on an 1802 based Microcomputer running the ELF-DOS operating system. ELF-DOS runs on the same hardware as Elf/OS, such as the [Pico/Elf](http://www.elf-emulation.com/picoelf.html) by Mike Riley or the [1802-Mini](https://github.com/dmadole/1802-Mini) by David Madole.

Usage
-----
```
asm02 [options] filename
```
| Option | Meaning |
|---|---|
| `-l` | Show the listing on the console |
| `-L` | Write the listing to a `.lst` file |
| `-s` | Show the symbol table |
| `-1805` | Enable the 1804/5/6 instructions |
| `-Dname` | Define `name` with the value 1 |
| `-Dname=value` | Define `name` with the given value |

The file name may include a drive letter and a path, such as `D:/src/hello.asm`, and must include its extension. The object file is written beside the source file with the extension `.obj`, in the text format used by Link/02. See `asm02.doc` for the preprocessor, the directives, the pseudo ops and the expression evaluator.

The exit code is 0 when the file assembled without errors and non-zero otherwise.

Building
--------
The assembler is assembled and linked with the [Asm/02](https://github.com/arhefner/Asm-02) assembler and [Link/02](https://github.com/arhefner/Link-02) linker, the same versions used to build ELF-DOS. The Makefile expects them in `/opt/elfc`; set `ASM` and `LINK` to use them from somewhere else.
```
make          # assemble src/*.asm and link ./asm02
make clean
```
Copy the `asm02` file that this produces into the `/bin` directory of an ELF-DOS volume.

`elfdos-sdk/` is a copy of the ELF-DOS SDK that the assembler is built against; see `elfdos-sdk/MANIFEST.txt` for the ELF-DOS version it came from, and `elfdos-sdk/DEVELOPER_GUIDE.md` for the program interface. Rebuild the assembler against a newer SDK if the ELF-DOS kernel's minor version changes.

Differences from the Elf/OS version
-----------------------------------
* The program has an ELF-DOS header and loads at `PROG_BASE`. It takes its arguments from the ELF-DOS argument table.
* Console and file calls go through the ELF-DOS kernel, in `src/dosio.asm`. Console output can be redirected.
* Lines written to the console, the object file and the list file end with CR LF. Source lines may end with CR LF, LF or CR.
* Each level of include file has its own file block, in place of saving and restoring a single one. Include files may be nested 4 deep, and nesting any deeper is reported as an error.
* The stack is moved to the top of free memory while the assembler runs, since the ELF-DOS system stack is 128 bytes. The define table is below the stack and the label table is above the program, as before.
* The extension of the object and list files replaces the extension of the last part of a path, so a dot in a directory name is left alone.
* A source file or an output file that cannot be opened ends the run with an error.
* The build date and time come from the real time clock when there is one, and are otherwise 1 January 2026.
* `LSKP` assembles as `C8`. The Elf/OS version assembles it as `C2`.
* A file with no `END` address no longer has a stray record written to the end of its object file.

Things that are unchanged, and may be a surprise
-----------------------------------------------
* A label must be written in lower case where it is defined. A use of it is matched without regard to case.
* A comparison that is true has the value -1, where the Asm/02 that runs on a PC gives 1.
* The extended opcodes of the PC assembler (`.op`) are not supported, so the assembler cannot assemble itself.
* `VER`, `EVER` and `EEVER` build Elf/OS version headers.

Testing
-------
The assembler has been run under the Run/02 emulator, booting ELF-DOS 1.2 from a FAT16 disk image. It has not been run on real hardware.
