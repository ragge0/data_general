#
#
SRCS=zpvar.s support.s startup.s loader.s 65subr.s 65tbl.s 65emul.s
AS=../nova-as/as
A2TAP=../a2tap/a2tap


all:	nova65

nova65: ${SRCS}
	${AS} -o nova65.o ${SRCS}
	${A2TAP} -dv -o nova65.tap nova65.o

clean:
	/bin/rm -f nova65.o nova65.tap
