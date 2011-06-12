#!/bin/zsh

ME=$(basename $0)
USAGE="usage: ${ME} [-j #] [-m] [-n name] [-v] [options]"

VERBOSE=""
want_make=
jobs=12
NAME=$(basename ${PWD})

while getopts j:mn:v c; do
	case "${c}" in
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
	echo "Running configure with standard arguments"
	export	CCACHE_PREFIX=distcc
	unset	CCACHE_PREFIX
	export	CC="gcc -std=gnu99"
	export	CFLAGS='-pipe -Os -D_FORTIFY_SOURCE=2'
	export	CXX="g++"
	export	CXXFLAGS='-pipe -Os'
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
