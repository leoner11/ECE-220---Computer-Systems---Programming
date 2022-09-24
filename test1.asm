.ORIG x3000
; Add this test code to the start of your file (just after .ORIG).
; I'd put it in another file, but we can't use the PRINT_SLOT and 
; PRINT_CENTERED labels outside of the mp1.asm file (at least, not 
; easily).

; Read the comments in this file to understand what it's doing and
; for ways that you can use this test code.  You can also just run
; it and diff the output with the output produced by our 'gold'
; (bug-free!) version.
;
; After assembling mp1 with lc3as, execute the test script by typing
;    lc3sim -s script1 > your_output
; (look at the script--it just loads mp1 with a file command, then
; continues execution; when the LC-3 halts, the script is finished,
; so the simulator halts).
;
; You can then type
; 	diff your_output out1
; to compare your code's output with ours.
;

	; feeling lazy, so I'm going to set all of the bits to the same value
	LD	R0,BITS
	ADD	R2,R0,#0
	ADD	R3,R0,#0
	ADD	R4,R0,#0
	ADD	R5,R0,#0
	ADD	R6,R0,#0

	; let's try PRINT_SLOT ... 11:00
	AND	R1,R1,#0
	ADD	R1,R1,#4

	; set a breakpoint here in the debugger, then use 'next' to
	; execute your subroutine and see what happens to the registers;
	; they're not supposed to change (except for R7)...
	JSR	PRINT_CENTERED

	; we're short on human time to test your code, so we'll do 
	; something like the following instead (feel free to replicate)...
	LD	R7,BITS
	NOT	R7,R7
	ADD	R7,R7,#1
	ADD	R0,R0,R7
	BRz	R0_OK
	LEA	R0,R0_BAD
	PUTS
R0_OK	

	; this trap changes register values, so it's not sufficient
	; to check that all of the registers are unchanged; HALT may
	; also lead to confusion because the register values differ
	; for other reasons (R7 differences, for example).
	HALT

BITS	.FILL	xABCD	; something unusual
VLINE	.FILL	x7C	; ASCII vertical line character
R0_BAD	.STRINGZ "PRINT_SLOT changes R0!\n"

; your code should go here ... don't forget .ORIG and .END

PRINT_SLOT

    LEA R0, TIME_STRINGS
	LOOP_MAMMA_MIA
	; R1 jadi parameter of how much u wanna times the R0
	ADD R0, R0, #7 ; this prints out 08:00
	ADD R1, R1, #-1
	BRp LOOP_MAMMA_MIA ; loops back to LOOP_MAMMA_MIA
	TRAP x22 ; Print out the TIME_SLOT given


PRINT_CENTERED

AND R0, R0, #0
AND R5, R5, #0
AND R2, R2, #0
AND R3, R3, #0
AND R4, R4, #0
AND R6, R6, #0

	;R2 STORE ADDRESS
	;R3 IS THE COUNTER
        LD R2, INPUT
        BRz PRINT_SUSPICIOUS_STUFF
        AND R2, R2, #0
   	LEA R2, INPUT ;STORE_STRING

	COUNTER_FOR_INPUT

		ADD R3, R3, #1 ;COUNTER
		ADD R2, R2, #1 ;Move address stored in R2
		LDR R0, R2, #0
		BRnp COUNTER_FOR_INPUT
		BRnzp FILTER_LENGTH_TEST

	; ex: string length 6
	; kalau dikurang 6 = positive, berarti dia lebih dri 6
	; kalau dikurang 6 = negatif, dibawah 6
	; kalau dikurang 6 = zero, dia pas 6

	PRINT_SUSPICIOUS_STUFF

		LD R0, SPACE
		ADD R6, R6, #6

		COUNTER
			TRAP x21
			ADD R6, R6, #-1
			BRp COUNTER
			BRnzp STOP
	

	FILTER_LENGTH_TEST

	ADD R5, R5, R3 ; store in SAVE_LOAD_DATA
	ADD R3, R3, #-6
	BRp IF_STRING_MORE_6
	BRz IF_STRING_EQUALS_6
	BRn IF_STRING_LESS_6


	IF_STRING_MORE_6

		AND R0, R0, #0
        LEA R2, INPUT
        LDR R0, R2, #0
		AND R3, R3, #0
		ADD R3, R3, #6

		COUNTER_MORE_6

			TRAP X21
			ADD R2, R2, #1 ; this is counter max 6 kali to change the address of the String
            LDR R0, R2, #0
			ADD R3, R3, #-1 ; this until 6 times until finally goes back to
			BRp COUNTER_MORE_6
			BRnzp STOP
		
		

	IF_STRING_EQUALS_6

		LEA R0, INPUT
		TRAP x22
		BRnzp STOP


    IF_STRING_EQUALS_5

        LEA R0, INPUT
        TRAP x22
        LD R0, SPACE
        TRAP x21
        BRnzp STOP


	IF_STRING_LESS_6
		
        TEST_IF_EQUALS_5

            ADD R5, R5, #-5
            BRz IF_STRING_EQUALS_5

        ADD R5, R5, #5
		ADD R5, R5, #-6
		NOT R5, R5
        ADD R5, R5, #1
		; R5 contains the number of spaces we need to print (either trailing or leading space)
		; skrg valuenya 1 misalnya

		TRAILING_SPACE_COUNTER

			;INGAT SEMUA REGISTER NTAR HARUS DI RECONFIGURE LAGI
			ADD R4, R4, #1 ;R4 is the amount of trailing space needed
			ADD R5, R5, #-1
			BRp LEADING_SPACE_COUNTER
			BRnzp PRINT_LEADING_SPACE
		
		LEADING_SPACE_COUNTER

			ADD R6, R6, #1 ;R5 is the amount of leading space needed
			ADD R5, R5, #-1
			BRp TRAILING_SPACE_COUNTER
			BRnzp PRINT_LEADING_SPACE

		PRINT_LEADING_SPACE

            ; ADD R5, R5, #0
            ; BRz PRINT_STRING_HERE

            LD R0, SPACE
			TRAP x21
            ADD R6, R6, #-1
			BRp PRINT_LEADING_SPACE

		PRINT_STRING_HERE

			LEA R0, INPUT
			TRAP x22
            
            
		PRINT_TRAILING_SPACE

            LD R0, SPACE
			TRAP x21
            ADD R4, R4, #-1
			BRp PRINT_TRAILING_SPACE
			BRnzp STOP

		; for length of 5, just add one space in the back
		; for length of 2 and 4 just add spaces in the front and back
		; for length of 1 and 3, adds a space in the front and 2 in the back


;SAVE_LOAD_DATA SEMENTARA MASIH TIDAK DIPAKAI
SAVE_LOAD_DATA ;for 
LDR R3, R5, #0 ; bring back value of r3 in print centered


TIME_STRINGS
    .STRINGZ "07:00 "
    .STRINGZ "08:00 "
    .STRINGZ "09:00 "
    .STRINGZ "10:00 "
    .STRINGZ "11:00 "
    .STRINGZ "12:00 "
    .STRINGZ "13:00 "
    .STRINGZ "14:00 "
    .STRINGZ "15:00 "
    .STRINGZ "16:00 "
    .STRINGZ "17:00 "
    .STRINGZ "18:00 "
    .STRINGZ "19:00 "
    .STRINGZ "20:00 "
    .STRINGZ "21:00 "
    .STRINGZ "22:00 "


INPUT
	.STRINGZ "ANJING"

SPACE
	.FILL x0020

STOP
HALT
.END

