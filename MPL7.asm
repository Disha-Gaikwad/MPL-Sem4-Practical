;Write X86/64 ALP to detect protected mode and display the values of GDTR, LDTR, IDTR, TR and MSW Registers also identify CPU type using CPUID instruction.

section .data
    nline db 10, 10
    nline_len equ $ - nline

    colon db ":"

    rmsg db 10, 'Processor is in Real Mode...'
    rmsg_len equ $ - rmsg

    pmsg db 10, 'Processor is in Protected Mode...'
    pmsg_len equ $ - pmsg

    gmsg db 10, "GDTR (Global Descriptor Table Register): "
    gmsg_len equ $ - gmsg

    imsg db 10, "IDTR (Interrupt Descriptor Table Register): "
    imsg_len equ $ - imsg

    lmsg db 10, "LDTR (Local Descriptor Table Register) : "
    lmsg_len equ $ - lmsg

    tmsg db 10, "TR (Task Register) : "
    tmsg_len equ $ - tmsg

    mmsg db 10, "MSW (Machine Status Word) : "
    mmsg_len equ $ - mmsg

section .bss
    GDTR resw 3           ; 48 bits, so 3 words
    IDTR resw 3
    LDTR resw 1           ; 16 bits, so 1 word
    TR resw 1
    MSW resw 1
    char_sum resb 4       ; 16-bits, so 4 digits

;----------------------------------------------------------------------
%macro print 2
    mov rax, 1
    mov rdi, 1
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro

%macro exit 0
    mov rax, 60
    mov rdi, 0
    syscall
%endmacro
;----------------------------------------------------------------------

section .text
global _start

_start:
    ; Check processor mode
    SMSW [MSW]
    mov rax, [MSW]
    ror rax, 1          ; Check PE bit: if 1 = Protected Mode, else Real Mode
    jc p_mode           ; If PE bit is clear, it's Real Mode, jump to p_mode

    print rmsg, rmsg_len
    jmp next

p_mode:
    print pmsg, pmsg_len

next:
    ; Retrieve GDTR, IDTR, LDTR, and TR
    SGDT [GDTR]
    SIDT [IDTR]
    SLDT [LDTR]
    STR [TR]

    ; Print GDTR (Global Descriptor Table Register)
    print gmsg, gmsg_len ; GDTR
    mov ax, [GDTR + 4]  ; Load value of GDTR[4,5] in AX
    call disp16_proc     ; Display GDTR contents
    mov ax, [GDTR + 2]  ; Load value of GDTR[2,3] in AX
    call disp16_proc     ; Display GDTR contents
    print colon, 1
    mov ax, [GDTR + 0]  ; Load value of GDTR[0,1] in AX
    call disp16_proc     ; Display GDTR contents

    ; Print IDTR (Interrupt Descriptor Table Register)
    print imsg, imsg_len
    mov ax, [IDTR + 4]
    call disp16_proc
    mov ax, [IDTR + 2]
    call disp16_proc
    print colon, 1
    mov ax, [IDTR + 0]
    call disp16_proc

    ; Print LDTR (Local Descriptor Table Register)
    print lmsg, lmsg_len
    mov ax, [LDTR]
    call disp16_proc

    ; Print TR (Task Register)
    print tmsg, tmsg_len
    mov ax, [TR]
    call disp16_proc

    ; Print MSW (Machine Status Word)
    print mmsg, mmsg_len
    mov ax, [MSW]
    call disp16_proc

    ; Print a newline
    print nline, nline_len

    ; Exit the program
    exit

;----------------------------------------------------------------------

disp16_proc:
    ; Convert and display 16-bit number as a hexadecimal string
    mov rsi, char_sum + 3    ; Load last byte address of char_sum buffer into RSI
    mov rcx, 4               ; Number of digits to display (4 hex digits)

cnt:
    mov rdx, 0               ; Clear rdx before div operation (as in div instruction: rdx:rax / rbx)
    mov rbx, 16              ; Divisor = 16 for hexadecimal
    div rbx                  ; Divide rax by 16
    cmp dl, 09h              ; Check if remainder is less than or equal to 9
    jbe add30
    add dl, 07h              ; If remainder is greater than 9, adjust for ASCII A-F
add30:
    add dl, 30h              ; Convert to ASCII code
    mov [rsi], dl            ; Store result in buffer

    dec rsi                  ; Move pointer to previous byte in buffer
    dec rcx                  ; Decrement the count
    jnz cnt                  ; If not zero, repeat

    ; Print the result
    print char_sum, 4        ; Display the result on the screen
    ret
