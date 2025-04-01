# Copyright (c) 2024, Anders Magnusson
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Convert a 6502 memory address to a nova byte address
# in:  ac2 - 6502 address
# out: ac2 - Nova byte address
# scr: 
_m65ton:
	lda 0,holesz	# fetch size of 6502 memory hole
	movl# 2,2,szc	# address over 32k?
	  sub 0,2	# yes, subtract hole size
	lda 0,mstart	# fetch start of 6502 memory in nova byte memory
	add 0,2		# make final address
	jmp 0,3		# return

#
# Store ac0 in 6502 memory
# ac0 - value
# ac2 - address
#
_st65:
	sta 3,st65ret
	sta 2,st65addr
	sta 0,st65val
	jsr _m65ton
	lda 0,st65val
	jsr @sbyt
	lda 2,st65addr
	jmp @st65ret

st65ret: .word 0
st65addr: .word 0
st65val: .word 0

#
# Load a 6502 byte into ac0
# ac2: address
#
_ld65:
	sta 3,st65ret
	jsr _m65ton
	jsr @lbyt
	jmp @st65ret

#
# Print out all registers
# PC=0000 A=00 X=00 Y=00 SP=00 SR=00000000
dr0:	.word ('P << 8) | 'C
dr1:	.word 'A
dr2:	.word 'X
dr3:	.word 'Y
dr4:	.word 'P | ('S << 8)
dr5:	.word 'R | ('S << 8)
drcrlf: .word 015 | (012 << 8)
drpc:	.word 0
_dumpreg:
	sta 3,drpc
	lda 0,drcrlf
	jsr drstr
	lda 0,dr0
	lda 1,PC
	jsr pr1
	lda 0,dr1
	lda 1,A
	jsr pr1
	lda 0,dr2
	lda 1,X
	jsr pr1
	lda 0,dr3
	lda 1,Y
	jsr pr1
	lda 0,dr4
	lda 1,SP
	jsr pr1
#	lda 0,dr5
#	lda 1,SR
#	jsr pr1
	lda 0,drcrlf
	jsr drstr
	jmp @drpc

# 
dr1sp:	.word 0
dr1_1:	.word 0
dr1_x:	.word '=
dr1_s:	.word 32
pr1:
	sta 3,dr1sp
	sta 1,dr1_1
	jsr drstr	# print reg name
	lda 0,dr1_x
	jsr @putch
	lda 0,dr1_1
	jsr drhex	# print ac0 in hex
	lda 0,dr1_s
	jsr @putch	# space
	jmp @dr1sp

# Print reg name in ac0
drspc:	.word 0
drstr:
	sta 3,drspc
	mov 0,1
	movs 0,0
	lda 2,C377
	and 2,0,szr
	  jsr @putch
	mov 1,0
	jsr @putch
	jmp @drspc

# Print the number in ac0 in hex.
# If upper byte set, print four digits, otherwise 2
drhsp:	.word 0
drhac0: .word 0
drhex:
	sta 3,drhsp
	sta 0,drhac0
	movs 0,0
	lda 2,C377
	and 2,0,szr
	  jsr drhex2
	lda 0,drhac0
	jsr drhex2
	jmp @drhsp

# Print the low byte in ac0 in hex.
_drctab: .word '0,'1,'2,'3,'4,'5,'6,'7,'8,'9,'A,'B,'C,'D,'E,'F
drctab: .word _drctab
drhpc:	.word 0
drhex2:
	sta 3,drhpc
	mov 0,2
	lda 1,C4
	jsr @shr
	lda 3,drctab
	lda 1,C17
	and 1,0
	add 0,3
	lda 0,0,3
	jsr @putch
	mov 2,0
	lda 1,C17
	and 1,0
	lda 3,drctab
	add 0,3
	lda 0,0,3
	jsr @putch
	jmp @drhpc

dstaddr:.word ('A << 8) | 'D, ('D << 8) | 'R
dstarg: .word ('A << 8) | 'R, ('G << 8) | 'C
dstopn: .word ('O << 8) | 'P
dstpc:	.word 0
_dumpstate:
	sta 3,dstpc
# ARGC
	lda 0,dstarg
	jsr drstr
	lda 0,dstarg+1
	jsr drstr
	lda 0,dr1_x
	jsr @putch
	lda 0,argc65
	jsr drhex
	lda 0,dr1_s
	jsr @putch

# OP
	lda 0,dstopn
	jsr drstr
	lda 0,dr1_x
	jsr @putch
	lda 0,opn65
	jsr drhex
	lda 0,dr1_s
	jsr @putch

# ADDR
	lda 0,dstaddr
	jsr drstr
	lda 0,dstaddr+1
	jsr drstr
	lda 0,dr1_x
	jsr @putch
	lda 0,addr65
	jsr drhex
	lda 0,dr1_s
	jsr @putch

	lda 0,adrcrlf
	jsr drstr
	jmp @dstpc

adrcrlf: .word 015 | (012 << 8)

_prtexit:
	jsr @putstr
	lda 0,excrlf
	jsr drstr
	halt

excrlf: .word 015 | (012 << 8)

die1:	.word 0
_die:
	sta 2,die1
	jsr @dumpreg
	jsr @dumpstate
	lda 2,die1
	jmp _prtexit


_dprtops:
	.word ('E << 8) | 'R, ('R << 8) | 32
	.word ('A << 8) | 'D, ('C << 8) | 32
	.word ('A << 8) | 'N, ('D << 8) | 32
	.word ('A << 8) | 'S, ('L << 8) | 32
	.word ('B << 8) | 'C, ('C << 8) | 32
	.word ('B << 8) | 'C, ('S << 8) | 32
	.word ('B << 8) | 'E, ('Q << 8) | 32
	.word ('B << 8) | 'I, ('T << 8) | 32
	.word ('B << 8) | 'M, ('I << 8) | 32
	.word ('B << 8) | 'N, ('E << 8) | 32
	.word ('B << 8) | 'P, ('L << 8) | 32
	.word ('B << 8) | 'R, ('K << 8) | 32
	.word ('B << 8) | 'V, ('C << 8) | 32
	.word ('B << 8) | 'V, ('S << 8) | 32
	.word ('C << 8) | 'L, ('C << 8) | 32
	.word ('C << 8) | 'L, ('D << 8) | 32
	.word ('C << 8) | 'L, ('I << 8) | 32
	.word ('C << 8) | 'L, ('V << 8) | 32
	.word ('C << 8) | 'M, ('P << 8) | 32
	.word ('C << 8) | 'P, ('X << 8) | 32
	.word ('C << 8) | 'P, ('Y << 8) | 32
	.word ('D << 8) | 'E, ('C << 8) | 32
	.word ('D << 8) | 'E, ('X << 8) | 32
	.word ('D << 8) | 'E, ('Y << 8) | 32
	.word ('E << 8) | 'O, ('R << 8) | 32
	.word ('I << 8) | 'N, ('C << 8) | 32
	.word ('I << 8) | 'N, ('X << 8) | 32
	.word ('I << 8) | 'N, ('Y << 8) | 32
	.word ('J << 8) | 'M, ('P << 8) | 32
	.word ('J << 8) | 'S, ('R << 8) | 32
	.word ('L << 8) | 'D, ('A << 8) | 32
	.word ('L << 8) | 'D, ('X << 8) | 32
	.word ('L << 8) | 'D, ('Y << 8) | 32
	.word ('L << 8) | 'S, ('R << 8) | 32
	.word ('N << 8) | 'O, ('P << 8) | 32
	.word ('O << 8) | 'R, ('A << 8) | 32
	.word ('P << 8) | 'H, ('A << 8) | 32
	.word ('P << 8) | 'H, ('P << 8) | 32
	.word ('P << 8) | 'L, ('A << 8) | 32
	.word ('P << 8) | 'L, ('P << 8) | 32
	.word ('R << 8) | 'O, ('L << 8) | 32
	.word ('R << 8) | 'O, ('R << 8) | 32
	.word ('R << 8) | 'T, ('I << 8) | 32
	.word ('R << 8) | 'T, ('S << 8) | 32
	.word ('S << 8) | 'B, ('C << 8) | 32
	.word ('S << 8) | 'E, ('C << 8) | 32
	.word ('S << 8) | 'E, ('D << 8) | 32
	.word ('S << 8) | 'E, ('I << 8) | 32
	.word ('S << 8) | 'T, ('A << 8) | 32
	.word ('S << 8) | 'T, ('X << 8) | 32
	.word ('S << 8) | 'T, ('Y << 8) | 32
	.word ('T << 8) | 'A, ('X << 8) | 32
	.word ('T << 8) | 'A, ('Y << 8) | 32
	.word ('T << 8) | 'S, ('X << 8) | 32
	.word ('T << 8) | 'X, ('A << 8) | 32
	.word ('T << 8) | 'X, ('S << 8) | 32
	.word ('T << 8) | 'Y, ('A << 8) | 32
dprtops: .word _dprtops
dprtcsp: .word (': << 8) | ' 
dprttt:	.word ('\t << 8) | '\t

dpdrsp:	.word 32
dpdrstr: .word drstr
dpdrhex: .word drhex
dprt1pc: .word 0
dprt1x:	.word 0
#
# Print trace 
_dprt1:
	sta 3,dprt1pc

# Print PC
	lda 0,oldPC
	jsr @dpdrhex
	lda 0,dprtcsp
	jsr @dpdrstr

# Print opcode
	lda 0,insn65
	jsr @dpdrhex
	lda 0,dpdrsp
	jsr @dpdrstr

# Print OP
	lda 2,dprtops
	lda 0,opn65
	movzl 0,0
	add 0,2
	sta 2,dprt1x

	lda 0,0,2
	jsr @dpdrstr
	lda 2,dprt1x
	lda 0,1,2
	jsr @dpdrstr
	lda 0,dprttt
	jsr @dpdrstr

	jmp @dprt1pc

dprtss:	.word ('; << 8) | ' 
dprtae:	.word 'A
dprtxe:	.word 'X
dprtye:	.word 'Y
dprtcl:	.word ('\r << 8) | '\n
drpr1:	.word pr1
drprd:	.word '-
_dprt2:
	sta 3,dprt1pc
	lda 0,dprtss
	jsr @dpdrstr

	lda 0,dprtae
	lda 1,A
	jsr @drpr1

	lda 0,dprtxe
	lda 1,X
	jsr @drpr1

	lda 0,dprtye
	lda 1,Y
	jsr @drpr1

# print out flags as either their letter or a -
	lda 1,C10
	sta 1,drprcnt	# number of status flags
	lda 1,drprsrn	# pointer to highest flag storage +1
	sta 1,030	# auto-decrement location
	lda 1,drprpp	# pointer to highest flag name -1
	sta 1,020	# auto-inc location

	lda 0,drprd	# fetch -
	lda 1,@030	# fetch flag value
	lda 2,@020	# fetch flag name
	mov 1,1,szr	# flag set?
	  mov 2,0	# give name
	jsr @putch
	dsz drprcnt	# all flags checked?
	  jmp .-7

	lda 0,dprtcl
	jsr @dpdrstr

	jmp @dprt1pc

drprcnt:.word 0
drprsrn:.word SR_N+1
drprpp:	.word drprpa-1
drprpa:	.word 'N
	.word 'V
	.word 'W
	.word 'B
	.word 'D
	.word 'I
	.word 'Z
	.word 'C
