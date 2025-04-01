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

tstr:	.bptr _tstr
qstr:	.bptr _qstr
start:
# What to do?
	lda 2,qstr
	jsr @putstr
	jsr @rdnum	# fetch a number, return in ac0, C set if err
	mov 0,0,szc	
	  jmp start	# error, redo
	mov 0,0,snr
	  jmp basic	# 0, basic
	movzr 0,0,szr	# skip if 1
	  jmp start

	lda 2,tstr
	jsr @putstr
	jsr @rdnum

# Test program is a 64k image but only low bytes + vectors are relevant.
# Since we have a hole 0x8000-0xbfff we load the last 16k block twice.
	lda 0,C16k	# 0x4000
	subo 2,2	# 0
	jsr @load
	lda 0,C16k
	lda 2,C16k
	jsr @load
	lda 0,C16k
	lda 2,C48k
	jsr @load
	lda 0,C16k
	lda 2,C48k
	jsr @load
	lda 2,tdone
	jsr @putstr
	lda 0,diagstart
	sta 0,PC
	jmp @exec65

tdone:	.bptr _tdone
C10k:	.word 0x2800
C16k:	.word 0x4000
C48k:	.word 0xc000


_tdone:	.asciz "\r\n\r\nTEST PROGRAM STARTING...\r\n"
_qstr:	.asciz "\r\n\r\nTEST PROGRAM OR BASIC? (1/0)  "
_tstr:	.asciz "\r\n\r\nINSERT TEST PROGRAM TAPE AND PRESS <CR> "
_bdone:	.asciz "\r\n\r\nBASIC INTERPRETER STARTING...\r\n\r\n"

bdone:	.bptr _bdone
basic:
	lda 0,C10k
	lda 2,C48k
	jsr @load
	lda 2,bdone
	jsr @putstr
	lda 0,bastart
	sta 0,PC
	jmp @exec65
