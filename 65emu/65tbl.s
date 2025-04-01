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
#
	.set ADC,1
	.set AND,2
	.set ASL,3
	.set BCC,4
	.set BCS,5
	.set BEQ,6
	.set BIT,7
	.set BMI,8
	.set BNE,9
	.set BPL,10
	.set BRK,11
	.set BVC,12
	.set BVS,13
	.set CLC,14
	.set CLD,15
	.set CLI,16
	.set CLV,17
	.set CMP,18
	.set CPX,19
	.set CPY,20
	.set DEC,21
	.set DEX,22
	.set DEY,23
	.set EOR,24
	.set INC,25
	.set INX,26
	.set INY,27
	.set JMP,28
	.set JSR,29
	.set LDA,30
	.set LDX,31
	.set LDY,32
	.set LSR,33
	.set NOP,34
	.set ORA,35
	.set PHA,36
	.set PHP,37
	.set PLA,38
	.set PLP,39
	.set ROL,40
	.set ROR,41
	.set RTI,42
	.set RTS,43
	.set SBC,44
	.set SEC,45
	.set SED,46
	.set SEI,47
	.set STA,48
	.set STX,49
	.set STY,50
	.set TAX,51
	.set TAY,52
	.set TSX,53
	.set TXA,54
	.set TXS,55
	.set TYA,56

	.set IMP,0
	.set IMM,1
	.set ACC,2
	.set INDX,3
	.set ZPY,4
	.set ZP,5
	.set REL,6
	.set INDY,7
	.set ZPX,8
	.set IND,9
	.set ABS,10
	.set ABSY,11
	.set ABSX,12

	.set SETNZ,001<<10
	.set RDVAL,002<<10
	.set WRVAL,004<<10
	.set WRA,010<<10

#
# instructions/operands/flags are encoded in a 16-bit word.
# Bit assignment:
#      0 - 5   instruction (6 bits)
#      6 - 9   argument (4 bits)
#      10      flag SETNZ
#      11      flag RDVAL
#      12      flag WRVAL
#      13      flag WRA
#


_itbl65:
	.word BRK|(IMP<<6)|(0)
	.word ORA|(INDX<<6)|(0|SETNZ|RDVAL|WRA)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word ORA|(ZP<<6)|(0|SETNZ|RDVAL|WRA)
	.word ASL|(ZP<<6)|(0|SETNZ|RDVAL|WRVAL)
	.word 0|(0<<6)|(0)
	.word PHP|(IMP<<6)|(0)
	.word ORA|(IMM<<6)|(0|SETNZ|RDVAL|WRA)
	.word ASL|(ACC<<6)|(0|SETNZ|RDVAL|WRVAL)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word ORA|(ABS<<6)|(0|SETNZ|RDVAL|WRA)
	.word ASL|(ABS<<6)|(0|SETNZ|RDVAL|WRVAL)
	.word 0|(0<<6)|(0)
	.word BPL|(REL<<6)|(0)
	.word ORA|(INDY<<6)|(0|SETNZ|RDVAL|WRA)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word ORA|(ZPX<<6)|(0|SETNZ|RDVAL|WRA)
	.word ASL|(ZPX<<6)|(0|SETNZ|RDVAL|WRVAL)
	.word 0|(0<<6)|(0)
	.word CLC|(IMP<<6)|(0)
	.word ORA|(ABSY<<6)|(0|SETNZ|RDVAL|WRA)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word ORA|(ABSX<<6)|(0|SETNZ|RDVAL|WRA)
	.word ASL|(ABSX<<6)|(0|SETNZ|RDVAL|WRVAL)
	.word 0|(0<<6)|(0)
	.word JSR|(ABS<<6)|(0)
	.word AND|(INDX<<6)|(0|SETNZ|RDVAL|WRA)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word BIT|(ZP<<6)|(0|RDVAL)
	.word AND|(ZP<<6)|(0|SETNZ|RDVAL|WRA)
	.word ROL|(ZP<<6)|(0|SETNZ|RDVAL|WRVAL)
	.word 0|(0<<6)|(0)
	.word PLP|(IMP<<6)|(0)
	.word AND|(IMM<<6)|(0|SETNZ|RDVAL|WRA)
	.word ROL|(ACC<<6)|(0|SETNZ|RDVAL|WRVAL)
	.word 0|(0<<6)|(0)
	.word BIT|(ABS<<6)|(0|RDVAL)
	.word AND|(ABS<<6)|(0|SETNZ|RDVAL|WRA)
	.word ROL|(ABS<<6)|(0|SETNZ|RDVAL|WRVAL)
	.word 0|(0<<6)|(0)
	.word BMI|(REL<<6)|(0)
	.word AND|(INDY<<6)|(0|SETNZ|RDVAL|WRA)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word AND|(ZPX<<6)|(0|SETNZ|RDVAL|WRA)
	.word ROL|(ZPX<<6)|(0|SETNZ|RDVAL|WRVAL)
	.word 0|(0<<6)|(0)
	.word SEC|(IMP<<6)|(0)
	.word AND|(ABSY<<6)|(0|SETNZ|RDVAL|WRA)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word AND|(ABSX<<6)|(0|SETNZ|RDVAL|WRA)
	.word ROL|(ABSX<<6)|(0|SETNZ|RDVAL|WRVAL)
	.word 0|(0<<6)|(0)
	.word RTI|(IMP<<6)|(0)
	.word EOR|(INDX<<6)|(0|SETNZ|RDVAL|WRA)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word EOR|(ZP<<6)|(0|SETNZ|RDVAL|WRA)
	.word LSR|(ZP<<6)|(0|SETNZ|RDVAL|WRVAL)
	.word 0|(0<<6)|(0)
	.word PHA|(IMP<<6)|(0)
	.word EOR|(IMM<<6)|(0|SETNZ|RDVAL|WRA)
	.word LSR|(ACC<<6)|(0|SETNZ|RDVAL|WRVAL)
	.word 0|(0<<6)|(0)
	.word JMP|(ABS<<6)|(0)
	.word EOR|(ABS<<6)|(0|SETNZ|RDVAL|WRA)
	.word LSR|(ABS<<6)|(0|SETNZ|RDVAL|WRVAL)
	.word 0|(0<<6)|(0)
	.word BVC|(REL<<6)|(0)
	.word EOR|(INDY<<6)|(0|SETNZ|RDVAL|WRA)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word EOR|(ZPX<<6)|(0|SETNZ|RDVAL|WRA)
	.word LSR|(ZPX<<6)|(0|SETNZ|RDVAL|WRVAL)
	.word 0|(0<<6)|(0)
	.word CLI|(IMP<<6)|(0)
	.word EOR|(ABSY<<6)|(0|SETNZ|RDVAL|WRA)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word EOR|(ABSX<<6)|(0|SETNZ|RDVAL|WRA)
	.word LSR|(ABSX<<6)|(0|SETNZ|RDVAL|WRVAL)
	.word 0|(0<<6)|(0)
	.word RTS|(IMP<<6)|(0)
	.word ADC|(INDX<<6)|(0|SETNZ|RDVAL|WRA)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word ADC|(ZP<<6)|(0|SETNZ|RDVAL|WRA)
	.word ROR|(ZP<<6)|(0|SETNZ|RDVAL|WRVAL)
	.word 0|(0<<6)|(0)
	.word PLA|(IMP<<6)|(0|SETNZ|WRA)
	.word ADC|(IMM<<6)|(0|SETNZ|RDVAL|WRA)
	.word ROR|(ACC<<6)|(0|SETNZ|RDVAL|WRVAL)
	.word 0|(0<<6)|(0)
	.word JMP|(IND<<6)|(0)
	.word ADC|(ABS<<6)|(0|SETNZ|RDVAL|WRA)
	.word ROR|(ABS<<6)|(0|SETNZ|RDVAL|WRVAL)
	.word 0|(0<<6)|(0)
	.word BVS|(REL<<6)|(0)
	.word ADC|(INDY<<6)|(0|SETNZ|RDVAL|WRA)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word ADC|(ZPX<<6)|(0|SETNZ|RDVAL|WRA)
	.word ROR|(ZPX<<6)|(0|SETNZ|RDVAL|WRVAL)
	.word 0|(0<<6)|(0)
	.word SEI|(IMP<<6)|(0)
	.word ADC|(ABSY<<6)|(0|SETNZ|RDVAL|WRA)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word ADC|(ABSX<<6)|(0|SETNZ|RDVAL|WRA)
	.word ROR|(ABSX<<6)|(0|SETNZ|RDVAL|WRVAL)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)				# 80
	.word STA|(INDX<<6)|(0|WRVAL)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word STY|(ZP<<6)|(0|WRVAL)
	.word STA|(ZP<<6)|(0|WRVAL)
	.word STX|(ZP<<6)|(0|WRVAL)
	.word 0|(0<<6)|(0)
	.word DEY|(IMP<<6)|(0|SETNZ)			# 88
	.word 0|(0<<6)|(0)
	.word TXA|(IMP<<6)|(0|SETNZ|WRA)
	.word 0|(0<<6)|(0)
	.word STY|(ABS<<6)|(0|WRVAL)
	.word STA|(ABS<<6)|(0|WRVAL)
	.word STX|(ABS<<6)|(0|WRVAL)
	.word 0|(0<<6)|(0)
	.word BCC|(REL<<6)|(0)				# 90
	.word STA|(INDY<<6)|(0|WRVAL)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word STY|(ZPX<<6)|(0|WRVAL)
	.word STA|(ZPX<<6)|(0|WRVAL)
	.word STX|(ZPY<<6)|(0|WRVAL)
	.word 0|(0<<6)|(0)
	.word TYA|(IMP<<6)|(0|SETNZ|WRA)		# 98
	.word STA|(ABSY<<6)|(0|WRVAL)
	.word TXS|(IMP<<6)|(0)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word STA|(ABSX<<6)|(0|WRVAL)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word LDY|(IMM<<6)|(0|SETNZ|RDVAL)		# A0
	.word LDA|(INDX<<6)|(0|SETNZ|RDVAL|WRA)
	.word LDX|(IMM<<6)|(0|SETNZ|RDVAL)
	.word 0|(0<<6)|(0)
	.word LDY|(ZP<<6)|(0|SETNZ|RDVAL)
	.word LDA|(ZP<<6)|(0|SETNZ|RDVAL|WRA)
	.word LDX|(ZP<<6)|(0|SETNZ|RDVAL)
	.word 0|(0<<6)|(0)
	.word TAY|(IMP<<6)|(0|SETNZ)			# A8
	.word LDA|(IMM<<6)|(0|SETNZ|RDVAL|WRA)
	.word TAX|(IMP<<6)|(0|SETNZ)
	.word 0|(0<<6)|(0)
	.word LDY|(ABS<<6)|(0|SETNZ|RDVAL)
	.word LDA|(ABS<<6)|(0|SETNZ|RDVAL|WRA)
	.word LDX|(ABS<<6)|(0|SETNZ|RDVAL)
	.word 0|(0<<6)|(0)
	.word BCS|(REL<<6)|(0)				# B0
	.word LDA|(INDY<<6)|(0|SETNZ|RDVAL|WRA)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word LDY|(ZPX<<6)|(0|SETNZ|RDVAL)
	.word LDA|(ZPX<<6)|(0|SETNZ|RDVAL|WRA)
	.word LDX|(ZPY<<6)|(0|SETNZ|RDVAL)
	.word 0|(0<<6)|(0)
	.word CLV|(IMP<<6)|(0)				# B8
	.word LDA|(ABSY<<6)|(0|SETNZ|RDVAL|WRA)
	.word TSX|(IMP<<6)|(0|SETNZ)
	.word 0|(0<<6)|(0)
	.word LDY|(ABSX<<6)|(0|SETNZ|RDVAL)
	.word LDA|(ABSX<<6)|(0|SETNZ|RDVAL|WRA)
	.word LDX|(ABSY<<6)|(0|SETNZ|RDVAL)
	.word 0|(0<<6)|(0)
	.word CPY|(IMM<<6)|(0|SETNZ|RDVAL)		# C0
	.word CMP|(INDX<<6)|(0|SETNZ|RDVAL)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word CPY|(ZP<<6)|(0|SETNZ|RDVAL)
	.word CMP|(ZP<<6)|(0|SETNZ|RDVAL)
	.word DEC|(ZP<<6)|(0|SETNZ|RDVAL|WRVAL)
	.word 0|(0<<6)|(0)
	.word INY|(IMP<<6)|(0|SETNZ)			# C8
	.word CMP|(IMM<<6)|(0|SETNZ|RDVAL)
	.word DEX|(IMP<<6)|(0|SETNZ)
	.word 0|(0<<6)|(0)
	.word CPY|(ABS<<6)|(0|SETNZ|RDVAL)
	.word CMP|(ABS<<6)|(0|SETNZ|RDVAL)
	.word DEC|(ABS<<6)|(0|SETNZ|RDVAL|WRVAL)
	.word 0|(0<<6)|(0)
	.word BNE|(REL<<6)|(0)				# D0
	.word CMP|(INDY<<6)|(0|SETNZ|RDVAL)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word CMP|(ZPX<<6)|(0|SETNZ|RDVAL)
	.word DEC|(ZPX<<6)|(0|SETNZ|RDVAL|WRVAL)
	.word 0|(0<<6)|(0)
	.word CLD|(IMP<<6)|(0)				# D8
	.word CMP|(ABSY<<6)|(0|SETNZ|RDVAL)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word CMP|(ABSX<<6)|(0|SETNZ|RDVAL)
	.word DEC|(ABSX<<6)|(0|SETNZ|RDVAL|WRVAL)
	.word 0|(0<<6)|(0)
	.word CPX|(IMM<<6)|(0|SETNZ|RDVAL)		# E0
	.word SBC|(INDX<<6)|(0|SETNZ|RDVAL|WRA)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word CPX|(ZP<<6)|(0|SETNZ|RDVAL)
	.word SBC|(ZP<<6)|(0|SETNZ|RDVAL|WRA)
	.word INC|(ZP<<6)|(0|SETNZ|RDVAL|WRVAL)
	.word 0|(0<<6)|(0)
	.word INX|(IMP<<6)|(0|SETNZ)			# E8
	.word SBC|(IMM<<6)|(0|SETNZ|RDVAL|WRA)
	.word NOP|(IMP<<6)|(0)
	.word 0|(0<<6)|(0)
	.word CPX|(ABS<<6)|(0|SETNZ|RDVAL)
	.word SBC|(ABS<<6)|(0|SETNZ|RDVAL|WRA)
	.word INC|(ABS<<6)|(0|SETNZ|RDVAL|WRVAL)
	.word 0|(0<<6)|(0)
	.word BEQ|(REL<<6)|(0)				# F0
	.word SBC|(INDY<<6)|(0|SETNZ|RDVAL|WRA)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word SBC|(ZPX<<6)|(0|SETNZ|RDVAL|WRA)
	.word INC|(ZPX<<6)|(0|SETNZ|RDVAL|WRVAL)
	.word 0|(0<<6)|(0)
	.word SED|(IMP<<6)|(0)				# F8
	.word SBC|(ABSY<<6)|(0|SETNZ|RDVAL|WRA)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word 0|(0<<6)|(0)
	.word SBC|(ABSX<<6)|(0|SETNZ|RDVAL|WRA)
	.word INC|(ABSX<<6)|(0|SETNZ|RDVAL|WRVAL)
	.word 0|(0<<6)|(0)
