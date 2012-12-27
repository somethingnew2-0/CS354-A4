# Name and section: Peter Collins, section 2
# Partner's Name and section: Brennan Schmidt, Section 2

# This MIPS assembly language program loops to read a
# user-entered integer (entered in decimal).  For each valid
# integer read, the integer is printed back out,
# first in decimal, and then in base 2.
# The program ends when a poorly-formed integer is
# read.

.data
int_prompt: .asciiz "Enter an integer: "
integer_array: .word 0:32

.text
__start:
    sub   $sp, $sp, 8   # 2 word AR, for 2 parameters
while:    

    puts  int_prompt
    jal   get_integer 
    bltz  $v1, end       # end when $v1 return value is less than 0
    move  $8, $v0

    sw    $8, 4($sp)
    li    $9, 10        # set base of integer to 10
    sw    $9, 8($sp)
    jal   print_integer
    putc  '\n'

    sw    $8, 4($sp)
    li    $9, 2         # set base of integer to 2
    sw    $9, 8($sp)
    jal   print_integer
    putc  '\n'

    b     while

end:
    putc  '\n'
    add   $sp, $sp, 8   # pop AR
    done
          
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



##################################
#print_integer:
# receives two parameters, an integer to be printed, and a base radix to print out,
# and prints it out
print_integer:
#prologue
	sub $sp, 24
	sw  $ra, 24($sp)
    sw   $8,  4($sp)
    sw   $9,  8($sp)
    sw   $10, 12($sp)
    sw   $11, 16($sp)
    sw   $12, 20($sp)

	la $11 integer_array
	li $12, 0	    # $12 is the digit counter
	lw $8, 28($sp)  #loads first parameter, integer to be printed
	lw $9, 32($sp)  # loads second parameter, base radix of integer
	bgez $8, format_integer # if the number is positive, don't print a '-'
	putc '-'
	mul $8, $8, -1  # convert to positive number after printing minus sign
format_integer:
	rem $10, $8, $9 # get last digit of integer, depending on what base is
	sw $10, ($11)   # store the digit in the integer array
	add $11, 4      # increment address of array
	add $12, 1      # increment digit counter
	div $8, $8, $9  # remove last digit
	bgtz $8, format_integer  # if there are more digits, loop back
	sub $11, 4      # adjust array pointer to point to last digit
output_integer:
	lw $8, ($11)    # load the new first digit
	add $8, 0x30    # convert to ascii value
	putc $8         # output digit
	sub $11, 4      # decrement array pointer
	sub $12, 1      # decrement digit counter
	bgtz $12, output_integer  # if there are more digits, print them!

#epilogue
	li   $v0, 0
	lw   $8,  4($sp)          # restore register values
    lw   $9,  8($sp)
    lw   $10, 12($sp)
    lw   $11, 16($sp)
    lw   $12, 20($sp)
    lw   $ra, 24($sp)
    add  $sp, $sp, 24 
	jr $ra


