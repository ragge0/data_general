#	$Id: Makefile,v 1.8 2022/11/13 14:09:33 ragge Exp $
#
# Makefile.in for cpp
#

CFLAGS = -g -Wall -Wmissing-prototypes -I../objdump
DEST=as

OBJS=	as.o directives.o nova.o relocate.o aslex.o \
	segments.o symbol.o tempfile.o expr.o ofile.o aout16.o parse.o

HDRS=	as.h nova.h instr.h

EXTRACLEAN = instr.h

all: $(DEST) $(OBJS)

$(OBJS): $(HDRS)

$(DEST): instr.h $(OBJS)
	$(CC) $(LDFLAGS) $(OBJS) -o $@ $(LIBS)

.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<

instr.h: nova-instr.awk
	cat nova-instr.awk | awk -v flavor=AS -f nova-instr.awk > instr.h



clean:
	/bin/rm -f $(OBJS) $(DEST) $(EXTRACLEAN)
