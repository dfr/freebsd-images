#! /bin/sh

. lib.sh

branch=$1; shift
tag=$1; shift
repo=${REPOBASE}/${branch}/repo

majorver=$(echo ${tag} | cut -d. -f1)
name=freebsd-pkgbase
images=
for arch in amd64 aarch64; do
    echo Generating ${name} for ${arch}

    abi=FreeBSD:${majorver}:${arch}
    c=$(sudo buildah from --arch=${arch} scratch)
    m=$(sudo buildah mount $c)
    tar -L -C $repo -cf - ${abi}/latest | sudo tar -C $m -xf -

    sudo buildah unmount $c
    i=$(sudo buildah commit --rm $c)
    sudo buildah tag $i localhost/${name}:${tag}-${arch}
    images="${images} $i"
done

set -x

if sudo buildah manifest exists localhost/${name}:${tag}; then
    sudo buildah manifest rm localhost/${name}:${tag}
fi
sudo buildah manifest create localhost/${name}:${tag} ${images}
