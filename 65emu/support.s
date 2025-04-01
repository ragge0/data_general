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
	.text

# in: ac2, string pointer
# calls: lbyt, putch
#
putstr_ret:	.word 0

_putstr:
	sta 3,putstr_ret
plp:	jsr @lbyt
	mov 0,0,snr
	  jmp @putstr_ret
	jsr @putch
	inc 2,2
	jmp plp

#
# Load byte (rtol version)
# in: ac2	byte pointer
# out: ac0	byte read
# ac1 destroyed
#
_lbyt:
	lda 1,C377
	movr 2,2,szc
	  movs 1,1
	lda 0,0,2
	and 1,0,szc
	  movs 0,0
	movl 2,2
	jmp 0,3

#
# Store byte (rtol version)
# in: ac2	byte pointer
# in: ac0	byte to write (upper bits must be 0)
# ac1 destroyed
_sbyt:
	sta 3,sbytret
	lda 3,C377
	movr 2,2,szc	# create word ptr
	  movs 0,0,skp	# if left swap byte
	  movs 3,3	# if right swap mask
	lda 1,0,2	# fetch word
	and 3,1
	add 1,0
	sta 0,0,2
	movl 2,2
	jmp @sbytret

sbytret: .word 0
#
# write character in ac0 to tto
# in: ac0
#
_putch:
	skpbz tto
	  jmp .-1
	doas 0,tto
	jmp 0,3


#
# Read a char from tti.
# out: ac0
#
_getch:
	skpdn tti
	  jmp .-1
	dias 0,tti
	jmp 0,3

# shift ac0 right ac1 bits
# destroys ac1.  Result in ac0.
_shr:
	neg 1,1,snr
	  jmp 0,3
	movzr 0,0
	inc 1,1,szr
	  jmp .-2
	jmp 0,3

# Read a number from tti until CR
rdn:	.word 0
rderr:	.word 0
rdpc:	.word 0
_rdnum:
	sta 3,rdpc
	subo 0,0
	sta 0,rdn	# Clear return num
	sta 0,rderr	# Clear error

rd1:	jsr @getch
	jsr @putch
	lda 1,C15
	sub# 1,0,snr
	  jmp rdret	# got CR
	lda 1,C60
	subz 1,0,snc	# below 0?
	  isz rderr	# yep, set err
	lda 1,C12
	adcz# 0,1,snc	# skip if <10
	  isz rderr	# set err
# ac0 0 <= n < 10 now
	lda 2,rdn
	mov 2,1
	addzl 2,2
	addzl 1,2
	add 0,2
	sta 2,rdn
	jmp rd1

# get back
rdret:
	lda 0,rderr
	subzl 1,1
	mov 0,0,szr	# put error in C
	  movzr 1,1
	lda 0,rdn
	jmp @rdpc

