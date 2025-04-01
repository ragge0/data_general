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
	.zrel
	iorst		# init
	nios tti	# start rx
	jmp @_start	# go!
_start:	.word start

# Emulator register storage
A:	.word 0		# Reg A (AC)
X:	.word 0		# Reg X
Y:	.word 0		# Reg Y
SP:	.word 0		# Reg SP
PC:	.word 0		# PC

	.org 040	# after auto-incdec locations
SR_C:	.word 0		# Carry
SR_Z:	.word 0		# Zero
SR_I:	.word 0		# 
SR_D:	.word 0		# Decimal
SR_B:	.word 0		# Break
SR_ALW:	.word 0
SR_V:	.word 0		# Overflow
SR_N:	.word 0		# Negative
lbyt:	.word _lbyt
sbyt:	.word _sbyt
putch:	.word _putch
getch:	.word _getch
putstr:	.word _putstr
load:	.word _load
st65:	.word _st65
ld65:	.word _ld65
exec65:	.word _exec65

# constants and parameters 
C60:	.word 060
C77:	.word 077
C377:	.word 0377
C7400:	.word 07400

mstart:	.word 040000	# start of emulator memory in nova byte mem
mend:	.word 0177777	# end emulator memory
holesz:	.word 0x4000	# 6502 memory hole size
diagstart: .word 0x400
bastart:.word 0xe116

# Emulator-specific variables
insn65:	.word 0		# 71 current opcode of instruction
itbl65: .word _itbl65	# 72 address of encoded instruction table
enc65:	.word 0		# 73 current encoded instruction word
argc65:	.word 0		# 74 argument type for current insn
opn65:	.word 0		# 75 current instruction internal op number
addr65:	.word 0		# current calculated address
arg8_65: .word 0

dumpreg: .word _dumpreg
dumpstate: .word _dumpstate
prtexit: .word _prtexit
die:	.word _die
C2:	.word 2
C3:	.word 3
C4:	.word 4
C10:	.word 010
C12:	.word 012
C15:	.word 015
C17:	.word 017
C200:	.word 0200
C400:	.word 0400
shr:	.word _shr
gmem:	.word _gmem
trace:	.word 0
oldPC:	.word 0
rdnum:	.word _rdnum

setnz_v:.word 001<<10
rdval_v:.word 002<<10
wrval_v:.word 004<<10
wra_v:	.word 010<<10
