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

.globl multiply
.globl faculty

.data
nl:	.asciiz "\n"
promptMsg:	.asciiz	"Enter a number: "
factMsg:	.asciiz	"! = "
.text

main:
	la	$a0, promptMsg
	li	$v0, 4
	syscall
	
	li	$v0, 5
	syscall
	# store user input in $v0
	move $t9, $v0
	
	li	$v0, 1
	move $a0, $t9
	syscall
	
	la	$a0, factMsg
	li	$v0, 4
	syscall
	
	move $v0, $t9
	
	move $a0, $v0
	jal faculty

	move	$a0, $v0 # move the return value into $a0
	li	$v0, 1
	syscall
	
	li	$v0, 10
	syscall
 
# the factorial we are calculating uses $a0
faculty:
	PUSH($ra) # super necessesary because we call multiply
	move	$t7, $a0 # set i to n
	li	$t6, 1 # result
	loop:
		ble	$t7, $zero, exitF # exit if done
		# move numbers into $a1 and $a2
		
		move	$a1, $t7
		move	$a2, $t6
		
		jal	multiply
		
		move	$t6, $t0
		addi	$t7, $t7, -1 # i--
		j	loop


# uses $a1 and $a2 for the two numbers that are being multiplied
multiply:
	li	$t0, 0 # set result to 0
	li	$t1, 0 # set i to 1
	multLoop:
		bge	$t1, $a1, exitM # exit when i > $a1
		add	$t0, $t0, $a2 # add $a2 to result
		addi	$t1, $t1, 1 # i++
		j	multLoop
	
exitM:
	move	$v0, $t0 # move result to $v0
	jr	$ra

	
exitF:
	POP($ra)
	move	$v0, $t6 # move result to $v0
	jr	$ra