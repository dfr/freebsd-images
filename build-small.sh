#! /bin/sh

. lib.sh

set -x

REPO=$1; shift
VER=$1; shift

c=$(sudo buildah from freebsd-minimal:$VER)
m=$(sudo buildah mount $c)

sudo pkg --rootdir $m add $REPO/FreeBSD-utilities-$VER.pkg

sudo buildah unmount $c
i=$(sudo buildah commit $c)
sudo buildah rm $c
tag_image $i freebsd-small
