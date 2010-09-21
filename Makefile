PREFIX	=/opt
BINDIR	=${PREFIX}/bin

all:	configure.zsh

install:configure.zsh
	install -D -c configure.zsh ${BINDIR}/configure

uninstall:
	${RM} ${BINDIR}/configure
