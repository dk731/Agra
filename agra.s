	.text
	.align	2

	.global pixel	
    .type pixel, %function
pixel:
@ r0 - x, r1 - y, r2 - pcol
	push {r0-r11, lr}

	push {r0-r2}
	bl getBuffer
	mov r3, r0
	pop {r0-r2}
	
	ldmfd r3, {r4-r8}	
@ r4 - buffer pointer, r8 - drawing mode
	
	cmp r0, #0
	bmi ENDPIXEL
	cmp r1, #0
	bmi ENDPIXEL
	cmp r0, r5
	bpl ENDPIXEL
	cmp r1, r6
	bpl ENDPIXEL

	mla r9, r5, r1, r0

	lsl r9, #2 @ buffer offset

	ldr r0, [r2] @ foreground color
    ldr r1, [r4, r9] @ backgorund color

	push {r9}

	mov r9, #3
	lsl r9, #30

	and r5, r0, r9
	and r6, r1, r9

	lsr r5, #30
	lsr r6, #30

	add r2, r5, r6
	cmp r2, #4
	bpl OVER

OVER:
	mov r2, #3
CHECKOVEND:
	mov r3, r2
	ror r2, #2

	mov r9, #255
	lsl r9, #2
	orr r9, r9, #3

	and r7, r0, r9
	and r10, r0, r9, lsl #10
	and r11, r0, r9, lsl #20
	
	lsr r10, #10
	lsr r11, #20

	push {r9}
	mov r9, #3
	sub r5, r9, r5
	lsl r5, #1

	lsr r7, r5
	lsr r10, r5
	lsr r11, r5

	pop {r9}
	push {r7, r10, r11} @ load true color foreground

	and r7, r1, r9
	and r10, r1, r9, lsl #10
	and r11, r1, r9, lsl #20
	
	lsr r10, #10
	lsr r11, #20

	push {r9}
	mov r9, #3
	sub r6, r9, r6
	lsl r6, #1

	lsr r7, r6
	lsr r10, r6
	lsr r11, r6

	pop {r9}
	push {r7, r10, r11} @ load true color background

	cmp r8, #0
	beq COPYMODE
	cmp r8, #1
	beq ANDMODE
	cmp r8, #2
	beq ORMODE
	cmp r8, #3
	beq XORMODE
	cmp r8, #4
	beq ADDMODE

	b ENDPIXEL

COPYMODE:
	pop {r7, r10, r11}
	pop {r7, r10, r11}
	mov r2, r0
	b SETBUFFER

ANDMODE:
	pop {r8, r9, r10} @ background rgb
	pop {r5, r6, r7} @ foreground rgb

	mov r0, #255
	lsl r0, #2
	orr r0, #3

	mov r1, #3
	sub r3, r1, r3
	lsl r3, #1

	and r11, r5, r8
	lsl r11, r3

	and r11, r11, r0

	orr r2, r11

	and r11, r6, r9
	lsl r11, r3
	and r11, r11, r0

	orr r2, r11, lsl #10

	and r11, r7, r10
	lsl r11, r3
	and r11, r11, r0

	orr r2, r11, lsl #20

	b SETBUFFER

ORMODE:
	pop {r8, r9, r10} @ background rgb
	pop {r5, r6, r7} @ foreground rgb

	mov r0, #255
	lsl r0, #2
	orr r0, #3

	mov r1, #3
	sub r3, r1, r3
	lsl r3, #1

	orr r11, r5, r8
	lsl r11, r3

	and r11, r11, r0

	orr r2, r11

	orr r11, r6, r9
	lsl r11, r3
	and r11, r11, r0

	orr r2, r11, lsl #10

	orr r11, r7, r10
	lsl r11, r3
	and r11, r11, r0

	orr r2, r11, lsl #20

	b SETBUFFER

XORMODE:
	pop {r8, r9, r10} @ background rgb
	pop {r5, r6, r7} @ foreground rgb

	mov r0, #255
	lsl r0, #2
	orr r0, #3

	mov r1, #3
	sub r3, r1, r3
	lsl r3, #1

	eor r11, r5, r8
	lsl r11, r3

	and r11, r11, r0

	orr r2, r11

	eor r11, r6, r9
	lsl r11, r3
	and r11, r11, r0

	orr r2, r11, lsl #10

	eor r11, r7, r10
	lsl r11, r3
	and r11, r11, r0

	orr r2, r11, lsl #20


	b SETBUFFER

ADDMODE:
	pop {r8, r9, r10} @ background rgb
	pop {r5, r6, r7} @ foreground rgb

	mov r0, #255
	lsl r0, #2
	orr r0, #3

	mov r1, #3
	sub r3, r1, r3
	lsl r3, #1

	add r11, r5, r8
	lsr r11, #1
	lsl r11, r3

	and r11, r11, r0

	orr r2, r11

	add r11, r6, r9
	lsr r11, #1
	lsl r11, r3
	and r11, r11, r0

	orr r2, r11, lsl #10

	add r11, r7, r10
	lsr r11, #1
	lsl r11, r3
	and r11, r11, r0

	orr r2, r11, lsl #20

SETBUFFER:
	pop {r9}
	str r2, [r4, r9]

ENDPIXEL:
	pop {r0-r11, lr}
	bx lr
	
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	.global line
    .type line, %function
line:
	push {r0-r11, lr}

	push {r0-r3}
	bl getBuffer
	mov r4, r0

	pop {r0-r3}
	add r4, r4, #12

@ r5 - dx
@ r6 - sx
@ r7 - dy
@ r8 - sy
@ r9 - err

	subs r5, r0, r2 @ dx
	bmi NEG1

	mov r6, #-1
	b ENDIF1
NEG1:
	mvn r5, r5 @ dx
	add r5, r5, #1
	mov r6, #1 @ sx

ENDIF1:

	subs r7, r1, r3 @ dy
	bpl POS2

NEG2:
	mov r8, #1
	b ENDIF2
POS2:
	beq NEG2
	mvn r7, r7 @ dy
	add r7, r7, #1
	mov r8, #-1 @ sy

ENDIF2:

	add r9, r5, r7 @ err

WHILETRUE:
	push {r2}
	mov r2, r4 @ setup color
	bl pixel
	pop {r2}


	cmp r0, r2 @ if (x0 == x1 && y0 == y1) break;
	bne ENDIFBREAK
	cmp r1, r3
	bne ENDIFBREAK
	b ENDLINE
ENDIFBREAK:
	lsl r10, r9, #1 @ e2

	cmp r10, r7 @ if (dy <= e2)
	bmi ENDIFX @ if less than zero

	add r9, r9, r7
	add r0, r0, r6

ENDIFX:
	cmp r5, r10 @  if (dx >= e2)
	bmi ENDIFY

	add r9, r9, r5
	add r1, r1, r8

ENDIFY:
	b WHILETRUE

ENDLINE:
	pop {r0-r11, lr}
	bx lr


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	.global triangleFill
    .type triangleFill, %function
triangleFill:
	push {r0-r11, lr}
	add sp, sp, #52
	ldmfd sp, {r4, r5}
	sub sp, sp, #52

	
	bl line
	push {r0, r1}
	mov r0, r4
	mov r1, r5
	bl line
	pop {r0, r1}
	push {r2, r3}
	mov r2, r4
	mov r3, r5
	bl line
	pop {r2, r3}

@Find min and max x
	cmp r0, r2
	bmi EELX
	cmp r0, r4
	bmi ELXX
	mov r10, r0

	cmp r2, r4
	bmi ELXXX
	mov r8, r2
	b ENDMMX
ELXXX:
	mov r8, r4
	b ENDMMX
ELXX:
	mov r10, r4
	mov r8, r2
	b ENDMMX
EELX:

	cmp r2, r4
	bmi EELXX
	mov r10, r2
	cmp r0, r4
	bmi EELXXX
	mov r8, r4
	b ENDMMX
EELXXX:
	mov r8, r0
	b ENDMMX
EELXX:
	mov r10, r4
	mov r8, r0
ENDMMX:
	mov r6, r8

@Find min and max y
	cmp r1, r3 
	bmi EELY
	cmp r1, r5
	bmi ELYY
	mov r11, r1
	cmp r3, r5
	bmi ELYYY
	mov r9, r3
	b ENDMMY
ELYYY:
	mov r9, r5
	b ENDMMY
ELYY:
	mov r11, r5
	mov r9, r3
	b ENDMMY
EELY:
	cmp r3, r5
	bmi EELYY
	mov r11, r3
	cmp r1, r5
	bmi EELYYY
	mov r9, r5
	b ENDMMY
EELYYY:
	mov r9, r1
	b ENDMMY
EELYY:
	mov r11, r5
	mov r9, r1
ENDMMY:
	mov r7, r9

FORY:
	cmp r11, r7
	bmi ENDTRIANGLEFILL

	mov r6, r8
FORX:
	cmp r10, r6
	bmi FORXEND

	push {r0-r3}

	bl CHECKIFTRIANGLE

	cmp r0, #0
	beq ENDIFD
	
	bl getBuffer

	add r2, r0, #12
	mov r0, r6
	mov r1, r7

	bl pixel

ENDIFD:
	pop {r0-r3}

	add r6, r6, #1
	b FORX

FORXEND:
	add r7, r7, #1
	b FORY

ENDTRIANGLEFILL:
	pop {r0-r11, lr}
	bx lr

CHECKIFTRIANGLE:
	push {r1-r11, lr}

	sub r9, r2, r0
	sub r10, r5, r1
	mul r8, r9, r10

	sub r9, r1, r3
	sub r10, r4, r0

	mla r8, r9, r10, r8

	sub r10, r2, r0
	sub r11, r7, r1
	mul r9, r10, r11

	sub r10, r1, r3
	sub r11, r6, r0

	bl CHECK
	
	sub r10, r4, r2
	sub r11, r7, r3
	mul r9, r10, r11

	sub r10, r3, r5
	sub r11, r6, r2

	bl CHECK

	sub r10, r0, r4
	sub r11, r7, r5
	mul r9, r10, r11

	sub r10, r5, r1
	sub r11, r6, r4

	bl CHECK

	b IFIN

CHECK:
	mla r9, r10, r11, r9

	mul r9, r8, r9

	cmp r9, #0
	bmi IFOUT
	beq IFOUT

	bx lr
IFIN:
	mov r0, #1
	b ENDCHEKTR
IFOUT:
	mov r0, #0
ENDCHEKTR:
	pop {r1-r11, lr}
	bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	.global circle
    .type circle, %function
circle:
	push {r0-r11, lr}
@ r0 - x1, r1 - y1, r6 - radius, r3 - x, r4 - y, r5 - P, r2 - color
	
	cmp r2, #0
	bmi ENDCIRCLE

	mov r3, r2
	mov r4, #0
	mov r7, #1
	sub r5, r7, r2
	push {r0-r5}
	bl getBuffer
	add r6, r0, #12
	pop {r0-r5}

	mov r8, r2
	mov r2, r6
	mov r6, r8

	stmfd sp!, {r0, r1}
MAINWHILEC:
	add r4, r4, #1

	cmp r5, #0
	bpl ELSEPIF
	add r8, r7, r4, lsl #1
	add r5, r5, r8
	b ENDPIF
ELSEPIF:
	sub r3, r3, #1
	add r8, r7, r4, lsl #1
	sub r8, r8, r3, lsl #1
	add r5, r5, r8
ENDPIF:
	cmp r3, r4
	bpl ENDBIF
	b ENDMAINWHILEC
ENDBIF:
	add r0, r0, r3
	add r1, r1, r4
	bl pixel
	ldmfd sp, {r0, r1}

	sub r0, r0, r3
	add r1, r1, r4
	bl pixel
	ldmfd sp, {r0, r1}

	add r0, r0, r3
	sub r1, r1, r4
	bl pixel
	ldmfd sp, {r0, r1}

	sub r0, r0, r3
	sub r1, r1, r4
	bl pixel
	ldmfd sp, {r0, r1}

	cmp r3, r4
	beq MAINWHILEC

	add r0, r0, r4
	add r1, r1, r3
	bl pixel
	ldmfd sp, {r0, r1}

	sub r0, r0, r4
	add r1, r1, r3
	bl pixel
	ldmfd sp, {r0, r1}

	add r0, r0, r4
	sub r1, r1, r3
	bl pixel
	ldmfd sp, {r0, r1}

	sub r0, r0, r4
	sub r1, r1, r3
	bl pixel
	ldmfd sp, {r0, r1}

	b MAINWHILEC


ENDMAINWHILEC:

	add r0, r0, r6
	bl pixel
	ldmfd sp, {r0, r1}

	sub r0, r0, r6
	bl pixel
	ldmfd sp, {r0, r1}

	add r1, r1, r6
	bl pixel
	ldmfd sp, {r0, r1}

	sub r1, r1, r6
	bl pixel
	ldmfd sp!, {r0, r1}

ENDCIRCLE:
	pop {r0-r11, lr}
	bx lr
	