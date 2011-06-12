#!/bin/zsh

ME=$(basename $0)
USAGE="usage: ${ME} [-d] [-j #] [-m] [-n name] [-v] [options]"

VERBOSE=""
want_make=
jobs=12
NAME=$(basename ${PWD})

distrib=yes
while getopts dj:mn:v c; do
	case "${c}" in
	d )	distrib="";;
	j )	jobs="${OPTARG}";;
	m )	want_make=yes;;
	n )	NAME="${OPTARG}";;
	v )	VERBOSE="yes";;
	* )	echo "${USAGE}" >&2; exit 1;;
	esac
done
shift $((OPTIND - 1))

if [ $# -ge 1 ]; then
	NAME="${1}"
	shift
fi

CUSTOM="${0}-${NAME}"

if [ -x "${CUSTOM}" ]; then
	echo "Running configure with preferred arguments"
	. "${CUSTOM}"
else
	CCMODE='-march=native'
	echo "Running configure with standard arguments"
	if [ "${distrib}" ]; then
		export	CCACHE_PREFIX=distcc
		export	CC="ccache gcc -std=gnu99 ${CCMODE}"
		export	CFLAGS='-pipe -Os -D_FORTIFY_SOURCE=2'
		export	CXX="ccache g++ ${CCMODE}"
		export	CXXFLAGS='-pipe -Os'
	else
		unset	CCACHE_PREFIX
		export	CC="gcc -std=gnu99 ${CCMODE}"
		export	CFLAGS='-pipe -Os -D_FORTIFY_SOURCE=2'
		export	CXX="g++ ${CCMODE}"
		export	CXXFLAGS='-pipe -Os'
	fi
fi
#
if [ ! -x ./configure ]; then
	if [ "${VERBOSE}" ]; then
		export BOOTSTRAP_VERBOSE=yes
		bootstrap
	else
		unset BOOTSTRAP_VERBOSE
		bootstrap
	fi
fi
#
./configure								\
	--prefix=/opt/${NAME}						\
	$@

[ "${want_make}" ] && make -j${JOBS}
