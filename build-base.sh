#! /bin/sh

. lib.sh

fixup() {
    local m=$1
    local c=$2
    local workdir=$3

    # extra libs from runtime
    cp ${workdir}/runtime/lib/libcrypt.so.* $m/lib
    cp ${workdir}/runtime/lib/libz.so.* $m/lib

    local desc=$(cat <<EOF
In addition to the contents of static, contains:
- base system dynamic libraries
- SSL dynamic libraries
EOF
	  )
    add_annotation $c "org.opencontainers.image.title=Base image for dynamically linked workloads"
    add_annotation $c "org.opencontainers.image.description=${desc}"
}

parse_args "$@"
if [ "${has_certctl_package}" = "yes" ]; then
    packages="FreeBSD-clibs FreeBSD-openssl-lib"
else
    packages="FreeBSD-openssl"
fi

if [ ${BUILD} = yes ]; then
    build_image static base "" fixup ${packages}
    build_image base base "-debug" fixup FreeBSD-rescue
fi
if [ ${PUSH} = yes ]; then
    push_image base
fi
