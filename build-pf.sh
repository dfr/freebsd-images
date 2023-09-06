#! /bin/sh

. lib.sh

fixup() {
    local m=$1
    local c=$2
    local workdir=$3

    local desc=$(cat <<EOF
In addition to the contents of small, adds:
- pf
EOF
	  )
    buildah config --annotation "org.opencontainers.image.title=Image for shell-based workloads with pf" $c || return $?
    buildah config --annotation "org.opencontainers.image.description=${desc}" $c || return $?
}

parse_args "$@"
build_image small pf fixup \
	    FreeBSD-pf
