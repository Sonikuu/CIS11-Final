
.ORIG x3000

AND R1, R1, #0		;Clear, this is loop counter
AND R4, R4, #0		;This is the digit counter


;------INPUT-------

LOOPSTART
JSR CLS
LEA R0, ASK		;Load ask string to R0
PUTS			;Print

ADD R0, R1, #1		;Move R1 to R0
JSR DISPLAYNUM

LEA R0, ENDASK		;Making it pretty
PUTS

;Now, display current entered number
ADD R0, R4, #0	;Number of digits to read from stack
JSR DIGNUM	;Turns stack into a number
JSR DISPLAYNUM	;And this displays that number

GETC			;Get character
ADD R3, R0, x-A		;First, check if the user pushed enter
BRz NEXTGRADE		;If they did, stop getting chars

ADD R3, R0, x-8		;Check for backspace
BRnp NOTBKSPC
ADD R4, R4, #0		;Check if current digits is 0
BRnz LOOPSTART
JSR POP			;Remove top of stack
ADD R4, R4, #-1		;Decrement digits	
BRnzp LOOPSTART
NOTBKSPC

ADD R3, R4, #-3		;Check if digits is max
BRzp LOOPSTART 

LD R2, NEGCHAROFF	;Convert from char to actual number
ADD R0, R0, R2
BRn LOOPSTART		;If negative, its not a number, get new char
ADD R2, R3, #-9		;Else, check if its above last number char
BRp LOOPSTART		;If it is, get a new char
JSR PUSH		;Else, push to stack
ADD R4, R4, #1		;Increment digit count
BRnzp LOOPSTART		;And get next char

NEXTGRADE
;Get number to put onto stack instead of individual digits
ADD R0, R4, #0
JSR DIGNUM
ADD R3, R0, #0	;Move back for a bit

;Going to clear the digits in stack
DIGITCLEAR
ADD R4, R4, #-1	;Check if digits left is 0
BRn CLEARED
JSR POP		;Pop it
BRnzp DIGITCLEAR

CLEARED
ADD R0, R3, #0
JSR PUSH		;Put the added value onto stack, for later use
ADD R1, R1, #1		
AND R4, R4, #0		;Clear digit counter
LD R2, LOOPCOUNT
ADD R2, R2, R1
BRn LOOPSTART		;If negative, get next grade, else proceed to end

;End, this will display results
LD R1, STACK_START
LD R2, STACK_SIZE
NOT R2, R2
ADD R2, R2, #1	;Negatve stack size
AND R3, R3, #0	;Stack pointer offset
ADD R3, R3, #1
AND R5, R5, #0	;Average counter

LD R4, BASE_MIN	;Set min and max to 100 and 0
ST R4, MIN
LD R4, BASE_MAX
ST R4, MAX
JSR CLS

;-----OUTPUT ALL-----

OUTPUTLOOP
ADD R4, R3, R2	;Check if top of stack
BRp ENDOUTPUTLOOP

LEA R0, OUTGRADE
PUTS

ADD R0, R3, #0		;Move R3 to R0
JSR DISPLAYNUM

LEA R0, ENDASK
PUTS

ADD R4, R1, R3
LDR R0, R4, #0		;Load this position
JSR DISPLAYNUM
ADD R4, R0, #0		;Store R0 in R4
LD R0, SPACE		;Print a space
OUT
ADD R0, R4, #0		;And then print the grade
JSR DISPLAYGRADE

;-----OUTPUT MIN, MAX, AVG---------

;Min check
LD R4, MIN
NOT R4, R4
ADD R4, R4, #1
ADD R4, R4, R0
BRzp NOT_MIN
ST R0, MIN
NOT_MIN

;Max check
LD R4, MAX
NOT R4, R4
ADD R4, R4, #1
ADD R4, R4, R0
BRnz NOT_MAX
ST R0, MAX
NOT_MAX

;Avg add
ADD R5, R5, R0

ADD R3, R3, #1
LD R0, NEWLINE
OUT
BRnzp OUTPUTLOOP

ENDOUTPUTLOOP

LD R0, NEWLINE
OUT

;Calc average
LD R1, LOOPCOUNT
NOT R1, R1
ADD R1, R1, #1
ADD R0, R5, #0
JSR DIV
ST R0, AVG

;Display minimum
LEA R0, MINTXT
PUTS
LD R0, MIN
JSR DISPLAYNUM
ADD R4, R0, #0		;Store R0 in R4
LD R0, SPACE		;Print a space
OUT
ADD R0, R4, #0		;And then print the grade
JSR DISPLAYGRADE
LD R0, NEWLINE
OUT

;Display maximum
LEA R0, MAXTXT
PUTS
LD R0, MAX
JSR DISPLAYNUM
ADD R4, R0, #0		;Store R0 in R4
LD R0, SPACE		;Print a space
OUT
ADD R0, R4, #0		;And then print the grade
JSR DISPLAYGRADE
LD R0, NEWLINE
OUT

;Display average
LEA R0, AVGTXT
PUTS
LD R0, AVG
JSR DISPLAYNUM
ADD R4, R0, #0		;Store R0 in R4
LD R0, SPACE		;Print a space
OUT
ADD R0, R4, #0		;And then print the grade
JSR DISPLAYGRADE
LD R0, NEWLINE
OUT

HALT

;Consts
ASK		.STRINGZ "Enter grade #"
ENDASK		.STRINGZ ": "
OUTGRADE	.STRINGZ "Grade "
MINTXT		.STRINGZ "Lowest:  "
MAXTXT		.STRINGZ "Highest: "
AVGTXT		.STRINGZ "Average: "
CHAROFF 	.FILL x30
NEGCHAROFF 	.FILL x-30
LOOPCOUNT	.FILL #-5
BASE_MIN	.FILL #10000
BASE_MAX	.FILL #0

;Vars
MIN	.FILL #0
MAX	.FILL #0
AVG	.FILL #0

NEWLINE	.FILL xA
SPACE	.FILL x20

STACK_SIZE	.FILL x0
STACK_START	.FILL x4000

;------------FAST MULTIPLICATION-----------------------------------
;Uses: R0 and R1 as input, R0 as output
;R2, R3, R4, and R5 are used but restored
;R2: Temp output
;R3: Bit counter thingy
;R4: Dump register used for checks
;R5: Negative flag
MULT1
;Save registers
ST R1, REGSTR1
ST R2, REGSTR2
ST R3, REGSTR3
ST R4, REGSTR4
ST R5, REGSTR5

AND R2, R2, #0	;Clear output
AND R5, R5, #0	;Clear negative flag
AND R3, R3, #0	;Clear counter
ADD R3, R3, #1	;Add 1 to counter to start

;Negative checks
ADD R4, R0, #0
BRzp MULT_INPUTNOTNEG0	;If input 0 is not negative, skip this
ADD R5, R5, #1	;Add 1 to the flag
NOT R0, R0	;Make positive for now
ADD R0, R0, #1
MULT_INPUTNOTNEG0

ADD R4, R1, #0
BRzp MULT_LOOP	;If input 1 is not negative, skip this
ADD R5, R5, #1	;Add 1 to the flag
NOT R1, R1	;Make positive for now
ADD R1, R1, #1

;Main loop
MULT_LOOP

AND R4, R3, R1	;Check if bits match
BRz MULT_SKIPADD;If not, skip addition
ADD R2, R0, R2	;Add current R0 to R2

MULT_SKIPADD
ADD R0, R0, R0	;Double R0
ADD R3, R3, R3	;Double R3
BRz MULT_END	;If R3 is now 0, skip to end
BRnzp MULT_LOOP	;Else, loop again

MULT_END

;Check if negative flag is set
AND R5, R5, #1
BRz MULT_NOTNEG
NOT R2, R2	;Invert R2
ADD R2, R2, #1
MULT_NOTNEG

;Move R2 to R0
ADD R0, R2, #0

;Load registers
LD R1, REGSTR1
LD R2, REGSTR2
LD R3, REGSTR3
LD R4, REGSTR4
LD R5, REGSTR5
RET		;And return
;-----------------END FASTMULT-----------------------------------------

;----------------DISPLAY NUM SUBROUTINE----------------------
;Uses: R0 as input

;Vars

DISPLAYNUM

ST R0, DREGSTR0	;Store R0 - R7
ST R1, DREGSTR1
ST R2, DREGSTR2
ST R3, DREGSTR3
ST R4, DREGSTR4
ST R5, DREGSTR5
ST R6, DREGSTR6
ST R7, DREGSTR7

;Init values
LD R5, CHAROFF	;Load char offset
AND R2, R2, #0	;Clear 0 flag
LD R6, NUM10000	;Current digit to Divide by
ADD R4, R0, #0
BRzp DISPLAYNUM_LOOP	;If this is negative
LD R0, DASH
OUT
NOT R4, R4
ADD R4, R4, #1

DISPLAYNUM_LOOP
ADD R3, R6, #-1		;Check if current digit is 1
BRz DISPLAYNUM_END	;If it is, end
ADD R0, R4, #0		;Otherwise, divide number by R1
ADD R1, R6, #0
JSR DIV			;R0 is now digit to output, R1 is leftovers
ADD R2, R2, R0		;Check if 0 flag or R0 is greater than 0
BRz DISPLAYNUM_SKIP	;If not, skip out
ADD R0, R0, R5	;Move digit counter + char offset to R0
OUT		;Output

DISPLAYNUM_SKIP
ADD R4, R1, #0		;Move R1 to R4
ADD R0, R6, #0		;Prepare to divide by 10
AND R1, R1, #0
ADD R1, R1, #10
JSR DIV
ADD R6, R0, #0
BRnzp DISPLAYNUM_LOOP	;And repeat

DISPLAYNUM_END
ADD R0, R4, R5	;Just add char offset to R0
OUT		;And done

LD R0, DREGSTR0	;Load R0 - R7
LD R1, DREGSTR1
LD R2, DREGSTR2
LD R3, DREGSTR3
LD R4, DREGSTR4
LD R5, DREGSTR5
LD R6, DREGSTR6
LD R7, DREGSTR7

RET
;------------------------DISPLAY NUM END--------------------

;---------------DIVISION & MODULUS SUBROUTINE----------
;Uses: R0 and R1 as inputs, R0 and R1 as output
;R0 is quotient, R1 is modulus
DIV
ST R2, REGSTR2	;Store R2, R3, R4,
ST R3, REGSTR3
ST R4, REGSTR4
AND R2, R2, x0	;Clear R2 and R3
AND R3, R3, x0	;R3 will be the sign
AND R4, R4, x0	;Modulus

;Zero check
ADD R1, R1, #0
BRnp DIVNOTZERO
AND R0, R0, x0
AND R1, R1, x0
BRnzp DIVEND 
DIVNOTZERO

;Negative checks
ADD R0, R0, #0
BRzp DIVNOTNEG0	;If its not negative, skip this part
ADD R3, R3, #1
NOT R0, R0	;Negate R0
ADD R0, R0, #1
DIVNOTNEG0

ADD R1, R1, #0
BRnz DIVNEG1	;If it IS negative, skip this part
NOT R1, R1	;Negate R1
ADD R1, R1, #1
BRnzp DIVLOOP
DIVNEG1
ADD R3, R3, #1

DIVLOOP	;Main multiplication loop
ADD R0, R0, R1	;Subtract R1 from R0
BRn DIVEND	;If R0 is now negative, end
ADD R2, R2, #1	;Else, add 1 to quotient
BRnzp DIVLOOP	;And repeat, using BRnzp because it uses labels without modifying R7

DIVEND
NOT R1, R1	;Negate R1, make it positive
ADD R1, R1, #1
ADD R4, R1, R0	;Add R0 and R1 together to get modulus
AND R3, R3, x1	;Check if the first bit in R3 is 1
BRnz DIVNEGPROD;If is not, skip invert product step
NOT R2, R2
ADD R2, R2, #1
NOT R4, R4
ADD R4, R4, #1
DIVNEGPROD
	
;Move values
ADD R0, R2, #0
ADD R1, R4, #0

;Reload old values
LD R2, REGSTR2
LD R3, REGSTR3
LD R4, REGSTR4
RET
;---------------DIVISION & MODULUS SUBROUTINE END--------------

;------------------------STACK PUSH SUBROUTINE--------------------------
;Uses: R0 as input

;Start of subroutine
PUSH
ST R1, REGSTR1	;Store R1 and R2
ST R2, REGSTR2

LD R1, STACK_SIZE	;Get current size
ADD R1, R1, #1		;Add 1 to size
ST R1, STACK_SIZE	;Set as new size
LD R2, STACK_START	;Load start pos
ADD R1, R1, R2		;Add together
STR R0, R1, #0		;Store data at new top of stack

LD R1, REGSTR1		;Restore values
LD R2, REGSTR2 
RET
;----------------------STACK PUSH END-------------------------

;------------------------STACK POP SUBROUTINE--------------------------
;Uses: R0 as output

;Start of subroutine
POP
ST R1, REGSTR1	;Store R1, R2, and R7
ST R2, REGSTR2
ST R7, REGSTR7

ST R0, REGSTR0	;Store R0 for a bit
JSR ISEMPTY	;Check if empty
ADD R0, R0, #0
BRp POP_SKIP	;If positive, skip this part
LEA R0, POPERROR	;Print error message
PUTS
LD R7, REGSTR7
RET

LD R0, REGSTR0
POP_SKIP
LD R1, STACK_SIZE	;Get current size
LD R2, STACK_START	;Load start pos
ADD R1, R1, R2		;Add together
LDR R0, R1, #0		;Load data at top of stack
AND R2, R2, #0		;Clear R2
STR R2, R1, #0		;And set the loaded stack spot to 0
LD R1, STACK_SIZE	;Reload stack size
ADD R1, R1, #-1		;Subtract 1
ST R1, STACK_SIZE	;Set


LD R1, REGSTR1		;Restore values
LD R2, REGSTR2 
LD R7, REGSTR7
RET
;----------------------STACK POP END-------------------------

;----------------------STACK ISEMPTY SUBROUTINE---------------
;Uses: R0 as output

;Start of subroutine
ISEMPTY

LD R0, STACK_SIZE	;Get current size
BRz #2			;If 0, skip these lines
AND R0, R0, #0
ADD R0, R0, #1
RET
;------------------------STACK ISEMPTY END------------------

;------------------------CLEAR CONSOLE SUBROUTINE------------------
;Clears the console
;No input, no output
CLS_LINES	.FILL #26	;Lines to clear

CLS
ST R0, REGSTR0
ST R1, REGSTR1
ST R7, REGSTR7

LD R0, NEWLINE
LD R1, CLS_LINES

CLS_LOOP
OUT
ADD R1, R1, #-1
BRp CLS_LOOP
LD R0, REGSTR0
LD R1, REGSTR1
LD R7, REGSTR7
RET
;----------------------CLEAR CONSOLE END-------------------

;-----------------------DIGITS TO NUM SUBROUTINE------------------------
;This will use digits from the stack and turn it into a number, starting from the top of the stack
;With the number of digits specified by input number
;EX: x4003 4, x4002 1, x4001, 5, x4000 0 will be 4150
;Outputs: R0, Inputs: R0
DIGNUM
ST R1, DREGSTR1
ST R2, DREGSTR2
ST R3, DREGSTR3
ST R4, DREGSTR4
ST R5, DREGSTR5
ST R7, DREGSTR7

LD R1, STACK_START
LD R2, STACK_SIZE

ADD R3, R1, R2	;This gets top of stack
AND R2, R2, #0	;Current output
AND R1, R1, #0	;Mult counter
ADD R1, R1, #1
ADD R4, R0, #0	;Loop counter	

DIGNUM_LOOP
ADD R4, R4, #-1	;Check if end
BRn DIGNUM_END

LDR R0, R3, #0	;Get from stack
JSR MULT1	;Multiply
ADD R2, R2, R0	;Add output to total

LD R0, NUM10
JSR MULT1	;Multiply multiplier by 10
ADD R1, R0, #0

ADD R3, R3, #-1	;Move stack pointer down 1
BRnzp DIGNUM_LOOP	;And repeat

DIGNUM_END
ADD R0, R2, #0	;Move output to R0

LD R1, DREGSTR1
LD R2, DREGSTR2
LD R3, DREGSTR3
LD R4, DREGSTR4
LD R5, DREGSTR5
LD R7, DREGSTR7

RET
;------------------------DIGITS TO NUM END------------------

;------------------------DISPLAY GRADE SUBROUTINE---------------
;This will take a number and display the proper grade for it
;Inputs: R0, No outputs

;Consts
GRADE_A	.FILL #-90
GRADE_B	.FILL #-80
GRADE_C	.FILL #-70
GRADE_D	.FILL #-60

CHAR_A	.FILL x41
CHAR_B	.FILL x42
CHAR_C	.FILL x43
CHAR_D	.FILL x44
CHAR_F	.FILL x46

DISPLAYGRADE

ST R0, REGSTR0
ST R1, REGSTR1
ST R7, REGSTR7

LD R1, GRADE_A
ADD R1, R0, R1
BRn DISPLAYGRADE_A
LD R0, CHAR_A
OUT
BRnzp DISPLAYGRADE_END
DISPLAYGRADE_A

LD R1, GRADE_B
ADD R1, R0, R1
BRn DISPLAYGRADE_B
LD R0, CHAR_B
OUT
BRnzp DISPLAYGRADE_END
DISPLAYGRADE_B

LD R1, GRADE_C
ADD R1, R0, R1
BRn DISPLAYGRADE_C
LD R0, CHAR_C
OUT
BRnzp DISPLAYGRADE_END
DISPLAYGRADE_C

LD R1, GRADE_D
ADD R1, R0, R1
BRn DISPLAYGRADE_D
LD R0, CHAR_D
OUT
BRnzp DISPLAYGRADE_END
DISPLAYGRADE_D

;If none of the above, F
LD R0, CHAR_F
OUT

DISPLAYGRADE_END
LD R0, REGSTR0
LD R1, REGSTR1
LD R7, REGSTR7
RET
;------------------------DISPLAY GRADE END------------------------

;Storage
REGSTR0	.FILL #0
REGSTR1	.FILL #0
REGSTR2	.FILL #0
REGSTR3	.FILL #0
REGSTR4	.FILL #0
REGSTR5	.FILL #0
REGSTR6	.FILL #0
REGSTR7	.FILL #0

DREGSTR0	.FILL #0
DREGSTR1	.FILL #0
DREGSTR2	.FILL #0
DREGSTR3	.FILL #0
DREGSTR4	.FILL #0
DREGSTR5	.FILL #0
DREGSTR6	.FILL #0
DREGSTR7	.FILL #0

;Consts
NUM10000	.FILL #10000
NUM10		.FILL #10



POPERROR	.STRINGZ "Stack is empty!\n"
DASH	.FILL x2D


.END
