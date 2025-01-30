section .data
msg1 db 10,13,"Enter 5 64 bit numbers", 0
len1 equ $-msg1
msg2 db 10,13,"Entered 5 64 bit numbers", 0
len2 equ $-msg2

section .bss
array resq 5 ; reserve space for 5 64-bit numbers (40 bytes total)
counter resb 1 ; 1 byte for loop counter

section .text
global _start

_start:
    ; Display msg1
    mov rax, 1           ; sys_write
    mov rdi, 1           ; file descriptor (stdout)
    mov rsi, msg1        ; pointer to message
    mov rdx, len1        ; message length
    syscall              ; invoke syscall

    ; Initialize counter to 5 (we will read 5 numbers)
    mov byte [counter], 5

    ; Accept 5 64-bit numbers
    mov rbx, 0           ; index (starting position in array)
loop1:
    mov rax, 0           ; sys_read
    mov rdi, 0           ; file descriptor (stdin)
    lea rsi, [array + rbx] ; pointer to the correct position in the array
    mov rdx, 8           ; read 8 bytes (64-bit number)
    syscall              ; invoke syscall
    add rbx, 8           ; move to the next 64-bit number in array
    dec byte [counter]    ; decrement counter
    jnz loop1            ; loop until 5 numbers are read

    ; Display msg2
    mov rax, 1           ; sys_write
    mov rdi, 1           ; file descriptor (stdout)
    mov rsi, msg2        ; pointer to message
    mov rdx, len2        ; message length
    syscall              ; invoke syscall

    ; Re-initialize counter for the second loop
    mov byte [counter], 5

    ; Display the 5 64-bit numbers
    mov rbx, 0           ; reset index to 0
loop2:
    mov rax, 1           ; sys_write
    mov rdi, 1           ; file descriptor (stdout)
    lea rsi, [array + rbx] ; pointer to the number in array
    mov rdx, 8           ; 8 bytes (64-bit number) to write
    syscall              ; invoke syscall
    add rbx, 8           ; move to the next number in array
    dec byte [counter]    ; decrement counter
    jnz loop2            ; loop until all numbers are displayed

    ; Exit the program
    mov rax, 60          ; sys_exit
    xor rdi, rdi         ; exit code 0
    syscall              ; invoke syscall
