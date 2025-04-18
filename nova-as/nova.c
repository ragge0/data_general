/*	$Id: asarchsubr.c,v 1.17 2022/11/13 14:42:46 ragge Exp $	*/
/*
 * Copyright (c) 2022 Anders Magnusson (ragge@ludd.ltu.se).
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <stdio.h>
#include <stddef.h>
#include <string.h>

#include "as.h"

static int little_endian;

//static struct expr *mkbptr(struct expr *e);

enum { A_ACE, A_E, A_ACSD, A_NIO, A_IO, A_0AC, A_1AC,
	A_ZREL, A_BPTR, SKIP, DEV };
#define LASTC	A_1AC
static char *idec[LASTC+1];

#define OPC(x,y,z)	{ HDRNAM(x), y, z },
struct insn insn[] = {
#include "instr.h"
};
int ninsn = sizeof(insn) / sizeof(insn[0]);

#define MKACS(x) ((x) << 13)
#define MKACD(x) ((x) << 11)

static struct insn *
acptarg(int a)
{
	struct insn *ir;

	if (tok_get() != INSTR)
		return NULL;
	ir = (void *)yylval.hdr;
	if (ir->class != a)
		return NULL;
	return ir;
}

static int
acget(void)
{

	if (tok_get() != NUMBER)
err:		error("value out of bounds");
	if (yylval.val < 0 || yylval.val > 3)
		goto err;
	return yylval.val;
}

static int
tokpg(int t)
{
	int n;

	if ((n = tok_get()) != t) {
		tok_unget(n);
		return 0;
	}
	return 1;
}

/*
 * Read and parse an instruction from the input stream.
 * Save it on the tempfile.
 */
void
p1_instr(struct insn *ir)
{
	struct expr *e;
	int hsh, ind, ac, ad, skip, dev, idx, t;
	char *s;

	if (ir->class == A_ZREL) {
		p1_setseg(ir->hname, tokpg(NUMBER) ? yylval.val : 0);
		return;
	}
	if (ir->class == A_BPTR) {
		p1_wrexpr(p1_rdexpr());
		cdot++;
		while ((t = tok_get()) == ',') {
			tmpwri(ir->hhdr.num);
			p1_wrexpr(p1_rdexpr());
			cdot++;
		}
		tok_unget(t);
		return;
	}
	if (ir->class > LASTC)
err:		error("syntax error");

	hsh = ind = ac = ad = skip = dev = idx = 0;
	s = idec[ir->class];
	while (*s != 0) {
		switch (*s++) {
		case 'A': ac = acget(); break;
		case 'B': ad = acget(); break;
		case ',': tok_acpt(','); break;
		case '#': if ((t = tok_input()) == '#') {
				hsh = 010;
			} else
				tok_unput(t);
			break;
		case '@': if (tokpg('@'))
				ind = 02000;
			break;
		case '?': if (tokpg(','))
				idx = acget() << 8;
			break;
		case '=': if (tokpg(',')) {
				if ((ir = acptarg(SKIP)) == NULL)
					goto err;
				skip = ir->opcode;
			}
			break;
		case 'D':
			if ((ir = acptarg(DEV)) == NULL)
				goto err;
			dev = ir->opcode;
			break;
		case 'E': e = p1_rdexpr(); break;
		default: goto err;
		}
	}

	tmpwri(MKACS(ac) | MKACD(ad) | hsh | skip | dev | ind | idx);
	if (ir->class == A_E || ir->class == A_ACE)
		p1_wrexpr(e);
	cdot++;
}

/*
 *
 */
void
mach_init(void)
{
	struct seg *seg;

	idec[A_ACE]	= "B,@E?";
	idec[A_E]	= "@E?";
	idec[A_ACSD]	= "#A,B=";
	idec[A_NIO]	= "D";
	idec[A_IO]	= "B,D";
	idec[A_0AC]	= "";
	idec[A_1AC]	= "A";

	/* Create zrel section in advance */
	seg = createseg(".zrel");
	if (seg->segnum != SEG_ZREL)
		aerror("zrel segnum");
}

/*
 * Check if a relative jump is too long for a short instruction.
 * Expect all distances to be inside limits.
 */
int
toolong(struct hshhdr *h, int d)
{
	return 0;
}

/*
 * Get the size for a long-style jxx instruction.
 * Do not exist on Nova.
 */
int
longdiff(struct hshhdr *h)
{
	return 1;
}

void
myinsn(int n)
{
}

int
myprint(int *ch)
{
	return 1;
}

int
mywrite(int *ch)
{
	return 0;
}

/*
 * Create the target-specific part of a relocation.
 * Call addreloc() to insert it in the relocation list.
 */
void
md_reloc(struct direc *d, struct eval *ev)
{
	if (d->type != 2)
		error("relocation not word");

//printf("md_reloc: %s %o\n", sp->hname, sp->flsdi);
	if (ev->type == EVT_UND) {
		addreloc(ev->sp, 0, REL_UNDEXT);
		if (uflag == 0)
			error("symbol '%s' not defined", ev->sp->hname);
	} else {
		if (ev->segn == SEG_TEXT) {
			addreloc(ev->sp, 0, REL_TEXT);
		} else if (ev->segn == SEG_DATA) {
			addreloc(ev->sp, 0, REL_DATA);
		} else if (ev->segn == SEG_BSS) {
			addreloc(ev->sp, 0, REL_BSS);
		} else if (ev->segn == SEG_ZREL) {
			addreloc(ev->sp, 0, REL_ZP);
		} else
			error("bad relocate segment %d", ev->segn);
	}
}

/*
 * result of an expression is usually unsigned, so we may have to convert it 
 * to signed.
 */
static int
valsign(int val)
{
	if (sizeof(int) == 2)
		return val; /* nothing to do */
	val = (signed short)val;
	return val;
}

/*
 * Write out an instruction to destination file.
 * The instructions should not have any unresolved symbols here.
 */
void
p2_instr(struct insn *in)
{
	struct eval evv, *ev;
	int val, instr, type;

	ev = &evv;
	switch (in->class) {
	case A_ACE:
	case A_E:
		instr = in->opcode | tmprd();
		type = expres(ev, p2_rdexpr());
		if ((instr & 01400) != 0) {
			/* relative AC2 or AC3 (or PC) */
			val = valsign(ev->val);
			if (type != EVT_ABS)
				error("expression not absolute");
			if (val < -128 || val > 127)
				error("ACrel too far off");
		} else {
			switch (type) {
			case EVT_UND:
				if (uflag == 0)
					error("symbol %s undefined",
					    ev->sp->hname);
				addreloc(ev->sp, 0, REL_UNDEXT);
				/* FALLTHROUGH */
			case EVT_ABS:
				/* can only be zero page */
				if (ev->val < 0 || ev->val > 0377)
					error("expr value out of bounds");
				val = ev->val;
				break;
			case EVT_SEG:
				/* segment defined */
				if (ev->segn == SEG_ZREL) {
					if (ev->val < 0 || ev->val > 0377)
						error("expr out of bounds");
					addreloc(ev->sp, 0, REL_ZP | REL_8);
					val = ev->val;
					break;
				}
				val = ev->val - cdot; /* now relative PC */
				if (val < -128 || val > 127)
					error("symbol distance too far");
				if (ev->segn == SEG_TEXT)
					addreloc(ev->sp, 0, REL_TEXT | REL_8);
				else if (ev->segn == SEG_DATA)
					addreloc(ev->sp, 0, REL_DATA | REL_8);
				else if (ev->segn == SEG_BSS)
					addreloc(ev->sp, 0, REL_BSS | REL_8);
				instr |= 0400;
				break;
			}
		}
		instr |= (val & 0377);
		break;

	case A_ACSD:
	case A_NIO:
	case A_IO:
	case A_0AC:
	case A_1AC:
		instr = in->opcode | tmprd();
		break;

	case A_BPTR:
		/* byte pointer */
		type = expres(ev, p2_rdexpr());
		instr = ev->val;
		if (type == EVT_UND) {
			addreloc(ev->sp, 0, REL_UNDEXT);
		} else if (type == EVT_SEG) {
			if (ev->sp == NULL)
				error("bptr missing symbol");
			instr += ev->sp->val; /* double symbol address */
			addreloc(ev->sp, 0, REL_BPTR);
		}
		break;

	case A_ZREL:
		return;

	default:
		aerror("unknown class %d", in->class);
		instr = 0;
	}
	ow2byte(instr);
}

#if 0
/*
 * Traverse and convert simple expressions to "byte addresses".
 */
struct expr *
mkbptr(struct expr *e)
{
	if (e->op == IDENT && e->e_sym->flsdi & SYM_DEFINED) {
		/* convert to doubled const */
		e->e_val = e->e_sym->val * 2;
		e->op = NUMBER;
	}
	if (e->op == IDENT || e->op == NUMBER || e->op == '.')
		return e;
	e->e_left = mkbptr(e->e_left);
	if (e->op != 7 && e->op != '~')
		e->e_right = mkbptr(e->e_right);
	return e;
}

/*
 * Save 1/2/4 byte from initialization.
 * When an initialization value is read from the temp file this routine
 * is called to both save the value and also add a relocation word if
 * containing a reference. 
 */
void
wrval(struct direc *d, int val, struct symbol *sp)
{

	if (d->type == MD_WORD && cursub->odd) {
		ow2byte(cursub->bsave);
		cursub->odd = 0;
		cdot++;
	}

	switch (d->type) {
	case MD_BYTE: /* byte */
		if (val > 0377 || val < -128)
			error("byte out of range");
		val &= 0377;
		if (little_endian) {
			if (cursub->odd) {
				ow2byte(cursub->bsave | (val << 8));
				cdot++;
			} else
				cursub->bsave = val;
		} else {
			if (cursub->odd) {
				ow2byte(cursub->bsave | val);
				cdot++;
			} else
				cursub->bsave = val << 8;
		}
		cursub->odd ^= 1;
		break;

	case MD_WORD: /* word */
		if (sp) {
			val += sp->val;
			if ((sp->flsdi & SYM_DEFINED) == 0) {
				addreloc(sp, 0, REL_UNDEXT);
			} else {
				if (sp->sub->segnum == SEG_TEXT) {
					addreloc(sp, 0, REL_TEXT);
				} else if (sp->sub->segnum == SEG_DATA) {
					addreloc(sp, 0, REL_DATA);
				} else if (sp->sub->segnum == SEG_BSS) {
					addreloc(sp, 0, REL_BSS);
				} else if (sp->sub->segnum == SEG_ZREL) {
					addreloc(sp, 0, REL_ZP);
				} else
					error("bad relocate segment %d",
					    sp->sub->segnum);
			}
		}
		ow2byte(val);
		cdot++;
		break;

	case MD_LONG:
		ow4byte(val);
		cdot += 2;
		break;

	default:
		error("wrval");
	}
}
#endif

/*
 * Convert to a target-dependent relocate word.
 *
 * Bit 0 (if set) tells it's a PC-relative relocation.
 *
 * Bit 1-3 are segment for relocation, as below:
 * 000	  absolute number
 * 002	  reference to text	segment
 * 004	  reference to initialized data
 * 006	  reference to uninitialized data (bss)
 * 010	  reference to undefined external symbol
 *
 * Bit 4-15 are sequence number of referenced symbol.
 */
int
relwrd(struct reloc *r)
{
	int rv = r->rtype;

	if (r->sp && (rv & REL_UNDEXT))
		rv |= ((r->sp->hhdr.num - SYMBASE) << 4);
	return rv;
}

void
myoptions(char *str)
{
	if (strcmp(str, "little-endian") == 0)
		little_endian = 1;
	else if (strcmp(str, "big-endian") == 0)
		little_endian = 0;
	else
		error("bad -m option '%s'", str);
}
