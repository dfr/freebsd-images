#! /bin/sh

. lib.sh

set -x

REPO=$1; shift
TAG=$1; shift

c=$(sudo buildah from freebsd-minimal:${TAG})
m=$(sudo buildah mount $c)

workdir=$(make_workdir)
sudo pkg --rootdir $m --repo-conf-dir ${workdir}/repos install -y \
     FreeBSD-utilities
rm -rf ${workdir}

sudo buildah unmount $c
i=$(sudo buildah commit $c)
sudo buildah rm $c
tag_image $i freebsd-small
