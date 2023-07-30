#! /bin/sh

. lib.sh

fixup() {
    local m=$1; shift
    local c=$1; shift

    # bootstrap pkg from latest
    sudo mkdir -p $m/usr/local/etc/pkg/repos
    t=$(mktemp)
    cat > $t <<EOF
FreeBSD: {
  url: "pkg+http://pkg.FreeBSD.org/\${ABI}/latest",
}
EOF
    sudo mv $t $m/usr/local/etc/pkg/repos/FreeBSD.conf


    echo Bootstrap package management
    # bootstrap before installing the config for FreeBSD-base, otherwise
    # it will attempt to install pkg from FreeBSD-base instead of FreeBSD.
    sudo buildah run $c pkg -y bootstrap
    sudo rm $m/usr/local/sbin/pkg-static.pkgsave
    sudo strip $m/usr/local/sbin/pkg-static

    # Installing pkgbase repo
    t=$(mktemp)
    cat > $t <<EOF
# FreeBSD pkgbase repo - assumes pkgbase image mounted as /pkgbase

FreeBSD-base: {
  url: "file:///pkgbase/\${ABI}/latest",
  signature_type: "none",
  enabled: yes
}
EOF
    sudo mv $t $m/usr/local/etc/pkg/repos/pkgbase.conf

}

build_image $1 $2 freebsd-base freebsd-minimal fixup \
	    FreeBSD-runtime \
	    FreeBSD-rc \
	    FreeBSD-pkg-bootstrap \
	    FreeBSD-mtree
