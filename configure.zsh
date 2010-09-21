#!/bin/zsh

ME=$(basename $0)
USAGE="usage: ${ME} [-j #] [-m] name [options]"

want_make=
jobs=12

while getopts j:m c; do
	case "${c}" in
	j )	jobs="${OPTARG}";;
	m )	want_make=yes;;
	* )	echo "${USAGE}" >&2; exit 1;;
	esac
done
shift $((OPTIND - 1))

if [ $# -lt 1 ]; then
	echo "${USAGE}" >&2
	exit 1
fi

NAME="${1}"
shift

CUSTOM="${0}-${NAME}"

if [ -x "${CUSTOM}" ]; then
	echo "Running configure with preferred arguments"
	. "${CUSTOM}"
else
	echo "Running configure with standard arguments"
	export	CCACHE_PREFIX=distcc
	export	CC="ccache gcc -std=gnu99 -march=native"
	export	CFLAGS='-pipe -Os -D_FORTIFY_SOURCE=2'
	export	CXX='ccache g++'
	export	CXXFLAGS='-pipe -Os'
fi
#
if [ ! -x ./configure ]; then
	bootstrap
fi
#
./configure								\
	--prefix=/opt/${NAME}						\
	$@

[ "${want_make}" ] && make -j${JOBS}
