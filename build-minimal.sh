#! /bin/sh

. lib.sh

set -x

REPO=$1; shift
VER=$1; shift

c=$(sudo buildah from scratch)
m=$(sudo buildah mount $c)

sudo pkg --rootdir $m add $REPO/FreeBSD-runtime-$VER.pkg
sudo pkg --rootdir $m add $REPO/FreeBSD-clibs-$VER.pkg
sudo pkg --rootdir $m add $REPO/FreeBSD-rc-$VER.pkg

sudo pkg --rootdir $m add $REPO/FreeBSD-libarchive-$VER.pkg
sudo pkg --rootdir $m add $REPO/FreeBSD-libucl-$VER.pkg
sudo pkg --rootdir $m add $REPO/FreeBSD-libbz2-$VER.pkg
sudo pkg --rootdir $m add $REPO/FreeBSD-liblzma-$VER.pkg
sudo pkg --rootdir $m add $REPO/FreeBSD-kerberos-$VER.pkg
sudo pkg --rootdir $m add $REPO/FreeBSD-openssl-$VER.pkg
sudo pkg --rootdir $m add $REPO/FreeBSD-fetch-$VER.pkg
sudo pkg --rootdir $m add $REPO/FreeBSD-pkg-bootstrap-$VER.pkg

sudo buildah run $c pkg -y bootstrap
sudo rm $m/usr/local/sbin/pkg-static.pkgsave
sudo strip $m/usr/local/sbin/pkg-static

sudo buildah unmount $c
i=$(sudo buildah commit $c)
sudo buildah rm $c
tag_image $i freebsd-minimal
