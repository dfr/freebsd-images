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
    add_annotation $c "org.opencontainers.image.title=Small image for shell-based workloads"
    add_annotation $c "org.opencontainers.image.description=${desc}"
}

parse_args "$@"

if [ ${BUILD} = yes ]; then
    build_image minimal small "" fixup \
		FreeBSD-utilities FreeBSD-libbsm
fi
if [ ${PUSH} = yes ]; then
    push_image small
fi
