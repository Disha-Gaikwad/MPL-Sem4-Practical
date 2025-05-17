;Write an X86/64 ALP to accept a string and to display its length.

section .data
msg1 db 10,13,"Enter a string: ", 0  ; Prompt message
len1 equ $-msg1                    ; Calculate length of msg1

section .bss
str1 resb 200                       ; Buffer for the input string
result resb 16                      ; Buffer for the output result

section .text
global _start

_start:
    ; Display prompt message
    mov rax, 1                      ; syscall number for write
    mov rdi, 1                      ; file descriptor (stdout)
    mov rsi, msg1                   ; pointer to msg1
    mov rdx, len1                   ; length of msg1
    syscall                         ; invoke syscall

    ; Read input string
    mov rax, 0                      ; syscall number for read
    mov rdi, 0                      ; file descriptor (stdin)
    mov rsi, str1                   ; pointer to str1
    mov rdx, 200                    ; max input size
    syscall                         ; invoke syscall

    ; Null-terminate input string (assuming there's space)
    mov byte [rsi], 0               ; Add null byte at the end of the input string

    ; Process input string (rotate and convert to ASCII)
    call display                    ; Call the display function to process input and output result

    ; Exit the program
    mov rax, 60                     ; syscall number for exit
    xor rdi, rdi                    ; exit code 0
    syscall                         ; invoke syscall

%macro dispmsg 2
    mov rax, 1                      ; syscall number for write
    mov rdi, 1                      ; file descriptor (stdout)
    mov rsi, %1                     ; pointer to the message
    mov rdx, %2                     ; message length
    syscall                         ; invoke syscall
%endmacro

display:
    ; Prepare to process the input string
    mov rsi, str1                   ; pointer to the input string
    mov rdi, result                 ; pointer to the result buffer
    xor rcx, rcx                    ; clear counter (this will track the number of processed chars)

process_input:
    ; Check if we have reached the null-terminator
    mov al, [rsi + rcx]             ; load the character from input string
    test al, al                     ; check if it's the null-terminator
    jz done_processing              ; if null-terminator, we're done

    ; Convert character to its ASCII representation (if necessary)
    ; Assuming the input is a valid hexadecimal character (0-9, A-F)
    mov bl, al                       ; copy the current character to bl
    cmp bl, '0'                      ; compare with '0'
    jb invalid_char                  ; if less than '0', it's invalid
    cmp bl, '9'                      ; compare with '9'
    jbe valid_digit                  ; if between '0' and '9', it's valid

    cmp bl, 'A'                      ; compare with 'A'
    jb invalid_char                  ; if less than 'A', it's invalid
    cmp bl, 'F'                      ; compare with 'F'
    jbe valid_digit                  ; if between 'A' and 'F', it's valid

invalid_char:
    ; Handle invalid character (you may want to add error handling here)
    inc rcx
    jmp process_input

valid_digit:
    ; Convert the character to its corresponding hex value (0-9 -> 0x0-0x9, A-F -> 0xA-0xF)
    sub bl, '0'                      ; make '0' -> 0, '1' -> 1, ..., '9' -> 9
    cmp bl, 9
    jbe store_digit                  ; if it's between '0' and '9', store as is

    sub bl, 7                        ; for 'A' to 'F', subtract 7 to get the correct value (A->10, B->11, ..., F->15)

store_digit:
    ; Store the hex digit in the result buffer
    add bl, '0'                      ; convert back to ASCII (0-9 -> '0'-'9')
    mov [rdi + rcx], bl              ; store the result character
    inc rcx                          ; move to next position in the result buffer
    jmp process_input

done_processing:
    ; Null-terminate the result string
    mov byte [rdi + rcx], 0          ; null-terminate the result string

    ; Display result message
    mov rdx, rcx                     ; length of result string
    dispmsg result, rdx              ; call dispmsg macro to print result

    ret
