%macro	int2dozenal	2
	  mov r9, 12 ;Variable for dividing decimal
	  mov r8, 0
	  mov r8b, NULL ;rest of string added on top of this
	  mov eax, %1  ;integer
	  %%cvtDecLp:
	  	mov edx, 0 ;Clear modulus
	  	div r9d ;Divide decimal by 12
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
	  %%endVert:
		mov [%2], r8
%endmacro
section	.data
	; -----
	;  Define standard constants.
	LF		    equ	10			; line feed
	NULL		  equ	0			; end of string
	SPACE		  equ	0x20			; space
	TRUE		  equ	1
	FALSE		  equ	0
	SUCCESS		equ	0			; Successful operation
	NOSUCCESS	equ	1			; Unsuccessful operation
	STDIN		  equ	0			; standard input
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
	O_CREAT		equ	0x40
	O_TRUNC		equ	0x200
	O_APPEND	equ	0x400
	O_RDONLY	equ	000000q			; file permission - read only
	O_WRONLY	equ	000001q			; file permission - write only
	O_RDWR		equ	000002q			; file permission - read and write
	S_IRUSR		equ	00400q
	S_IWUSR		equ	00200q
	S_IXUSR		equ	00100q
	; -----
	;  Variables for getFileDescriptors()
	usageMsg	    db	"Usage: ./wordCount -w <searchWord> <-mc|-ic> -f <inputFile>"
			          db	LF, NULL
	errbadCLQ	    db	"Error, invalid command line arguments."
			          db	LF, NULL
	errWordSpec	  db	"Error, invalid search word specifier."
			          db	LF, NULL
	errWordLength	db	"Error, search word length must be < 80 "
			          db	"characters."
			          db	LF, NULL
	errFileSpec	  db	"Error, invalid input file specifier."
			          db	LF, NULL
	errCaseSpec	  db	"Error, invalid match case specifier."
			          db	LF, NULL
	errOpenIn	    db	"Error, can not open input file."
			          db	LF, NULL
	; -----
	;  Define constants and variables for getWord()
	MAXWORDLENGTH	equ	80
	BUFFSIZE	    equ	300000
	;BUFFSIZE	equ	3
	bfMax		    dq	BUFFSIZE
	curr		    dq	BUFFSIZE
	wasEOF		  db	FALSE
	errFileRead	db	"Error reading input file."
			        db	LF, NULL
	; -----
	;  Define constants and variables for displayResults()
	resultStart	db	"Found '", NULL
	resultSpace	db	"' ", NULL
	resultEnd	  db	" times.", LF, NULL
	; -------------------------------------------------------
	section	.bss
		buff		resb	BUFFSIZE+1
		tmpString	resb	MAXWORDLENGTH+1

; -------------------------------------------------------
section	.text

; -------checkParameters-----------------------------------
;  Check and return command line parameters.
;	Assignment #11 requires a word to search for, flag for
;	case handling and a file name.
;	Example:    % ./wordCount -w <searchWord> <-mc|-ic> -f <infile>
; -----
; HLL Call:
;	bool = checkParameters(ARGC, ARGV, searchWord, matchCase, rdFileDesc)
;  Arguments passed:
;	1) argc, value
;	2) argv, address
;	3) search word string, address  rdx
;	4) match case boolean, address  rcx
;	5) input file descriptor, address  r8
global checkParameters
checkParameters:
	push rbp			 ; Prolougue
	mov  rbp, rsp  ; rbp points to stack
	;--------Starting declarations------------
	mov  rbx, rsi  ; rbx points to argument vector
	mov  r12, 0		 ; iterator/counter for vector arguements
	mov  r13, 0		 ; Holder for arguments in vectors
	;---------Check Argc---------
	cmp  rdi, 6   ;Check for right number of arg count
	je argWdsp
	startError:
		cmp rdi, 1   ;if only one argument, the file name, usage error
		ja badErr
			mov rdi, usageMsg
			call printString
			mov rax, FALSE
			jmp funcOut	;End function with false in rax and printed error.
	badErr:
		mov rdi, errbadCLQ ;has more than one arguement, but not == 13
		call printString
		mov rax, FALSE
		jmp funcOut	;Ends function with false in rax and printed error
	;--------- -w ----------------
	argWdsp:
		add r12, 8 ;iterator for whole vector set to arg after filename
		mov r13, qword[rbx+r12] ;Location of "-w"
		cmp byte[r13], '-'
		jne wdSpErr ;check each character of arg specs
			cmp byte[r13+1], 'w'
			jne wdSpErr
				cmp byte[r13+2], NULL
				je wordCheck ;if they're all equal skip ahead
	wdSpErr:
		mov rdi, errWordSpec
		call printString
		mov rax, FALSE
		jmp funcOut ;set rax to false and end function if spec is wrong
	;--------Check search word--------
	wordCheck:
		add r12, 8 ;get argument associated with last spec
		mov r13, qword[rbx+r12] ;place value into argument for func call
		mov r11, 0
		makeSrchLp:
			;Adds chars into r15 at count...
			mov r10b, byte[r13+r11] ; Command line char
			mov byte[rdx+r11], r10b ; Return address for chars
			cmp r10b, NULL ; Runs after null is placed in curr
			je endMakeSrch ; Stops when null is done
			inc r11
			cmp r11, MAXWORDLENGTH
			jb makeSrchLp ; Loops until NULL or > maxLength
		endMakeSrch:
		;Returns string searchWord:
		jmp argMatch
	wordErr:
		mov rdi, errWordLength
		call printString
		mov rax, FALSE
		jmp funcOut ;print error, rax to false, end function
	;--------- -ic/-mc ----------------
	argMatch:
		add r12, 8 ;mov up to the next arg in vector
		mov r13, qword[rbx+r12] ;Location of "-mc" or "-ic"
		cmp byte[r13], '-'
		jne caseErr
			cmp byte[r13+2], 'c'
			jne caseErr
				cmp byte[r13+3], NULL
				jne caseErr
			;Check for m or i:
			cmp byte[r13+1], 'm'
			jne nextCaseSpec
				mov r13, TRUE
				mov byte[rcx], r13b
				jmp argFile
			nextCaseSpec:
				cmp byte[r13+1], 'i'
				je argFile
					;jmp argFile
	caseErr:
		mov rdi, errCaseSpec
		call printString
		mov rax, FALSE
		jmp funcOut ;print error, set rax to false, end function
	;-------- -f --------
	argFile:
		;mov rax, FALSE  ;Reset rax to false for new tests
		add r12, 8  ;move up in vector
		mov r13, qword[rbx+r12] ;Location of "-bk"
		cmp byte[r13], '-'
		jne fileErr
			cmp byte[r13+1], 'f'
			jne fileErr
				cmp byte[r13+2], NULL
				je fileCheck ;Send to error label if incorrect
	fileErr:
		mov rdi, errFileSpec
		call printString
		mov rax, FALSE
		jmp funcOut  ;Print error, set rax to false, end program
	;--------Check file exists--------
	fileCheck:
		add r12, 8 ;mov up to the next arg in vector
		mov r13, qword[rbx+r12] ;Location of read bmp file name
		;Try to open file.
		push rdx
		push rcx
		push rdi
		push rsi
		push rax
			mov rax, SYS_open ;Tell system to open file
			mov rdi, r13 ;Tells system the name of the file
			mov rsi, O_RDONLY ;file permission for read only
			syscall ;call system
			cmp rax, 0
			jl readErr ;If file didn't open, rax < 0
			mov [r8], rax ;Store file descriptor
		pop rax
		pop rsi
		pop rdi
		pop rcx
		pop rdx
		jmp endSuccess ;If input file is valid, jump to write argument
	readErr:
		pop rax
		pop rsi
		pop rdi
		pop rdx
		pop rcx
		mov rdi, errOpenIn
		call printString ;Print error for bad file name
		mov rax, FALSE
		jmp funcOut ;print error, set rax to false, end function
	;-----------End function--------
	endSuccess:
		mov rax, TRUE
	funcOut: ;End program jump spot
	pop rbp
ret

; -------getWord-------------------------------------------
;  Get a single word of text and return.
;  Implements basic C++ (searchWord << inFile) functionality.
;  A "word" is considered a set of contiguous non-white space
;  characters.  White space includes spaces, tabs, and LF.
;  Any character <= a space character is considered white space.
;  Function terminates word string with a NULL.
;  If a word exceeds the passed max length, must not over-write
;  the buffer.  Instead, just skip remaining characters.
;  This returns a partial word (which is ok in this context).
;  This routine handles the I/O buffer management.
;	- if buffer is empty, get more chars from file
;	- return word and update buffer pointers
;  If a word is returned, return TRUE.
;  Otherwise, return FALSE.
; -----
; HLL Call:
;	bool = getWord(currentWord, maxLength, rdFileDesc)
;  Arguments passed:
;	1) word buffer, address   rdi
;	2) max word length (excluding NULL), value   rsi
;	3) file descriptor, value   rdx
global getWord
getWord:
	;--------------------------------------------
	;Reset currWord and iterator:
	mov r11, qword[curr] ; iterator for buff
	mov qword[rdi], 0
	mov r10, 0
	;Check if buffer is empty
	cmp r11, qword[bfMax]
	jb getCurrLoop ;Skipps fillBuff
	;--------------------------------------------
	; For curr == bfMax and !eof, fill buffer:
 	fillBuff:
		;Check eof true && curr == bfMax:
		mov r15b, byte[wasEOF]
		cmp r15b, TRUE
		je falseEndFunc
		;Reset curr to 0.
		mov r15, 0
		mov qword[curr], r15
		;Collect unconsidered trifles:
		push rdi
		push rsi
		push rax
		push r10 ; Preserve place in currWord
			;Read file into buffer:
			mov rax, SYS_read
			mov rdi, rdx  ; file descriptor in rdi
			mov rsi, buff ; where to place chars
			mov rdx, BUFFSIZE
			syscall
			;Save read count:
			mov r15, rax
		;Restore:
		pop r10
		pop rax
		pop rsi
		pop rdi
		;Check for read error:
		cmp r15, 0
		jb notRead
		;Move # chars read to bfMax for limit:
		mov qword[bfMax], r15
		mov r11, 0 ; Restart if building a word already
		;Check for EOF if read < buffsize
		cmp r15, BUFFSIZE
		je getCurrLoop ;Jump past resets
		 ;wasEOF if read numbers < buffsize
			mov r15b, TRUE
			mov byte[wasEOF], r15b
  ;---------------------------------------
	; Get Current Word, rsi = maxLength, rdi = word return
	getCurrLoop:
		;Iterate buffer for word:
		mov r12b, byte[buff+r11]
		inc r11
		mov qword[curr], r11
		;Finish currWord at/below space char:
		cmp r12b, 32
		jbe endCurrlp
			mov byte[rdi+r10], r12b
			inc r10
			;End currWord at max length:
			cmp r10, 79
			jae endCurrlp
				;Refill buff if at end:
				cmp r11, qword[bfMax]
				jae fillBuff
				;Get next char:
				jmp getCurrLoop
		endCurrlp:
			mov byte[rdi+r10], NULL ;Null terminated current word
			mov rax, TRUE ; set true for word obtained
			jmp endofFunc ; leave
	notRead:
		;Error for file read:
		;pop rax
		mov rdi, errFileRead
		call printString
	falseEndFunc:
		;For error or eof==true;
		mov rax, FALSE
	endofFunc:
ret

; -------checkWord------------------------------------------
;  Compare strings, searchWord to currWord.
;  If same, increment word count.
;  Must handle match based on case flag.
; -----
;  HLL Call:
;	call checkWord(searchWord, currentWord, matchCase, wordCount)
;  Argument passed:
;	1)   searchWord, address  = rdi
;	2)   currentWord, address = rsi
;	3) match case flag, value = rdx
;	4)   word count, address  = rcx
global checkWord
checkWord:
	mov r10, 0 ;iterator
	;Since, for some reason, the case of the first letter of
	; searchWord needs to be changed for the -ic PRINTOUT:
	cmp rdx, TRUE
	je currVSsrch
	mov r11b, byte[rdi]
	cmp r11b, "A"
	jb currVSsrch
		cmp r11b, "Z"
		ja currVSsrch ; Z <= char <= A, make lower and change the variable
			add r11b, 32
			mov byte[rdi], r11b
	currVSsrch:
		mov r11b, byte[rdi+r10] ; Get char at searchWord
		mov r12b, byte[rsi+r10] ; Get char at currWord
		inc r10
		;Check for letters for case change:
		cmp r12b, 122 ; > 122 = not a letter
		ja chkMchCase
			cmp r12b, 65 ; < 65 = not a letter
			jb chkMchCase
			cmp r12b, 90 ; < 91 = lowercase already
			jbe ontoLetter
				cmp r12b, 97 ;91-96 = not a letter
				jb chkMchCase
	ontoLetter:
		;Check case condition:
		cmp rdx, TRUE ; true == mc
		je chkMchCase
			;If ignore case, make current lowercase
			cmp r12b, 97
			jae chkMchCase
				add r12b, 32 ;Make lowercase
	chkMchCase:
		;Chk if chars match:
		cmp r12b, r11b
		jne endwdChk ;Leave if no match
		cmp r11b, NULL
		je matchDone ;If they match and at null, inc count
		jmp currVSsrch ;If match and !null, loop
	matchDone:
		;If it survives to here, gets a point:
		inc qword[rcx]
	endwdChk:
ret

; -------displayResults--------------------------------------
;  Display formatted results to screen.
;	includes search word and count (in Dozenal).
;	format:
;		Found '<searchWord>' <wordCount> times.
; -----
;  HLL Call:
;	displayResults(searchWord, wordCount)
;  Arguments passed:
;	1) search word string, address  rdi
;	2) word count, value   rsi
global displayResults
displayResults:
	mov r12, rdi
	;Cvt int to Dozenal in macro:
	int2dozenal esi, tmpString
	mov rdi, resultStart
	call printString
	mov rdi, r12
	call printString
	mov rdi, resultSpace
	call printString
	mov rdi, tmpString
	call printString
	mov rdi, resultEnd
	call printString
ret

; *******printString*************************************************
;  Generic function to display a string to the screen.
;  String must be NULL terminated.
;  Algorithm:
;	Count characters in string (excluding NULL)
;	Uses syscall to output characters
; -----
;  HLL Call:
;	printString(stringAddr);
;  Arguments:
;	1) address, string
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
