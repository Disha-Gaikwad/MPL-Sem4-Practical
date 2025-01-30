section .data
arr_msg db 'Enter 5 array elements (space separated, hex values): ', 10
arr_len equ $ - arr_msg  ; Calculate length of arr_msg

larg_msg db 'Largest Number is::'
larg_len equ $ - larg_msg  ; Calculate length of larg_msg

nwline db 10
array dq 0, 0, 0, 0, 0       ; Array to store user input
arrcnt dd 05h

section .bss
arr_num resb 16    ; Buffer for number output
large resq 1       ; Variable to store the largest number
input_buffer resb 100 ; Buffer for user input (maximum 100 bytes)

%macro dispmsg 2
mov rax, 1          ; System call for write
mov rdi, 1          ; Standard output stream
mov rsi, %1         ; Message start address
mov rdx, %2         ; Message length
syscall
%endmacro

%macro read_input 2
mov rax, 0          ; System call for read
mov rdi, 0          ; Input from stdin
mov rsi, %1         ; Buffer address
mov rdx, %2         ; Buffer size
syscall
%endmacro

section .text
global _start

_start:
    ; Display message asking for array input
    dispmsg arr_msg, arr_len

    ; Read user input for array elements (up to 100 characters)
    read_input input_buffer, 100

    ; Convert input string to numbers and store in the array
    mov rsi, input_buffer   ; rsi points to input_buffer
    mov rcx, [arrcnt]       ; rcx = number of array elements (5)

parse_input:
    ; Parse each element (expecting hex digits)
    call parse_hex
    mov [array + rcx*8 - 8], rax ; Store the parsed value in the array

    dec rcx
    jnz parse_input

    ; Find the largest number
    mov rsi, array          ; rsi points to the array
    mov rcx, [arrcnt]       ; rcx holds the number of elements in the array (5)
    mov rax, [rsi]          ; Load the first element of the array into rax
    dec rcx                 ; Decrement the count by 1

find_largest:
    add rsi, 8              ; Move to the next element (8 bytes)
    cmp rax, [rsi]          ; Compare the current max with the next element
    ja skip_comparison      ; If current max is greater, skip the swap
    xchg rax, [rsi]         ; Swap: store the greater value in rax
skip_comparison:
    loop find_largest       ; Repeat for all elements

    ; Store the largest number
    mov [large], rax

    ; Display the largest number message
    dispmsg larg_msg, larg_len

    ; Move largest number to rbx for display
    mov rbx, [large]
    call disp_num

    ; Print newline
    dispmsg nwline, 1

exit:
    ; Exit the program
    mov rax, 60            ; System call for exit
    mov rdi, 0             ; Exit code 0
    syscall

parse_hex:
    ; Convert a string of hex digits to a number in rax
    xor rax, rax            ; Clear rax (number accumulator)
parse_hex_loop:
    movzx rbx, byte [rsi]   ; Load next byte from input
    inc rsi                 ; Move to the next character
    cmp rbx, '0'            ; Check if it's a valid hex digit
    jb parse_hex_done
    cmp rbx, '9'
    jbe parse_hex_valid
    cmp rbx, 'a'
    jge parse_hex_valid
    cmp rbx, 'f'
    jle parse_hex_valid
    jmp parse_hex_done

parse_hex_valid:
    ; Convert ASCII hex to integer (0-9 or A-F)
    sub rbx, '0'            ; Convert ASCII to numeric value
    cmp rbx, 9
    jbe parse_hex_continue
    sub rbx, 7              ; Adjust for 'a' to 'f'
parse_hex_continue:
    shl rax, 4              ; Shift left by 4 bits to make space for the next digit
    or rax, rbx             ; Add the current hex digit to the accumulator
    jmp parse_hex_loop

parse_hex_done:
    ret

disp_num:
    ; Convert the number to hex and display it
    mov rdi, arr_num      ; Point rdi to the buffer
    mov rcx, 16           ; Set loop count for 16 hex digits

dispup1:
    rol rbx, 4            ; Rotate left by 4 bits (to extract each hex digit)
    mov dl, bl            ; Get the lower byte of rbx
    and dl, 0fh           ; Mask to get only the lower nibble
    add dl, '0'           ; Convert to ASCII
    cmp dl, '9'           ; Compare with '9'
    jbe dispskip1         ; If less than or equal to '9', skip adjustment
    add dl, 7             ; Adjust to 'A'-'F' range if necessary

dispskip1:
    mov [rdi], dl         ; Store the ASCII value in the buffer
    inc rdi               ; Move to the next byte in the buffer
    loop dispup1          ; Decrement rcx and repeat if not zero
    ; Display the number as a string
    dispmsg arr_num, 16
    ret
