# Author: Miguel Mendez - utdallas.edu
# Modification History:
# This code was written by Miguel Mendez on 20 November 2021.
# Procedures:
#	main:	Takes in as an input the file name and makes sure its a valid input
#	loNew: 	Loads a character from the input file and also stores it into the newFileContent buffer
#	readNoStore:	Loads a character from the input file but DOESN'T store it into the newFileContent
#	printTheOutput:	This subroutine prints the output of the main procedure to the console as well as the output file
#	prtany: 	Calculates the output in binary or hexadecimal and prints it to the console as well as the output file
#	prtDecimal:	Calculates the output in base 10 and prints it to the console as well as the output file
#	calculate:	This function calculates the input value and records it in base 10
#######################################################

.data
        fout:   	.asciiz "testout.txt"      # hard coded filename for output, could be swapped with FileName?
        eSpace:		.asciiz " "
        colon:		.asciiz ":"
        semiColon:	.asciiz ";"
        newLinen:	.asciiz "\n"
    	lineNumber:	.asciiz ".) "
    	comma:		.asciiz ","
        Prompt1: 	.asciiz "Please enter the input file name: "
        Error:          .asciiz "Error while opening file"
        space:          .asciiz "      "
	userInput:  .asciiz     "Please enter your integer: "
	nl:         .asciiz     "\n"
	hexInput:   .asciiz     "Here is the input in hexadecimal: "
	binaryOutput:   .asciiz "Here is the output in binary: "
	hexOutput:  .asciiz     "Here is the output in hexadecimal: "
	hexDigit:   .asciiz     "0123456789ABCDEF"
	obuf:       .space      130
	obufe:        
        
        
        .align 2 
        fileContent:    .space 1
        newFileContent:	.space 100000
        FileName:	.space 20
        Original:	.space 4
        #.align 1
        #newFileContent: .space 100000

########################################################        

        .text
        .globl main
        
# main:
# Author: Miguel Mendez - utdallas.edu
# Modification History:
# This code was written by Miguel Mendez on 21 October 2021 and modified on Nov 22 2021
# Description: This procedure is the main body of code for the program. 
# It begins by taking as an input the file name
# Opens and reads the input file name byte by byte
# Then stores the read characters into various registers 
# and in the end outputs the results both to console output and the 
# Arguments:
#	$s0 - The address of array fileContent, this is used to get $t0
#	$t1 - InputType stored as a <char>
#	$t2 - InputLength stored as an <int>
#	$t3 - OutputType stored as a <char>
#	$t4 - Universally used loop counter <int>
#	$t5 - Misc register stored as a <char>
#	$t6 - Misc integer stored as a <int>
#	$t7 - OutputType stored as a <char>
#	$t8 - LineCounter stored as a <int>
#	$t9 - InputValue stored as a <int>
#	$s2 - InputValue Base stored as a <int>
#	$s4 - <Address> of 'original' string buffer
#	$s5 - Base of outputValue <int>
#	$s6 - File descriptor for file input and later, file output
#	$s7 - NewFileContent <address>
               
main:
        # Printing Prompt1 (Asking for input file name)
        li $v0,4		# Load $v0 with a command to print a string 
        la $a0, Prompt1		# Loading prompt 1 into the address $a0
        syscall                 # Execute command specified by $v0	
        
        # Reading the input for FileName and saving it to FileName
        li $v0, 8		# Loading $v0 with a command to read a String from the console
        la $a0, FileName	# Loading 'FileName' into the address $a0
        la $a1, 20		# Setting the limit to 'FileName' length
        syscall                 # Execute command specified by $v0			
	
	# Cleanup the 'FileName' by removing the '\n' character
	la $s0, FileName   	# $s0 contains base address of FileName
	loop:			# Loop to find the '\n' character
	lb $s1, 0($s0)   	# load character into $s1 from the $s0 filename array
	beq $s1, 10, end   	# Break to end if $s1 (byte) is equal to 10 (newline)
   	addi $s0, $s0, 1  	# increment str address
   	j loop			# Continue looping until the end is reached
	end:			
   	sb $0, 0($s0)   	# replace newline with 0
        
        # open 'FileName' 
        li $v0,13               # Loading $v0 with a system call service for opening file
        la $a0,FileName        	# Load 'FileName' into the address $a0
        li $a1,0                # set file flag = read (0)
        syscall                 # Execute command specified by $v0
        move $s6,$v0		# save the file descriptor to $s6 we will use this later
        bne $s6,-1,L0		# Break to L0(Regularly scheduled programming) if opening file was successful, otherwise,
        
Error1: # Print message "Error while opening file input.txt"
        li $v0,4		# Load $v0 with a command to print a string          
        la $a0,Error       	# Load the error message into the address $a0
        syscall                 # Execute command specified by $v0
        j Exit 			# Exit out of program
             
L0:	# This part doesn't really do anything anymore but initialize $s7
        la $s7,newFileContent   # $s7= address of array newFileContent              
########################################### Read Line Loop ###################################################### 
                      
        add $t8,$0,$0		# Initialize $t8 (file line counter) to 0
Next:   # This is the start of the character counter loop
	addi $t8,$t8,1		# Increment $t8 (line counter) by 1
	jal loNew		# Call load next byte function
        # Load inputType
	move $t1,$t0		# Store input type into $t1
	jal getInputBase	# Call getInputBase which stores the input value base
	# Load inputLength
	jal loNew		# Call load next byte function
	andi $t0,$t0,0x0F 	# Translate $t0 from an ASCII char into a integer using a bit mask
	move $t2,$t0		# Store inputLength into $t2
	# Load inputLength part 2 OR outputType 
	jal loNew		# Call load next byte function
	bgt $t0,'9', noNum	# Branch to noNum if $t0 isn't a digit
	mul $t2,$t2,10		# Otherwise multiply $t2 by 10
	andi $t0,$t0,0x0F 	# Translate $t0 from an ASCII char into a integer using a bit mask
	add $t2,$t2,$t0 	# Add $t0 and $t2 and store in $t2 to get new inputLength
	# Load outputType
	jal loNew		# Call load next byte function
noNum:	move $t3,$t0		# Store output type into $t3
	jal getOutputBase	# Call getOutputBase which stores the output value base
	# Load colon and space
	jal loNew		# Call load next byte function
	jal loNew		# Call load next byte function
	# Load plus or negative
	jal loNew		# Call load next byte function
	move $t7,$t0		# Store sign value into $t7
	#################### Start aloop for loading inputValue ##########################
	li $t4, 0		# Initialize counter $t4 for loopc
	la $s4, Original	# Initialize $s4 to the beginning address of the string 'Original'
	li $t9, 0		# Initialize $t9 which will hold the input value in base 10
	loopc:			# Loop through the inputValue secton of input	
	bge $t4,$t2,nPart 	# Branch out of loopc to nPart when $t4 is greater than $t2(inputLength)
	jal loNew		# Call load next byte function
	sb $t0,0($s4)		# Store char $t0 into Original array
	addi $s4,$s4,1		# Increment $s4 address by 1 
	beq $t0,32,loopc	# Restart loop if a space was loaded instead of a number
	jal calculate		# Call calculate which calculates the input value and stores it in $t9 in base 10
	addi $t4,$t4,1		# Increment loop counter $t4
	j loopc			# Restart loopc
	#################### Ending of loading inputValue loop ##########################
	nPart:			# Now print the output
	jal printTheOutput	# Call printTheOutput to print the output and save it to new file 
	#XXXXXXXXXXX#
	newLineLoop:		# Loop through the rest of the line until a '\n' is found
	jal readNoStore		# Call read next byte function
	beq $t0,10,L4		# If the loaded char ($t0) is equal to '\n' branch to L4
	j newLineLoop		# Restart newLineLoop
	#XXXXXXXXXXX#
L4:	# Repeat Read Line Loop
        j Next                  # repeat the above process from label Next until end of file is reached
        
########################################### End of Read Line Loop #################################################

loopDone: 			# Outside of Read Line Loop structure. 
	addi $s7,$s7,-1		# Remove "\n" by replacing the char at newFileContent pointer 
	sb $0, 0($s7) 		# Enter end of file into the newFileContent, where "\n" would be
	# Close the input file
        li $v0, 16              # Load $v0 with a System call service routine for closing file
        move $a0,$s6            # File descriptor to close
        syscall                 # Execute command specified by $v0	
        
WriteToFile:			# This writes the buffer newFileContent into the file "testout.txt"
  ###############################################################
  # Open (for writing) a file that does not exist
  li   $v0, 13       		# system call for open file
  la   $a0, fout    		# output file name
  li   $a1, 1        		# Open for writing (flags are 0: read, 1: write)
  li   $a2, 0        		# mode is ignored
  syscall            		# Execute command specified by $v0      
  move $s6, $v0      		# save the file descriptor 
  ###############################################################
  # Write to file just opened
  li   $v0, 15       		# system call for write to file
  move $a0, $s6      		# file descriptor 
  la   $a1, newFileContent   	# address of buffer from which to write
  li   $a2, 10000       	# hardcoded buffer length
  syscall                 	# Execute command specified by $v0 #Write to file
  ###############################################################
  # Close the file 
  li   $v0, 16       		# system call for close file
  move $a0, $s6      		# file descriptor to close
  syscall                 	# Execute command specified by $v0 #Close file
  ###############################################################
  
Exit:   # Following lines exit to the OS
	li $v0,10		# Load $v0 with a command to terminate the program
        syscall                 # Execute command specified by $v0
        
################################# VVVVVVVVV FUNCTIONS VVVVVVVVV ################################################

# loNew:
# Author: Miguel Mendez - utdallas.edu
# Modification History:
# This code was written by Miguel Mendez on 21 October 2021 and modified on Nov 22 2021
# Description: Procedure to loop through the entire input file, storing the character into $t0
# This function also stores the character at $t0 into a buffer newFileContent'
# Arguments:
#	$s0 - The <address> of array fileContent, this is used to get $t0 
#	$s6 - File descriptor of the input file 
#	$s7 - The current <address> of newFileContent array 
#	$t0 - The <character> located at $s0 

loNew:
	# Read content from file
        li $v0, 14              # Load $v0 with a System call service for reading file
        move $a0,$s6            # Move the file descriptor ($s6) into $a0
        la $a1,fileContent      # The buffer that holds the file content
        la $a2,1            	# file length of 1, we will have to call use syscall for every char
        syscall                 # Execute command specified by $v0
        beqz $v0,loopDone	# If $v0 returns 0, no characters were read, break to loopDone
	# Load array address
        la $s0,fileContent      # $s0= address of array fileContent
	lb $t0,0($s0)		# Load character at fileContent array address pointer into $t0
	sb $t0,0($s7)		# Store character $t0 into newFileContent array at pointer
	addi $s7,$s7,1		# Increment NewFileContent array address pointer by 1
	jr $ra			# Return	
	# I noticed that storing the fileContent array address into $s7 caused my data to overflow a lot
	# and filled up my data segment by a LOT
	# But I dont know what else I could have done,
	# I can't store it into a floating point

#####################################################################################################################################

# readNoStore
# Author: Miguel Mendez - utdallas.edu
# Modification History:
# This code was written by Miguel Mendez on 21 October 2021 and modified on Nov 22 2021
# Description: Procedure to loop through the entire input file, storing the character into $t0
# The is the same as loNew but it doesn't store the characters read into newFileContent array
# Somehow this seemed like a better idea than just using a boolean value to store or dont store
# Arguments:
#	$s0 - The <address> of array fileContent, this is used to get $t0 
#	$s6 - File descriptor of the input file 
#	$t0 - The <character> located at $s0 

readNoStore:
	# Read content from file
        li $v0, 14              # Load $v0 with a System call service for reading file
        move $a0,$s6            # Move the file descriptor ($s6) into $a0
        la $a1,fileContent      # The buffer that holds the file content
        la $a2,1            	# file length of 1, we will have to call use syscall for every char
        syscall                 # Execute command specified by $v0
        beqz $v0,loopDone	# If $v0 returns 0, no characters were read, break to loopDone
	# Load array address
        la $s0,fileContent      # $s0= address of array fileContent
	lb $t0,0($s0)		# Load character at fileContent array address pointer into $t0 
	jr $ra			# Return	
################################ ********** Print output functions ********** #####################################

# printTheOutput:
# Author: Miguel Mendez - utdallas.edu
# Modification History:
# This code was written by Miguel Mendez on 21 November 2021
# Description: Print the output of the program to both the standard output, and the file output
# Does this by printing the content of various different registers
# Anything that is meant to be printed to the file output is saved into the buffer NewFileContent
# Arguments:
#	$s0 - The address of array fileContent, this is used to get $t0
#	$t1 - InputType stored as a <char>
#	$t2 - InputLength stored as an <int>
#	$t3 - OutputType stored as a <char>
#	$t4 - Universally used loop counter <int>
#	$t5 - Misc register stored as a <char>
#	$t6 - Misc integer stored as a <int>
#	$t7 - OutputType stored as a <char>
#	$t8 - LineCounter stored as a <int>
#	$t9 - InputValue stored as a <int>
#	$s2 - InputValue Base stored as a <int>
#	$s4 - <Address> of 'original' string buffer
#	$s5 - Base of outputValue <int>
#	$s7 - NewFileContent <address>
printTheOutput:
printLineNo:	# Print the line number to standard output and a "==" to file output
	li $v0, 1		# Load $v0 with a command to print an integer
	move $a0,$t8		# Load $t8 (LineCounter) into $a0
	syscall                 # Execute command specified by $v0
	li $v0,4		# Load $v0 with a command to print a string
	la $a0,lineNumber	# Load ".) " into the argument to finish printing line number
	syscall                 # Execute command specified by $v0
	#% Now start printing to newFileContent 
	li $t5,9		# Use temporary register $t5 to store a TAB
	sb $t5,0($s7)		# Store character $t5 into newFileContent array at pointer
	addi $s7,$s7,1		# Increment NewFileContent array address pointer by 1
	li $t5,61		# Use temporary register $t5 to store a "="
	sb $t5,0($s7)		# Store character $t5 into newFileContent array at pointer
	addi $s7,$s7,1		# Increment NewFileContent array address pointer by 1
	li $t5,61		# Use temporary register $t5 to store a "="
	sb $t5,0($s7)		# Store character $t5 into newFileContent array at pointer
	addi $s7,$s7,1		# Increment NewFileContent array address pointer by 1 	 	
	li $t5,32		# Use temporary register $t5 to store a SPACE
	sb $t5,0($s7)		# Store character $t5 into newFileContent array at pointer
	addi $s7,$s7,1		# Increment NewFileContent array address pointer by 1
printInputType:
	li $v0,11		# Load $v0 with a command to print a character 
	move $a0,$t1		# Load $t1 (inputType) into the argument
	syscall                 # Execute command specified by $v0
	#% Now start printing to newFileContent
	move $t5,$t1		# Use temporary register $t5 to store a character
	sb $t5,0($s7)		# Store character $t5 into newFileContent array at pointer
	addi $s7,$s7,1		# Increment NewFileContent array address pointer by 1
printCoSp:	# Print a colon and a space to output and file output
	li $v0,4		# Load $v0 with a command to print a string
	la $a0,colon		# Load ":" into the argument
	syscall                 # Execute command specified by $v0
	li $v0,4		# Load $v0 with a command to print a string
	la $a0,eSpace		# Load " " into the argument
	syscall                 # Execute command specified by $v0
	#% Now start printing to newFileContent
	li $t5,58		# Use temporary register $t5 to store a character colon
	sb $t5,0($s7)		# Store character $t5 into newFileContent array at pointer
	addi $s7,$s7,1		# Increment NewFileContent array address pointer by 1
	li $t5,32		# Use temporary register $t5 to store a space character
	sb $t5,0($s7)		# Store character $t5 into newFileContent array at pointer
	addi $s7,$s7,1		# Increment NewFileContent array address pointer by 1
printSign:
	li $v0,11		# Load $v0 with a command to print a character
	move $a0, $t7		# Load $t7 (positive/negative sign) into the argument
	syscall                 # Execute command specified by $v0
	#% Now start printing to newFileContent
	move $t5,$t7		# Use temporary register $t5 to store a character
	sb $t5,0($s7)		# Store character $t5 into newFileContent array at pointer
	addi $s7,$s7,1		# Increment NewFileContent array address pointer by 1
printOriginal:
	li $t4, 0		# Initialize counter $t4 to 0
	move $t5,$s4		# Temporary copy $s4 to $t5
	la $s4, Original 	# Storing beginning Original array address to $s4
	subu $t2,$t5,$s4	# We manually reset $t2 to the 'Original' String length incase the input had spaces
	loopb:			# Loop through the 'Original' String
	bge $t4,$t2,printSeCo	# Break out of loop when $t4 = $t2(inputLength)
	li $v0,11		# Load $v0 with a command to print a character	              
	lb $t5,0($s4)		# Load char from $s4 pointer into $t5
	move $a0, $t5		# Load $t5 into the argument $a0
	syscall                 # Execute command specified by $v0
	#% Now start printing to newFileContent
	sb $t5,0($s7)		# Store character $t5 into newFileContent array at pointer
	addi $s7,$s7,1		# Increment NewFileContent array address pointer by 1
	addi $t4,$t4,1		# Increment loop counter by 1
	addi $s4,$s4,1		# Increment Original array address pointer by 1
	j loopb			# Restart loopb
printSeCo:	# Print a semicolon and a space to both output and file output
	li $v0,4		# Load $v0 with a command to print a string
	la $a0,semiColon	# Load ";" into the argument
	syscall                 # Execute command specified by $v0
	li $v0,4		# Load $v0 with a command to print a string
	la $a0,eSpace		# Load " " into the argument
	syscall                 # Execute command specified by $v0
	#% Now start printing to newFileContent
	li $t5,59		# Use temporary register $t5 to store a character ";"
	sb $t5,0($s7)		# Store character $t5 into newFileContent array at pointer
	addi $s7,$s7,1		# Increment NewFileContent array address pointer by 1
	li $t5,32		# Use temporary register $t5 to store a SPACE character 
	sb $t5,0($s7)		# Store character $t5 into newFileContent array at pointer
	addi $s7,$s7,1		# Increment NewFileContent array address pointer by 1
printOutputType:
	li $v0,11		# Load $v0 with a command to print a character
	move $a0,$t3		# Load $t3 (outputType into the argument
	syscall                 # Execute command specified by $v0
	#% Now start printing to newFileContent
	move $t5,$t3		# Use temporary register $t5 to store a character
	sb $t5,0($s7)		# Store character $t5 into newFileContent array at pointer
	addi $s7,$s7,1		# Increment NewFileContent array address pointer by 1    	
printCoSp2:	# Print a colon and a space to both output and file output 
	li $v0,4		# Load $v0 with a command to print a string
	la $a0,colon		# Load ":" into the argument
	syscall                 # Execute command specified by $v0
	li $v0,4		# Load $v0 with a command to print a string
	la $a0,eSpace		# Load " " into the argument
	syscall                 # Execute command specified by $v0
	#% Now start printing to newFileContent
	li $t5,58		# Use temporary register $t5 to store a character ":"
	sb $t5,0($s7)		# Store character $t5 into newFileContent array at pointer
	addi $s7,$s7,1		# Increment NewFileContent array address pointer by 1
	li $t5,32		# Use temporary register $t5 to store a space character 
	sb $t5,0($s7)		# Store character $t5 into newFileContent array at pointer
	addi $s7,$s7,1		# Increment NewFileContent array address pointer by 1
printOutputValue:		
	li	$a1,32		# initialize a1 to 32 this helps with outputing the correct amount of bits
	beq $s5,1,prtany	# If the base of the output is binary branch to print binary
	beq $s5,4,prtany	# If the base is not base 10 branch to prtany to print the output value
	j	prtDecimal	# If the output base is not binary or hexadecimal, call prtDecimal
printNewLn:			# This is the end of the print output subroutine.
	li $v0,4		# Load $v0 with a command to print a string
	la $a0,newLinen		# Load "\n" into the argument to print a new line
	syscall                 # Execute command specified by $v0
	move $s7, $s4 		# Move $s7 back to the saved location
	addi $s7,$s7,1		# Increment past the new line character
	
	jr $ra			# Return 
#######################################   END of inner PrintTheOutput body?  #############################################################

# prtany:
# Author: Craig Estey
# Modification History:
# This code was written by Craig Estey on February 2nd, 2017 and modified by Miguel Mendez on nov 21, 2021 to include spaces every 4 characters
# Description: This procedure prints the output in binary or hexadecimal as requested based on the output base
# It does this by utilizing bitmasking. First the individual digit is isolated and then it is checked against a string to see what its equivalent output is
# An additional loop counter was added, that creates a space every 4 characters.
# Arguments:
#	$s0 - The address of array fileContent, this is used to get $t0
#   	$a0 -- output string
#   	$s5 -- number of bits to output
#   	$a2 -- bit width of number base digit
#	$t4 -- loop counter used for spaces
#   	$t9 -- number to print
#   	$s1 -- current digit value
#   	$s3 -- current remaining number value
#   	$t6 -- output pointer
#   	$a3 -- mask for digit
	prtany:
    	li      $a3,1			# initializing a3 to 1
    	li	$t4,0		   	# start counter for every four print a space
    	sllv    $a3,$a3,$s5             # get mask + 1
    	subu    $a3,$a3,1               # get mask for digit
	# for output
    	la      $t6,obufe               # point one past end of buffer
    	subu    $t6,$t6,1               # point to last char in buffer
    	sb      $zero,0($t6)            # store string EOS
	#% For file output
    	add 	$s7,$s7,44		# Lets try guessing to 44 to see if that looks good 
    	move 	$s4,$s7			# Save the location s7 is at to s4
    	li	$t5,10			# Set $t5 equal to 10 ("\n")
    	sb	$t5,0($s7)		# load new line into the pointer $s7
    	move    $s3,$t9                 # Copy number in $t9 to $s5
	#@@@@@@@@@@@@@@@@@@@@@#
	prtany_loop:	
	beq 	$t4,4,everyFour		# Every 4 characters insert a space
	testStatement:
	add 	$t4,$t4,1		# increment loop counter
    	and     $s1,$s3,$a3             # isolate digit
    	lb      $s1,hexDigit($s1)       # get ascii digit
    	
    	subu    $t6,$t6,1               # move output pointer one left
    	sb      $s1,0($t6)              # store into output buffer
	subu 	$s7,$s7,1		# move newFileContent pointer left
	sb      $s1,0($s7)              # store into output buffer
	
    	srlv    $s3,$s3,$s5             # slide next number digit into lower bits
    	sub     $a1,$a1,$s5             # bump down remaining bit count
    	bgtz    $a1,prtany_loop         # more to do? if yes, loop
	#@@@@@@@@@@@@@@@@@@@@@#
	li $v0,11			# Load $v0 with a command to print a character
	move $a0, $t7			# Load $t7 (positive/negative sign) into the argument
	syscall                 	# Execute command specified by $v0	
	subu $s7,$s7,1			# Decrement newFileContent pointer and add the sign
	sb $t7,0($s7)			# Store character $t7(positive/negative sign) into newFileContent array at pointer
    	# output the number
    	li      $v0,4			# Load $v0 with a command to print a String
    	move    $a0,$t6                 # point to ascii digit string start
    	syscall				# Execute command specified by $v0
	j printNewLn			# Jump to printSign2 unconditionally
    
everyFour:	# Every four digits enter a space
	li  $t5, 32		#load a space into $t5
	subu $t6,$t6,1		#decrement pointer
	subu $s7,$s7,1		#decrement pointer 
	sb  $t5,0($t6)		#store char $t5
	sb  $t5,0($s7) 		#store char $t5 
	li $t4,0		#restart counter
	j testStatement		#jump back

# prtDecimal:
# Author: Miguel Mendez - utdallas.edu
# Modification History:
# This code was written by Miguel Mendez on 21 November 2021
# Description: Print the output in base 10 to both the output and the output file
# Does this by dividing the number by 10 and then placing the remainder at the buffer location
# and using the quotient to do another divide by 10. It repeats this process until it reaches 0.
# Every 3 characters a comma is inserted.
# Arguments:
#	$s7 - The <address> of array NewFileContent, this is used for inserting characters into the buffer
#	$t4 - A loop counter used to count for inserting commas <int>
#	$t5 - Temporary misc. character <char>
#	$t9 - The number of the input <int> 
#	$s3 - a copy of the input number <int>
#	$s5 - The base (10) <int>
#	$t6 - standard output pointer
#	$s1 - The remainder byte <int>
prtDecimal: 
	li 	$t4,0			# Initialize counter $t4 to 0, use this to print commas
	# For Standard output
    	la      $t6,obufe               # point one past end of buffer
    	subu    $t6,$t6,1               # point to last char in buffer
    	sb      $zero,0($t6)            # store string EOS	
    	# For buffer
    	add 	$s7,$s7,45		# Lets try guessing to 45 to see if that looks good
    	move 	$s4,$s7			# Copy and save the location of s7 to $s4
    	li	$t5,10			# Set $t5 equal to 10 ("\n")
    	sb	$t5,0($s7)		# load new line into the pointer $s7
    	move    $s3,$t9                 # Copy number in $t9 to $s3
    	#@@@@@@@@#
	printLoop:
	beq $t4,3,everyThree		# Check to put comma
	testTwo:
	add $t4,$t4,1			# increment counter
	divu $s3,$s5			# divide $s3 by base $s5
	mfhi $s1			# get remainder put $s1
	subu $t6,$t6,1			# move output pointer left
	subu $s7,$s7,1			# move newFileContent pointer left
	lb $s1,hexDigit($s1)       	# get ascii digit
	sb $s1,0($t6)			# store the byte into t6
	sb $s1,0($s7)			# store the byte into $t6
	mflo $s3			# get quotient
	bgtz $s3,printLoop		# If more to do repeat printLoop
	#@@@@@@@@#
	li $v0,11		# Load $v0 with a command to print a character
	move $a0, $t7		# Load $t7 (positive/negative sign) into the argument
	syscall                 # Execute command specified by $v0	
	#add sign
	subu $s7,$s7,1		# Decrement newFileContent pointer and add the sign
	sb $t7,0($s7)		# Store character $t5 into newFileContent array at pointer
	# output string
    	li      $v0,4
    	#syscall

    	# output the number
    	move    $a0,$t6      		# point to ascii digit string start
    	syscall				
	j printNewLn			
	
everyThree: 
	li  $t5, 44			#load a comma into $t5
	subu $t6,$t6,1			#decrement pointer
	subu $s7,$s7,1			# move newFileContent pointer left
	sb  $t5,0($t6)			#store char $t5
	sb  $t5,0($s7) 			#store char $t5 into newFileContent pointer
	li $t4,0			#restart counter
	j testTwo			#jump back    
#############################################################################

################################ ********** End of print functions ********** #####################################

# getInputBase:
# Author: Miguel Mendez - utdallas.edu
# Modification History:
# This code was written by Miguel Mendez on 21 November 2021
# Description: Get the inputBase character and then translate that ASCII key into a integer 
# Arguments:
#	$s2 - inputValueBase
#	$t1 - InputType stored as a <char>

getInputBase: 
	bne $t1,'d',not10	# Check if $t1(inputType) is 'd' and branch to not10 otherwise
	li $s2,10		# Load 10 into $s2 (inputValueBase)
	jr $ra			# Return
not10:
	bne $t1,'b',not2	# Check if $t1(inputType) is 'b' and branch to not2 otherwise
	li $s2,2		# Load 2 into $s2 (inputValueBase)
	jr $ra			# Return
not2:
	li $s2,16		# Load 16 into $s2 (inputValueBase)
	jr $ra			# Return

# getOutputBase:
# Author: Miguel Mendez - utdallas.edu
# Modification History:
# This code was written by Miguel Mendez on 21 November 2021
# Description: Get the inputBase character and then translate that ASCII key into a integer 
# Arguments:
#	$t3 - OutputType stored as a <char>
#	$s5 - OutputBase stored as an <int>
getOutputBase: 
	bne $t3,'D',notTen	# Check if $t3(outputType) is 'D' and branch to notTen otherwise
	li $s5, 10		# Load 10 into $s5 (outputValueBase)
	jr $ra			# Return
notTen:
	bne $t3,'B',notTwo	# Check if $t3(outputType) is 'B' and branch to notTwo otherwise
	li $s5, 1		# Load 1 into $s5 (outputValueBase) We use this for bit masking
	jr $ra			# Return
notTwo:
	li $s5, 4		# Load 4 into $s5 (outputValueBase) We use this for bit masking
	jr $ra			# Return
	
# Calculate:
# Author: Miguel Mendez - utdallas.edu
# Modification History:
# This code was written by Miguel Mendez on 21 November 2021
# Description: Procedure to calculate the inputValue, using the read character, 
# and the inputValueBase, and a misc character
# Arguments:
#	$t0 - Read character stored as an <char>
#	$t9 - Input value stored as an <int>
#	$t6 - misc integer value used for calculation
#	$s2 - inputValueBase stored as an <int>
calculate:
	bgt $t0,'9',hexaNums	# Branch to hexaNums if the char at $t0 is a letter
	mul $t9,$t9,$s2		# Multiply the current $t9(inputValue) by $s2(inputValueBase)
	andi $t6,$t0,0x0F 	# Translate $t0 from ASCII into an int using a bit mask and store into $t6
	add $t9,$t9,$t6		# Add $t6 to $t9(inputValue)
	jr $ra			# Return
hexaNums:	
	mul $t9,$t9,$s2		# Multiply the current $t9(inputValue) by $s2(inputValueBase)
	add $t6,$t0,-55		# Get the integer value by subtracting 55 from the character at $t0 and store in $t6
	add $t9,$t9,$t6		# Add $t6 to $t9(inputValue)
	jr $ra			# Return
