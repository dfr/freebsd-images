#! /bin/sh

ARCHES="amd64 aarch64"
PKG=pkg
REG=registry.lab.rabson.org
BUILD=no
PUSH=no

build() {
    local spec=$1; shift
    local branch=$(echo $spec | cut -d: -f1)
    local ver=$(echo $spec | cut -d: -f2)

    for image in mtree static base minimal small pf; do
	./build-${image}.sh -P ${PKG} -A "${ARCHES}" -b ${branch} ${ver} || exit 1
    done
}

push() {
    local spec=$1; shift
    local branch=$(echo $spec | cut -d: -f1)
    local ver=$(echo $spec | cut -d: -f2)

    for image in mtree static base minimal small pf; do
	./build-${image}.sh -P ${PKG} -A "${ARCHES}" -p ${branch} ${ver} || exit 1
    done
}

while getopts "A:P:R:bp" arg; do
    case ${arg} in
	A)
	    ARCHES="${OPTARG}"
	    ;;
	P)
	    PKG="${OPTARG}"
	    ;;
	R)
	    REG="${OPTARG}"
	    ;;
	b)
	    BUILD=yes
	    ;;
	p)
	    PUSH=yes
	    ;;
	*)
	    echo "Unknown argument"
    esac
done
shift $((OPTIND-1))

builds="\
	main:15 \
	stable/14:14 \
	stable/13:13 \
	releng/13.2:13.2"

if [ $# -gt 0 ]; then
    builds="$@"
fi

for i in ${builds}; do
    if [ ${BUILD} = yes ]; then
	build $i
    fi
    if [ ${PUSH} = yes ]; then
	push $i
    fi
done
