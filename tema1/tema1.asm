%include "includes/io.inc"

extern getAST
extern freeAST

section .bss
    ; La aceasta adresa, scheletul stocheaza radacina arborelui
    root: resd 1

section .text
global main

%macro GET_OPERANDS 0   ; marco-ul pune in eax si ebx numerele din copiii unui nod
    mov edx, [ebp + 8]  ; sau in general rezultatele operatiilor acestora
    mov ebx, edx
    add ebx, 4          ; copil stanga
    push dword[ebx]
    call evaluate
    add esp, 4
    push eax
    
    mov edx, [ebp + 8]
    mov ebx, edx
    add ebx, 8          ; copil dreapta
    push dword[ebx]
    call evaluate
    add esp, 4
    push eax
    
    pop ebx
    pop eax
%endmacro

char2digit:             ; transforma un caracter intr-o cifra
    push ebp
    mov ebp, esp
 
    mov eax, [ebp + 8]
    cmp eax, '0'
    jl nondigit
    cmp eax, '9'
    jg nondigit
    sub eax, '0'
    jmp digit
    
nondigit:
    mov eax, -1
    
digit:
    leave
    ret
    
bytes2number:            ; transforma un sir de caractere intr-un numar
    push ebp
    mov ebp, esp
    
    xor ebx, ebx
    xor ecx, ecx
    xor eax, eax
    mov edx, [ebp + 8]
    mov al, byte[edx]
    cmp al, '-'         ; daca primul caracter e - incepem de la ecx = 1
    jnz looplabel
    inc ecx
    
looplabel:
    xor eax, eax
    mov edx, [ebp + 8]
    mov al, byte[edx + ecx]
    push eax
    call char2digit
    add esp, 4
    cmp eax, -1
    jz endloop
    imul ebx, 10
    add ebx, eax 
    inc ecx
    jmp looplabel    
 
endloop: 
    xor eax, eax
    mov edx, [ebp + 8]
    mov al, byte[edx]
    cmp al, '-'         ; numarul se neaga daca e precedat de -
    jnz end
    xor eax, eax
    sub eax, ebx
    mov ebx, eax
    
end:            
    leave
    ret

main:
    ; NU MODIFICATI
    push ebp
    mov ebp, esp
    
    ; Se citeste arborele si se scrie la adresa indicata mai sus
    call getAST
    mov [root], eax
    
    ; Implementati rezolvarea aici:    
    
    push dword[root]
    call evaluate
    add esp, 4
    
    PRINT_DEC 4, eax
    
    ; NU MODIFICATI
    ; Se elibereaza memoria alocata pentru arbore
    push dword [root]
    call freeAST
    
    xor eax, eax
    leave
    ret
    
evaluate:                ; functia recursiva care parcurge graful
    push ebp
    mov ebp, esp
    mov edx, [ebp + 8]
    mov ebx, [edx]  
                         ; se verifica daca data din nod este semnul unei operatii
    cmp byte[ebx], '+'
    jz plus
    
    cmp byte[ebx], '*'
    jz ori
    
    cmp byte[ebx], '/'
    jz imp
    
    cmp byte[ebx], '-'
    jz minus_test
    
is_number:               ; in caz ca e numar se returneaza  
    mov edx, [ebp + 8]
    mov ebx, [edx] 
    push ebx    
    call bytes2number
    add esp, 4
    mov eax, ebx
    jmp endfunction   
                        ; in caz ca e semn se apeleaza functia pentru cei doi copii
                        ; si se aplica operatia corespunzatoare rezultatelor din copii
plus:
    GET_OPERANDS
    add eax, ebx
    jmp endfunction
                         ; un test suplimentar pentru semnul -, datorita existentei
minus_test:              ; numerelor negative
    cmp byte[ebx + 1], '0'
    jl minus
    cmp byte[ebx + 1], '9'
    jg minus
    jmp is_number
    
minus:
    GET_OPERANDS
    sub eax, ebx
    jmp endfunction
    
ori:
    GET_OPERANDS
    imul eax, ebx
    jmp endfunction

imp:
    GET_OPERANDS
    cdq
    idiv ebx    
    jmp endfunction

endfunction:
    leave
    ret