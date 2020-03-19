%include "include/io.inc"

extern atoi
extern printf
extern exit

; Functions to read/free/print the image.
; The image is passed in argv[1].
extern read_image
extern free_image
; void print_image(int* image, int width, int height);
extern print_image

; Get image's width and height.
; Store them in img_[width, height] variables.
extern get_image_width
extern get_image_height

section .data
        use_str db "Use with ./tema2 <task_num> [opt_arg1] [opt_arg2]", 10, 0
        
section .rodata
        hint db "revient", 0
        new_message db "C'est un proverbe francais.", 0
        task2_message_length dd 28
        t3 db ",--..--_A.-_B-..._C-.-._D-.._E._F..-._G--._H...._I.._J.---_K-.-_L.-.._M--_N-._O---_P.--._Q--.-_R.-._S..._T-_U..-_V...-_W.--_X-..-_Y-.--_Z--.._1.----_2..---_3...--_4....-_5....._6-...._7--..._8---.._9----._0-----_"

section .bss
    task:       resd 1
    img:        resd 1
    img_width:  resd 1
    img_height: resd 1
    blurred_img: resd 1

section .text
global main
main:
    ; Prologue
    ; Do not modify!
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]
    cmp eax, 1
    jne not_zero_param

    push use_str
    call printf
    add esp, 4

    push -1
    call exit

not_zero_param:
    ; We read the image. You can thank us later! :)
    ; You have it stored at img variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 4]
    call read_image
    add esp, 4
    mov [img], eax

    ; We saved the image's dimensions in the variables below.
    call get_image_width
    mov [img_width], eax

    call get_image_height
    mov [img_height], eax

    ; Let's get the task number. It will be stored at task variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 8]
    call atoi
    add esp, 4
    mov [task], eax

    ; There you go! Have fun! :D
    mov eax, [task]
    cmp eax, 1
    je solve_task1
    cmp eax, 2
    je solve_task2
    cmp eax, 3
    je solve_task3
    cmp eax, 4
    je solve_task4
    cmp eax, 5
    je solve_task5
    cmp eax, 6
    je solve_task6
    jmp done

solve_task1:
    sub esp, 4
    push dword[img]
    call bruteforce_singlebyte_xor
    add esp, 8
    
    mov bh, ah
    shr eax, 16
    xor ecx, ecx
    xor edx, edx
    mov dx, ax
    imul edx, dword[img_width]
    imul edx, 4
    add edx, dword[img]
    
task1_print:
    mov bl, byte[edx + 4 * ecx]
    xor bl, bh
    cmp bl, 0
    jz end_print1
    PRINT_CHAR bl
    inc ecx
    cmp bl, 0
    jnz task1_print
    
end_print1:
    NEWLINE
    PRINT_DEC 1, bh
    NEWLINE
    PRINT_DEC 2, ax
    NEWLINE
    
    jmp done
    
solve_task2:
    sub esp, 4
    push dword[img]
    call bruteforce_singlebyte_xor
    add esp, 8
    
    push eax    
    xor ecx, ecx
    mov ecx, dword[img_height]
    imul ecx, dword[img_width]
    mov edx, dword[img]
    
task2_next_int:
    mov bl, byte[edx + 4 * ecx]
    xor bl, ah
    mov byte[edx + 4 * ecx], bl
    dec ecx
    cmp ecx, 0
    jge task2_next_int  
      
    pop eax    
    mov bh, ah
    shr eax, 16    
    inc ax
    xor edx, edx
    mov dx, ax
    imul edx, dword[img_width]
    imul edx, 4
    add edx, dword[img]
    xor ecx, ecx
    
write_message:
    mov bl, byte[new_message + ecx]
    mov byte[edx + ecx * 4], bl
    inc ecx
    cmp ecx, dword[task2_message_length]
    jl write_message
    
    xor eax, eax
    mov al, bh
    imul eax, 2
    add eax, 3
    mov ebx, 5
    cdq
    idiv ebx
    sub eax, 4
    shl eax, 8
    
    xor ecx, ecx
    mov ecx, dword[img_height]
    imul ecx, dword[img_width]
    mov edx, dword[img]
task2_xor_next_int:
    mov bl, byte[edx + 4 * ecx]
    xor bl, ah
    mov byte[edx + 4 * ecx], bl
    dec ecx
    cmp ecx, 0
    jge task2_xor_next_int
    
    push dword[img_height]
    push dword[img_width]
    push dword[img]
    call print_image
    add esp, 12
    
    jmp done
    
solve_task3:
    mov eax, [ebp + 12]
    mov ebx, DWORD[eax + 16]
    
    push ebx
    call atoi
    add esp, 4
    push eax
    
    mov eax, [ebp + 12]
    mov ebx, DWORD[eax + 12]
    
    push ebx
    push dword[img]
    call morse_encrypt
    add esp, 12
    
    push dword[img_height]
    push dword[img_width]
    push dword[img]
    call print_image
    add esp, 12

    jmp done
    
solve_task4:
    mov eax, [ebp + 12]
    mov ebx, DWORD[eax + 16]
    
    push ebx
    call atoi
    add esp, 4
    push eax
    
    mov eax, [ebp + 12]
    mov ebx, DWORD[eax + 12]
    
    push ebx
    push dword[img]
    call lsb_encode
    add esp, 12
    
    push dword[img_height]
    push dword[img_width]
    push dword[img]
    call print_image
    add esp, 12
    
    
    jmp done
    
solve_task5:
    mov eax, [ebp + 12]
    mov ebx, DWORD[eax + 12]
    
    push ebx
    call atoi
    add esp, 4
    
    push eax
    push dword[img]
    call lsb_decode
    add esp, 8
    
    jmp done
    
solve_task6:
    mov eax, [ebp + 12]
    push DWORD[eax + 4]
    call read_image
    add esp, 4
    
    mov [blurred_img], eax
    mov eax, [img]
    mov edx, 2
    
task6_next_line:
    add eax, dword[img_width]
    add eax, dword[img_width]
    add eax, dword[img_width]
    add eax, dword[img_width]
    
    mov ecx, 2
task6_next_char:
    dec ecx
    pushad
    mov edx, dword[eax + 4 * ecx]
    mov ebx, dword[eax + 4 * (ecx - 1)]
    add edx, ebx
    mov ebx, dword[eax + 4 * (ecx + 1)]
    add edx, ebx
    sub ecx, dword[img_width]
    mov ebx, dword[eax + 4 * ecx]
    add edx, ebx
    add ecx, dword[img_width]
    add ecx, dword[img_width]
    mov ebx, dword[eax + 4 * ecx]
    sub ecx, dword[img_width]
    add edx, ebx
    pushad
    mov ebx, eax
    sub ebx, dword[img]
    mov eax, [blurred_img]
    add eax, ebx
    push eax
    push ebx
    mov eax, edx
    xor edx, edx
    mov ebx, 5
    cdq
    idiv ebx
    mov edx, eax
    pop ebx
    pop eax
    mov dword[eax + 4 * ecx], edx
    popad    
    popad
    add ecx, 2
    cmp ecx, dword[img_width]
    jl task6_next_char
    inc edx
    cmp edx, dword[img_height]
    jl task6_next_line
    
task6_end:     
    push dword[img_height]
    push dword[img_width]
    push dword[blurred_img]
    call print_image
    add esp, 12

    jmp done

    ; Free the memory allocated for the image.
done:
    push DWORD[img]
    call free_image
    add esp, 4

    push DWORD[blurred_img]
    call free_image
    add esp, 4
    
    ; Epilogue
    ; Do not modify!
    xor eax, eax
    leave
    ret
    
bruteforce_singlebyte_xor:
    push ebp
    mov ebp, esp
        
    mov edx, [ebp + 8]
    mov ecx, [img_width]
    mov ebx, [img_height]
    imul ecx, ebx    
    mov ecx, 255

next_char:
    pushad
    sub esp, 4
    mov dword[esp], 0
    push ecx
    call check_char
    add esp, 4
    pop eax
    cmp eax, 0
    jz skip
    mov [ebp + 12], eax
skip:
    popad    
    dec ecx
    cmp ecx, 0
    jg next_char
    mov eax, [ebp + 12]
    leave
    ret
    
check_char:
    push ebp
    mov ebp, esp
    
    mov ebx, [ebp + 8]
    mov ecx, [img_width]
    mov eax, [img_height]
    imul ecx, eax
    mov eax, ecx
    
next_int:
    push ecx
    neg ecx
    add ecx, eax
    push eax
    mov eax, dword[edx + 4 * ecx]
    xor eax, ebx
    cmp eax, 0
    jne not_zero
    
    sub esp, 4
    push ebx
    push ecx
    call found_zero;
    add esp, 8
    pop eax
    
    cmp eax, 0
    jz not_zero
    mov [ebp + 12], eax
    
not_zero:    
    pop eax
    pop ecx
    dec ecx
    cmp ecx, 0
    jg next_int
    
    leave
    ret
    
found_zero:
    push ebp
    mov ebp, esp
    pushad
   
    mov ebx, dword[img_width]
    mov eax, [ebp + 8]
    cdq
    idiv ebx
    imul eax, dword[img_width]
    mov ebx, dword[img]
   
    mov ecx, [ebp + 12]
    sub esp, 4
    mov dword[esp], 0
    push ecx
    call check_string
    add esp, 4
    pop eax
   
    mov [ebp + 16], eax
        
    popad
    leave
    ret
    
check_string:
    push ebp
    mov ebp, esp
    pushad
    
    xor ecx, ecx
    sub edx, 7
    
next_number:  
    add edx, 7
    push edx
    mov edx, [ebx + 4 * eax]
    xor edx, [ebp + 8]
    pushad
    mov edx, ebx
    imul eax, 4
    add edx, eax
    mov ecx, 7
    
check_next:
    neg ecx
    mov bl, byte[edx + 4 * (ecx + 7)]
    xor bl, byte[ebp + 8]    
    mov bh, byte[hint + (ecx + 7)]
    cmp bh, bl
    jnz break_check_next
    
    neg ecx
    dec ecx
    cmp ecx, 0
    jg check_next
    jmp success
    
break_check_next:  
    popad
    mov edx, [img_width]
    imul edx, [img_height]
    cmp eax, edx
    jge end_of_file
    pop edx
    inc eax
    inc ecx
    sub edx, 7
    cmp ecx, edx
    jne next_number
    jmp end_of_file
    
success:
    popad
    pop edx
    pushad
    mov ebx, [img_width]
    cdq
    idiv ebx
    xor ecx, ecx
    mov edx, eax
    imul edx, [img_width]
    pushad
    
print_char:
    mov ebx, dword[img]
    push ecx
    imul ecx, 4
    add ebx, ecx
    pop ecx
    mov eax, [ebx + 4 * edx]
    xor eax, [ebp + 8]
    cmp eax, 0
    jz end_print
    inc ecx
    cmp eax, 0
    jnz print_char
    
end_print:
    popad   
    shl eax, 16
    mov ah, byte[ebp + 8]
    mov [ebp + 12], eax
    add esp, 32 
    jmp end_check_string
    
end_of_file:
    add esp, 4
end_check_string:
    popad
    leave
    ret
    
morse_encrypt:
    push ebp
    mov ebp, esp
    
    mov edx, [ebp + 12]
    xor ecx, ecx
    
task3_next:
    xor ebx, ebx
    mov eax, [edx + ecx]
    
task3_next_letter:
    cmp al, byte[t3 + ebx]
    jz letter_found
    inc ebx
    cmp byte[t3 + ebx], 0
    jnz task3_next_letter
    jmp letter_not_found
    
letter_found:
    pushad
    mov ecx, 1
    
task3_next_code:
    push eax
    push edx
    mov eax, [ebp + 16]
    mov edx, 4
    imul eax, edx
    mov edx, [ebp + 8]
    add edx, eax
    xor eax, eax
    mov al, byte[t3 + ebx + ecx]
    mov dword[edx], eax
    inc dword[ebp + 16]
    pop edx
    pop eax
    inc ecx
    cmp byte[t3 + ebx + ecx], '_'
    jnz task3_next_code
    mov eax, [ebp + 16]
    mov edx, 4
    imul eax, edx
    mov edx, [ebp + 8]
    add edx, eax   
    mov dword[edx], 32
    inc dword[ebp + 16]
    popad
    
letter_not_found:
    inc ecx
    cmp byte[edx + ecx], 0
    jnz task3_next
    mov eax, [ebp + 16]
    mov edx, 4
    imul eax, edx
    mov edx, [ebp + 8]
    add edx, eax   
    mov dword[edx - 4], 0
    leave
    ret
    
lsb_encode:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp + 12]
    dec byte[ebp + 16]
    xor ecx, ecx
task4_next_char:

    mov dl, byte[eax + ecx]
    pushad
    mov ecx, 8
    
task4_next_bit: 
    mov bl, 1
    dec ecx
    shl bl, cl
    and bl, dl
    cmp bl, 0
    jz task4_zero
    
    push eax
    push edx
    mov eax, [ebp + 8]
    mov edx, [ebp + 16]
    or byte[eax + 4 * edx], 1
    inc byte[ebp + 16]
    pop edx
    pop eax
    jmp task4_not_zero
    
task4_zero:
    push eax
    push edx
    mov eax, [ebp + 8]
    mov edx, [ebp + 16]
    and byte[eax + 4 * edx], 0xfe
    inc byte[ebp + 16]
    pop edx
    pop eax

task4_not_zero:
    inc ecx
    dec ecx
    cmp ecx, 0
    jg task4_next_bit
    popad
    inc ecx
    cmp byte[eax + ecx], 0
    jg task4_next_char
    mov ecx, 8
    push eax
    push edx
    
task4_last_byte:
    mov eax, [ebp + 8]
    mov edx, [ebp + 16]
    and byte[eax + 4 * edx], 0xfe
    inc byte[ebp + 16]
    loop task4_last_byte
    pop edx
    pop eax
    leave
    ret
    
lsb_decode:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp + 8]
    mov edx, [ebp + 12]
    add eax, edx
    add eax, edx
    add eax, edx
    add eax, edx
    sub eax, 4
    
task5_next_byte:
    xor edx, edx
    mov ecx, 7
    add eax, 4
    
task5_next:
    mov bl, byte[eax]
    push eax
    mov al, 1
    and al, bl
    shl dl, 1
    or dl, al
    dec ecx
    pop eax
    add eax, 4
    cmp ecx, 0
    jnz task5_next
    
    cmp dl, 0
    jz task5_end
    PRINT_CHAR dl
    cmp dl, 0
    jnz task5_next_byte
    
task5_end:
    NEWLINE
    leave
    ret