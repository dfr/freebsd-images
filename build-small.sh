#! /bin/sh

. lib.sh

fixup() {
}

build_image $1 $2 freebsd-minimal freebsd-small fixup \
	    FreeBSD-utilities
