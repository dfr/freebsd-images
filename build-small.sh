#! /bin/sh

. lib.sh

REPO=$1; shift
TAG=$1; shift

majorver=$(echo ${TAG} | cut -d. -f1)
images=
for arch in amd64 aarch64 ; do
    abi=FreeBSD:${majorver}:${arch}
    c=$(sudo buildah from --arch=${arch} freebsd-minimal:${TAG})
    m=$(sudo buildah mount $c)

    echo Generating image for ${arch}

    echo Installing packages
    workdir=$(make_workdir)
    sudo env ABI=${abi} pkg --rootdir $m --repo-conf-dir ${workdir}/repos install -yq \
	 FreeBSD-utilities
    rm -rf ${workdir}

    sudo buildah unmount $c
    i=$(sudo buildah commit --rm $c)
    sudo buildah tag $i freebsd-small:${TAG}-${arch}
    images="${images} $i"
done

sudo buildah manifest rm freebsd-small:${TAG}
sudo buildah manifest create freebsd-small:${TAG} ${images}

