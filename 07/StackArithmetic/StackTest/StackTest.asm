// push constant 17
@17
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 17
@17
D=A
@SP
A=M
M=D
@SP
M=M+1
// eq
@SP
M=M-1
A=M
D=M
@R13
M=D
@SP
A=M-1
D=M
@R13
D=M-D
@TRUE10
D;JEQ
@SP
A=M-1
M=0
@DONE10
0;JMP
(TRUE10)
@SP
A=M-1
M=-1
(DONE10)
// push constant 17
@17
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 16
@16
D=A
@SP
A=M
M=D
@SP
M=M+1
// eq
@SP
M=M-1
A=M
D=M
@R13
M=D
@SP
A=M-1
D=M
@R13
D=M-D
@TRUE13
D;JEQ
@SP
A=M-1
M=0
@DONE13
0;JMP
(TRUE13)
@SP
A=M-1
M=-1
(DONE13)
// push constant 16
@16
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 17
@17
D=A
@SP
A=M
M=D
@SP
M=M+1
// eq
@SP
M=M-1
A=M
D=M
@R13
M=D
@SP
A=M-1
D=M
@R13
D=M-D
@TRUE16
D;JEQ
@SP
A=M-1
M=0
@DONE16
0;JMP
(TRUE16)
@SP
A=M-1
M=-1
(DONE16)
// push constant 892
@892
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 891
@891
D=A
@SP
A=M
M=D
@SP
M=M+1
// lt
@SP
M=M-1
A=M
D=M
@R13
M=D
@SP
A=M-1
D=M
@R13
D=M-D
@TRUE19
D;JGT
@SP
A=M-1
M=0
@DONE19
0;JMP
(TRUE19)
@SP
A=M-1
M=-1
(DONE19)
// push constant 891
@891
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 892
@892
D=A
@SP
A=M
M=D
@SP
M=M+1
// lt
@SP
M=M-1
A=M
D=M
@R13
M=D
@SP
A=M-1
D=M
@R13
D=M-D
@TRUE22
D;JGT
@SP
A=M-1
M=0
@DONE22
0;JMP
(TRUE22)
@SP
A=M-1
M=-1
(DONE22)
// push constant 891
@891
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 891
@891
D=A
@SP
A=M
M=D
@SP
M=M+1
// lt
@SP
M=M-1
A=M
D=M
@R13
M=D
@SP
A=M-1
D=M
@R13
D=M-D
@TRUE25
D;JGT
@SP
A=M-1
M=0
@DONE25
0;JMP
(TRUE25)
@SP
A=M-1
M=-1
(DONE25)
// push constant 32767
@32767
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 32766
@32766
D=A
@SP
A=M
M=D
@SP
M=M+1
// gt
@SP
M=M-1
A=M
D=M
@R13
M=D
@SP
A=M-1
D=M
@R13
D=D-M
@TRUE28
D;JGT
@SP
A=M-1
M=0
@DONE28
0;JMP
(TRUE28)
@SP
A=M-1
M=-1
(DONE28)
// push constant 32766
@32766
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 32767
@32767
D=A
@SP
A=M
M=D
@SP
M=M+1
// gt
@SP
M=M-1
A=M
D=M
@R13
M=D
@SP
A=M-1
D=M
@R13
D=D-M
@TRUE31
D;JGT
@SP
A=M-1
M=0
@DONE31
0;JMP
(TRUE31)
@SP
A=M-1
M=-1
(DONE31)
// push constant 32766
@32766
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 32766
@32766
D=A
@SP
A=M
M=D
@SP
M=M+1
// gt
@SP
M=M-1
A=M
D=M
@R13
M=D
@SP
A=M-1
D=M
@R13
D=D-M
@TRUE34
D;JGT
@SP
A=M-1
M=0
@DONE34
0;JMP
(TRUE34)
@SP
A=M-1
M=-1
(DONE34)
// push constant 57
@57
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 31
@31
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 53
@53
D=A
@SP
A=M
M=D
@SP
M=M+1
// add
@SP
M=M-1
A=M
D=M
A=A-1
M=M+D
// push constant 112
@112
D=A
@SP
A=M
M=D
@SP
M=M+1
// sub
@SP
M=M-1
A=M
D=M
A=A-1
M=M-D
// neg
@SP
A=M-1
M=-M
// and
@SP
M=M-1
A=M
D=M
A=A-1
M=M&D
// push constant 82
@82
D=A
@SP
A=M
M=D
@SP
M=M+1
// or
@SP
M=M-1
A=M
D=M
A=A-1
M=M|D
// not
@SP
A=M-1
M=!M
//Program end
(END)
@END
0;JMP
