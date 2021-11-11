##
# Push value to application stack.
# PARAM: Registry with value.
##
.macro	PUSH (%reg)
	addi	$sp,$sp,-4              # decrement stack pointer (stack builds "downwards" in memory)
	sw	    %reg,0($sp)             # save value to stack
.end_macro

##
# Pop value from application stack.
# PARAM: Registry which to save value to.
##
.macro	POP (%reg)
	lw	    %reg,0($sp)             # load value from stack to given registry
	addi	$sp,$sp,4               # increment stack pointer (stack builds "downwards" in memory)
.end_macro

.data
primes:		.space  1000            # reserves a block of 1000 bytes in application memory
err_msg:	.asciiz "Invalid input! Expected integer n, where 1 < n < 1001.\n"
nl:			.asciiz "\n"
prompt:		.asciiz "gib a number: "
.text

main:
	li	$v0, 4
	la	$a0, prompt
	syscall

	# get input
    li      $v0, 5                  # set system call code to "read integer"
    syscall                         # read integer from standard input stream to $v0
    move	$t9, $v0				 # user input is now in $t9

	li 	$v0, 4
	la	$a0, nl
	syscall

	# $t9 contains user input
    # validate input
    li 	    $t0,1001                # $t0 = 1001
    slt	    $t1,$t9,$t0		    # $t1 = ($v0 < $t0) ? 1 : 0    # $
    beq     $t1,$zero,invalid_input # if ($t1 == 0) then the input was larger 1001 and we jump to invalid_input
    nop
    li	    $t0,1                   # $t0 = 1
    slt     $t1,$t0,$t9		        # ($t0 < $v0) ? 1 : 0
    beq     $t1,$zero,invalid_input # if ($t1 == 0) then the input was smaller than 1 and we jump to invalid_input
    nop
    
    # initialise primes array
    la	    $t0, primes              # $s1 = address of the first element in the array
    PUSH($t0)
    move    $t1, $t9 # constant
    li 	    $t2, 0 # counter
    li	    $t3, 1
    
    jal init_loop
    
    # exit program
    j       exit_program
    nop
    
    
init_loop:
    sb	    $t3, ($t0)              # primes[i] = 1 "place $t3 where $t0 is pointing to"
    addi    $t0, $t0, 1             # increment pointer to move forward in the array
    addi    $t2, $t2, 1             # increment counter
    bne	    $t2, $t1, init_loop     # loop if counter != 999
    
    POP($t0)						# $t0 now points to the start of the array
    # set 0 and 1 to 0 because we know they are not primes    
    sb	$zero, ($t0)
    addi    $t0, $t0, 1             # increment pointer to move forward in the array
    sb	$zero, ($t0)
    addi    $t0, $t0, 1             # increment pointer to move forward in the array
    
    li		$t2, 2					# set counter to 2

    PUSH($ra)
    jal		main_loop
    
    POP($ra)
    jr		$ra

main_loop:
	ble		$t2, $t1, loop
		
    j       exit_program
    nop
    
loop:
	lb		$t4, ($t0) # load what $t0 is pointing to into $t4
	bne		$t4, $t3, go_on
	jal		found_prime


go_on:	
	addi    $t0, $t0, 1             # increment pointer to move forward in the array
	addi    $t2, $t2, 1	# increment outer counter i
	ble		$t2, $t9, loop
	
	POP($ra)
	jr		$ra
	
	
found_prime:
	li	$t7, 2			# j, $t1 is n, i is the outer counter
	mul	$t6, $t7, $t2	# $t6 = i*j
	inner_loop:
			
				

		# need to go $t6 somehow
		# move pointer up $t6 - $t0 steps
		# move one multiple up, the current multiple is the outer counter
		#sub		$t5, $t0, $t6
		# inner-inner counter i j - 1, $t7 - 1
		addi	$t8, $t7, -1
		mul		$s1, $t2, $t8 # s1 is is how much we need to increment the pointer with
		add     $t0, $t0, $s1 # increment pointer to move forward in the array
		sb		$zero, ($t0)  # the pointer is now at a non-prime, set it's value to 0
		sub     $t0, $t0, $s1 # decrement pointer
				
		addi	$t7, $t7, 1	  # increment inner counter j
		mul		$t6, $t7, $t2	# $t6 = i*j
				
		ble		$t6, $t9, inner_loop
		
	li		$v0, 1
	move	$a0, $t2
	syscall
		
	li		$v0, 4
	la		$a0, nl
	syscall
	
	jr	$ra
	

invalid_input:
    # print error message
    li      $v0, 4                  # set system call code "print string"
    la      $a0, err_msg            # load address of string err_msg into the system call argument registry
    syscall                         # print the message to standard output stream
    
    

exit_program:
    # exit program
    li $v0, 10                      # set system call code to "terminate program"
    syscall                         # exit program