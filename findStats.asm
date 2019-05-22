; **********************************************************************************
section	.data
	; -----
	;  Define standard constants.
	LF		equ	10			; line feed
	CR		equ	13			; carridge return
	NULL		equ	0			; end of string
	TRUE		equ	0
	FALSE		equ	-1
	SUCCESS		equ	0			; Successful operation
	NOSUCCESS	equ	1			; Unsuccessful operation
	STDIN		equ	0			; standard input
	STDOUT		equ	1			; standard output
	STDERR		equ	2			; standard error
	SYS_exit	equ	1			; system call code for terminate
	SYS_fork	equ	2			; system call code for fork
	SYS_read	equ	3			; system call code for read
	SYS_write	equ	4			; system call code for write
	SYS_open	equ	5			; system call code for file open
	SYS_close	equ	6			; system call code for file close
	SYS_create	equ	8			; system call code for file open/create
	; -----
	;  Local variables for combSort() procedure (if any)
	dtwo			dd	2
	ddTen			dd	10
	ddTwelve	dd	12
	dNine			dd	9
	i					dd	0
	gap				dd	0
	swapped		db	TRUE
	; ---------------------------------------------
section .bss
; ********************************************************************************
section	.text
; *******************************************************************************
;  Comb sort function.
;	Note, must update the comb sort algorithm to sort
;	in desending order
; -----
;  HLL Call:
;	combSort(list, len)
;  Arguments Passed:
;	1) list, addr
;	2) length, value
;  Returns:
;	sorted list (list passed by reference)
global	combSort
combSort:
	;	YOUR CODE GOES HERE
	; 1.  Before loops, set gap to length, set swapped to TRUE
	mov eax, esi ;length
	mov dword[gap], eax   ;gap = length
	mov byte[swapped], TRUE  ;rdi = swapped
	;------Outer Loop---------------------------------------------
	; 2.  Outer loop : for gap > 1, or swapped != FALSE
	cSort:
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
			mov eax, dword[rdi+rcx*4] ; eax = array[i]
			mov ebx, dword[rdi+r8*4] ; ebx = array[i+gap]
			cmp eax, ebx
			jle chkNext
			;b.If [i]>[i+gap], switch and swapped == TRUE, continue loop
				mov dword[rdi+rcx*4], ebx
				mov dword[rdi+r8*4], eax
				mov byte[swapped], TRUE
			;c. Increment i
			chkNext:
			inc rcx
			inc r8
			;d. cmp i+gap to length, loop inner if less than
			cmp r8d, esi
			jl innerComb
		;--------End Inner Loop---------------------------------------
		;4.  End Inner :
		;a. Cmp gap to 1, if less than, end loop
		mov r9d, dword[gap]
		cmp r9d, 1
		jg cSort
		;b. Cmp swapped to TRUE, if yes then reloop outer
		cmp byte[swapped], TRUE
		je cSort
	;5.  End Outer : Done
	endComb:
ret
; *******************************************************************************
;  Find the minimum, maximum, median, sum, and average for
;  a list of integers
;  Note, for an odd number of items, the median value is defined as
;  the middle value.  For an even number of values, it is the integer
;  average of the two middle values.
;  Note, assumes the list is already sorted.
; -----
;  HLL Call:
;	basicStats(list, len, min, med, max)
;  Arguments Passed:
;	1) list, addr
;	2) length, value
;	3) minimum, addr
;	4) maximum, addr
;	5) median, addr
;	6) sum, addr
;	7) average, addr
;  Returns:
;	minimum, maximum, median, sum, and average via
;	pass-by-reference (addresses on stack)
global basicStats
basicStats:
  ;Prologue:
  push rbp
  mov rbp, rsp
  dec rsi
  mov eax, dword[rdi+(rsi*4)] ;move last value in sorted array to rax
  mov dword[rcx], eax ;set max value
  mov eax, dword[rdi] ;move first value of sorted array to rax
  mov dword[rdx], eax ;set min value
  inc rsi ;reset length
  mov r12d, 2
  mov eax, esi ;put length in eax for divide
  mov rdx, 0
  div r12d
  mov r13d, eax ;len/2 in r13
  mov eax, dword[rdi+(r13*4)] ;set value at length/2
  cmp edx, 0 ; modulus=0, even number
  jne setMed ;if odd, med is in eax
    dec r13 ;get middleLeft value
    add eax, dword[rdi+(r13*4)] ;add middleLeft to middleRight
    mov rdx, 0
    div r12d ;divide by two
  setMed:
  mov dword[r8], eax ;set med to value in eax
  ;Set sum(r9)
  mov rax, 0
  mov r12, 0
  mov rcx, rsi
  sumMit:
    add eax, dword[rdi+(r12*4)] ;add current indexed value
    inc r12d
    loop sumMit ;loop through array
  mov dword[r9], eax ;set sum to value in eax
  ;Set ave(pop)
  mov rdx, 0
  div esi ;divide sum by length
  mov r12, qword[rbp+16] ; get address of ave
  mov dword[r12], eax ; set ave
  ;Epilogue:
  pop rbp
ret
; *******************************************************************************
;  Find the integer square root of a passed number.
;	iSqrt_est = [ (iNumber/iSqrt_est) + iSqrt_est] / 2
; -----
;  HLL Call:
;	ans = iSqrt(num)
;  Arguments Passed:
;	1) number, value
;  Returns:
;	integer square root (in eax)
global iSqrt
iSqrt:
	mov rcx, 51 ; iterator limit
	mov r15, rdi ; iSqrt = iNumber
	; rdi is iNumber, r8 is iSqrt, rax is operation
	sqrtLoop:
		mov rax, rdi     ; iNumber
		mov rdx, 0
		div r15           ; iNumber / iSqrt
		add rax, r15     ; result + iSqrt
		mov rdx, 0
		div dword[dtwo]	 ; result / 2
		mov r15, rax      ; r8 = iSqrt
		loop sqrtLoop
	mov eax, r15d  ;returns value in eax
ret
; *******************************************************************************
;  Function to calculate the integer standard deviation for an
;  array of numbers.
; -----
;  HLL Call:
;	bValue = iStdDev(list, len)
;  Arguments Passed:
;	1) list, addr
;	2) length, value
;	3) average (integer), value
;  Returns:
;	standard deviation (in eax)
global intStdDev
intStdDev:
	; rdi = array
	; esi = length
	; edx = average
	mov ecx, esi  ; loop from length to 1
	mov r9d, edx ; r9d = average
	mov r8, 0  ; Iterator from 0 to len-1
	mov r11, 0
	mov rdx, 0
	; --------------------
	; Traverse array from 0 to 229
	deviLoop:
		mov rax, 0
		mov eax, dword[rdi+r8*4] ; eax = array[i] from 0
		; Subtract average from each item
		sub eax, r9d	; eax = [i] - ave
		; multiply each item by itelf
		mul eax				; eax = eax^2
		; Divide it by total length
		mov rdx, 0
		div esi
		; Add to total sum
		add r11d, eax  ; r11 = summation
		inc r8d
		cmp r8d, esi
		jb deviLoop
	mov rax, r11
	mov rdi, rax ;move value to argument 1 position
	call iSqrt ;call value returning function
	;results come back from isqrt in eax
ret
; ********************************************************************************
