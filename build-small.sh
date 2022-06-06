#! /bin/sh

set -x

DOCKER=docker.io/dougrabson
QUAY=quay.io/dougrabson
HOME=registry.home.rabson.org

REPO=$1; shift
VER=$1; shift

c=$(sudo buildah from $DOCKER/freebsd-minimal:$VER)
m=$(sudo buildah mount $c)

sudo pkg --rootdir $m add $REPO/FreeBSD-utilities-$VER.pkg
sudo pkg --rootdir $m add $REPO/FreeBSD-kerberos-$VER.pkg

sudo buildah unmount $c
i=$(sudo buildah commit $c)
sudo buildah rm $c
for reg in $DOCKER $QUAY $HOME; do
    sudo buildah tag $i $reg/freebsd-small:13.1
done
