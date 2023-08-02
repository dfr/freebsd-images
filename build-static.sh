#! /bin/sh

. lib.sh

fixup() {
    local m=$1
    local c=$2
    local workdir=$3

    # copy /etc/passwd from FreeBSD-runtime
    cp ${workdir}/runtime/etc/master.passwd $m/etc || return $?
    pwd_mkdb -d $m/etc $m/etc/master.passwd || return $?
    cp ${workdir}/runtime/etc/group $m/etc || return $?

    if [ "${has_caroot_data}" != "yes" ]; then
	# copy /usr/share/certs from caroot to avoid pulling in openssl
	# In FreeBSD-14, we install caroot-data instead
	mkdir ${workdir}/caroot || return $?
	env ABI=${abi} pkg --rootdir ${workdir}/caroot --repo-conf-dir ${workdir}/repos \
	     install -yq FreeBSD-caroot || return $?
	tar -C ${workdir}/caroot -cf - usr/share/certs | tar -C $m -xf - || return $?
    fi
    # for both 13.x and 14.x we need to manually rehash
    env DESTDIR=$m /usr/sbin/certctl rehash || return $?

    local desc=$(cat <<EOF
Contains:
- SSL certificates
- /etc/passwd
- /etc/group
- timezone data
EOF
	  )
    buildah config --label "org.opencontainers.image.title=Base image for statically linked workloads" $c || return $?
    buildah config --label "org.opencontainers.image.description=${desc}" $c || return $?
}

parse_args "$@"
if [ "${has_caroot_data}" = "yes" ]; then
    packages="FreeBSD-caroot-data FreeBSD-zoneinfo"
else
    packages="FreeBSD-zoneinfo"
fi
build_image freebsd-mtree freebsd-static fixup ${packages}
