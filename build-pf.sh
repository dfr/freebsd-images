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
    add_annotation $c "org.opencontainers.image.title=Image for shell-based workloads with pf"
    add_annotation $c "org.opencontainers.image.description=${desc}"
}

parse_args "$@"

if [ ${BUILD} = yes ]; then
    build_image small pf "" fixup \
		FreeBSD-pf
fi
if [ ${PUSH} = yes ]; then
    push_image pf
fi
