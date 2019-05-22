; ***************************************************************
section	.data
	; -----
	;  Define standard constants.
		LF		    equ	10			; line feed
		NULL		  equ	0			  ; end of string
		ESC		    equ	27			; escape character
		TRUE		  equ	1
		FALSE		  equ	0
		SUCCESS		equ	0			  ; Successful operation
		NOSUCCESS	equ	1			  ; Unsuccessful operation
		STDIN		  equ	0		  	; standard input
		STDOUT		equ	1			  ; standard output
		STDERR		equ	2			  ; standard error
		SYS_read	equ	0			  ; call code for read
		SYS_write	equ	1			  ; call code for write
		SYS_open	equ	2			  ; call code for file open
		SYS_close	equ	3			  ; call code for file close
		SYS_fork	equ	57			; call code for fork
		SYS_exit	equ	60			; call code for terminate
		SYS_creat	equ	85			; call code for file open/create
		SYS_time	equ	201			; call code for get time
	; -----
	;  Message strings
		header			db	"**********************************************", LF
								db	ESC, "[1m", "Palindromic Numbers Program"
								db	ESC, "[0m", LF, LF, NULL
		msgStart		db	"--------------------------------------", LF
								db	"Start Counting", LF, NULL
		palMsgMain	db	"Palindromic Numbers: ", NULL
		msgProgDone	db	LF, LF, "Completed.", LF, NULL
		numberLimit	dq	0		; limit (quad)
		thdCount		dd	0		; thread Count
	; -----
	;  Globals (used by threads)
		PAL_STEP		equ	10000
		idxCounter	dq	1
		palCount		dq	0
		myLock1			dq	0
		myLock2			dq	0
	; -----
	;  Thread data structures
		pthreadID0	dq	0, 0, 0, 0, 0
		pthreadID1	dq	0, 0, 0, 0, 0
		pthreadID2	dq	0, 0, 0, 0, 0
		pthreadID3	dq	0, 0, 0, 0, 0
	; -----
	;  Variables for thread function.
		msgThread1	db	" ...Thread starting...", LF, NULL
	; -----
	;  Variables for printMessageValue
		newLine			db	LF, NULL
		comma				db	", ", NULL
	; -----
	;  Variables for getArguments function
		THREAD_MIN		equ	1
		THREAD_MAX		equ	4
		LIMIT_MIN			equ	10
		LIMIT_MAX			dq	5000000000
		PRT_LIMIT			equ	1000
		NUMS_PER_LINE	equ	10
		errUsage			db	"Usgae: ./palNums <-t1|-t2|-t3|-t4> ",
									db	"-l <dozenalNumber>", LF, NULL
		errOptions		db	"Error, invalid command line options."
									db	LF, NULL
		errTHSpec			db	"Error, invalid thread count specifier."
									db	LF, NULL
		errTHValue		db	"Error, thread count invalid."
									db	LF, NULL
		errLMSpec			db	"Error, invalid limit specifier."
									db	LF, NULL
		errLMValue		db	"Error, limit invalid."
									db	LF, NULL
	; -----
	;  Variables for int2dozenal function
		tmpNum				dq	0
	; -----
	;  Uninitialized data
	section	.bss
		tmpString			resb	20
; ***************************************************************
section	.text
; -----
;  External statements for thread functions.
extern	pthread_create, pthread_join
; ================================================================
;  Palindromic numbers program.
global main
main:
	push	rbp
	mov	rbp, rsp
	; -----
	;  Get/check command line arguments
		mov	rdi, rdi			; argc
		mov	rsi, rsi			; argv
		mov	rdx, thdCount
		mov	rcx, numberLimit
		call	getArguments
		cmp	rax, TRUE
		jne	progDone
	; -----
	;  Initial actions:
	;	Display initial messages
		mov	rdi, header
		call	printString
		mov	rdi, msgStart
		call	printString
	; -----
	;  Create new thread(s)
	;	pthread_create(&pthreadID0, NULL, &findPalNums, NULL);
		mov	rdi, msgThread1
		call	printString
		mov	rdi, pthreadID0
		mov	rsi, NULL
		mov	rdx, findPalNums
		mov	rcx, NULL
		call	pthread_create
	;	call other threads as needed based on user provided thread count.
		cmp dword[thdCount], 1
		je endTHDcrt
			mov	rdi, msgThread1
			call	printString
			mov	rdi, pthreadID1
			mov	rsi, NULL
			mov	rdx, findPalNums
			mov	rcx, NULL
			call	pthread_create
		cmp dword[thdCount], 2
		je endTHDcrt
			mov	rdi, msgThread1
			call	printString
			mov	rdi, pthreadID2
			mov	rsi, NULL
			mov	rdx, findPalNums
			mov	rcx, NULL
			call	pthread_create
		cmp dword[thdCount], 3
		je endTHDcrt
			mov	rdi, msgThread1
			call	printString
			mov	rdi, pthreadID3
			mov	rsi, NULL
			mov	rdx, findPalNums
			mov	rcx, NULL
			call	pthread_create
		endTHDcrt:
	;  Wait for thread(s) to complete.
	;	pthread_join (pthreadID0, NULL);
	WaitForThreadCompletion:
		mov	rdi, qword [pthreadID0]
		mov	rsi, NULL
		call	pthread_join
		;	join other threads as appropriate...
		cmp dword[thdCount], 1
		je endTHDjn
			mov	rdi, qword [pthreadID1]
			mov	rsi, NULL
			call	pthread_join
		cmp dword[thdCount], 2
		je endTHDjn
			mov	rdi, qword [pthreadID2]
			mov	rsi, NULL
			call	pthread_join
		cmp dword[thdCount], 3
		je endTHDjn
			mov	rdi, qword [pthreadID3]
			mov	rsi, NULL
			call	pthread_join
		endTHDjn:
	; -----
	;  Display final count
	showFinalResults:
		mov	rdi, newLine
		call	printString
		mov	rdi, palMsgMain
		call	printString
		mov	rdi, qword [palCount]
		mov	rsi, tmpString
		call	int2dozenal
		mov	rdi, tmpString
		call	printString
		mov	rdi, newLine
		call	printString
	; -----
	;  Program done, display final message
	;	and terminate.
	doMsg:
		mov	rdi, msgProgDone
		call	printString
	progDone:
		pop	rbp
		mov	rax, SYS_exit			; system call for exit
		mov	rdi, SUCCESS			; return code SUCCESS
		syscall

; *******getArguments********************************************************
;  Function getArguments()
;	 Get, check, convert, verify range, and return the
;	 sequential/parallel option and the limit.
;  Example HLL call:
;	 stat = getArguments(argc, argv, &thdConut, &numberLimit)
;  This routine performs all error checking, conversion of
;  ASCII/dozenal to integer, verifies legal range.
;  For errors, applicable message is displayed and FALSE is returned.
;  For good data, all values are returned via addresses with TRUE returned.
;  Command line format (fixed order):
;	<-t1|-t2|-t3|-t4> -l <dozenalNumber>
; -----
;  Arguments:
;	- ARGC, value rdi
;	- ARGV, address rsi
;	- thread count (dword), address rdx
;	- limit (qword), address rcx
global getArguments
getArguments:
	;-----------------Check Argc----------------------
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	;-----------------Starting declarations----------------------
		mov  rbx, rsi  ; Points to arg vector
		mov  r15, rdx  ; Return address for thread count
		mov  r14, rcx  ; Return address for limit
		mov  r13, r8   ; Return address for print flag
		mov  r12, 0		 ; iterator/counter for vector arguements
		mov  r11, 0		 ; Holder for vector qwords
		mov  r10, 0		 ; Used for argument transmissions
	;---------Check Argc---------
	cmp  rdi, 4   ;Check for right number of arg count
	je argThreads
	startError:
		cmp rdi, 1   ;if only one argument, the file name, usage error
		ja badErr
			mov rdi, errUsage
			call printString
			mov rax, FALSE
			jmp funcOut	;End function with false in rax and printed error.
	badErr:
		mov rdi, errOptions ;has more than one arguement, but not == 4
		call printString
		mov rax, FALSE
		jmp funcOut	;Ends function with false in rax and printed error
	;--------- -t# ----------------
	argThreads:
		add r12, 8 ;iterator for whole vector set to arg after filename
		mov r13, qword[rbx+r12] ;Location of "-a"
		cmp byte[r13], '-'
		jne threadErr ;check each character of arg specs
			cmp byte[r13+1], 't'
			jne threadErr
				cmp byte[r13+3], NULL
				jne threadErr ;if they're all equal skip ahead
					mov r10b, byte[r13+2]
					sub r10b, "0"
					cmp r10b, THREAD_MIN ; Check for <1
					jb thnumErr
						cmp r10b, THREAD_MAX ; Check for >4
						ja thnumErr ;If not equal, check for 2
							mov dword[r15], r10d ;Returns thread count
							jmp argLett
	threadErr:
		mov rdi, errTHSpec
		call printString
		mov rax, FALSE
		jmp funcOut ;set rax to false and end function if spec is wrong
	thnumErr:
		mov rdi, errTHValue
		call printString
		mov rax, FALSE
		jmp funcOut ;set rax to false and end function if spec is wrong
	;-------- -l --------
	argLett:
		add r12, 8 ;get argument
		mov r13, qword[rbx+r12] ;Location of "-l"
		cmp byte[r13], '-'
		jne ellErr
			cmp byte[r13+1], 'l'
			jne ellErr
				cmp byte[r13+2], NULL
				je limNum ;move to convert part
	ellErr:
		mov rdi, errLMSpec
		call printString
		mov rax, FALSE
		jmp funcOut ;print error, set rax to false, end function
	;--------Check limit number--------
	limNum:
		add r12, 8
		mov rdi, qword[rbx+r12] ;moves value to rbx
		mov rsi, r14
		call dozenal2int
		cmp rax, FALSE
		je lmRangeErr
		cmp qword[rsi], LIMIT_MIN
		jb lmRangeErr
		mov r13, qword[LIMIT_MAX]
		cmp qword[r14], r13
		jbe endTrue
		lmRangeErr:
			mov rdi, errLMValue
			call printString
			mov rax, FALSE
			jmp funcOut ;if value is wrong, print error and set rax to false
	;-------- fin --------
	endTrue:
		mov rax, TRUE
		jmp funcOut
	endFalse:
		mov rax, FALSE
	funcOut:
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbx
		pop rbp
ret

; ******findPalNums**********************************************************
;  Thread function, findPalNums()
;	Find palindromic numbers.
; -----
;  Arguments:
;	N/A (global variable accessed)
;  Returns:
;	N/A (global variable accessed)
global findPalNums
findPalNums:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
		mov r10, 10
		mov r14, 0
	;-----------------Main Loop----------------------
	;Get idxCounter and numberLimit in critical section:
	mainPalLoop:
	mov r13, 1 ;current Limit (r13)
	add r13, PAL_STEP
	call spinLock1
		add qword[palCount], r14
		mov r14, 0
		mov rbx, qword[numberLimit]	;Grabs numberLimit (don't change this)
		mov r12, qword[idxCounter]	;Grabs current number to check
		add r13, r12 ;currentLimit = idxCounter+10000
		cmp rbx, r13 ;If numberLimit < 10000
		jae withStep ;don't use +10000 as currentLimit
			mov r13, rbx ;currentLimit = numberLimit (no adding 10000)
	withStep:
		mov qword[idxCounter], r13 ;idxCounter update for next thread
		call spinUnlock1
		cmp r12, rbx ;If idxCounter = numberLimit, End
		jae limitReached
			jmp palLoop
	;-----------------Iterate next 10000----------------------
		;Loop until r12 reaches r13
		palLoop:
			mov r15, 0     ;Set r15 to 0
			mov rax, r12   ;Set rax to current num to check
			;----------Loop: Get and Add Digits-------
			addDigitsLoop:
				mov rdx, 0   ;Clear modulus
				div r10			 ;Divide current num by 10
				imul r15, r10 ;multiply r15 by 10
				add r15, rdx ;Remainder is new digit
				cmp rax, 0   ;When rax = 0, exit loop, digits added in r15
				jne addDigitsLoop
			;---------Check for Harsh--------
			cmp r15, r12		 ;If == num, inc palcount
			jne incCurrent
				inc r14
		;----------Inc Number and Loop---------
		;Checks if r12 = current limit (idxCounter+step)
			incCurrent:
				cmp r12, r13	   ;Compares current number with limit
				je mainPalLoop  ;When current == limit+1, get next 10000
				inc r12	;Increments current number
				jmp palLoop ;Loops
		;----------End of Loop---------
		;When idxCounter >= numberLimit, end function
		limitReached: ;End of loop
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
ret

; *****spinLock1*************************************************************
;  Mutex lock
;	checks lock (shared gloabl variable)
;		if unlocked, sets lock
;		if locked, lops to recheck until lock is free
global	spinLock1
spinLock1:
	mov	rax, 1			; Set the RAX register to 1.
	lock	xchg	rax, qword [myLock1]	; Atomically swap the RAX register with
					;  the lock variable.
					; This will always store 1 to the lock, leaving
					;  the previous value in the RAX register.
	test	rax, rax	        ; Test RAX with itself. Among other things, this will
					;  set the processor's Zero Flag if RAX is 0.
					; If RAX is 0, then the lock was unlocked and
					;  we just locked it.
					; Otherwise, RAX is 1 and we didn't acquire the lock.

	jnz	spinLock1		; Jump back to the MOV instruction if the Zero Flag is
					;  not set; the lock was previously locked, and so
					; we need to spin until it becomes unlocked.
ret

; *****spinUnlock1***********************************************************
;  Mutex unlock
;	unlock the lock (shared global variable)
global	spinUnlock1
spinUnlock1:
	mov	rax, 0			; Set the RAX register to 0.
	xchg	rax, qword [myLock1]	; Atomically swap the RAX register with
					;  the lock variable.
ret

; ******dozenal2int**********************************************************
;  Function: Check and convert ASCII/dozenal string
;		to integer.
;  HLL Call:
;	bool = dozenal2int(dozenalStr, &num);
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
    add rax, r15  ;Add current num from string to decimal
		inc r13
		jmp cvt2Dec ;loop
	;------------End Conversion--------------
	chkValue:
		mov qword[rsi], rax ;move value into return register
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

; *******int2dozenal*********************************************************
;  Convert integer to ASCII/dozenal string.
;	Note, no error checking done on integer.
;	No leading spaces placed in string.
; -----
;  HLL Call:
;	int2dozenal(integer, strAddr)
; -----
;  Arguments:
;	- integer, value rdi
;	- string, address rsi
; -----
;  Returns:
;	ASCII/dozenal string (NULL terminated)
global int2dozenal
int2dozenal:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r14
	;-----------------Starting declarations----------------------
		mov rax, rdi    ;rax gets num to make doz
		mov r14, 12 		;doz conversion
		mov rdx, 0			;For modulus
		mov r11, 0			;iterator
		mov r13, 0
	;-----------------Convert to doz ----------------------
	mov r13b, NULL
	grabNum:
		cmp rax, 0 			;When decimal is complete, end grabNum loop.
		je endVert
			mov rdx, 0 		;Clear modulus
			div r14 			;Divide decimal by 12
			cmp dl, 9		  ;Check if above 9 for cvt type
			ja vertDoz
				add dl, "0" ;Convert to string
				jmp addChar
			vertDoz:
	      cmp dl, 10
	      je cvtXLett
	        mov dl, "E"
	        jmp addChar
	      cvtXLett:
	    		mov dl, "X" ;Convert to string
			addChar:
				inc r11
				shl r13, 8
				mov r13b, dl	;Move new char into string.
			jmp grabNum 		;Run again.
		endVert:
		mov qword[rsi], r13 ;Return null terminated ascii doz string
	pop r14
	pop r12
	pop rbx
	pop rbp
ret
; ******printString**********************************************************
;  Generic function to display a string to the screen.
;  String must be NULL terminated.
;  Algorithm:
;	Count characters in string (excluding NULL)
;	Use syscall to output characters
;  Arguments:
;	- address, string
;  Returns:
;	nothing
global	printString
printString:
	; -----
	;  Count characters to write.
		mov	rdx, 0
	strCountLoop:
		cmp	byte [rdi+rdx], NULL
		je	strCountLoopDone
		inc	rdx
		jmp	strCountLoop
	strCountLoopDone:
		cmp	rdx, 0
		je	printStringDone
	; -----
	;  Call OS to output string.
		mov	rax, SYS_write			; system code for write()
		mov	rsi, rdi			; address of characters to write
		mov	rdi, STDOUT			; file descriptor for standard in
							; rdx=count to write, set above
		syscall					; system call
	; -----
	;  String printed, return to calling routine.
	printStringDone:
ret
; ******************************************************************
