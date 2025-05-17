;Write a switch case driven X86/64 ALP to perform 64-bit hexadecimal arithmetic operations (+,-,*, /) using suitable macros. Define procedure for each operation.

%macro scall 4
    mov rax, %1
    mov rdi, %2
    mov rsi, %3
    mov rdx, %4
    syscall
%endmacro

section .data
    menu db 10d,13d,"**********MENU**********"
    db 10d,13d,"1. Addition"
    db 10d,13d,"2. Subtraction"
    db 10d,13d,"3. Multiplication"
    db 10d,13d,"4. Division"
    db 10d,13d,"5. Exit"
    db 10d,13d,"Enter your Choice: "
    menu_len equ $-menu
    m1 db 10d,13d,"Addition: "
    l1 equ $-m1
    m2 db 10d,13d,"Subtraction: "
    l2 equ $-m2
    m3 db 10d,13d,"Multiplication: "
    l3 equ $-m3
    m4 db 10d,13d,"Division: "
    l4 equ $-m4
    prompt1 db 10d,13d,"Enter first 64-bit hexadecimal number: "
    len_prompt1 equ $-prompt1
    prompt2 db 10d,13d,"Enter second 64-bit hexadecimal number: "
    len_prompt2 equ $-prompt2

section .bss
    answer resb 16
    choice resb 2
    input_buffer resb 17
    num1 resq 1
    num2 resq 1

section .text
    global _start
    _start:
up:
    scall 1,1,menu,menu_len
    scall 0,0,choice,2
    cmp byte[choice],'1'
    je case1
    cmp byte[choice],'2'
    je case2
    cmp byte[choice],'3'
    je case3
    cmp byte[choice],'4'
    je case4
    cmp byte[choice],'5'
    je case5
    jmp up

case1:
    scall 1,1,m1,l1
    call read_numbers
    call addition
    call display
    jmp up

case2:
    scall 1,1,m2,l2
    call read_numbers
    call subtraction
    call display
    jmp up

case3:
    scall 1,1,m3,l3
    call read_numbers
    call multiplication
    call display
    jmp up

case4:
    scall 1,1,m4,l4
    call read_numbers
    call division
    call display
    jmp up

case5:
    mov rax,60
    mov rdi,0
    syscall

read_numbers:
    scall 1,1,prompt1,len_prompt1
    scall 0,0,input_buffer,17
    call convert_input
    mov [num1], rax
    scall 1,1,prompt2,len_prompt2
    scall 0,0,input_buffer,17
    call convert_input
    mov [num2], rax
    ret

convert_input:
    mov rsi, input_buffer
    xor rax, rax
    xor rbx, rbx
.convert_loop:
    mov al, [rsi]
    cmp al, 0Ah
    je .done
    cmp al, '0'
    jb .invalid
    cmp al, '9'
    jbe .digit
    cmp al, 'A'
    jb .invalid
    cmp al, 'F'
    jbe .upper
    cmp al, 'a'
    jb .invalid
    cmp al, 'f'
    jbe .lower
.invalid:
    mov rax,60
    mov rdi,1
    syscall
.digit:
    sub al, '0'
    jmp .combine
.upper:
    sub al, 'A'
    add al, 10
    jmp .combine
.lower:
    sub al, 'a'
    add al, 10
.combine:
    shl rbx, 4
    or bl, al
    inc rsi
    jmp .convert_loop
.done:
    mov rax, rbx
    ret

addition:
    mov rax, [num1]
    add rax, [num2]
    ret

subtraction:
    mov rax, [num1]
    sub rax, [num2]
    ret

multiplication:
    mov rax, [num1]
    mov rbx, [num2]
    mul rbx
    ret

division:
    mov rax, [num1]
    xor rdx, rdx
    mov rbx, [num2]
    div rbx
    ret

display:
    mov rsi, answer+15
    mov rcx, 16
.cnt:
    mov rdx, 0
    mov rbx, 16
    div rbx
    cmp dl, 09h
    jbe .add30
    add dl, 07h
.add30:
    add dl, 30h
    mov [rsi], dl
    dec rsi
    dec rcx
    jnz .cnt
    scall 1,1,answer,16
    ret
