;  Sort a list of number using the comb sort algorithm.
;  Also finds the minimum, median, maximum, sum, and average of the list.
; **********************************************************************************
;  Comb Sort Algorithm:
;  void function combSort(array, length)
;     gap = length
;
;     outter loop until gap = 1 OR swapped = false
;         gap = (gap * 10) / 12	     			// update gap for next sweep
;         if gap < 1
;           gap = 1
;         end if
;
;         i = 0
;         swapped = false
;
;         inner loop until i + gap >= length	       // single comb sweep
;             if  array[i] > array[i+gap]
;                 swap(array[i], array[i+gap])
;                 swapped = true
;             end if
;             i = i + 1
;         end inner loop
;      end outter loop
;  end function
; **********************************************************************************

;  Macro, "int2dozenal", to convert a signed base-10 integer into
;  an ASCII string representing the Duodecimal value.
;	YOUR CODE GOES HERE
%macro	int2dozenal	3
	;	YOUR CODE GOES HERE
	  mov esi, dword[ddTwelve] ;Variable for dividing decimal
		mov ecx, 7
	  mov r8, 0
	  mov r8b, NULL ;rest of string added on top of this
	  mov eax, %1  ;integer
	  mov r10, "+"
	  cmp eax, 0
	  jg %%cvtDecLp
			mov r10, -1
			imul r10
	    mov r10, "-"
	  %%cvtDecLp:
	  	mov edx, 0 ;Clear modulus
	  	div dword[ddTwelve] ;Divide decimal by 12
			dec ecx
	  	cmp edx,9
	  	jg %%chkCvtLet
	  		add edx, "0" ;Convert to string
	  		jmp %%addChar
	  	%%chkCvtLet:
	      cmp edx, 10
	      je %%cvtXLett
	        mov edx, "E"
	        jmp %%addChar
	      %%cvtXLett:
	    		mov edx, "X" ;Convert to string
	  	%%addChar:
	  		shl r8, 0x08 ;shift left for new byte to be added
	  		mov r8b, dl
	    cmp eax, 0 ;When complete, end loop.
	    jne %%cvtDecLp
	  	shl r8, 0x08
	    mov r8b, r10b
	  %%endVert:
		cmp ecx, 1
		jl %%storeDuo
		shl r8, 0x08
		add r8b, 32
		loop %%endVert
		%%storeDuo:
		mov [%2], r8
%endmacro
; --------------------------------------------------------------
;  Simple macro to display a string to the console.
;	Call:	printString  <stringAddr>
;	Arguments:
;		%1 -> <stringAddr>, string address
;  Count characters (excluding NULL).
;  Display string starting at address <stringAddr>
%macro	printString	1
	push	rax					; save altered registers
	push	rdi					; not required, but
	push	rsi					; does not hurt.  :-)
	push	rdx
	push	rcx
	mov	rdx, 0
	mov	rdi, %1
	%%countLoop:
	cmp	byte [rdi], NULL
	je	%%countLoopDone
	inc	rdi
	inc	rdx
	jmp	%%countLoop
	%%countLoopDone:
	mov	rax, SYS_write				; system call for write (SYS_write)
	mov	rdi, STDOUT				; standard output
	mov	rsi, %1					; address of the string
	syscall						; call the kernel
	pop	rcx					; restore registers to original values
	pop	rdx
	pop	rsi
	pop	rdi
	pop	rax
%endmacro
; ****************************************************************
section	.data
	; -----
	;  Define constants.
	TRUE			equ	1
	FALSE			equ	0
	SUCCESS		equ	0			; successful operation
	NOSUCCESS	equ	1			; unsuccessful operation
	STDIN			equ	0			; standard input
	STDOUT		equ	1			; standard output
	STDERR		equ	2			; standard error
	SYS_read	equ	0			; system call code for read
	SYS_write	equ	1			; system call code for write
	SYS_open	equ	2			; system call code for file open
	SYS_close	equ	3			; system call code for file close
	SYS_fork	equ	57			; system call code for fork
	SYS_exit	equ	60			; system call code for terminate
	SYS_creat	equ	85			; system call code for file open/create
	SYS_time	equ	201			; system call code for get time
	LF				equ	10
	SPACE			equ	" "
	NULL			equ	0
	ESC				equ	27
	LIMIT			equ	10000
	MAX_STR_LENGTH	equ	15
	; -----
	;  Provided data
	array		dd	 1113, -1232,  2146,  1376,  5120,  2356,  3164,  4565, -3155,  3157
					dd	-2759,  6326,   171,  -547, -5628, -7527,  7569,  1177,  6785, -3514
					dd	 1001,   128, -1133,  9105,  3327,   101, -2115, -1108,     1,  2115
					dd	 1227, -1226,  5129,  -117,  -107,   105,  3109,  9999,  1150,  3414
					dd	-1107,  6103,  1245,  5440,  1465,  2311,   254,  4528, -1913,  6722
					dd	 4149,  2126, -5671,  7647, -4628,   327,  2390,  1177,  8275, -5614
					dd	 3121,  -415,   615,   122,  7217,   421,   410,  1129,  812,   2134
					dd	-1221,  2234, -7151,  -432,   114,  1629,  2114,  -522,  2413,   131
					dd	 5639,   126,  1162,   441,   127,   877,   199,  5679, -1101,  3414
					dd	 2101,  -133,  5133,  6450, -4532, -8619,   115,  1618,  9999,  -115
					dd	-1219,  3116,  -612,  -217,   127, -6787, -4569,  -679,  5675,  4314
					dd	 3104,  6825,  1184,  2143,  1176,   134,  5626,   100,  4566,  2346
					dd	 1214, -6786,  1617,   183, -3512,  7881,  8320,  3467, -3559,  -190
					dd	  103,  -112,    -1,  9186,  -191,  -186,   134,  1125,  5675,  3476
					dd	-1100,     1,  1146,  -100,   101,    51,  5616, -5662,  6328,  2342
					dd	 -137, -2113,  3647,   114,  -115,  6571,  7624,   128,  -113,  3112
					dd	 1724,  6316,  4217, -2183,  4352,   121,   320,  4540,  5679,  1190
					dd	-9130,   116,  5122,   117,   127,  5677,   101,  3727,     0,  3184
					dd	 1897, -6374,  1190,    -1,  1224,     0,   116,  8126,  6784,  2329
					dd	-2104,   124, -3112,   143,   176, -7534, -2126,  6112,   156,  1103
					dd	 1153,   172,  1146, -2176,  -170,   156,   164,  -165,   155,  5156
					dd	 -894, -4325,   900,   143,   276,  5634,  7526,  3413,  7686,  7563
					dd	  511,  1383, 11133,  4150,   825,  5721,  5615, -4568, -6813, -1231
					dd	 9999,   146,  8162,  -147,  -157,  -167,   169,   177,   175,  2144
					dd	-1527, -1344,  1130,  2172,  7224,  7525,   100,     1,  2100,  1134
					dd	  181,   155,  2145,   132,   167,  -185,  2150,  3149,  -182,  1434
					dd	  177,    64, 11160,  4172,  3184,   175,   166,  6762,   158, -4572
					dd	-7561, -1283,  5133,  -150,  -135,  5631,  8185,   178,  1197,  1185
					dd	 5649,  6366,  3162,  5167,   167, -1177,  -169, -1177,  -175,  1169
					dd	 3684,  9999, 11217,  3183, -2190,  1100,  4611, -1123,  3122,  -131
	length		dd	300
	minimum		dd	0
	median		dd	0
	maximum		dd	0
	sum				dd	0
	average		dd	0
	; -----
	;  Misc. data definitions (if any).
	dtwo			dd	2
	ddTen			dd	10
	ddTwelve	dd	12
	dNine			dd	9
	i					dd	0
	gap				dd	0
	swapped		db	TRUE
	; -----
	;  Provided string definitions.
	newLine		db	LF, NULL
	hdr				db	"CS 218 - Assignment #7"
						db	LF, LF, NULL
	hdrMin		db	"Minimum: ", NULL
	hdrMax		db	"Maximum: ", NULL
	hdrMed		db	"Median:  ", NULL
	hdrSum		db	"Sum:     ", NULL
	hdrAve		db	"Average: ", NULL
	; **********************************************************************************
	section .bss
	tempString	resb	MAX_STR_LENGTH
; ****************************************************************
section	.text
global	_start
_start:
; ******************************
;  Sort data using Comb sort.
;  Find statistical information.
; 1.  Before loops, set gap to length, set swapped to TRUE
mov eax, dword[length]
mov dword[gap], eax   ;gap = length
mov byte[swapped], TRUE  ;rdi = swapped
;------Outer Loop---------------------------------------------
; 2.  Outer loop : for gap > 1, or swapped != FALSE
combSort:
	;a. Update gap to == (gap*10)/12
	mov eax, dword[gap]
	imul dword[ddTen]
	idiv dword[ddTwelve]
	;b. Cmp gap to 1, if less, set gap = 1
	cmp eax, 1
	jg gapSet
		mov eax, 1
	gapSet:
	mov dword[gap], eax
	;c. set i = 0
	mov rcx, 0
	;d. set swapped == FALSE
	mov byte[swapped], FALSE
	;3.  Inner Loop : for i+gap >= length
	mov r8d, dword[gap]
	;------Inner Loop---------------------------------------------
	innerComb:
		;a. cmp array[i] to array[i+gap]
		mov eax, dword[array+rcx*4] ; eax = array[i]
		mov ebx, dword[array+r8*4] ; ebx = array[i+gap]
		cmp eax, ebx
		jle chkNext
		;b.If [i]>[i+gap], switch and swapped == TRUE, continue loop
			mov dword[array+rcx*4], ebx
			mov dword[array+r8*4], eax
			mov byte[swapped], TRUE
		;c. Increment i
		chkNext:
		inc rcx
		inc r8
		;d. cmp i+gap to length, loop inner if less than
		cmp r8d, dword[length]
		jl innerComb
	;--------End Inner Loop---------------------------------------
	;4.  End Inner :
	;a. Cmp gap to 1, if less than, end loop
	mov r9d, dword[gap]
	cmp r9d, 1
	jg combSort
	;b. Cmp swapped to TRUE, if yes then reloop outer
	cmp byte[swapped], TRUE
	je combSort
;5.  End Outer : Done
endComb:
;-----End Outer Loop-----------------------------------------
;-------------
; Get Minumum:
mov eax, dword[array]
mov dword[minimum], eax
mov ecx, dword[length]
dec ecx
;-------------
; Get Maximum:
mov ebx, dword[array+rcx*4]
mov dword[maximum], ebx
;-------------
; Quick Loop for sum:
getValues:
	add eax, dword[array+rcx*4]
loop getValues
mov dword[sum], eax
;-------------
; Get Average:
cdq
idiv dword[length]
mov dword[average], eax
;-------------
; Get Median:
mov eax, dword[length]
cdq
idiv dword[dtwo]
mov rsi, rax
mov eax, dword[array+rsi*4]
cmp edx, 0
jne oddLength
	dec rsi
	add eax, dword[array+rsi*4]
	cdq
	idiv dword[dtwo]
oddLength:
mov dword[median], eax
;-------------
; ******************************
;  Display results to screen in duodecimal.
printString	hdr
	printString	hdrMin
	int2dozenal	dword [minimum], tempString, MAX_STR_LENGTH
	printString	tempString
	printString	newLine
	printString	hdrMax
	int2dozenal	dword [maximum], tempString, MAX_STR_LENGTH
	printString	tempString
	printString	newLine
	printString	hdrMed
	int2dozenal	dword [median], tempString, MAX_STR_LENGTH
	printString	tempString
	printString	newLine
	printString	hdrSum
	int2dozenal	dword [sum], tempString, MAX_STR_LENGTH
	printString	tempString
	printString	newLine
	printString	hdrAve
	int2dozenal	dword [average], tempString, MAX_STR_LENGTH
	printString	tempString
	printString	newLine
	printString	newLine
; ******************************
;  Done, terminate program.
last:
	mov	rax, SYS_exit
	mov	rbx, SUCCESS
	syscall
