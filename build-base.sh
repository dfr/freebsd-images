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
    buildah config --annotation "org.opencontainers.image.title=Base image for dynamically linked workloads" $c || return $?
    buildah config --annotation "org.opencontainers.image.description=${desc}" $c || return $?
}

parse_args "$@"
if [ "${has_certctl_package}" = "yes" ]; then
    packages="FreeBSD-clibs FreeBSD-openssl-lib"
else
    packages="FreeBSD-openssl"
fi
build_image static base fixup ${packages}
