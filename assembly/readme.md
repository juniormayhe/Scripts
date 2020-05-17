# Developing assembly in Windows

## 32 bits

Create a teste32.asm to print message using x86 registers
```asm
extern _printf
global _main

section .data
msg: db "Hello, world!",10,0

section .text
_main:
    push msg
    call _printf
    add esp,4   
    ret
```

## Install MinGW for windows

Unpack NASM into MinGW folder: https://www.nasm.us/pub/nasm/releasebuilds/2.14.02/win64/nasm-2.14.02-win64.zip

Compile asm to 32bits object
```
nasm -f win32 c:\Proyectos\assembly\teste32.asm
```

Build to 32 bits executable
```
c:\MinGW\bin>ld -Lc:\MinGW\lib\gcc\mingw32\6.3.0 -Lc:\MinGW\lib -o C:\Proyectos\assembly\teste32.exe C:\Proyectos\assembly\teste32.obj -lmingw32 -lgcc -lgcc_eh -lmoldname -lmingwex -lmsvcrt -ladvapi32 -lshell32 -luser32 -lkernel32 -lmingw32 -lgcc -lgcc_eh -lmoldname -lmingwex -lmsvcrt
```

Run from command prompt
```
teste32.exe
```

## 64 bits

```asm
; ----------------------------------------------------------------------------------------
; This is a Win64 console program that writes "Hello" on one line and then exits.  It
; uses puts from the C library.
; ----------------------------------------------------------------------------------------
        extern  puts

        global  main

        section .text
main:
        sub     rsp, 28h                        ; Reserve the shadow space
        mov     rcx, message                    ; First argument is address of message
        call    puts                            ; puts(message)
        add     rsp, 28h                        ; Remove shadow space
        ret
message:
        db      'Hello', 0                      ; C strings need a zero byte at the end
```

Compile to 64 bits object
```
nasm -fwin64 teste64.asm 
```

Build to 64 bits executable

## For windows install 
http://mingw-w64.org/doku.php/download/win-builds

## For linux install
- Ubuntu, Debian: $ sudo apt-get install gcc make nasm
- Fedora: $ sudo dnf install gcc make nasm
- CentOS, RHEL: $ sudo yum install gcc make nasm

```
C:\MinGW64\bin>gcc -m64 teste64.obj -o teste64.exe
C:\MinGW64\bin>teste64.exe
```

# Developing for Linux

## Install packages

Ubuntu, Debian: $ sudo apt-get install gcc make nasm
Fedora: $ sudo dnf install gcc make nasm
CentOS, RHEL: $ sudo yum install gcc make nasm

## Create the file
```asm
default rel

          global    hello

          section   .text
hello:    lea       rax, [rel msg]
          ret

          section   .data
msg:      db        "Hello, World!", 10      ; note the newline at the end with 10
```

## Compile it to linux 64bits object
```
nasm -felf64 hello_world.asm -o hello_world.o / or nasm -f elf64 hello.asm && ld -o hello hello.o
gcc hello_world.o -o hello_world
chmod u+x hello_world
./hello_world
```

# References

https://cs.lmu.edu/~ray/notes/nasmtutorial/
