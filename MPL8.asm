%macro IO 4
    mov rax, %1
    mov rdi, %2
    mov rsi, %3
    mov rdx, %4
    syscall
%endmacro

section .data
    sourceBlock db 12h,45h,87h,24h,97h
    count equ 05

    space db " "
    spacelen equ $ - space

    msgSource db 10,"The source block contains the elements : ",10
    msgSource_len equ $ - msgSource

    msgDest db 10,"The destination block contains the elements : ",10
    msgDest_len equ $ - msgDest

    bef db 10, "Before Block Transfer : ",10
    beflen equ $ - bef

    aft db 10,10 ,"After Block Transfer : ",10
    aftlen equ $ - aft

    newLine db " ",10
    nl equ $ - newLine

section .bss
    destBlock resb 5
    result resb 4
section .text
    global _start
    _start:
        IO 1, 1, bef, beflen
        IO 1, 1, msgSource, msgSource_len

        mov rsi, sourceBlock
        call printBlock

        IO 1, 1, msgDest, msgDest_len
        mov rsi, destBlock
        call printBlock

        mov rsi, sourceBlock
        mov rdi, destBlock

        call withStringInstruction ; change this to switch between different modes

        IO 1, 1, aft, aftlen

        IO 1, 1, msgSource, msgSource_len
       
        mov rsi, sourceBlock
        call printBlock

        IO 1, 1, msgDest, msgDest_len
        mov rsi, destBlock
        call printBlock

        IO 1, 1, newLine, nl

        call exit
    ret

    withStringInstruction:
        mov rcx, count
        cld
        rep movsb
    ret

    withoutString:
        mov rcx, 05
        again:
            mov al, [rsi]
            mov [rdi], al

            inc rsi
            inc rdi
