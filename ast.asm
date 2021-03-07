NULL equ 0
DECIMAL equ 10
NODE_SIZE equ 12
LEFT_SON equ 4
RIGHT_SON equ 8

section .data
    root_node dw NULL
    delim db " ", 0

section .bss
    root resd 1

section .text

; used for checking the corectness
extern check_atoi
extern print_tree_inorder
extern print_tree_preorder
extern evaluate_tree

; external preocedures used for building the AST
extern strlen
extern strtok
extern malloc
extern strdup

global create_tree
global iocla_atoi

; additional function that alocates memory for a tree node and copies the
; string passed as parameter in the allocated information field
alocate_node:
    push ebp
    mov ebp, esp
    mov eax, [ebp + 8]

    ; store the ebx and ecx registers to keep their value
    push ebx
    push ecx

    ; ebx now contains pointer to an array of characters
    mov ebx, eax
    push NODE_SIZE
    call malloc
    mov dword[eax + LEFT_SON], NULL
    mov dword[eax + RIGHT_SON], NULL
	pop edx
    ; ecx contains the node, and eax will contain the duplicated string
    mov ecx, eax
    push ecx
    push ebx
    call strdup

	pop edx
    pop ecx
    mov [ecx], eax
    mov eax, ecx

    ; restore all registers except eax which contains the result
    pop ecx
    pop ebx

    leave
    ret


; equivalent of C function atoi
iocla_atoi:
    push ebp
    mov ebp, esp
    xor edi, edi
    mov edi, 1

    ; gets the input String
    mov eax, dword [ebp + 8]

    ; used strlen to get the size of the String and store it in ecx
    push eax
    call strlen
    mov ecx, eax
    pop eax

    mov edx, ecx
    dec ecx
convert:
    ; iterates through the String in reverse order using ecx register
    xor ebx, ebx
    test ecx, ecx
    jl end_convert

    ; gets each character
    mov bl, byte [eax + ecx]

    ; if a operator character is encountered, mark the number as negative
    cmp bl, '0'
    jl signed_num

    ; converts each character to its numerical equivalent,
    ; then adds it to the stack
    sub bl, '0'
    push ebx
    dec ecx
    jmp convert

end_convert:
    ; set ecx back to string's length
    mov ecx, edx
    mov edx, DECIMAL
    ; eax contains the partial sums and the converted number
    mov eax, 0

get_integer:
    ; we multiply each time by 10 two 32-bit registers. Since all input
    ; numbers can be reprezented on 32-bit, we do not care about edx content
    mul edx
    mov edx, DECIMAL
    ; gets each converted digit from the stack and adds it to the sum
    pop ebx
    add eax, ebx
    loop get_integer
    ;cmp edi, 0
    mul edi

end_atoi:
    ; return the number, which is stored in eax
    leave
    ret
signed_num:
    ; if minus is encountered, then decrement the total number of digits
    ; and set edi value to -1 for multiplication
    mov edi, -1
    dec edx
    jmp end_convert



; auxiliary AST builder functipn
buildTree:
    push ebp
    mov ebp, esp
    mov eax, dword [ebp + 8]
    ; gets the next value from the input string
    mov edx, delim
    push edx
tokenize:
    push eax
    call strtok
    pop ecx
    pop ecx
    ; if the string is null then an additional node must not be created
    cmp eax, 0
    je end
    push eax
    ; to check if the curent value is either operand or operator, we call
    ; strlen, and if the value is bigger than 1, then it is an operator
    call strlen
    mov edx, eax
    pop eax

    cmp edx, 1
    ; if the length is 1, then it can be an operator or a single digit operand
    je check_operand;
is_number:
    ; for numbers, alocate a node and let it to be a leaf node
    push eax
    call alocate_node
    pop edx
    jmp end

not_a_number:

    ; for operators, alocate a node and compute it's descendants
    push eax
    call alocate_node
    mov esi, eax
    pop edx

    push esi
    push NULL

    call buildTree
    pop edx
    pop esi
    ; set the left and right son to their corresponding addresses
    mov [esi + LEFT_SON], eax

    push eax
    push esi
    push NULL
    call buildTree
    pop edx
    pop esi
    mov [esi + RIGHT_SON], eax

    pop eax
    pop edx
    mov eax, esi

end:
    leave
    ret

check_operand:
    ; check if the single char value is a digit or not
    mov cl, byte [eax]
    cmp cl, '0'
    jl not_a_number
    jmp is_number


; main function
create_tree:
    enter 0, 0
    xor eax, eax
    ; the function only modifies eax, so we save all registers
    pusha

    mov eax, dword [ebp + 8]
    push eax

    ; call the auxiliary function
    call buildTree
    ; store the resulting root node address in memory
    mov [root_node], eax

    pop eax

    popa
    ; store the final result in eax
    mov eax, dword [root_node]
    leave
    ret