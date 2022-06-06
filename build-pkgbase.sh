#! /bin/sh

DOCKER=docker.io/dougrabson
QUAY=quay.io/dougrabson
HOME=registry.home.rabson.org

REPO=$1; shift
VER=$1; shift

c=$(sudo buildah from scratch)
m=$(sudo buildah mount $c)
tar -C $REPO/../.. -cf - FreeBSD:13:amd64 | sudo tar -C $m -xf -

sudo buildah unmount $c
i=$(sudo buildah commit $c)
sudo buildah rm $c
for reg in $DOCKER $QUAY $HOME; do
    sudo buildah tag $i $reg/freebsd-pkgbase:$VER
done
