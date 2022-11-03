#! /bin/sh

. lib.sh

set -x

REPO=$1; shift
TAG=$1; shift

c=$(sudo buildah from scratch)
m=$(sudo buildah mount $c)

workdir=$(make_workdir)
sudo pkg --rootdir $m --repo-conf-dir ${workdir}/repos install -y \
     FreeBSD-runtime \
     FreeBSD-rc \
     FreeBSD-caroot \
     FreeBSD-pkg-bootstrap \
     FreeBSD-mtree

# run mtree to create directories with the right permissions etc.
sudo buildah run $c mtree -deU -p / -f /etc/mtree/BSD.root.dist > /dev/null
sudo buildah run $c mtree -deU -p /usr -f /etc/mtree/BSD.usr.dist > /dev/null
sudo buildah run $c mtree -deU -p /usr/include -f /etc/mtree/BSD.include.dist > /dev/null
sudo buildah run $c mtree -deU -p /usr/lib -f /etc/mtree/BSD.debug.dist > /dev/null

# bootstrap before installing the config for FreeBSD-base, otherwise
# it will attempt to install pkg from FreeBSD-base instead of FreeBSD.
sudo buildah run $c pkg -y bootstrap
sudo ls -l $m/usr
sudo rm $m/usr/local/sbin/pkg-static.pkgsave
sudo strip $m/usr/local/sbin/pkg-static

sudo mkdir -p $m/usr/local/etc/pkg/repos
sudo cp ${workdir}/repos/base.conf $m/usr/local/etc/pkg/repos
rm -rf ${workdir}


sudo fetch --output=$m/usr/share/keys/pkg/trusted/alpha.pkgbase.live.pub \
      https://alpha.pkgbase.live/alpha.pkgbase.live.pub

sudo buildah unmount $c
i=$(sudo buildah commit $c)
sudo buildah rm $c
tag_image $i freebsd-minimal
