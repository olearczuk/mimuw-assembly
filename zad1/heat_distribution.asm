section .bss
    width resb 4
    height resb 4
    matrix resb 8
    coolers_temp resb 4
    weight resb 4

section .text

struct_size equ 12

global start
start:
    mov [width], edi
    mov [height], esi
    mov [matrix], rdx,
    movss [coolers_temp], xmm0
    movss [weight], xmm1
    ret

global step
step:
    push rdx
    xor rcx, rcx
    mov eax, [height]
    mul dword [width]
    mov ecx, eax
    push rcx
    call _calculate_cell
    pop rcx
    call _set_new_values
    pop rdx
    ret

global place
place:
    push rbp
    push rbx
    xor r11, r11
    mov r11, struct_size
    xor rbp, rbp
    xor rbx, rbx

_place_heater:
    dec edi
    cmp edi, 0
    jl _place_heater_end

    mov rbp, rdx
    xor rax, rax
    mov eax, [rdx]
    mul dword [width]
    mov rdx, rbp
    add eax, [rsi]             ; index in matrix
    mul r11
    add rax, [matrix]          ; address corresponding to index
    mov rdx, rbp


    fld dword [rcx]
    fst dword [rax]            ; cur_temp = temp
    fstp dword [rax+4]         ; new_temp = temp

    mov dword [rax+8], 1       ; is_heater = 1

    add rsi, 4
    add rdx, 4
    add rcx, 4
    jmp _place_heater

_place_heater_end:
    pop rbx
    pop rbp
    ret

_calculate_cell:
    dec rcx
    cmp rcx, 0
    jl _end_calculate_cell

    push r12
    mov rax, rcx
    mov r11, struct_size        ; r11 holds struct_size value
    mul r11
    add rax, [matrix]
    mov r12, rax                ; r12 holds address of current index

    cmp dword [r12+8], 1        ; checking if this is heater
    je _handle_heater

    call _get_temp_above        ; after each call we substract cur_temp
    fsub dword [r12]

    call _get_temp_right
    fsub dword [r12]

    call _get_temp_below
    fsub dword [r12]

    call _get_temp_left
    fsub dword [r12]

    faddp
    faddp
    faddp                       ; summing all differences

    fmul dword [weight]         ; multiplying by weight

    fadd dword [r12]            ; adding cur_temp

    fstp dword [r12+4]          ; storing result in new_temp field

    pop r12
    jmp _calculate_cell

_handle_heater:
    pop r12
    jmp _calculate_cell

_end_calculate_cell:
    ret

_get_temp_above:
    push rdx

    mov rax, rcx
    sub eax, [width]
    cmp eax, 0
    jl _get_coolers_temp         ; checking if this is first row

    mul r11
    add rax, [matrix]
    fld dword [rax]              ; pushing cur_temp on stack

    pop rdx
    ret

_get_temp_right:
    push rdx

    mov rax, rcx
    inc rax
    mov r9, rax
    xor rdx, rdx
    div dword [width]

    cmp rdx, 0
    je _get_coolers_temp          ; checking if this is last column

    mov rax, r9
    mul r11
    add rax, [matrix]
    fld dword [rax]               ; pushing cur_temp on stack

    pop rdx
    ret

_get_temp_below:
    push rdx

    xor rax, rax
    mov eax, [width]
    mul dword [height]
    mov rdx, rcx
    add edx, [width]
    cmp rdx, rax

    jge _get_coolers_temp         ; checking if this is last row
    
    mov rax, rdx
    mul r11
    add rax, [matrix]
    fld dword [rax]               ; pushing cur_temp on stack

    pop rdx
    ret

_get_temp_left:
    push rdx

    mov rax, rcx
    xor rdx, rdx
    div dword [width]
    cmp rdx, 0
    je _get_coolers_temp          ; checking if this is first column

    mov rax, rcx
    dec rax
    mul r11
    add rax, [matrix]
    fld dword [rax]               ; pushing cur_temp on stack

    pop rdx
    ret
    
_get_coolers_temp:
    fld dword [coolers_temp]      ; pushing cooler's temp on stack

    pop rdx
    ret

_set_new_values:
    dec rcx
    cmp rcx, 0
    jl _end_set_new_values

    mov rax, rcx
    mov r11, struct_size
    mul r11
    add rax, [matrix]             ; rax -> address of current index


    fld dword [rax+4]
    fstp dword [rax]              ; cur_temp = new_value
    jmp _set_new_values

_end_set_new_values:
    ret