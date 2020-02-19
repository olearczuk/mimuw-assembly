section .text
global manipulate_color

; rdi = bytes array with RGB values
; rsi = width
; rdx = height
; rcx = color that should be changed
; r8 = value [-127, 127]
manipulate_color:
    push rdi
    ; Store r8 sign in r9, and abs(r8) in r8
    cmp r8b, 0
    jl neg_value
    pos_value:
        mov r9, 1
        jmp gen_vectors
    neg_value:
        mov r9, -1
        neg r8b

; Generating vectors for modifying image
gen_vectors:
    ; generating first vector
    xorps xmm1, xmm1
    pinsrb xmm1, r8b, 0
    pinsrb xmm1, r8b, 3
    pinsrb xmm1, r8b, 6
    pinsrb xmm1, r8b, 9
    pinsrb xmm1, r8b, 12
    pinsrb xmm1, r8b, 15 ; [r8b,0,0,r8b,0,0,r8b,0,0,r8b,0,0,r8b,0,0,r8b]

    ; generating second vector
    pxor xmm2, xmm2
    pinsrb xmm2, r8b, 2
    pinsrb xmm2, r8b, 5
    pinsrb xmm2, r8b, 8
    pinsrb xmm2, r8b, 11
    pinsrb xmm2, r8b, 14 ; [0,0,r8b,0,0,r8b,0,0,r8b,0,0,r8b,0,0,r8b,0]

    ; generating third vector
    pxor xmm3, xmm3
    pinsrb xmm3, r8b, 1
    pinsrb xmm3, r8b, 4
    pinsrb xmm3, r8b, 7
    pinsrb xmm3, r8b, 10
    pinsrb xmm3, r8b, 13 ; [0,r8b,0,0,r8b,0,0,r8b,0,0,r8b,0,0,r8b,0,0]

    ; Now cycle xmm1, xmm2, xmm3, xmm1, ... forms sequence that holds r8b every 3 elements
    ; Now based on the value of cl (R/G/B) we have to set order of these sequences

    ; R case -> order is already fine
    cmp cl, 1
    je modify_image

    cmp cl, 2
    je G_case

    ; B case -> order should be (xmm2, xmm3, xmm1)
    movdqa xmm0, xmm2
    movdqa xmm2, xmm3 ; xmm2 -> xmm3
    movdqa xmm3, xmm1 ; xmm3 -> xmm1
    movdqa xmm1, xmm0 ; xmm1 -> xmm2
    jmp modify_image

    ; G case -> order should be (xmm3, xmm1, xmm2)
    G_case:
    movdqa xmm0, xmm3
    movdqa xmm3, xmm2 ; xmm3 -> xmm2
    movdqa xmm2, xmm1 ; xmm2 -> xmm1
    movdqa xmm1, xmm0 ; xmm1 -> xmm3


modify_image:
    ; computing size of image height * width * 3
    mov rax, rdx
    mul rsi
    mov rdx, 3
    mul rdx

    main_loop:
        cmp rax, 0
        jle loop_end

        movdqa xmm0, xmm1
        call add_vectors

        movdqa xmm0, xmm2
        call add_vectors

        movdqa xmm0, xmm3
        call add_vectors

        jmp main_loop

    loop_end:
        pop rdi
        ret


add_vectors:
    cmp rax, 0
    jle add_vectors_ret

    movdqa xmm4, [rdi]
    cmp r9, -1
    je sub_value
    paddusb xmm4, xmm0
    jmp update_image_index
    sub_value:
        psubusb xmm4, xmm0

    update_image_index:
        movdqa [rdi], xmm4
        sub rax, 16
        add rdi, 16
    add_vectors_ret:
        ret



