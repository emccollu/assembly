###########################################################
#  data segment
.data
	lengths:
		.word	  327,   344,   310,   372,   324
		.word	  325,   316,   362,   328,   392
		.word	  317,   314,   315,   372,   324
		.word	  325,   316,   362,   338,   392
		.word	  321,   383,   333,   330,   337
		.word	  342,   335,   358,   323,   335
		.word	  327,   326,   326,   327,   227
		.word	  357,   387,   399,   311,   323
		.word	  324,   325,   326,   375,   394
		.word	  349,   326,   362,   331,   327
		.word	  377,   399,   397,   375,   314
		.word	  364,   341,   342,   373,   366
		.word	  304,   346,   323,   356,   363
		.word	  321,   318,   377,   343,   378
		.word	  312,   311,   310,   335,   310
		.word	  377,   399,   377,   375,   314
		.word	  394,   324,   312,   343,   376
		.word	  334,   326,   332,   356,   363
		.word	  324,   319,   322,   383,   310
		.word	  391,   392,   329,   329,   322
	widths:
		.word	  226,   252,   257,   267,   234
		.word	  217,   254,   217,   225,   253
		.word	  223,   273,   235,   261,   259
		.word	  225,   224,   263,   247,   223
		.word	  234,   234,   256,   264,   242
		.word	  233,   214,   273,   231,   255
		.word	  264,   273,   274,   223,   256
		.word	  244,   252,   231,   242,   256
		.word	  255,   224,   236,   275,   246
		.word	  253,   223,   253,   267,   235
		.word	  254,   229,   264,   267,   234
		.word	  256,   253,   264,   253,   265
		.word	  236,   252,   232,   231,   246
		.word	  250,   254,   278,   288,   292
		.word	  282,   295,   247,   252,   257
		.word	  257,   267,   279,   288,   294
		.word	  234,   252,   274,   286,   297
		.word	  244,   276,   242,   236,   253
		.word	  232,   251,   236,   287,   290
		.word	  220,   241,   223,   232,   245
	heights:
		.word	  124,   119,   122,   183,   110
		.word	  191,   192,   129,   129,   122
		.word	  135,   226,   162,   137,   127
		.word	  127,   159,   177,   175,   144
		.word	  179,   153,   136,   140,   235
		.word	  117,   114,   115,   172,   124
		.word	  125,   116,   162,   138,   192
		.word	  111,   183,   133,   130,   127
		.word	  111,   115,   158,   113,   115
		.word	  117,   126,   116,   117,   227
		.word	  177,   199,   177,   175,   114
		.word	  194,   124,   112,   143,   176
		.word	  134,   126,   132,   156,   163
		.word	  112,   154,   128,   113,   132
		.word	  161,   192,   151,   213,   126
		.word	  269,   114,   122,   115,   131
		.word	  194,   124,   114,   143,   176
		.word	  134,   126,   122,   156,   163
		.word	  149,   144,   114,   134,   167
		.word	  143,   129,   161,   165,   136
	len:	.word	100
	volumes:
		.space	400
	vMin:	.word	0
	vMid:	.word	0
	vMax:	.word	0
	vSum:	.word	0
	vAve:	.word	0
	# -----
	hdr:	.ascii	"MIPS \n"
		.ascii	"  Rectangular Prism Volumes Program:\n"
		.ascii	"  Also finds minimum, middle value, maximum, sum,"
		.asciiz	" and average for the volumes.\n\n"
	a1_st:	.asciiz	"\nVolumes Minimum      = "
	a2_st:	.asciiz	"\nVolumes Est. Median  = "
	a3_st:	.asciiz	"\nVolumes Maximum      = "
	a4_st:	.asciiz	"\nVolumes Sum          = "
	a5_st:	.asciiz	"\nVolumes Average      = "
	newLn:	.asciiz	"\n"
	blnks:	.asciiz	"  "
###########################################################
#  text/code segment
# --------------------
#  Compute volumes.
#  Then find middle, max, sum, and average for the volumes.
.text
.globl main
.ent main
main:
	# ******************************
	#  Display header.
		la	$a0, hdr
		li	$v0, 4
		syscall				# print header
#---------------------------------
# Load arrays:
	#Store addresses of arrays:
	la $t0, widths
	la $t1, lengths
	la $t3, volumes
	la $t5, heights
	#Load values for arithmetic
	lw $t4, len
	li $t6, 0 #iterator
# ------------------------------------------------
#	Loop to get each element of semi perims:
	volsLoop:
		lw   $s0, ($t0)	    # Load lengths[i]
		lw   $s1, ($t1)	    # Load widths[i]
		lw   $s2, ($t5)	    # Load heights[i]
		mul  $s0, $s0, $s1  # lengths[i] * widths[i]
		mul  $s0, $s0, $s2  # result * heights[i]
		sw   $s0, ($t3)	    # Store value in volumes[i]
		add  $t0, $t0, 4	  # lengths[i+1]
		add  $t1, $t1, 4	  # widths[i+1]
		add  $t3, $t3, 4    # volumes[i+1]
		add  $t5, $t5, 4    # heights[i+1]
		add  $t6, $t6, 1	  # Loop iterator+1
		bne  $t6, $t4, volsLoop
# ------------------------------------------------
# Find Totals from Volumes:
	#	Load the initial value/addresses
		la  $t0, vMin
		la  $t1, vMax
		la  $t2, vSum
		la  $t5, vAve
		la  $t7, vMid
		sub $t3, $t3, 4  #volumes[i-1]
	#Initialize min and max:
		lw  $s3, ($t3)
		lw  $s4, ($t3)
		lw $t6, len
		li  $s2, 0
# ------------------------------------------------
# Second loop to gather values:
	valueLoop:
		 lw  $s0, ($t3) # Get volume
		 add $s2, $s2, $s0 # Get sum
		 blt $s3, $s0, checkMax # Compare to curr min
		  move $s3, $s0 #If value < curr min, replace
		checkMax:
			bgt $s4, $s0, checkLoop # Compare to curr max
				move $s4, $s0 # If value > curr max, replace
		checkLoop:
			sub  $t3, $t3, 4  # iterate volumes
			sub  $t6, $t6, 1	# dec Iterator
			bnez  $t6, valueLoop
# ------------------------------------------------
# Store Gathered Values:
	sw   $s2, ($t2)   # Store vSum
	sw   $s3, ($t0) 	# Store vMin
	sw   $s4, ($t1) 	# Store vMax
	#	Get ave:
	div $s2, $s2, $t4
	sw $s2, ($t5)			# Store vAve
	#	Get mid:
	rem $t8, $t4, 2     # Determining even or odd
	div $t5, $t4, 2     # length/2
	mul $t5, $t5, 4     # *4 for word size array indexing
	add $t3, $t3, $t5   # Set volumes index to middle
	lw  $s0, ($t3)      # Load middle of list
	beqz $t5, storeMid  # If length was even #, skip next
		lw  $s1, 4($t3)   # Load word at middle+1
		add $s0, $s0, $s1 # Add both middle numbers
		div $s0, $s0, 2   # Divide middle 2 values by 2
	storeMid:
	sw  $s0, ($t7)      # Store vMid
#-------------------------------------
# Display Lines of 8:
	# Load initial values/addresses
	la $t8, volumes
	lw $t2, len
	# Loop to display
		la	$a0, newLn
		li	$v0, 4
		syscall						# Add line between header and values
	printAreas:
		la	$a0, blnks
		li	$v0, 4
		syscall						# Print spaces at start of line and between values
		lw	$a0, ($t8)
		li	$v0, 1
		syscall						# Print value at volumes[i]
		add $t8, $t8, 4		# Increment index
		add $t9, $t9, 1 	# Increment iterator
		rem $t1, $t9, 8 	# Check if iterator is divisor of 8
		bnez $t1, chkPrint	# If not, skip next
			la	$a0, newLn
			li	$v0, 4
			syscall					# Move to new line every 8 characters
			chkPrint:
		blt $t9, $t2, printAreas # Loop until iterator = length

#-------------------------------------

	# ******************************
	#  Display results.
		la	$a0, newLn		# print a newline
		li	$v0, 4
		syscall
	#  Print min message followed by result.
		la	$a0, a1_st
		li	$v0, 4
		syscall				# print "min = "
		lw	$a0, vMin
		li	$v0, 1
		syscall				# print min
	# -----
	#  Print middle message followed by result.
		la	$a0, a2_st
		li	$v0, 4
		syscall				# print "est med = "
		lw	$a0, vMid
		li	$v0, 1
		syscall				# print mid
	# -----
	#  Print max message followed by result.
		la	$a0, a3_st
		li	$v0, 4
		syscall				# print "max = "
		lw	$a0, vMax
		li	$v0, 1
		syscall				# print max
	# -----
	#  Print sum message followed by result.
		la	$a0, a4_st
		li	$v0, 4
		syscall				# print "sum = "
		lw	$a0, vSum
		li	$v0, 1
		syscall				# print sum
	# -----
	#  Print average message followed by result.
		la	$a0, a5_st
		li	$v0, 4
		syscall				# print "ave = "
		lw	$a0, vAve
		li	$v0, 1
		syscall				# print average
	# -----
	#  Done, terminate program.
	endit:
		la	$a0, newLn		# print a newline
		li	$v0, 4
		syscall
		li	$v0, 10
		syscall				# all done!
.end main
