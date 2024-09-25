#! /bin/sh

. lib.sh

fixup() {
    local m=$1
    local c=$2
    local workdir=$3

    # bootstrap pkg from latest
    mkdir -p $m/usr/local/etc/pkg/repos
    t=$(mktemp)
    cat > $t <<EOF
FreeBSD: {
  url: "pkg+http://pkg.FreeBSD.org/\${ABI}/latest",
}
EOF
    mv $t $m/usr/local/etc/pkg/repos/FreeBSD.conf

    echo Bootstrap package management
    # bootstrap before installing the config for FreeBSD-base, otherwise
    # it will attempt to install pkg from FreeBSD-base instead of FreeBSD.
    buildah run $c pkg -y bootstrap
    rm $m/usr/local/sbin/pkg-static.pkgsave
    strip $m/usr/local/sbin/pkg-static

    # Install repo config for FreeBSD-base
    install_pkgbase_repo ${workdir} $m || return $?

    local desc=$(cat <<EOF
In addition to the contents of base, adds:
- core system utilities
- pkg
EOF
	  )
    add_annotation $c "org.opencontainers.image.title=Minimal image for shell-based workloads"
    add_annotation $c "org.opencontainers.image.description=${desc}"
}

parse_args "$@"
if [ "${has_certctl_package}" = "yes" ]; then
    caroot="FreeBSD-certctl"
else
    caroot="FreeBSD-caroot"
fi

if [ ${BUILD} = yes ]; then
    build_image base minimal "" fixup \
		FreeBSD-runtime \
		${caroot} \
		FreeBSD-kerberos-lib \
		FreeBSD-libarchive \
		FreeBSD-libexecinfo \
		FreeBSD-libucl \
		FreeBSD-fetch \
		FreeBSD-rc \
		FreeBSD-pkg-bootstrap \
		FreeBSD-mtree
fi
if [ ${PUSH} = yes ]; then
    push_image minimal
fi
