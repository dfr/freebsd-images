#! /bin/sh

. lib.sh

fixup() {
    local m=$1
    local c=$2
    local workdir=$3

    local desc=$(cat <<EOF
Adds /rescue to base to help debug image problems
EOF
	  )
    buildah config --env "PATH=/rescue:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" $c || return $?
    buildah config --annotation "org.opencontainers.image.title=Base image for dynamically linked workloads (with /rescue)" $c || return $?
    buildah config --annotation "org.opencontainers.image.description=${desc}" $c || return $?
}

parse_args "$@"
build_image base base-debug fixup \
	    FreeBSD-rescue
