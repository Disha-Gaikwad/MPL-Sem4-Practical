section .data
    welmsg db 10,'Welcome to count +ve and -ve numbers in an array',10
    welmsg_len equ $-welmsg
    pmsg db 10,'Count of +ve numbers: '
    pmsg_len equ $-pmsg
    nmsg db 10,'Count of -ve numbers: '
    nmsg_len equ $-nmsg
    nwline db 10
    prompt db 'Enter the number of elements in the array: ', 0
    prompt_len equ $-prompt
    inputmsg db 'Enter each 64-bit hexadecimal number (without "0x"): ', 10, 0
    inputmsg_len equ $-inputmsg
    array resq 10   ; Allocate space for up to 10 numbers
    arrcnt resb 1    ; To store the number of elements in the array
    pcnt db 0
    ncnt db 0

section .bss
    dispbuff resb 2
    input_buffer resb 17  ; Buffer for user input

%macro print 2
    mov rax, 1
    mov rdi, 1
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro

section .text
    global _start
    _start:

    ; Print welcome message
    print welmsg, welmsg_len

    ; Prompt for the number of elements
    print prompt, prompt_len
    call read_input
    call convert_input
    movzx rax, byte [input_buffer]  ; Convert the user input to number of elements
    mov [arrcnt], al

    ; Prompt for the array elements
    print inputmsg, inputmsg_len
    mov rsi, array
    mov rcx, [arrcnt]
    mov rbx, 0  ; Index for the array

    read_elements:
        ; Read one input number
        call read_input
        call convert_input
        mov [rsi + rbx], rax  ; Store the number in the array
        inc rbx
        loop read_elements

    ; Initialize counters
    mov byte [pcnt], 0
    mov byte [ncnt], 0

    ; Count positive and negative numbers in the array
    mov rsi, array
    mov rcx, [arrcnt]
    count_loop:
        mov rax, [rsi]      ; Load number
        test rax, rax       ; Test if number is positive or negative
        jns positive        ; Jump if positive number
        inc byte [ncnt]     ; Negative number
        jmp next_number

    positive:
        inc byte [pcnt]     ; Positive number

    next_number:
        add rsi, 8          ; Move to the next number in the array (8 bytes per number)
        loop count_loop

    ; Print results
    print pmsg, pmsg_len
    mov bl, [pcnt]
    call disp8num
    print nmsg, nmsg_len
    mov bl, [ncnt]
    call disp8num
    print nwline, 1 ; New line

    ; Exit program
    mov rax, 60
    mov rdi, 0
    syscall

; Subroutine to read input
read_input:
    ; Call syscall to read user input
    scall 0, 0, input_buffer, 17
    ret

; Convert input string to number
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
    ; If input is invalid, exit with error
    mov rax, 60
    mov rdi, 1
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

; Display the 8-bit number as ASCII
disp8num:
    mov rcx, 2          ; Number digits to display
    mov rdi, dispbuff    ; Temp buffer
dup1:
    rol bl, 4           ; Rotate number from bl to get MS digit to LS digit
    mov al, bl          ; Move rotated number to AL
    and al, 0fh         ; Mask upper digit
    cmp al, 09          ; Compare with 9
    jbe dskip           ; If number below or equal to 9, skip
    add al, 07h         ; Else add 07h to adjust ASCII
dskip:
    add al, 30h         ; Convert to ASCII
    mov [rdi], al       ; Store ASCII code in temp buffer
    inc rdi             ; Increment pointer to next location in temp buffer
    loop dup1           ; Repeat until ECX becomes zero
    print dispbuff, 2    ; Display the value from temp buffer
    ret
