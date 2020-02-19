.text
.global generate_pgm
/*
image  r0
size   r1
R      r2
G      r3
B      [fp, #4]
*/
generate_pgm:
	push {r11}
	add r11, sp, #0

	ldr r4, [fp, #4] @ B
	mov r5, #0       @ index in image
_loop:
	cmp r5, r1       @ check if processed whole image
	bge _end
	mov r6, #0       @ accumulator

	mov r8, r5
	lsl r8, #1
	add r8, r5       @ 3 * index
	add r8, r0       @ image[index]

	ldrb r9, [r8]    @ image[index].r
	mul r9, r2
	lsr r9, #8       @ image[index].r * R / 256
	add r6, r9       @ add to accumulator

	add r8, #1
	ldrb r9, [r8]    @ image[index].g
	mul r9, r3
	lsr r9, #8       @ image[index].g * G / 256
	add r6, r9       @ add to accumulator

	add r8, #1
	ldrb r9, [r8]    @ image[index].b
	mul r9, r4
	lsr r9, #8       @ image[index].b * B / 256
	add r6, r9       @ add to accumulator

	sub r8, #2       @ image[index].r
	strb r6, [r8]    @ image[index].r = accumulator
	add r5, #1       @ index++
	b _loop

_end:
	add sp, r11, #0
	pop {r11}
	bx lr
