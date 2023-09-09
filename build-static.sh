#! /bin/sh

. lib.sh

fixup() {
    local m=$1
    local c=$2
    local workdir=$3

    # copy /etc/passwd from FreeBSD-runtime
    cp ${workdir}/runtime/etc/master.passwd $m/etc || return $?
    pwd_mkdb -p -d $m/etc $m/etc/master.passwd || return $?
    cp ${workdir}/runtime/etc/group $m/etc || return $?
    cp ${workdir}/runtime/etc/termcap.small $m/etc/termcap.small || return $?
    cp ${workdir}/runtime/etc/termcap.small $m/usr/share/misc/termcap || return $?

    if [ "${has_certctl_package}" != "yes" ]; then
	# Copy /usr/share/certs from caroot to avoid pulling in openssl In
	# FreeBSD-14, certctl is split out into its own package so we can just
	# install caroot.
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
- /etc/termcap
- timezone data
EOF
	  )
    add_annotation $c "org.opencontainers.image.title=Base image for statically linked workloads"
    add_annotation $c "org.opencontainers.image.description=${desc}"
}

parse_args "$@"
if [ "${has_certctl_package}" = "yes" ]; then
    packages="FreeBSD-caroot FreeBSD-zoneinfo"
else
    packages="FreeBSD-zoneinfo"
fi

if [ ${BUILD} = yes ]; then
    build_image mtree static "" fixup ${packages}
    build_image static static "-debug" fixup FreeBSD-rescue
fi
if [ ${PUSH} = yes ]; then
    push_image static
fi
