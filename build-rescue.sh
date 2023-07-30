#! /bin/sh

. lib.sh

fixup() {
}

build_image $1 $2 freebsd-mtree freebsd-rescue fixup FreeBSD-rescue

