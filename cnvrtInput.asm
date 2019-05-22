; ************************************************************************************
section	.data
  ; -----
  ;  Define standard constants.
  TRUE		      equ	1
  FALSE		      equ	0
  EXIT_SUCCESS	equ	0			; Successful operation
  STDIN		      equ	0			; standard input
  STDOUT		    equ	1			; standard output
  STDERR		    equ	2			; standard error
  SYS_read	    equ	0			; system call code for read
  SYS_write	    equ	1			; system call code for write
  SYS_open	    equ	2			; system call code for file open
  SYS_close	    equ	3			; system call code for file close
  SYS_fork	    equ	57			; system call code for fork
  SYS_exit	    equ	60			; system call code for terminate
  SYS_creat	    equ	85			; system call code for file open/create
  SYS_time	    equ	201			; system call code for get time
  LF		        equ	10
  SPACE		      equ	" "
  NULL		      equ	0
  ESC		        equ	27
  SUCCESS 	    equ	0
  NOSUCCESS	    equ	1
  OUTOFRANGE	  equ	2
  INPUTOVERFLOW	equ	3
  ENDOFINPUT	  equ	4
  ; -----
  ;  Program specific constants.
  MIN_NUM		    equ	-100000
  MAX_NUM		    equ	100000
  BUFFSIZE	    equ	51			; 50 chars plus NULL
  ; -----
  ;  NO STATIC LOCAL VARIABLES
  ;  LOCALS MUST BE DEFINED ON THE STACK!!
; =============================================================================
section	.text

; ************readDozenalNumber**************************************************
;  Read an ASCII base-12 number from the user.
;  Includes error checking and conversion to integer.
;  Return codes:
;	SUCCESS		Successful conversion and number within required range
;	NOSUCCESS	Invalid input entered
;	OUTOFRANGE	Valid number, but out of range
;	INPUTOVERFLOW	User entry character count exceeds maximum length
;	ENDOFINPUT	Return entered, no characters (for end of the input)
; -----HLL Call:-----
;	status = readDozenalNumber(&numberRead);
;  Arguments Passed:
;	- numberRead, addr
;  ----Returns:-----
;	number read (via reference)
;	status code (as above)
global readDozenalNumber
readDozenalNumber:
  push rbp
    mov rbp, rsp
    sub rbp, 52 ;Space for local variables in stack
  push rbx
  push r12
  push r13
  push r14
  push r15
 ;--------Starting declarations------------
  lea rbx, byte[rbp+51] ;Points to stack local variable
  mov r12, 0        ;Counter/Iterator
  mov r13, rdi      ;Stores address of rdi
  mov r14, 12       ;For conversion from tetra
  mov r15, 0        ;Holds bytes for checks
 ;---------Loop to get characters----------
  getChar:
  	mov rax, SYS_read ;Tell system what it will do
  	mov rdi, STDIN    ;Tell system where data is
  	lea rsi, byte[r13];Tell system where to put input
  	mov rdx, 1        ;Tell system how much to read
  	syscall           ;Call system to run operation
    	mov r15b, byte[rsi] ;Move byte into register
    	cmp r15b, LF    ;If LF, num is done
    	je readDone
        inc r12       ;Increase counter
      	cmp r12, BUFFSIZE ;If counter is at BUFFSIZE
      	jae getChar   ;Goes on/skips storing
          mov byte[rbx], r15b ;add to string
          dec rbx
        	jmp getChar ;loop again
 ;------------Complete String / Check BUFF--------------
  readDone:
  	mov byte[rbx], NULL ;End string with NULL
    cmp r12, 0 ;If counter never inc, was end of input
    jne checkBuff
      mov rax, ENDOFINPUT ;if no num, end
      jmp ended
    checkBuff:
      cmp r12, BUFFSIZE ;If counter went over 51
      jbe startConv
        mov rax, INPUTOVERFLOW ;Return error for max length
        jmp ended
 ;---------------Start Conversion-----------------
  startConv:
    mov rax, 0      ;For practically everything as always
    mov r15, 0      ;For character holding
    mov r10, 1      ;For pos or neg conversion
  ;---------------Loop to get to Numbers---------------
  skipSpace:
    ;Initial spaces check
    mov r15b, byte[rbx+r12] ;Move last byte of string to reg
    dec r12         ;Counter starts at # of chars
    cmp r15b, 32    ;Check for a space, skip it
    je skipSpace
    ; Pos or Neg Check
    cmp r15b, "+"
    je afterInitial ;Number will be positive initially anyway
    cmp r15b, "-"
    jne invalidIn ;If reaches here and not -, invalid
      mov r10, -1 ;Prep for neg value if "-"
  ;------------Convert to Dec Loop--------------------
  ; # = 48-57; E = 69;  X = 88, e = 101; x = 120;
  afterInitial:
    mov r15b, byte[rbx+r12] ;Move last byte of string to reg
    dec r12
    cmp r15b, NULL
    je checkMin    ;Reach NULL, finish loop
    cmp r15b, 120
    ja invalidIn   ;If char > "x", not a valid char
    cmp r15b, 48
    jb invalidIn   ;If char < "0", invalid
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
        jmp invalidIn  ;If reaches here, invalid char
      isXLett:
        mov r15b, 10
        jmp addDec
      isELett:
        mov r15b, 11
    addDec:
      mul r14       ;Mul rax by 12 to move it up for new num
      add rax, r15  ;Add current num from string to decimal
      jmp afterInitial   ;Loop till NULL
 ;----------------Check Ranges and End----------------
    checkMin:
      imul r10
      cmp rax, MIN_NUM
      jge checkMax      ;If num is less than 1, send error
        mov rax, OUTOFRANGE
        jmp ended
    checkMax:
      cmp rax, MAX_NUM
      jle endSucc       ;If num is above max, send error
        mov rax, OUTOFRANGE
        jmp ended
    invalidIn:
        mov rax, NOSUCCESS
        jmp ended
    endSucc:
      mov qword[rsi], rax ;returning in address at rsi
      mov rax, SUCCESS
  ended:
  pop r15
  pop r14
  pop r13
  pop r12
  pop rbx
  pop rbp
ret
; **************combSort*********************************************************
;  Comb sort function.
;	Note, must update the comb sort algorithm to sort
;	in desending order
; -----HLL Call:-----
;	combSort(list, len)
;  Arguments Passed:
;	1) list, addr
;	2) length, value
;  -----Returns:-----
;	sorted list (list passed by reference)
global	combSort
combSort:
  ; Set undeclarable variables:
  mov r10, 10      ;ddTen
  mov r12, 12      ;ddTwelve
  mov r13, TRUE    ;swapped
  mov r14, 0       ;gap
	; 1.  Before loops, set gap to length, set swapped to TRUE
	mov eax, esi ;length
	mov r14d, eax   ;gap = length
	mov r13b, TRUE  ;rdi = swapped
	;------Outer Loop---------------------------------------------
	; 2.  Outer loop : for gap > 1, or swapped != FALSE
	cSort:
		;a. Update gap to == (gap*10)/12
		mov eax, r14d
		imul r10d
		idiv r12d
		;b. Cmp gap to 1, if less, set gap = 1
		cmp eax, 1
		jg gapSet
			mov eax, 1
		gapSet:
		mov r14d, eax
		;c. set i = 0
		mov rcx, 0
		;d. set swapped == FALSE
		mov r13b, FALSE
		;3.  Inner Loop : for i+gap >= length
		mov r8d, r14d
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
				mov r13b, TRUE
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
		mov r9d, r14d
		cmp r9d, 1
		jg cSort
		;b. Cmp swapped to TRUE, if yes then reloop outer
		cmp r13b, TRUE
		je cSort
	;5.  End Outer : Done
	endComb:
ret
; **************basicStats*******************************************************
;  Find the minimum, maximum, median, sum, and average for
;  a list of integers
;  Note, for an odd number of items, the median value is defined as
;  the middle value.  For an even number of values, it is the integer
;  average of the two middle values.
;  Note, assumes the list is already sorted.
; -----HLL Call:-----
;	basicStats(list, len, min, med, max, sum, ave)
;  Arguments Passed:
;	1) list, addr
;	2) length, value
;	3) minimum, addr
;	4) maximum, addr
;	5) median, addr
;	6) sum, addr
;	7) average, addr
; ----- Returns:-----
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
; **************iSqrt************************************************************
;  Find the integer square root of a passed number.
;	iSqrt_est = [ (iNumber/iSqrt_est) + iSqrt_est] / 2
; -----HLL Call:-----
;	ans = iSqrt(num)
;  Arguments Passed:
;	1) number, value
; ----- Returns:-----
;	integer square root (in eax)
global iSqrt
iSqrt:
	mov rcx, 51 ; iterator limit
  mov r10, 2
	mov r15, rdi ; iSqrt = iNumber
	; rdi is iNumber, r8 is iSqrt, rax is operation
	sqrtLoop:
		mov rax, rdi     ; iNumber
		mov rdx, 0
		div r15           ; iNumber / iSqrt
		add rax, r15     ; result + iSqrt
		mov rdx, 0
		div r10d	 ; result / 2
		mov r15, rax      ; r8 = iSqrt
		loop sqrtLoop
	mov eax, r15d  ;returns value in eax
ret
; **************intStdDev********************************************************
;  Function to calculate the integer standard deviation for an
;  array of numbers.
; -----HLL Call:-----
;	ans = intStdDev(list, len)
;  Arguments Passed:
;	1) list, addr
;	2) length, value
;	3) average (integer), value
;  -----Returns:-----
;	standard deviation (in eax)
; ********************************************************************************
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
		imul eax				; eax = eax^2
		; Add to total sum
		add r11, rax  ; r11 = summation
		inc r8d
		cmp r8d, esi
		jb deviLoop
	mov rax, r11
	; Divide it by total length
		mov rdx, 0
		div rsi
	mov rdi, rax ;move value to argument 1 position
	call iSqrt ;call value returning function
	;results come back from isqrt in eax
ret
