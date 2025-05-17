;Write X86/64 ALP to convert 4-digit Hex number into its equivalent BCD number and 5- digit BCD number into its equivalent HEX number.
;Make your program user friendly to accept the choice from user for: 
;(a) HEX to BCD b) BCD to HEX (c) EXIT.
;Display proper strings to prompt the user while accepting the input and displaying the result. (Wherever necessary, use 64-bit registers).

section .data
    msg1 db 10, 10, '###### Menu for Code Conversion######', 10
    db '1: Hex to BCD', 10
    db '2: BCD to Hex', 10
    db '3: Exit', 10
    db 10, 10, 'Enter Choice:'
    msg1length equ $ - msg1

    msg2 db 10, 10, 'Enter 4 digit hex number:'
    msg2length equ $ - msg2

    msg3 db 10, 10, 'BCD Equivalent:'
    msg3length equ $ - msg3

    msg4 db 10, 10, 'Enter 5 digit BCD number:'
    msg4length equ $ - msg4

    msg5 db 10, 10, 'Wrong Choice Entered....Please try again!!!', 10, 10
    msg5length equ $ - msg5

    msg6 db 10, 10, 'Hex Equivalent:'
    msg6length equ $ - msg6

    cnt db 0

section .bss
    arr resb 06      ; Common buffer for choice, hex, and BCD input
    dispbuff resb 08 ; Buffer to store display output
    ans resb 01      ; Buffer to store individual characters

%macro disp 2
    mov rax, 01
    mov rdi, 01
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro

%macro accept 2
    mov rax, 0
    mov rdi, 0
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro

section .text
global _start

_start:
menu:
    disp msg1, msg1length
    accept arr, 2     ; Get the choice (1, 2, or 3)
    cmp byte [arr], '1'
    jne l1
    call hex2bcd_proc
    jmp menu

l1:
    cmp byte [arr], '2'
    jne l2
    call bcd2hex_proc
    jmp menu

l2:
    cmp byte [arr], '3'
    je exit
    disp msg5, msg5length
    jmp menu

exit:
    mov rax, 60        ; Exit system call
    mov rbx, 0         ; Exit status
    syscall

hex2bcd_proc:
    disp msg2, msg2length
    accept arr, 5      ; Accept 4 digits of hex
    call conversion
    mov rcx, 0
    mov ax, bx
    mov bx, 10         ; Base of Decimal No. system

l33:
    mov dx, 0
    div bx             ; Divide the number by 10
    push rdx           ; Push remainder onto stack
    inc rcx
    inc byte [cnt]
    cmp ax, 0
    jne l33

    disp msg3, msg3length

l44:
    pop rdx
    add dl, 30h        ; Convert to ASCII
    mov [ans], dl
    disp ans, 1
    dec byte [cnt]
    jnz l44
    ret

bcd2hex_proc:
    disp msg4, msg4length
    accept arr, 6      ; Accept 5 digits of BCD
    disp msg6, msg6length
    mov rsi, arr
    mov rcx, 5
    mov rax, 0
    mov ebx, 0ah       ; Multiplier for BCD

l55:
    mov rdx, 0
    mul ebx            ; Multiply eax by 10 (decimal base)
    mov dl, [rsi]
    sub dl, 30h        ; Convert ASCII to integer
    add rax, rdx
    inc rsi
    dec rcx
    jnz l55

    mov ebx, eax       ; Store the result in ebx
    call disp32_num    ; Display the result in hex
    ret

conversion:
    mov bx, 0
    mov ecx, 4
    mov esi, arr

up1:
    rol bx, 4
    mov al, [esi]
    cmp al, 39h
    jbe l22
    sub al, 07h        ; Adjust for hex A-F
l22:
    sub al, 30h        ; Convert ASCII to integer
    add bl, al
    inc esi
    loop up1
    ret

disp32_num:
    mov rdi, dispbuff
    mov rcx, 8         ; Number of digits (since it's 32-bit)

l77:
    rol ebx, 4
    mov dl, bl
    and dl, 0fh
    add dl, 30h
    cmp dl, 39h
    jbe l66
    add dl, 07h
l66:
    mov [rdi], dl
    inc rdi
    dec rcx
    jnz l77

    disp dispbuff + 3, 5  ; Display only the lower 5 digits (since upper 3 are '0')
    ret
