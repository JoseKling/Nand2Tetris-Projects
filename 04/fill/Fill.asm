// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel;
// the screen should remain fully black as long as the key is pressed. 
// When no key is pressed, the program clears the screen, i.e. writes
// "white" in every pixel;
// the screen should remain fully clear as long as no key is pressed.

@8191
D=A
@size
M=D

(NOTPRESSED)
@KBD
D=M
@FILL
    D;JGT
@NOTPRESSED
    D;JEQ

(PRESSED)
@KBD
D=M
@ERASE
    D;JEQ
@PRESSED
    D;JGT

(FILL)
@size
D=M
@i
M=D
(LOOPFILL)
    @i
    D=M 
    @SCREEN
    D=D+A
    A=D
    M=-1
    @i
    MD=M-1
    @LOOPFILL
        D+1;JGT
    @PRESSED
        D+1;JEQ

(ERASE)
@size
D=M
@i
M=D
(LOOPERASE)
    @i
    D=M
    @SCREEN
    D=D+A
    A=D
    M=0
    @i
    MD=M-1
    @LOOPERASE
        D+1;JGT
    @NOTPRESSED
        D+1;JEQ

// In priciple the program es already an infinite loop. Just a safety measure.
(END)
@END
0;JMP