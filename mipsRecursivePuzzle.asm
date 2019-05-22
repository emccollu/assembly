###########################################################################
#  data segment
.data
  # -----
  #  Constants
   TRUE       = 1
  FALSE       = 0
  ERROR_LIMIT = 3
  # -----
  #  Variables for main
  hdr:		  .ascii	"\nMIPS Assignment #5\n"
            .asciiz	"Row Puzzle Solution Program\n\n"
  # y n y y n
  game1:		  .word	3, 6, 4, 1, 3, 4, 2, 5, 3, 0
  game1Len:	  .word	10
  game1Start:	.word	0
  game2:		  .word	3, 1, 2, 3, 0
  game2Len:	  .word	5
  game2Start:	.word	0
  game3:		  .word	3, 7, 2, 4, 3, 4, 3, 2, 7, 3, 3, 5, 2, 0
  game3Len:	  .word	14
  game3Start:	.word	0
  game4:		  .word	3, 7, 2, 4, 3, 4, 3, 2, 4, 3, 2, 5, 2, 1, 1, 0
  game4Len:	  .word	16
  game4Start:	.word	0
  game5:		  .word	3, 6, 2, 4, 3, 4, 3, 2, 4, 3, 2, 5, 3, 4, 5, 0
  game5Len:	  .word	16
  game5Start:	.word	0
  endMsg:		  .ascii	"\nYou have reached recursive nirvana.\n"
              .asciiz	"Program Terminated.\n"
  # -----
  #  Local variables for prtNewline function.
  newLine:	  .asciiz	"\n"
  # -----
  #  Local variables for showGame() function.
  stars:		  .ascii	"\n**********************************************"
              .asciiz	"****************************\n"
  gameBrd:	  .asciiz	"Game Board: "
  dashs:		  .asciiz	"----"
  xtra:		    .asciiz	"-"
  bar:		    .asciiz	" | "
  offset0:	  .asciiz	"   "
  offset1:	  .asciiz	"  "
  # -----
  #  Local variables for getStartPosition() function.
  strtMsg1:	  .asciiz	"Enter a start position (0-"
  strtMsg2:	  .asciiz	"): "
  errValue:	  .ascii	"\nError, invalid start position. "
              .asciiz	"Please re-enter.\n"
  errLimit:	  .asciiz	"\nSorry, too many errors.\n\n"
  # -----
  #  Local variables for displayResult() function.
  frmMsg:		  .asciiz	"Starting from position "
  yesMsg:		  .asciiz	" you can win!  :-)\n"
  noMsg:		  .asciiz	" you can not win.  :-(\n"
  # -----
  #  Local variables for doAnother() function.
  sPmt:		    .asciiz	"Try another start position (y/n)? "
  ansErr:		  .asciiz	"Error, must answer with (y/n).\n"
  ans:		    .space	3

###########################################################################
#  text/code segment
.text
.globl main
.ent main
main:
  # -----
  #  Display program header.
  la	$a0, hdr
  li	$v0, 4
  syscall					# print header
  # -----
  #  Basic process:
  #	show game board
  #	reqest starting position
  #		if too many errors, exit
  #	determine if winnable
  #	show results
  # -----
  #  Do game1
  li	$s0, 1				# game counter
  la	$a0, game1
  lw	$a1, game1Len
  move	$a2, $s0
  jal	showGame
  tryGame1Again:
    la	$a0, game1Start
    lw	$a1, game1Len
    jal	getStartPosition
    beq	$v0, FALSE, gameOver
    lw	$a0, game1Start
    la	$a1, game1
    lw	$a2, game1Len
    jal	canWin
    lw	$a0, game1Start
    move	$a1, $v0
    la	$a2, game1
    lw	$a3, game1Len
    sub	$sp, $sp, 4
    sw	$s0, ($sp)
    jal	displayResult
    add	$sp, $sp, 4
    jal	doAnother
    beq	$v0, TRUE, tryGame1Again
  # -----
  #  Do game2
  add	$s0, $s0, 1
  la	$a0, game2
  lw	$a1, game2Len
  move	$a2, $s0
  jal	showGame
  tryGame2Again:
    la	$a0, game2Start
    lw	$a1, game2Len
    jal	getStartPosition
    beq	$v0, FALSE, gameOver
    lw	$a0, game2Start
    la	$a1, game2
    lw	$a2, game2Len
    jal	canWin
    lw	$a0, game2Start
    move	$a1, $v0
    la	$a2, game2
    lw	$a3, game2Len
    sub	$sp, $sp, 4
    sw	$s0, ($sp)
    jal	displayResult
    add	$sp, $sp, 4
    jal	doAnother
    beq	$v0, TRUE, tryGame2Again
  # -----
  #  Do game3
  add	$s0, $s0, 1
  la	$a0, game3
  lw	$a1, game3Len
  move	$a2, $s0
  jal	showGame
  tryGame3Again:
    la	$a0, game3Start
    lw	$a1, game3Len
    jal	getStartPosition
    beq	$v0, FALSE, gameOver
    lw	$a0, game3Start
    la	$a1, game3
    lw	$a2, game3Len
    jal	canWin
    lw	$a0, game3Start
    move	$a1, $v0
    la	$a2, game3
    lw	$a3, game3Len
    sub	$sp, $sp, 4
    sw	$s0, ($sp)
    jal	displayResult
    add	$sp, $sp, 4
    jal	doAnother
    beq	$v0, TRUE, tryGame3Again
  # -----
  #  Do game4
  add	$s0, $s0, 1
  la	$a0, game4
  lw	$a1, game4Len
  move	$a2, $s0
  jal	showGame
  tryGame4Again:
    la	$a0, game4Start
    lw	$a1, game4Len
    jal	getStartPosition
    beq	$v0, FALSE, gameOver
    lw	$a0, game4Start
    la	$a1, game4
    lw	$a2, game4Len
    jal	canWin
    lw	$a0, game4Start
    move	$a1, $v0
    la	$a2, game4
    lw	$a3, game4Len
    sub	$sp, $sp, 4
    sw	$s0, ($sp)
    jal	displayResult
    add	$sp, $sp, 4
    jal	doAnother
    beq	$v0, TRUE, tryGame4Again
  # -----
  #  Do game5
  add	$s0, $s0, 1
  la	$a0, game5
  lw	$a1, game5Len
  move	$a2, $s0
  jal	showGame
  tryGame5Again:
    la	$a0, game5Start
    lw	$a1, game5Len
    jal	getStartPosition
    beq	$v0, FALSE, gameOver
    lw	$a0, game5Start
    la	$a1, game5
    lw	$a2, game5Len
    jal	canWin
    lw	$a0, game5Start
    move	$a1, $v0
    la	$a2, game5
    lw	$a3, game5Len
    sub	$sp, $sp, 4
    sw	$s0, ($sp)
    jal	displayResult
    add	$sp, $sp, 4
    jal	doAnother
    beq	$v0, TRUE, tryGame5Again
  # -----
  #  Done, show message and terminate program.
  gameOver:
  li	$v0, 4
  la	$a0, endMsg
  syscall
  li	$v0, 10
  syscall					# all done...
.end main

# =========================================================================
#  Very simple procedure to print a new line.
#	Note, this routine is optional.
.globl	prtNewline
.ent	prtNewline
prtNewline:
  la	$a0, newLine
  li	$v0, 4
  syscall
  jr	$ra
.end	prtNewline

# =========================================================================
#  Procedure to print game board (formatted).
# -----
#    Arguments:
#	$a0 - game baord, address
#	$a1 - length, value
#	$a2 - game number, value
#    Returns:
#	n/a
.globl	showGame
.ent	showGame
showGame:
  move $t1, $a0 # - gameBaord  address
  move $t2, $a1 # - length     value
  sub $t2, $t2, 1
  #Print "**************************************************************************"
  la $a0, stars
  li $v0, 4
  syscall
  #Print "Game Board:"
  la $a0, gameBrd
  li $v0, 4
  syscall
  #Print Game Number
	move	$a0, $a2
  li	$v0, 1
  syscall
  #Print to Next Line
  la $a0, newLine
  li $v0, 4
  syscall
  #Print to Next Line
  la $a0, newLine
  li $v0, 4
  syscall
  #Print space from left
  la $a0, offset0
  li $v0, 4
  syscall
  #Print  "-----------------------------------------"
  move $t0, $zero
  dashRepition:
    la $a0, dashs
    li $v0, 4
    syscall
    add $t0, $t0, 1
    ble $t0, $t2, dashRepition
  #Print.... one dash
  la $a0, xtra
  li $v0, 4
  syscall
  #Print to Next Line
  la $a0, newLine
  li $v0, 4
  syscall
  #Print space from left
  la $a0, offset1
  li $v0, 4
  syscall
  move $t0, $zero
  boardPrint:
    #Print " | "
    la $a0, bar
    li $v0, 4
    syscall
    #Print value on board
    lw $a0, ($t1)
    li	$v0, 1
    syscall
    #Loop until iterator == length
    add $t1, $t1, 4
    add $t0, $t0, 1
    ble $t0, $t2, boardPrint
  #Print " | "
  la $a0, bar
  li $v0, 4
  syscall
  #Print to Next Line
  la $a0, newLine
  li $v0, 4
  syscall
  #Print space from left
  la $a0, offset0
  li $v0, 4
  syscall
  #Print  "-----------------------------------------"
  move $t0, $zero
  dashRepition2:
    la $a0, dashs
    li $v0, 4
    syscall
    add $t0, $t0, 1
    ble $t0, $t2, dashRepition2
  #Print.... one dash
  la $a0, xtra
  li $v0, 4
  syscall
  #Print to Next Line
  la $a0, newLine
  li $v0, 4
  syscall
  jr	$ra
.end	showGame

# =========================================================================
#  Prompt for, read, and check starting position.
#	must be >= 0 and < length
# -----
#    Arguments:
#	$a0 - startPosition, address
#	$a1 - length, value
#    Returns:
#	startPosition via reference
#	$v0, status (TRUE or FALSE)
.globl	getStartPosition
.ent	getStartPosition
getStartPosition:
  move $t0, $a0 # - startPosition address
  sub $a1, $a1, 1 # - length  value
  move $t1, $zero
  #Print to Next Line
  la $a0, newLine
  li $v0, 4
  syscall
  startLoop:
    #Print "Enter a start position (0-"
    la $a0, strtMsg1
    li $v0, 4
    syscall
    #Print Game Length
  	move	$a0, $a1
    li	$v0, 1
    syscall
    #Print "): "
    la $a0, strtMsg2
    li $v0, 4
    syscall
    #Recieve input
    li $v0, 5
    syscall
    #Compare to 0
    bltz $v0, errorInput
    #Compare to Length
    bgt $v0, $a1, errorInput
    #Store StartPosition
    sw $v0, ($t0)
    la $v0, TRUE
    j endStart
  errorInput:
    # if errors > 3
    bgt $t1, 2, endMultErrors
    #Print error
    la $a0, errValue
    li $v0, 4
    syscall
    #Loop to request input
    add $t1, $t1, 1
    b startLoop
  endMultErrors:
    #Print "Sorry, too many errors."
    la $a0, errLimit
    li $v0, 4
    syscall
    #End false.
    la	$v0, FALSE
  endStart:
  jr	$ra
.end	getStartPosition

#####################################################################
#  Procedure to recursivly determine if the row board game
#  is winnable.
# -----
#  Arguments:
#	$a0 - startPosition, value
#	$a1 - game board, address
#	$a2 - length, value
#  Returns:
#	$v0 - TRUE/FALSE
.globl	canWin
.ent	canWin
canWin:
	#----------------------------------------------
	# Preserve recursively:
	subu $sp, $sp, 12
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	#----------------------------------------------
	# Check Base Case:
    la $v0, TRUE
    lw $t0, ($a1)
    beqz $t0, endBoard #ends true if 0 is reached
    la $v0, FALSE
		bltz $a0, endBoard
    bge $a0, $a2, endBoard# ends false if pos goes off the board.
	#----------------------------------------------
	# General Case:
	# canWin( pos+ brd [ pos ]) ∨  canWin( pos−brd [ pos ])
		move $s0, $a0   # Position to Retrieve
    mul $t0, $s0, 4 # *4 For Array
    add $a1, $a1, $t0 # Move Array to Position
    lw $s1, ($a1)
    add $a0, $s0, $s1   #  pos + brd[pos]
    jal canWin  # canWin (pos - brd[pos])
    #---------
    sub  $s0, $s0, $s1  #  pos - brd[pos]
    move $s1, $a0 # holding result of addition
    move $a0, $s0
    jal  canWin # canWin (pos - brd[pos])
    #---------
    or $a0, $a0, $s1

		move $a0, $s0   # Position to Retrieve
	#---------------------------------------------
	# Restore recusively after base case reached:
  endBoard:
	  lw $ra,   ($sp)
		lw $s0,  4($sp)
		lw $s1,  8($sp)
		addu $sp, $sp, 12
  jr	$ra
.end canWin

# =========================================================================
#  Function to display formatted final result.
# -----
#    Arguments:
#	$a0 - startPosition, value
#	$a1 - game winnable (TRUE/FALSE)
#	$a2 - game board, address
#	$a3 - length, value
#	$(fp) - game number, value
#    Returns:
#	n/a
.globl	displayResult
.ent	displayResult
displayResult:
	#Preserve Registers:
  subu $sp, $sp, 28
  sw $s0, 0($sp)
  sw $s1, 4($sp)
  sw $s2, 8($sp)
  sw $s3, 12($sp)
  sw $s4, 16($sp)
  sw $fp, 20($sp)
  sw $ra, 24($sp)
  addu $fp, $sp, 28

  move $s0, $a0   # $a0 - startPosition, value
  move $s1, $a1   # $a1 - game winnable (TRUE/FALSE)
  move $s2, $a2   # $a2 - game board, address
  move $s3, $a3   # $a3 - length, value
  lw $s4, ($fp) # $(fp) - game number, value
    #Print game Board
    move	$a0, $s2
    move	$a1, $s3
    move	$a2, $s4
    jal	showGame
    #Print to Next Line
    la $a0, newLine
    li $v0, 4
    syscall
    #Print "Starting from position "
    la $a0, frmMsg
    li $v0, 4
    syscall
    #Print startPosition
  	move	$a0, $s1
    li	$v0, 1
    syscall
    #Check win/lose:
    beq $s1, FALSE, gameLost
    #Print " you can win!  :-)\n"
    la $a0, yesMsg
    li $v0, 4
    syscall
    b endDisplay
  gameLost:
    #Print " you can not win.  :-(\n"
    la $a0, noMsg
    li $v0, 4
    syscall
  endDisplay:
	#Restore registers:
	lw $s0, 0($sp)
  lw $s1, 4($sp)
  lw $s2, 8($sp)
  lw $s3, 12($sp)
  lw $s4, 16($sp)
  lw $fp, 20($sp)
  lw $ra, 24($sp)
  addu $sp, $sp, 28
  jr	$ra
.end	displayResult

# =========================================================================
#  Function to ask user if they want to do another start position.
#  Note, same function as previous assignment.
#  Basic flow:
#	prompt user
#	read user answer (as character)
#		if y/Y -> return TRUE
#		if n/N -> return FALSE
#	otherwise, display error and re-prompt
#  Note, uses read string syscall.
# -----
#  Arguments:
#	none
#  Returns:
#	$v0 - TRUE/FALSE
.globl	doAnother
.ent	doAnother
doAnother:
  #Print to Next Line
  la $a0, newLine
  li $v0, 4
  syscall
  anotherLoop:
  #Print "Try another start position (y/n)? "
  la $a0, sPmt
  li $v0, 4
  syscall
  #Recieve input
  la $a0, ans
  li $a1, 3
  li $v0, 8
  syscall
  lb $t0, ans
  #Check if y or n:
  beq $t0, 0x79, yesInput
  beq $t0, 0x59, yesInput
  beq $t0, 0x6E, noInput
  beq $t0, 0x4E, noInput
    #Print Error & Loop
    la $a0, ansErr
    li $v0, 4
    syscall
    add $t1, $t1, 1
    b anotherLoop
  yesInput:
  la $v0, TRUE
  b endAnother
  noInput:
  la $v0, FALSE
  endAnother:
  jr	$ra
.end	doAnother

#####################################################################
