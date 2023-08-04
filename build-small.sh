#! /bin/sh

. lib.sh

fixup() {
    local m=$1
    local c=$2
    local workdir=$3

    local desc=$(cat <<EOF
In addition to the contents of minimal, contains:
- non-vital utilities and libraries
EOF
	  )
    buildah config --annotation "org.opencontainers.image.title=Small image for shell-based workloads" $c || return $?
    buildah config --annotation "org.opencontainers.image.description=${desc}" $c || return $?
}

parse_args "$@"
build_image minimal small fixup \
	    FreeBSD-utilities
