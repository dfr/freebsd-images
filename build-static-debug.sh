#! /bin/sh

. lib.sh

fixup() {
    local m=$1
    local c=$2
    local workdir=$3

    local desc=$(cat <<EOF
Adds /rescue to freebsd-static to help debug image problems
EOF
	  )
    sudo buildah config --env "PATH=/rescue" $c || return $?
    sudo buildah config --label "org.opencontainers.image.title=Base image for statically linked workloads (with /rescue)" $c || return $?
    sudo buildah config --label "org.opencontainers.image.description=${desc}" $c || return $?
}

parse_args "$@"
build_image freebsd-static freebsd-static-debug fixup \
	    FreeBSD-rescue
