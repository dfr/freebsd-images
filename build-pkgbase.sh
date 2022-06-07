#! /bin/sh

. lib.sh

REPO=$1; shift
VER=$1; shift

c=$(sudo buildah from scratch)
m=$(sudo buildah mount $c)
tar -C $REPO/../.. -cf - FreeBSD:13:amd64 | sudo tar -C $m -xf -

sudo buildah unmount $c
i=$(sudo buildah commit $c)
sudo buildah rm $c
tag_image $i freebsd-pkgbase
