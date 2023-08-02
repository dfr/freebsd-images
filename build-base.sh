#! /bin/sh

. lib.sh

fixup() {
    local m=$1
    local c=$2
    local workdir=$3

    local desc=$(cat <<EOF
In addition to the contents of freebsd-static, contains:
- base system dynamic libraries
- SSL dynamic libraries
EOF
	  )
    buildah config --label "org.opencontainers.image.title=Base image for dynamically linked workloads" $c || return $?
    buildah config --label "org.opencontainers.image.description=${desc}" $c || return $?
}

parse_args "$@"
if [ "${has_caroot_data}" = "yes" ]; then
    packages="FreeBSD-clibs FreeBSD-libssl"
else
    packages="FreeBSD-openssl"
fi
build_image freebsd-static freebsd-base fixup ${packages}
