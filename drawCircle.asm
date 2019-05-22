; -----
;  Function getParams()
;	Gets, checks, converts, and returns command line arguments.
;  Function drawCircle()
;	Plots provided circle function
; ---------------------------------------------------------
; ---------------------------------------------------------
section  .data
	; -----
	;  Define standard constants.
	TRUE		   equ	1
	FALSE		   equ	0
	SUCCESS		 equ	0			; successful operation
	NOSUCCESS	 equ	1
	STDIN		   equ	0			; standard input
	STDOUT		 equ	1			; standard output
	STDERR		 equ	2			; standard error
	SYS_read	 equ	0			; code for read
	SYS_write	 equ	1			; code for write
	SYS_open	 equ	2			; code for file open
	SYS_close	 equ	3			; code for file close
	SYS_fork	 equ	57			; code for fork
	SYS_exit	 equ	60			; code for terminate
	SYS_creat	 equ	85			; code for file open/create
	SYS_time	 equ	201			; code for get time
	LF		     equ	10
	SPACE		   equ	" "
	NULL		   equ	0
	ESC		     equ	27
	; -----
	;  OpenGL constants
	GL_COLOR_BUFFER_BIT	 equ	16384
	GL_POINTS		     equ	0
	GL_POLYGON		   equ	9
	GL_PROJECTION		 equ	5889
	GLUT_RGB		     equ	0
	GLUT_SINGLE		   equ	0
	; -----
	;  Define program constants.
	SP_MIN		equ	1
	SP_MAX		equ	1000
	DC_MIN		equ	0
	DC_MAX		equ	16777215
	BK_MIN		equ	0
	BK_MAX		equ	16777215
	; -----
	;  Local variables for getParams procedure.
	STR_LENGTH	equ	12
	errUsage	  db	"Usage: circles -sp <dozenalNumber> -dc <dozenalNumber> "
			        db	"-bk <dozenalNumber>"
			        db	LF, NULL
	errBadCL	  db	"Error, invalid or incomplete command line argument."
			        db	LF, NULL
	errSPsp		  db	"Error, speed specifier incorrect."
			        db	LF, NULL
	errSPvalue	db	"Error, speed value must be between 1 and 6E4(12)."
			        db	LF, NULL
	errDCsp		  db	"Error, draw color specifier incorrect."
			        db	LF, NULL
	errDCvalue	db	"Error, draw color value must be between "
			        db	"0 and 5751053(12)."
			        db	LF, NULL
	errBKsp		  db	"Error, background color specifier incorrect."
			        db	LF, NULL
	errBKvalue	db	"Error, background color value must be between "
			        db	"0 and 5751053(12)."
			        db	LF, NULL
	errDCBKsame	db	"Error, draw color and background color can "
			        db	"not be the same."
			        db	LF, NULL
	; -----
	;  Local variables for draw circles routine.
red		    dd	0			; 0-255
	green		  dd	0			; 0-255
	blue		  dd	0			; 0-255
	pi		    dq	3.14159265358979	; constant
	fltZero		dq	0.0
	fltOne		dq	1.0
	fltTwo		dq	2.0
	i         dq  0.0
	t		      dq	0.0			; loop variable
	tStep		  dq	0.001			; t step
	x		      dq	0.0			; current x
	y		      dq	0.0			; current y
	speed		  dq	0.0			; circle deformation speed
	s		      dq	0.0
	scale		  dq	10000.0			; scale factor for speed
	tmp1		  dq	0.0
	tmp2		  dq	0.0
	tmp3		  dq	0.0
	; ------------------------------------------------------------

section  .text
; -----Open GL routines-----
extern glutInit, glutInitDisplayMode, glutInitWindowSize
	extern glutInitWindowPosition
	extern glutCreateWindow, glutMainLoop
	extern glutDisplayFunc, glutIdleFunc, glutReshapeFunc, glutKeyboardFunc
	extern glutSwapBuffers
	extern gluPerspective
	extern glClearColor, glClearDepth, glDepthFunc, glEnable, glShadeModel
	extern glClear, glLoadIdentity, glMatrixMode, glViewport
	extern glTranslatef, glRotatef, glBegin, glEnd, glVertex3f, glColor3f
	extern glVertex2f, glVertex2i, glColor3ub, glOrtho, glFlush, glVertex2d
	extern glutPostRedisplay
	extern	cos, sin, cosf, sinf
; *******printString*********************************************************
;  Generic procedure to display a string to the screen.
;  String must be NULL terminated.
;  Algorithm:
;	Count characters in string (excluding NULL)
;	Use syscall to output characters
;  Arguments:
;	1) address, string
;  Returns:
;	nothing
global	printString
printString:
	push	rbp
	mov	rbp, rsp
	push	rbx
	push	rsi
	push	rdi
	push	rdx
	; -----
	;  Count characters in string.
	mov	rbx, rdi			; str addr
	mov	rdx, 0
	strCountLoop:
		cmp	byte [rbx], NULL
		je	strCountDone
		inc	rbx
		inc	rdx
		jmp	strCountLoop
	strCountDone:
		cmp	rdx, 0
		je	prtDone
	; -----
	;  Call OS to output string.
	mov	rax, SYS_write			; system code for write()
	mov	rsi, rdi			; address of characters to write
	mov	rdi, STDOUT			; file descriptor for standard in
	syscall					; system call
	; -----
	;  String printed, return to calling routine.
	prtDone:
	pop	rdx
	pop	rdi
	pop	rsi
	pop	rbx
	pop	rbp
ret

; **********getParams********************************************************
;  Boolean value returning function getParams()
;	Gets draw speed, draw color, and background color
;	from the line argument.
;	Performs error checking, converts ASCII/Dozenal to integer.
;	Command line format (fixed order):
;	  "-sp <dozenalNumber> -dc <dozenalNumber> -bk <dozenalNumber>"
; In debugger type this after run :
; ./circles -sp 7 -dc 5750x80 -bk 16994
; ./circles -sp 7 -dc 571e140 -bk 0
; ./circles -sp 35 -dc 1354104520 -bk 0
; 7 args
; arg2 = "-sp"
; arg3 = speed, dword
; arg4 = "-dc"
; arg5 = draw color, dword
; arg6 = "-bk"
; arg7 = background color, dword
; -----
;  Arguments:
;	1) ARGC, double-word, value
;	2) ARGV, double-word, address
;	3) speed, double-word, address
;	4) draw color, double-word, address
;	5) background color, double-word, address
global getParams
getParams:
	push rbp			 ; Prolougue
	mov  rbp, rsp  ; rbp points to stack
	;--------Starting declarations------------
	mov  rbx, rsi  ; rbx points to argument vector
	mov  r12, 0		 ; iterator/counter for vector arguements
	mov  r13, 0		 ; Holder for arguments in vectors
	;---------Check Argc---------
	cmp  rdi, 7   ;Check for right number of arg count
	je argSpeed
	startError:
		cmp rdi, 1   ;if only one argument, the file name, usage error
		ja badErr
			mov rdi, errUsage
			call printString
			mov rax, FALSE
			jmp funcOut	;End function with false in rax and printed error.
	badErr:
		mov rdi, errBadCL ;has more than one arguement, but not == 13
		call printString
		mov rax, FALSE
		jmp funcOut	;Ends function with false in rax and printed error
	;--------- -sp ----------------
	argSpeed:
		add r12, 8 ;iterator for whole vector set to arg after filename
		mov r13, qword[rbx+r12] ;Location of "-a"
		cmp byte[r13], '-'
		jne charSpErr ;check each character of arg specs
			cmp byte[r13+1], 's'
			jne charSpErr
				cmp byte[r13+2], 'p'
				jne charSpErr
					cmp byte[r13+3], NULL
					je speedValue ;if they're all equal skip ahead
	charSpErr:
		mov rdi, errSPsp
		call printString
		mov rax, FALSE
		jmp funcOut ;set rax to false and end function if spec is wrong
	;--------Check speed and Convert--------
	speedValue:
		add r12, 8 ;get argument associated with last spec
		mov rdi, qword[rbx+r12] ;place value into argument for func call
		mov esi, edx ;mov register to recieve cvt decimal into 2nd arg
		call dozenal2int ;call function
		cmp rax, FALSE ;check if function was successful
		je speedRngErr ;if not, the number must have had bad chars
		cmp dword[rsi], SP_MAX
		ja speedRngErr ;print error if A is > a_max
		cmp dword[rsi], SP_MIN
		jae argDraw ;if the number is above the min, move on
		speedRngErr:
			mov rdi, errSPvalue
			call printString
			mov rax, FALSE
			jmp funcOut ;print error, rax to false, end function
	;--------- -dc ----------------
	argDraw:
		mov rax, FALSE ;rax set to true in last part if it reached here
		add r12, 8 ;mov up to the next arg in vector
		mov r13, qword[rbx+r12] ;Location of "-dc"
		cmp byte[r13], '-'
		jne charDcErr
			cmp byte[r13+1], 'd'
			jne charDcErr
				cmp byte[r13+2], 'c'
				jne charDcErr
					cmp byte[r13+3], NULL
					je drawValue ;move to convert part if spec built correctly
	charDcErr:
		mov rdi, errDCsp
		call printString
		mov rax, FALSE
		jmp funcOut ;print error, set rax to false, end function
	;--------Check draw color and Convert--------
	drawValue:
		add r12, 8
		mov rdi, qword[rbx+r12] ;moves value to rbx
		mov rsi, rcx
		call dozenal2int
		cmp rax, FALSE
		je dcRangeErr
		cmp dword[rsi], DC_MIN
		jb dcRangeErr
		cmp dword[rsi], DC_MAX
		jbe argBckGrnd
		dcRangeErr:
			mov rdi, errDCvalue
			call printString
			mov rax, FALSE
			jmp funcOut ;if value is wrong, print error and set rax to false
	;--------- -bk ----------------
	argBckGrnd:
		mov rax, FALSE  ;Reset rax to false for new tests
		add r12, 8  ;move up in vector
		mov r13, qword[rbx+r12] ;Location of "-bk"
		cmp byte[r13], '-'
		jne charBkErr
			cmp byte[r13+1], 'b'
			jne charBkErr
				cmp byte[r13+2], 'k'
				jne charBkErr
					cmp byte[r13+3], NULL
					je bckgrndValue ;Send to error label if incorrect
	charBkErr:
		mov rdi, errBKsp
		call printString
		mov rax, FALSE
		jmp funcOut  ;Print error, set rax to false, end program
	;--------Check bckgrnd Color and Convert--------
	bckgrndValue:
		add r12, 8  ;Move up a space in vector
		mov rdi, qword[rbx+r12] ;Location of length value
		mov rsi, r8 ;Place for return value to go
		call dozenal2int
		cmp rax, FALSE ;If cvt function finds an error
		je bkRngErr
		cmp dword[rsi], BK_MIN ;If less than min
		jb bkRngErr
		cmp dword[rsi], BK_MAX ;if over max, send error
		jbe finalChk ;Otherwise, onto the next
		bkRngErr:
			mov rdi, errBKvalue
			call printString
			mov rax, FALSE
			jmp funcOut ;Print error, end program
	;-----------Cmp bck color to drw color--------
	finalChk:
		mov r11d, dword[rsi]
		cmp r11d, dword[rcx]
		jne goodEnd
			mov rdi, errDCBKsame
			call printString
			mov rax, FALSE
			jmp funcOut
	goodEnd:
		mov rax, TRUE
	funcOut: ;End program jump spot
	pop rbp
ret

global dozenal2int
dozenal2int:
	push r13
	push r14
	push r15
	push rax
	mov rax, 0  ;for multiply
	mov r13, 0  ;iterator/counter
	mov r14, 12 ;dozenal conversion
	mov r15, 0  ;byte holder
	cvt2Dec:
		mov r15b, byte[rdi+r13] ;gets the first byte of the argument
    cmp r15b, NULL
    je chkValue    ;Reach NULL, finish loop
    cmp r15b, 120
    ja wrongVal   ;If char > "x", not a valid char
    cmp r15b, 48
    jb wrongVal   ;If char < "0", invalid
    cmp r15b, 57
    ja chkCapLet   ;If 48 < char < 57, number
        sub r15b, "0" ;Convert to number
        jmp addDec    ;Add to decimal number
	chkCapLet:
    ; Found to be 57 < char < 121, still needs to be exact:
      cmp r15b, "X"
      je isXLett
      cmp r15b, "x"   ;Check for valid input, between A and D
      je isXLett
      cmp r15b, "E"   ;Check for valid input, between A and D
      je isELett
      cmp r15b, "e"   ;Check for valid input, between A and D
      je isELett
        jmp wrongVal  ;If reaches here, invalid char
    isXLett:
      mov r15b, 10
      jmp addDec
    isELett:
      mov r15b, 11
  addDec:
    mul r14d       ;Mul rax by 12 to move it up for new num
    add eax, r15d  ;Add current num from string to decimal
		inc r13
		jmp cvt2Dec ;loop
	;------------End Conversion--------------
	chkValue:
		mov dword[rsi], eax ;move value into return register
		pop rax ;pop rax for boolean
		mov rax, TRUE
		jmp endOfConv
	wrongVal:
		pop rax ;pop rax for boolean
		mov rax, FALSE ;set rax to false
	endOfConv:
	pop r15
	pop r14
	pop r13
ret
; ********drawCircles**********************************************************
;  Draw circles function.
;  Plots the following equations:
;	for (s=0.0; s<=1.0; sStep)
;		for (t=0.0; t<(2*pi); t+=tStep)
;			x = (1-s)*cos(t+pi*s)+s*cos(2*t)
;			y = (1-s)*sin(t+pi*s)-s*sin(2*t)
;		plot
; -----
;  Global variables accessed.
common	drawSpeed	1:4			; speed
common	drawColor	1:4			; draw color
common	backColor	1:4			; background color
; -----
global drawCircles
drawCircles:
	; -----
	;  Save registers
	push	rbp				; Note, rbp is changed indirectly
	push	rbx				; leave these push's/pop's as is
	push	r12
	; -----
	; Prepare for drawing
	; glClear(GL_COLOR_BUFFER_BIT);
	mov	rdi, GL_COLOR_BUFFER_BIT
	call	glClear
	; -----
	;  set draw colors, red, green and blue.
		mov r8, 0
		mov r8d, dword[drawColor]
		mov byte[blue], r8b
		shr r8d, 8
		mov byte[green], r8b
		shr r8d, 8
		mov byte[red], r8b
	; ----
	;  Set openGL drawing color.
		mov	edi, dword [red]
		mov	esi, dword [green]
		mov	edx, dword [blue]
		call glColor3ub			; call glColor3ub(r,g,b)
	; ----
	;  Init drawing canvas.
	; glBegin();
	mov	rdi, GL_POINTS
	call	glBegin
	; -----
	;  Set speed based on user entered drawSpeed
	;	speed = drawSpeed / 10000
		cvtsi2sd xmm0, dword[drawSpeed]
		divsd xmm0, qword[scale]
		movsd qword[speed], xmm0 	;speed = drawSpeed/scale
	;Lp--------------------------------------
	; iterate from t = 0 to t = 2pi
		movsd xmm0, qword[fltTwo]
		mulsd xmm0, qword[pi]
		movsd qword[i], xmm0  ; i = 2*pi
		movsd xmm0, qword[fltZero]
		movsd qword[t], xmm0  ; t = 0
	; -----
	;  Plot (x,y) based on provided equations
	;	x = (1-s)*cos(t+pi*s)+s*cos(2*t)
	;	y = (1-s)*sin(t+pi*s)-s*sin(2*t)
		;-- Set commons --
		; set 1-s for common (before loop, s not changed)
		movsd xmm0, qword[fltOne]
		subsd xmm0, qword[s]
		movsd qword[tmp1], xmm0  ;tmp1 = (1-s)
	circleLoop:
		; set t+pi*s for common
		movsd xmm0, qword[pi]
		mulsd xmm0, qword[s]
		addsd xmm0, qword[t]
		movsd qword[tmp2], xmm0 ;tmp2 = t+(pi*s)
		; set 2 * t for common
		movsd xmm0, qword[t]
		mulsd xmm0, qword[fltTwo]
		movsd qword[tmp3], xmm0 ; tmp3 = (2*t)
		;-----------
		; x = tmp1 * cos(tmp2) + s* cos(tmp3)
		movsd xmm0, qword[tmp2]
		call cos
		mulsd xmm0, qword[tmp1]
		movsd qword[x], xmm0   ; (1-s) * cos(t+pi*s)
		movsd xmm0, qword[tmp3]
		call cos
		mulsd xmm0, qword[s]
		addsd xmm0, qword[x]	; + s*cos(2*t)
		movsd qword[x], xmm0
		;-----------
		; y = tmp2 * sin(tmp1) - s* sin(2*t)
		movsd xmm0, qword[tmp2]
		call sin
		mulsd xmm0, qword[tmp1]
		movsd qword[y], xmm0   ; (1-s) * cos(t+pi*s)
		movsd xmm0, qword[tmp3]
		call sin
		mulsd xmm0, qword[s]
		subsd xmm0, qword[y]	; - s*cos(2*t)
		movsd qword[y], xmm0
		;-----------------
	;	plot(x1,y1);
		movsd xmm0, qword[x]			;Arg 1 for function call
		movsd xmm1, qword[y]			;Arg 2 for function call
		call glVertex2d						;Function call plotting points
		;----------
		;Check loop condition and end:
		movsd xmm0, qword[t]
		addsd xmm0, qword[tStep]  ; t + tStep
		movsd qword[t], xmm0
		ucomisd xmm0, qword[i] ;until t = 2pi
		jbe circleLoop
	; -----
	;  End drawing operations and flush unwritten operations.
	;  Set-up for next call.
	call	glEnd
	call	glFlush
	call	glutPostRedisplay
	; -----
	;  Update speed for next call.
		movsd xmm0, qword[s]
		addsd xmm0, qword[speed]
	; -----
	;  Check if s is > 1.0 and if so, reset s to 0.0
		ucomisd	xmm0, qword [fltOne]
		jbe drawNew
			movsd xmm0, qword[fltZero]  ; If s >= 1, set to 0
		drawNew:
			movsd qword[s], xmm0
	; -----
	;  Restore registers and return to main.
	pop	r12
	pop	rbx
	pop	rbp
ret
; ******************************************************************
