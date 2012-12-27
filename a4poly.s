# Name and section: Peter Collins, section 2
# Partner's Name and section: Brennan Schmidt, section 2

# This program reads in a single character representing a polynomial's
# degree.  It then reads in coefficients for the polynomial, placing
# each into an array.  The polynomial is printed out, and an integer
# is prompted for.  With a valid integer, the polynomial is evaluated
# at that value, and the result is printed out.

.data
ARRAY_SIZE:     .word   5
array:          .word   0:5        # array for coefficients
integer_array: .word 0:32
str_prompt1:    .asciiz "Polynomial program:\nEnter degree:  "
str_prompt2:    .asciiz "Enter coefficient for x^"
str_prompt3:    .asciiz ":"
str_prompt4:    .asciiz "Enter x:  "
msg_out1:       .asciiz "Polynomial entered:\n"
msg_out2:       .asciiz "x^"
msg_out3:       .asciiz " + "
msg_out4:       .asciiz "f("
msg_out5:       .asciiz ") = "
str_badinput:   .asciiz "\nBad input.  Quitting.\n"	
newline:        .asciiz "\n"	

 .text
__start:        
   sub  $sp, $sp, 12             # 3 parameters (max) passed from main()
                                 #   so allocate stack space for them
   puts str_prompt1

   jal  get_integer              # get degree
   # check validity of degree
   bltz $v1, bad_input
   li   $8, 4                    # maximum degree allowed
   move $9, $v0
   bgt  $9, $8, bad_input
   bltz $9, bad_input

   sw   $9, 4($sp)              # P1 is degree of polynomial
   la   $10, array              # P2 is base addr of array to hold coeffs
   sw   $10, 8($sp) 
   jal  read_coefficients
   bltz $v0, bad_input          # return value is -1 for bad input

   sw   $9, 4($sp)              # same parameters to print_polynomial
   sw   $10, 8($sp) 
   jal  print_polynomial

   # prompt for and get x value
   puts str_prompt4
   jal  get_integer             # get x value; check that it was a valid int
   bltz $v1, bad_input
   move $8,  $v0                # $8 is now the x value
   sw   $v0, 4($sp)             # P1 is x value
   sw   $9,  8($sp)             # P2 is degree of polynomial
   sw   $10, 12($sp)            # P3 is base addr of array holding coeffs
   jal  evaluate
   move $9, $v0                 # $9 is polynomial's value at x

   # print result
   puts msg_out4
   sw   $8, 4($sp)              # P1 is x
   li   $10, 10                 # P2 is radix to print in ($10 is radix=10)
   sw   $10, 8($sp)               
   jal  print_integer
   puts msg_out5
   sw   $9, 4($sp)              # P1 is evaluated value at x
   sw   $10, 8($sp)             # P2 is radix to print (10)
   jal  print_integer
   puts newline
   b    end_program

bad_input:  
   puts str_badinput
   b    end_program

end_program:    
   add  $sp, $sp, 12
   done


####################
#read_coefficients
# prompts user for a coefficient for each degree of x
# param 1: degree of polynomial
# param 2: base address of coefficients array
read_coefficients:
#prologue
	sub $sp, $sp, 16 
	sw $8, 4($sp)
	sw $9, 8($sp)
	sw $10, 12($sp)
	sw $ra, 16($sp)

	lw $9, 20($sp)        # load P1, degree of polynomial
	lw $10, 24($sp)	      # load P2, address of array
prompt_coefficient:
	puts str_prompt2      # get coefficient prompt
	add $8, $9, 0x30	  # convert degree to ascii value
	putc $8	    		  # output degree
	puts str_prompt3
	jal get_integer
	bltz $v1, bad_coefficient  # if bad input, jump to error message
	sw $v0, ($10)         # store coefficient in array
	add $10, 4			  # increment array pointer
	sub $9, 1			  # decrement degree
	bgez $9, prompt_coefficient # if there are more coefs to get, get them
	li $v0, 0    		  # good input return value
	b read_epilogue
bad_coefficient:
	li $v0, -1            # bad input return value
read_epilogue:            # epilogue
	lw $8, 4($sp)
	lw $9, 8($sp)
	lw $10, 12($sp)
	lw $ra, 16($sp) 
	add $sp, 16	
	jr $ra

####################
#evaluate
# the x value of the polyinomial, the degree of the polynomial, and the address
# of the coefficient array are parameters to this function. It calculates the
# polynomial with the given value of x and returns the value of the expression
evaluate:
#prologue
	sub $sp, 28 		#save registers
	sw $8, 4($sp)
	sw $9, 8($sp)
	sw $10, 12($sp)
	sw $11, 16($sp)
	sw $12, 20($sp)
	sw $13, 24($sp)
	sw $ra, 28($sp)

	lw $8, 32($sp) 		#load P1: value of x
	lw $9, 36($sp)		#load P2: degree of polynomial
	lw $10, 40($sp)		#load P3: address of coefficient array
	li $11, 0 			#return value
degree_loop:
	lw $12, ($10)		#load current coefficient
	move $13, $9 		#current degree loop power index
	blez $13, end_power_loop #if degree 0 skip the loop
power_loop:
	mul $12, $12, $8 	#multiply current coefficient by x
	sub $13, 1			#decrement loop power index
	bgtz $13, power_loop #if loop power index is 0 end loop, else muliply again 
end_power_loop:
	add $11, $11, $12	#add current calculated coefficient to return value
	sub $9, 1			#decrement degree to next work on
	add $10, 4			#go to next coefficient in array
	bgez $9, degree_loop #loop if more degree, else finish

#epilogue
	move $v0, $11 		#store return value
	lw $8, 4($sp)		#load saved registers
	lw $9, 8($sp)
	lw $10, 12($sp)
	lw $11, 16($sp)
	lw $12, 20($sp)
	lw $13, 24($sp)
	lw $ra, 28($sp)
	add $sp, 28
	jr $ra

##################################
#print_polynomial:
# prints out the entire polynomial. 
# P1: degree of polynomial
# P2: address of coefficients array
print_polynomial:
#prologue
	sub $sp, $sp, 24
	sw $8, 8($sp)
	sw $9, 12($sp)
	sw $10, 16($sp)
	sw $11, 20($sp)
	sw $ra, 24($sp)

	lw $9, 28($sp)       # load P1: degree of polynomial
	lw $10, 32($sp)      # load P2: address of array
	puts msg_out1        # output polynomial message
print_poly_loop:
	lw $11, ($10)   	 # load first coefficient
	sw $11, 4($sp)       # store coefficient as outgoing param
	jal print_integer
	puts msg_out2 		 # output "x^"
	add $8, $9, 0x30     # convert degree to ascii
	putc $8				 # output degree
	blez $9, end_print_poly_loop  # if it is the last degree, dont output "+"
	puts msg_out3
	sub $9, $9, 1        # decrement degree
	add $10, 4			 # update array pointer
	bgez $9, print_poly_loop  # if there is more to print, print it!
end_print_poly_loop:
	puts newline    
#epilogue
	lw $8, 8($sp)
	lw $9, 12($sp)
	lw $10, 16($sp)
	lw $11, 20($sp)
	lw $ra, 24($sp)
	add $sp, $sp, 24
	jr $ra
	


##################################
#print_integer:
# receives two parameters, an integer to be printed, and a base radix to print out,
# and prints it out
print_integer:
#prologue
	sub $sp, 20
	sw  $ra, 20($sp)
    sw   $8,  4($sp)
    sw   $9,  8($sp)
    sw   $10, 12($sp)
    sw   $11, 16($sp)

	la $11 integer_array
	li $12, 0	       # $12 is the digit counter
	lw $8, 24($sp)     # loads first parameter, integer to be printed
	bgez $8, format_integer  # if the number is positive, don't print a '-'
	putc '-'
	mul $8, $8, -1     # convert to positive number after printing minus sign
format_integer:
	rem $10, $8, 10    # get last digit of integer, depending on what base is
	sw $10, ($11)      # store the digit in the integer array
	add $11, 4         # increment address of array
	add $12, 1         # increment digit counter
	div $8, $8, 10     # remove last digit
	bgtz $8, format_integer # if there are more digits, loop back
	sub $11, 4         # adjust array pointer to point to last digit
output_integer:
	lw $8, ($11)       # load the new first digit
	add $8, 0x30       # convert to ascii value
	putc $8            # output digit
	sub $11, 4         # decrement array pointer
	sub $12, 1         # decrement digit counter
	bgtz $12, output_integer   # if there are more digits, print them!

#epilogue
	li   $v0, 0
	lw   $8,  4($sp)          # restore register values
    lw   $9,  8($sp)
    lw   $10, 12($sp)
    lw   $11, 16($sp)
    lw   $ra, 20($sp)
    add  $sp, $sp, 20 
	jr $ra

####################
#get_integer: 
# A function that reads in, and returns a user-integer in $v0.
# A badly formed integer leads to a negative return value in $v1.
# A well-formed integer has an optional '-' character followed by
# digits '0'-'9', and is ended with the newline character.

get_integer:
   sub  $sp, $sp, 24         # allocate AR
   sw   $ra, 24($sp)         # save registers in AR
   sw   $8,  4($sp)
   sw   $9,  8($sp)
   sw   $10, 12($sp)
   sw   $11, 16($sp)
   sw   $12, 20($sp)

   li   $10, 0               # $10 is the calcuated integer
   li   $v1, 0               # assume int is good
   li   $12, 0               # $12 is now flag, 1 means negative
                             #  and 0 means not negative
   getc $8                   # $8 holds 1 user-entered character 
   li   $11, '-'             # check if 1st character is '-'
   bne  $8, $11, notneg
   li   $12, 1               # is negative
   getc $8                   
notneg:
   li   $9, 10               # check if 1st character is newline
   beq  $8, $9, not_good_int

gi_while_1:
   li   $9, 10               # check if character is newline
   beq  $8, $9, gi_finish

   li   $9, 48               # $9 is the ASCII character '0'
   blt  $8, $9, not_good_int
   sub  $8, $8, $9           # $8 is now 2's comp rep that is >= 0

   li   $9, 10               # $9 is now the constant 10
   bge  $8, $9, not_good_int
	 
   mul  $10, $10, $9         # int = ( int * 10 ) + digit
   add  $10, $10, $8
         
   getc $8
   b    gi_while_1           # loop to get more digits

not_good_int:  
   li   $v1, -1	             # return value = -1 for bad int
   b    gi_epilogue

gi_finish: 
   beqz $12, gi_epilogue 
   mul  $10, $10, -1
gi_epilogue: 
   move $v0, $10             # set return value in its proper register
   lw   $8,  4($sp)          # restore register values
   lw   $9,  8($sp)
   lw   $10, 12($sp)
   lw   $11, 16($sp)
   lw   $12, 20($sp)
   lw   $ra, 24($sp)
   add  $sp, $sp, 24         # deallocate AR space
   jr   $ra                  # return

