#! /bin/sh

. lib.sh

fixup() {
    local m=$1
    local c=$2
    local workdir=$3

    # Extra libs from runtime. Depending on the branch, these may already be moved to clibs.
    for lib in libcrypt libz; do
	ls $m/lib/${lib}.so.* 2> /dev/null || cp ${workdir}/runtime/lib/${lib}.so.* $m/lib
    done

    local desc=$(cat <<EOF
In addition to the contents of static, contains:
- base system dynamic libraries
- SSL dynamic libraries
EOF
	  )
    add_annotation $c "org.opencontainers.image.title=Base image for dynamically linked workloads"
    add_annotation $c "org.opencontainers.image.description=${desc}"
}

fixup_debug() {
    local m=$1
    local c=$2
    local workdir=$3
    buildah config --env "PATH=/rescue:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" $c
}

parse_args "$@"
if [ "${has_certctl_package}" = "yes" ]; then
    packages="FreeBSD-clibs FreeBSD-openssl-lib"
else
    packages="FreeBSD-openssl"
fi

if [ ${BUILD} = yes ]; then
    build_image static base "" fixup ${packages}
    build_image base base "-debug" fixup_debug FreeBSD-rescue
fi
if [ ${PUSH} = yes ]; then
    push_image base
fi
