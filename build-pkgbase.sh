#! /bin/sh

. lib.sh

parse_args "$@"

repo=${REPOBASE}/${branch}/repo

majorver=$(echo ${tag} | cut -d. -f1)
name=freebsd-pkgbase
images=
for arch in amd64 aarch64; do
    echo Generating ${name} for ${arch}

    abi=FreeBSD:${majorver}:${arch}
    c=$(buildah from --arch=${arch} scratch)
    m=$(buildah mount $c)
    tar -L -C $repo -cf - ${abi}/latest | tar -C $m -xf -

    buildah unmount $c
    i=$(buildah commit --rm $c)
    buildah tag $i localhost/${name}:${tag}-${arch}
    images="${images} $i"
done

set -x

if buildah manifest exists localhost/${name}:${tag}; then
    buildah manifest rm localhost/${name}:${tag}
fi
buildah manifest create localhost/${name}:${tag} ${images}
