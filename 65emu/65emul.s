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
#

dprt1:	.word _dprt1
#
# The actual emulation loop for 6502
#
_exec65:

	# insn = mem[PC++];
	lda 2,PC
	sta 2,oldPC
	isz PC		# cannot wrap
	jsr @ld65	# fetch instruction
	sta 0,insn65	# save

	# Save encoded iword
	lda 2,itbl65	# address of instruction table
	add 0,2		# offset into instruction table
	lda 0,0,2	# encoded instruction word
	sta 0,enc65

	# argc = EXTARG(iary[insn].encode);
	lda 1,C7400	# get mask for lower 4 bits in left byte
	addzl 0,0	# shift left two bits
	ands 1,0	# and out argc and put in right byte
	sta 0,argc65	# save argument count

	# opn = EXTOP(iary[insn].encode);
	lda 0,enc65
	lda 1,C77
	and 1,0
	sta 0,opn65

	lda 0,trace
	mov 0,0,szr
	  jsr @dprt1

	# if (argc > ACC)
	# 	addr = mem[PC++];
	lda 0,argc65	# argc number
	subzl 1,1	# ac1 = 1
	inc 1,1		# ac1 = 2
	subz 0,1,szc	# skip if argc > ACC
	  jmp ex1
	lda 2,PC
	isz PC		# cannot wrap
	jsr @ld65	# fetch memory
	sta 0,addr65	# save
ex1:
	# if (argc >= IND)
	#	addr |= (mem[PC++] << 8);
	lda 1,C2	# generate 2
	addzl 1,1	# ac1 = 8
	lda 0,argc65
	subz 0,1,szc	# skip if argc > 8
	  jmp ex2
	lda 2,PC
	isz PC
	jsr @ld65
	movs 0,1
	lda 0,addr65
	add 1,0
	sta 0,addr65
ex2:
	# Get arguments
	jsr fargs

	# if (flags & RDVAL) {
	#	arg8 = A;
	# 	if (argc != ACC)
	#		arg8 = gmem(addr);
	# }
	lda 0,enc65
	lda 1,rdval_v
	and 0,1,snr
	  jmp ex3
	lda 0,A
	sta 0,arg8_65
	lda 0,argc65
	lda 1,C2
	sub 0,1,snr
	  jmp ex3
	lda 2,addr65
	jsr @gmem
	sta 0,arg8_65
ex3:
	# evaluate operations
	jsr @xopdec

	# if (flags & SETNZ)
	#	setnz(arg8);
	lda 0,enc65
	lda 1,setnz_v
	and 0,1,snr
	  jmp ex4

	subo 0,0
	lda 1,arg8_65
	mov 1,1,snr
	  inc 0,0
	sta 0,SR_Z

	subo 0,0
	lda 1,arg8_65
	lda 2,C200
	and 1,2,szr
	  inc 0,0
	sta 0,SR_N
ex4:

	# if ((flags & WRVAL) && !(argc == ACC))
	#	wmem(addr, arg8);
	lda 0,enc65
	lda 1,wrval_v
	and 0,1,snr
	  jmp ex5
	lda 0,argc65
	lda 1,C2
	sub 0,1,snr
	  jmp ex5
	lda 2,addr65
	movl# 2,2,szc	# out of bounds?
	  jmp ex8	# yep, complain
	lda 0,arg8_65
	jsr @st65
	jmp ex5
xopdec:	.word opdec

ex8:
	lda 2,ex5_s
	jmp @die
ex5_s:	.bptr _ex5_s
_ex5_s:	.asciz "WMEM OUT OF BOUNDS"
ex5:

	# if ((flags & WRA) || (argc == ACC))
	#	A = arg8;
	lda 0,enc65
	lda 1,wra_v
	and 0,1,szr
	  jmp ex6
	lda 0,argc65
	lda 1,C2
	sub 0,1,snr
	  jmp ex6
	jmp ex7
ex6:
	lda 0,arg8_65
	sta 0,A
ex7:

	lda 0,trace
	mov 0,0,szr
	  jsr @dprt2

	jmp _exec65

dprt2:	.word _dprt2

#
# Evaluate arguments.
#
fapc:	.word 0
fargs:
	sta 3,fapc
	lda 2,atbl
	lda 0,argc65
	add 0,2
	jmp @0,2

atbl:	.word _atbl
_atbl:	.word faret	# 0 no args
	.word faimm	# 1 immediate
	.word faacc	# 2, ACC
	.word faindx	# 3, INDX
	.word fazpy	# 4, ZPY
	.word faabs	# 5, ZP
	.word farel	# 6, REL
	.word faindy	# 7, INDY
	.word fazpx	# 8, ZPX
	.word faind	# 9, IND
	.word faabs	# 10, ABS, do nothing
	.word faabsy	# 11, ABSY
	.word faabsx	# 12, ABSX

faacc:
	jmp 0,3

fazpx:
	lda 0,addr65
	lda 1,X
	add 1,0
	lda 1,C377
	and 1,0
	sta 0,addr65
	jmp 0,3

fazpy:
	lda 0,addr65
	lda 1,Y
	add 1,0
	lda 1,C377
	and 1,0
	sta 0,addr65
	jmp 0,3

faabsy:
	lda 0,Y
	lda 1,addr65
	add 1,0
	sta 0,addr65
	jmp @fapc

faabsx:
	lda 0,X
	lda 1,addr65
	add 1,0
	sta 0,addr65
	jmp @fapc

faabs:
	jmp @fapc

faimm:
	lda 2,PC
	isz PC		# cannot wrap
	sta 2,addr65	# save
	jmp @fapc

# REL, relative address
farel:
	lda 0,addr65
	lda 1,C200
	lda 2,C377	# all bits set in lower byte
	movs 2,2	# swap to upper byte
	and# 0,1,szr	# sign extend?
	  add 2,0	# yep
	lda 1,PC
	add 1,0		# create new relative address
	sta 0,addr65
	jmp @fapc

inda2:	.word 0
faind:
	lda 2,addr65
	jsr @ld65
	sta 0,inda2
	lda 2,addr65
	inc 2,2
	jsr @ld65
	movs 0,0
	lda 1,inda2
	add 1,0
	sta 0,addr65
	jmp @fapc

indysp:	.word 0
faindy:
	sta 3,indysp
	lda 2,addr65
	jsr @ld65
	sta 0,inda2
	lda 2,addr65
	inc 2,2
	jsr @ld65
	movs 0,0
	lda 1,inda2
	add 1,0
	lda 1,Y
	add 1,0
	sta 0,addr65
	jmp @indysp

indxp:	.word 0
faindx:
	sta 3,indysp
	lda 2,addr65
	lda 0,X
	add 0,2
	lda 0,C377
	and 0,2
	sta 2,indxp
	jsr @ld65
	sta 0,inda2
	lda 2,indxp
	inc 2,2
	jsr @ld65
	movs 0,0
	lda 1,inda2
	add 1,0
	sta 0,addr65
	jmp @indysp

faret:	jmp @fapc

#
# Evaluate opcodes
#
opdec:
	sta 3,oppc

	lda 2,optab
	lda 0,opn65
	add 0,2
	jmp @0,2

optab:	.word _optab
_optab:
	.word ophlt	# 0
	.word opadc	# 1, ADC
	.word opand	# 2, AND
	.word opasl	# 3, ASL
	.word opbcc	# 4, BCC
	.word opbcs	# 5, BCS
	.word opbeq	# 6, BEQ
	.word opbit	# 7, BIT
	.word opbmi	# 8, BMI
	.word opbne	# 9, BNE
	.word opbpl	# 10, BPL
	.word opbrk	# 11, BRK
	.word opbvc	# 12, BVC
	.word opbvs	# 13, BVS
	.word opclc	# 14, CLC
	.word opcld	# 15, CLD
	.word opcli	# 16, CLI
	.word opclv	# 17, CLV
	.word opcmp	# 18, CMP
	.word opcpx	# 19, CPX
	.word opcpy	# 20, CPY
	.word opdecc	# 21, DEC
	.word opdex	# 22, DEX
	.word opdey	# 23, DEY
	.word opeor	# 24, EOR
	.word opinc	# 25, INC
	.word opinx	# 26, INX
	.word opiny	# 27, INY
	.word opjmp	# 28, JMP
	.word opjsr	# 29, JSR
	.word opret	# 30, LDA, do nothing
	.word opldx	# 31, LDX
	.word opldy	# 32, LDY
	.word oplsr	# 33, LSR
	.word opnop	# 34, NOP
	.word opora	# 35, ORA
	.word oppha	# 36, PHA
	.word opphp	# 37, PHP
	.word oppla	# 38, PLA
	.word opplp	# 39, PLP
	.word oprol	# 40, ROL
	.word opror	# 41, ROR
	.word oprti	# 42, RTI
	.word oprts	# 43, RTS
	.word opsbc	# 44, SBC
	.word opsec	# 45, SEC
	.word opsed	# 46, SED
	.word opsei	# 47, SEI
	.word opsta	# 48, STA
	.word opstx	# 49, STX
	.word opsty	# 50, STY
	.word optax	# 51, TAX
	.word optay	# 52, TAY
	.word optsx	# 53, TSX
	.word optxa	# 54, TXA
	.word optxs	# 55, TXS
	.word optya	# 56, TYA
oppc:	.word 0		# return address

ophlt:
	lda 2,ophlt_s
	jmp @die
ophlt_s: .bptr _ophlt_s
_ophlt_s: .asciz "MISSING OPERATOR"
	halt

# ADC
opadc:
	lda 0,SR_D
	mov 0,0,szr	# decimal flag set?
	  jmp adc_d
	jsr calcovf
	lda 0,SR_C
	lda 1,arg8_65	# Fetch C
	add 1,0		# addto
	lda 1,A		# fetch A
	add 1,0		# addto
	subo 1,1	# ac1 = 0
	sta 1,SR_C	# Clear C
	lda 2,C377
	subz# 0,2,snc	# > 255?
	  isz SR_C	# set C
	and 2,0
	sta 0,arg8_65
	jmp @oppc

# Decimal addition
adc_al:	.word 0
adc_ah: .word 0
adc_d:
	lda 2,C17
	lda 0,arg8_65
	and 2,0
	lda 1,A
	and 2,1
	add 1,0
	lda 1,SR_C
	add 1,0
	sta 0,adc_al

	lda 0,arg8_65
	addzl 0,0
	addzl 0,0
	movs 0,0
	and 2,0
	lda 1,A
	addzl 1,1
	addzl 1,1
	movs 1,1
	and 2,1
	add 1,0
	sta 0,adc_ah

	subo 0,0
	sta 0,SR_C

	lda 0,adc_al
	lda 1,C12
	adcz# 0,1,szc	# al >= 10?
	  jmp adc_noal	# no
	isz adc_ah
	sub 1,0
	sta 0,adc_al

adc_noal:
	lda 0,adc_ah
	adcz# 0,1,szc	# ah >= 10?
	  jmp adc_noah
	isz SR_C
	sub 1,0
	sta 0,adc_ah

adc_noah:
	lda 0,adc_ah
	addzl 0,0
	addzl 0,0
	lda 1,adc_al
	add 1,0
	sta 0,arg8_65
	jmp 0,3

# a1=A, a2 = arg8, a3 = C
calcres:.word 0
calcovf:
	subo 0,0
	sta 0,SR_V

# res = a1 + a2 + cin;
	lda 0,A
	lda 1,arg8_65
	add 1,0
	lda 1,SR_C
	add 1,0
	sta 0,calcres

	lda 2,C200

	lda 0,A
	and 2,0
	lda 1,arg8_65
	and 2,1
	sub# 1,0,szr	# a1 == a2?
	  jmp 0,3	# nope, go back
	lda 1,calcres
	and 2,1
	sub# 1,0,szr	# a1 == res?
	  isz SR_V	# nope, set V
	jmp 0,3

# AND
opand:
	lda 0,A
	lda 1,arg8_65
	and 1,0
	sta 0,arg8_65
	jmp 0,3

# ASL
opasl:
	subo 0,0
	sta 0,SR_C	# clear carry
	lda 0,arg8_65	# fetch arg
	movs 0,0	# mov to left byte
	movzl 0,0,szc	# shift left.  High bit set?
	  isz SR_C	# if set, set C
	movs 0,0	# mov back to right byte
	sta 0,arg8_65
	jmp 0,3

# BCC
opbcc:
	lda 0,SR_C
	lda 1,addr65
	mov 0,0,snr
	  sta 1,PC
	jmp @oppc

# BCS
opbcs:
	lda 0,SR_C
	lda 1,addr65
	mov 0,0,szr
	  sta 1,PC
	jmp @oppc

# BEQ
opbeq:
	lda 0,SR_Z
	lda 1,addr65
	mov 0,0,szr
	  sta 1,PC
	jmp @oppc

# BIT
opbit:
	subo 0,0	# Clear N,V,Z
	sta 0,SR_N
	sta 0,SR_V
	sta 0,SR_Z

	lda 0,arg8_65	# transfer bit 7,6 to SR
	movs 0,0
	movzl 0,0,szc	# Set N?
	  isz SR_N
	movzl 0,0,szc	# Set V?
	  isz SR_V

	lda 0,arg8_65
	lda 1,A
	and 1,0,snr	# Set Z?
	  isz SR_Z

	jmp 0,3

# BMI
opbmi:
	lda 0,SR_N
	lda 1,addr65
	mov 0,0,szr
	  sta 1,PC
	jmp 0,3

# BNE
opbne:
	lda 0,SR_Z
	lda 1,addr65
	mov 0,0,szr
	  jmp 0,3
# check for error
	lda 0,oldPC
	sub# 1,0,snr
	  jmp @die
	sta 1,PC
	jmp 0,3

# BPL
opbpl:
	lda 0,SR_N
	lda 1,addr65
	mov 0,0,snr	# skip if N set
	  sta 1,PC
	jmp 0,3

# BRK
brkpc:	.word 0
brkvec:	.word 0xFFFE
brkpush:.word push
brksrb:	.word srbits
opbrk:
	sta 3,brkpc
	isz PC
	lda 0,PC
	movs 0,0
	jsr @brkpush
	lda 0,PC
	jsr @brkpush

	jsr @brksrb
	jsr @brkpush

	subzl 0,0
	sta 0,SR_I
	lda 2,brkvec
	jsr @ld65
	sta 0,PC
	lda 2,brkvec
	inc 2,2
	jsr @ld65
	movs 0,0
	lda 1,PC
	add 1,0
	sta 0,PC
	jmp @brkpc

# BVC
opbvc:
	lda 0,SR_V
	lda 1,addr65
	mov 0,0,snr	# skip if V unset
	  sta 1,PC
	jmp 0,3

# BVS
opbvs:
	lda 0,SR_V
	lda 1,addr65
	mov 0,0,szr	# skip if V set
	  sta 1,PC
	jmp 0,3

# CLC
opclc:
	subo 0,0
	sta 0,SR_C
	jmp 0,3

# CLD
opcld:
	subo 0,0
	sta 0,SR_D
	jmp 0,3

# CLI
opcli:
	subo 0,0
	sta 0,SR_I
	jmp 0,3

# CLV
opclv:
	subo 0,0
	sta 0,SR_V
	jmp 0,3

# CMP
cmpc:	.word 0
opcmp:
	sta 3,cmpc
	lda 1,A
	jsr subval
	jmp @cmpc

# CPX
opcpx:
	sta 3,cmpc
	lda 1,X
	jsr subval
	jmp @cmpc

# CPY
opcpy:
	sta 3,cmpc
	lda 1,Y
	jsr subval
	jmp @cmpc


# compare ac1 with arg8 and set flags
subval:
	subo 0,0
	sta 0,SR_C	# Clear carry
	lda 2,C377
	lda 0,arg8_65
	com 0,0		# bitwise complement
	and 2,0		# ensure only lower byte
	add 1,0		# add complemented value
	inc 0,0		# add final value for complement
	subz# 0,2,snc	# > 255?
	  isz SR_C	# set C
	and 2,0		# only lower byte
	sta 0,arg8_65
	jmp 0,3

# DEC
opdecc:
	lda 0,arg8_65
	neg 0,0
	com 0,0
	lda 1,C377
	and 1,0
	sta 0,arg8_65
	jmp 0,3

# DEX
opdex:
	dsz X
	mov 0,0		# dec may be zero
	lda 0,X
	lda 1,C377
	and 1,0
	sta 0,arg8_65
	sta 0,X
	jmp 0,3

# DEY
opdey:
	dsz Y
	mov 0,0		# dec may be zero
	lda 0,Y
	lda 1,C377
	and 1,0
	sta 0,arg8_65
	sta 0,Y
	jmp 0,3

# EOR
opeor:
	lda 0,A
	lda 1,arg8_65
	mov 1,2
	andzl 0,2
	add 0,1
	sub 2,1
	sta 1,arg8_65
	jmp 0,3

# INC
opinc:
	lda 0,arg8_65
	inc 0,0
	lda 1,C377
	and 1,0
	sta 0,arg8_65
	jmp 0,3

# INX
opinx:
	lda 0,X
	inc 0,0
	lda 1,C377
	and 1,0
	sta 0,X
	sta 0,arg8_65
	jmp 0,3

# INY
opiny:
	lda 0,Y
	inc 0,0
	lda 1,C377
	and 1,0
	sta 0,Y
	sta 0,arg8_65
	jmp 0,3

# JMP
opjmp:
	lda 1,addr65
	lda 0,oldPC
	sub# 1,0,snr
	  jmp jmperr
	sta 1,PC
	jmp 0,3

jmpsucc:.word 0x3469	# address for success
jmperr:
	lda 0,jmpsucc
	sub# 1,0,szr
	  jmp @die

# test ran OK.  
	lda 2,sucs
	jsr @putstr
	halt

sucsb:	.asciz "TEST PROGRAM PASSED\r\n"
sucs:	.bptr sucsb


# JSR
jsrpc:	.word 0
jsrinp:	.word 0xffcf
jsrout:	.word 0xffd2
jsrc:	.word 0xffe1
jsrskp:	.word 0xffe7
opjsr:
	sta 3,jsrpc

	lda 1,addr65
	lda 0,jsrinp
	sub# 0,1,snr
	  jmp input
	lda 0,jsrout
	sub# 0,1,snr
	  jmp output
	lda 0,jsrc
	sub# 0,1,snr
	  jmp jsrsetc
	lda 0,jsrskp
	sub# 0,1,snr
	  jmp @jsrpc

	dsz PC
	lda 0,PC
	movs 0,0
	jsr push
	lda 0,PC
	jsr push
	lda 0,addr65
	sta 0,PC
	jmp @jsrpc

jsrsetc:
	subzl 0,0
	sta 0,SR_C
	jmp @jsrpc

inp_a:	.word 'a
inp_z:	.word 'z
inmsk:	.word 0xdf
input:
	jsr @getch
	# convert lower case to upper
	lda 1,inp_a
	adcz# 0,1,szc	# skip if ac0 >= 'a'
	  jmp inret
	lda 1,inp_z
	subz# 0,1,snc	# skip if ac0 <= 'z'
	  jmp inret
	lda 1,inmsk
	and 1,0

inret:	jsr @putch
	sta 0,A
	jmp @jsrpc

output:
	lda 0,A
	lda 1,C12
	sub# 1,0,snr	# Ignore LF
	  jmp @jsrpc
	jsr @putch
	lda 1,C15
	sub# 1,0,szr	# return if not CR
	  jmp @jsrpc
	lda 0,C12
	jsr @putch
	jmp @jsrpc

# LDX
opldx:
	lda 0,arg8_65
	sta 0,X
	jmp 0,3

# LDY
opldy:
	lda 0,arg8_65
	sta 0,Y
	jmp 0,3

# LSR
oplsr:
	subo 0,0
	sta 0,SR_C
	lda 0,arg8_65
	movzr 0,0,szc
	  isz SR_C
	sta 0,arg8_65
	jmp 0,3

# NOP
opnop:
	jmp 0,3

# ORA
opora:
	lda 0,arg8_65
	lda 1,A
	com 0,0
	and 0,1
	adc 0,1
	sta 1,arg8_65
	jmp 0,3

# PHA
opphapc:.word 0
oppha:
	sta 3,opphapc
	lda 0,A
	jsr push
	jmp @opphapc

# PLA
oppla:
	sta 3,opphapc
	jsr pop
	sta 0,arg8_65
	jmp @opphapc

# PLP
plpmsk:	.word 0xcf
opplp:
	sta 3,opphapc
	jsr pop
	lda 1,plpmsk
	and 1,0		# mask away unwanted bits read form stack

	jsr wsrbits

	jmp @opphapc

# Write status bits in ac0 to their positions
wsrbits:
	# clear all flags first
	lda 1,C10
	sta 1,placnt
	lda 1,plasrn
	sta 1,030
	subo 1,1

	sta 1,@030
	dsz placnt
	  jmp .-2

	# set flags popped
	lda 1,C10
	sta 1,placnt
	lda 1,plasrc
	sta 1,020

	subo 1,1
	movzr 0,0,szc
	  inc 1,1
	sta 1,@020
	dsz placnt
	  jmp .-5
	jmp 0,3

# PHP
srsets:	.word (1 << 4) | (1 << 5)
placnt: .word 0
plasrn:	.word SR_N+1
plasrc:	.word SR_C-1
plapc:	.word 0
opphp:
	sta 3,plapc
	jsr srbits
	jsr push
	jmp @plapc

# Get all SR bits in ac0
srbits:
	# First create the SR byte
	lda 1,C10	# number of flags
	sta 1,placnt
	lda 1,plasrn	# pointer to highest flag storage +1
	sta 1,030
	subo 0,0	# clear destination flag reg

	lda 1,@030	# fetch flag value
	movzl 0,0	# shift left one
	mov 1,1,szr	# flag set?
	  inc 0,0	# yep, set bit
	dsz placnt	# # all flags checked?
	  jmp .-5

# Now all bits in ac0
# Set always bits
	lda 1,srsets
	com 1,1		# or in always set bits
	and 1,0
	adc 1,0
	jmp 0,3


# pop a value from stack
# return in ac0
poppc:	.word 0
pop:
	sta 3,poppc
	lda 2,SP
	inc 2,2
	lda 1,C377
	and 1,2
	sta 2,SP
	lda 1,C400
	add 1,2
	jsr @ld65
	jmp @poppc

# push ac0 onto stack
push:
	sta 3,poppc
	lda 2,SP	# fetch SP
	lda 1,C400	# fetch stack offset
	add 1,2		# create pointer
	lda 1,C377
	and 1,0
	jsr @st65
	neg 2,2		# sub one from stack
	com 2,2
	lda 1,C377
	and 1,2		# ensure only low 8 bits for SP
	sta 2,SP
	jmp @poppc

# ROL
oprol:
	lda 2,SR_C
	subo 0,0
	sta 0,SR_C
	lda 0,arg8_65
	movs 0,0
	movzl 0,0,szc
	  isz SR_C
	movs 0,0
	add 2,0
	sta 0,arg8_65
	jmp 0,3

# ROR
opror:
	lda 2,SR_C
	movs 2,2
	subo 0,0
	sta 0,SR_C
	lda 0,arg8_65
	add 2,0
	movzr 0,0,szc
	  isz SR_C
	sta 0,arg8_65
	jmp 0,3

# RTI
rtipc:	.word 0
rtimsk:	.word 0xcf
oprti:
	sta 3,rtipc
	jsr pop
	lda 1,rtimsk
	and 1,0
	jsr wsrbits

	jsr pop
	sta 0,PC
	jsr pop
	movs 0,1
	lda 0,PC
	add 1,0
	sta 0,PC
	jmp @rtipc

# RTS
rtspc:	.word 0
oprts:
	sta 3,rtspc
	jsr pop
	sta 0,PC
	jsr pop
	movs 0,1
	lda 0,PC
	add 1,0
	inc 0,0
	sta 0,PC
	jmp @rtspc

# SBC
sbcovf:	.word calcovf
sbcpc:	.word 0
opsbc:
	sta 3,sbcpc
	lda 0,SR_D
	mov 0,0,szr
	  jmp sbcdec
	lda 0,arg8_65
	com 0,0
	lda 1,C377
	and 1,0
	sta 0,arg8_65
	jsr @sbcovf

	lda 0,A
	lda 1,arg8_65
	add 1,0
	lda 1,SR_C
	add 1,0
	subo 1,1
	sta 1,SR_C
	lda 2,C377
	subz# 0,2,snc
	  isz SR_C
	and 2,0
	sta 0,arg8_65
	jmp @sbcpc

sbc_al:	.word 0
sbc_ah: .word 0
# Decimal addition
x3484: .word 0x3484
sbcdec:
	lda 2,C17
	lda 1,A
	and 2,1		# al of A,  (A & 15)

	lda 0,arg8_65
	and 2,0
	sub 0,1		# A - arg8; - (arg8 & 15)

	# complement C
	lda 0,SR_C
	inc 0,0
	subzl 2,2	# create 1
	and 2,0		# ac0 == ~C

	sub 0,1		# sub C from previous res
	sta 1,sbc_al
	sta 2,SR_C	# set C

	lda 2,C17

	lda 1,A
	addzl 1,1
	addzl 1,1
	movs 1,1
	and 2,1

	lda 0,arg8_65
	addzl 0,0
	addzl 0,0
	movs 0,0
	and 2,0

	sub 0,1
	sta 1,sbc_ah

	# al negative?
	lda 0,sbc_al
	lda 1,C12
	movl# 0,0,snc
	  jmp sbc_noal
	add 1,0
	dsz sbc_ah
	mov 0,0		# dsz may skip, may be 0
	sta 0,sbc_al

sbc_noal:
	lda 0,sbc_ah
	movl# 0,0,snc
	  jmp sbc_noah
	add 1,0
	sta 0,sbc_ah
	subo 0,0
	sta 0,SR_C

sbc_noah:
	lda 0,sbc_ah
	addzl 0,0
	addzl 0,0
	lda 1,sbc_al
	add 1,0
	sta 0,arg8_65
	jmp 0,3

# SEC
opsec:
	subzl 0,0
	sta 0,SR_C
	jmp 0,3

# SED
opsed:
	subzl 0,0
	sta 0,SR_D
	jmp 0,3

# SEI
opsei:
	subzl 0,0
	sta 0,SR_I
	jmp 0,3

# STA
opsta:
	lda 0,A
	sta 0,arg8_65
	jmp 0,3

# STX
opstx:
	lda 0,X
	sta 0,arg8_65
	jmp 0,3

# STY
opsty:
	lda 0,Y
	sta 0,arg8_65
	jmp 0,3

# TAX
optax:
	lda 0,A
	sta 0,X
	sta 0,arg8_65
	jmp 0,3

# TAY
optay:
	lda 0,A
	sta 0,Y
	sta 0,arg8_65
	jmp 0,3

# TSX
optsx:
	lda 0,SP
	sta 0,X
	sta 0,arg8_65
	jmp 0,3

# TXA
optxa:
	lda 0,X
	sta 0,arg8_65
	jmp 0,3

# TXS
optxs:
	lda 0,X
	sta 0,SP
	jmp 0,3

# TYA
optya:
	lda 0,Y
	sta 0,arg8_65
	jmp 0,3

opret:	jmp 0,3

#
# Read memory while sanity checking
#
gmembbtm: .word 0xc000
gmembtop: .word 0xe1de
gmempc:	.word 0
_gmem:
	sta 3,gmempc
	movzl# 2,2,snc
	  jmp gld	# (addr & 0x8000) == 0)

	lda 0,gmembtop
	subz# 0,2,szc
	  jmp gmemerr
	lda 0,gmembbtm
	adcz# 0,2,snc
	  jmp gmemerr
gld:	jsr @ld65
	jmp @gmempc
gmemerr:
	lda 2,gm2_s
	jmp @die
gm2_s:	.bptr _gm2_s
_gm2_s:	.asciz "GMEM OUTSIDE BOUNDS"
