// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)
//
// This program only needs to handle arguments that satisfy
// R0 >= 0, R1 >= 0, and R0*R1 < 32768.

// Initialize R2 to 0.
@R2
M=0

// If R0 is zero, go straight to END
@R0
D=M
@END
D;JEQ

// Initialize a temporary variable with the content
// of R0. Only to keep R0 intact.
@R0
D=M
@temp
M=D

// Add R1 to R2 R0 times.
(LOOP)
@R1
D=M
@R2
M=M+D
@temp
M=M-1
D=M
@LOOP
D;JGT

(END)
@END
0;JMP
