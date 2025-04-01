#	$Id: Makefile,v 1.8 2022/11/13 14:09:33 ragge Exp $
#
# Makefile.in for cpp
#

CFLAGS = -g -Wall
DEST=a2tap

OBJS=	main.o

all: $(DEST)

$(DEST): $(OBJS)
	$(CC) $(LDFLAGS) $(OBJS) -o $@ $(LIBS)

.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	/bin/rm -f $(OBJS) $(DEST) $(EXTRACLEAN)
