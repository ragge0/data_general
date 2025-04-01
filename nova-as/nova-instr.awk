##	$Id: instr.awk,v 1.1 2022/11/12 16:23:44 ragge Exp $
##
##	Instruction definitions for nova.
##
##	Generate instruction definitions for different utilities.
##	It is modeled after the script that were supplied with 4.2BSD.
##
##	THIS FILE IS BOTH AN AWK SCRIPT AND THE DATA
##
##	Usage is as follows;
##	cat instr.awk | awk -v flavor=AS -f instr.awk > instr.h
##	cat instr.awk | awk -v flavor=ADB -f instr.awk > instr.h
##
##
##	Field	Description
##
##	$2	Instruction name
##
##	$3	Type (HARD, SOFT, REG, DIREC)
##
##	$4	Opcode/number/...
##
##	$5	Instruction class (ACE,SSDD,...)
##
## Code that prints out the instructions.
##
{
	if (NF == 0 || $1 != "#")
		next;
	if (flavor == "AS" ) {
		pre="";
		if ($3 == "SOFT")
			pre="B_";
		if ($3 == "HARD" || $3 == "DIREC")
			pre="A_";
		if ($3 == "SKIP")
			$5 = $3;
		if ($3 == "DEV")
			$5 = $3;
		printf "OPC(\"%s\",%s%s,%s)\n",$2,pre,$5,$4;
	}
	if (flavor == "ADB" ) {
		pre="";
		if ($3 == "SOFT")
			next;
		if ($3 == "HARD")
			pre="A_";
		if ($3 == "DEV")
			next;
		if ($3 == "SKIP")
			next;
		if ($3 == "DIREC") {
			next;
		}
		printf "OPC(\"%s\",%s%s,%s)\n",$2,pre,$5,$4;
	}
}
# lda	HARD	0020000	ACE
# sta	HARD	0040000	ACE
# jmp	HARD	0000000	E
# jsr	HARD	0004000	E
# isz	HARD	0010000	E
# dsz	HARD	0014000	E
##
# com	HARD	0100000	ACSD
# neg	HARD	0100400	ACSD

# adc	HARD	0102000	ACSD
# adcz	HARD	0102020	ACSD
# adco	HARD	0102040	ACSD
# adcc	HARD	0102060	ACSD
# adczl	HARD	0102120	ACSD
# adczr	HARD	0102220	ACSD
# adczs	HARD	0102320	ACSD
# adcol	HARD	0102140	ACSD
# adcor	HARD	0102240	ACSD
# adcos	HARD	0102340	ACSD
# adccl	HARD	0102160	ACSD
# adccr	HARD	0102260	ACSD
# adccs	HARD	0102360	ACSD
# adcl	HARD	0102100	ACSD
# adcr	HARD	0102200	ACSD
# adcs	HARD	0102300	ACSD

# mov	HARD	0101000	ACSD
# movz	HARD	0101020	ACSD
# movo	HARD	0101040	ACSD
# movc	HARD	0101060	ACSD
# movzl	HARD	0101120	ACSD
# movzr	HARD	0101220	ACSD
# movzs	HARD	0101320	ACSD
# movol	HARD	0101140	ACSD
# movor	HARD	0101240	ACSD
# movos	HARD	0101340	ACSD
# movcl	HARD	0101160	ACSD
# movcr	HARD	0101260	ACSD
# movcs	HARD	0101360	ACSD
# movl	HARD	0101100	ACSD
# movr	HARD	0101200	ACSD
# movs	HARD	0101300	ACSD

# sub	HARD	0102400	ACSD
# subz	HARD	0102420	ACSD
# subo	HARD	0102440	ACSD
# subc	HARD	0102460	ACSD
# subzl	HARD	0102520	ACSD
# subzr	HARD	0102620	ACSD
# subzs	HARD	0102720	ACSD
# subol	HARD	0102540	ACSD
# subor	HARD	0102640	ACSD
# subos	HARD	0102740	ACSD
# subcl	HARD	0102560	ACSD
# subcr	HARD	0102660	ACSD
# subcs	HARD	0102760	ACSD
# subl	HARD	0102500	ACSD
# subr	HARD	0102600	ACSD
# subs	HARD	0102700	ACSD

# add	HARD	0103000	ACSD
# addz	HARD	0103020	ACSD
# addo	HARD	0103040	ACSD
# addc	HARD	0103060	ACSD
# addzl	HARD	0103120	ACSD
# addzr	HARD	0103220	ACSD
# addzs	HARD	0103320	ACSD
# addol	HARD	0103140	ACSD
# addor	HARD	0103240	ACSD
# addos	HARD	0103340	ACSD
# addcl	HARD	0103160	ACSD
# addcr	HARD	0103260	ACSD
# addcs	HARD	0103360	ACSD
# addl	HARD	0103100	ACSD
# addr	HARD	0103200	ACSD
# adds	HARD	0103300	ACSD

# and	HARD	0103400	ACSD
# andz	HARD	0103420	ACSD
# ando	HARD	0103440	ACSD
# andc	HARD	0103460	ACSD
# andzl	HARD	0103520	ACSD
# andzr	HARD	0103620	ACSD
# andzs	HARD	0103720	ACSD
# andol	HARD	0103540	ACSD
# andor	HARD	0102640	ACSD
# andos	HARD	0103740	ACSD
# andcl	HARD	0103560	ACSD
# andcr	HARD	0103660	ACSD
# andcs	HARD	0103760	ACSD
# andl	HARD	0103500	ACSD
# andr	HARD	0103600	ACSD
# ands	HARD	0103700	ACSD

# inc	HARD	0101400	ACSD
# incz	HARD	0101420	ACSD
# inco	HARD	0101440	ACSD
# incc	HARD	0101460	ACSD
# inczl	HARD	0101520	ACSD
# inczr	HARD	0101620	ACSD
# inczs	HARD	0101720	ACSD
# incol	HARD	0101540	ACSD
# incor	HARD	0101640	ACSD
# incos	HARD	0101740	ACSD
# inccl	HARD	0101560	ACSD
# inccr	HARD	0101660	ACSD
# inccs	HARD	0101760	ACSD
# incl	HARD	0101500	ACSD
# incr	HARD	0101600	ACSD
# incs	HARD	0101700	ACSD

##
# nio	HARD	0060000	NIO
# nios	HARD	0060100	NIO
# nioc	HARD	0060200	NIO
# niop	HARD	0060300	NIO
# dia	HARD	0060400	IO
# dias	HARD	0060500	IO
# diac	HARD	0060600	IO
# diap	HARD	0060700	IO
# doa	HARD	0061000	IO
# doas	HARD	0061100	IO
# doac	HARD	0061200	IO
# doap	HARD	0061300	IO
# dib	HARD	0061400	IO
# dob	HARD	0062000	IO
# dic	HARD	0062400	IO
# doc	HARD	0063000	IO
# skpbn	HARD	0063400	NIO
# skpbz	HARD	0063500	NIO
# skpdn	HARD	0063600	NIO
# skpdz	HARD	0063700	NIO
##
# inten	HARD	0060177	0AC
# intds	HARD	0060277	0AC
# reads	HARD	0060477	1AC
# inta	HARD	0061477	1AC
# msko	HARD	0062077	1AC
# iorst	HARD	0062477	0AC
# halt	HARD	0063077	0AC
# mul	HARD	0073301	0AC
# div	HARD	0073101	0AC
##
# skp	SKIP	001
# szc	SKIP	002
# snc	SKIP	003
# szr	SKIP	004
# snr	SKIP	005
# sez	SKIP	006
# sbn	SKIP	007
##
# tti	DEV	010
# tto	DEV	011
# ptr	DEV	012
# cpu	DEV	077
##
# .zrel	DIREC	0	ZREL
# .bptr DIREC	0	BPTR
##
