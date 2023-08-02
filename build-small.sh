#! /bin/sh

. lib.sh

fixup() {
    local m=$1
    local c=$2
    local workdir=$3

    local desc=$(cat <<EOF
In addition to the contents of freebsd-minimal, contains:
- non-vital programs and libraries
EOF
	  )
    buildah config --label "org.opencontainers.image.title=Small image for shell-based workloads" $c || return $?
    buildah config --label "org.opencontainers.image.description=${desc}" $c || return $?
}

parse_args "$@"
build_image freebsd-minimal freebsd-small fixup \
	    FreeBSD-utilities
