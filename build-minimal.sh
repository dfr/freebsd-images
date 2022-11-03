#! /bin/sh

. lib.sh

REPO=$1; shift
TAG=$1; shift

majorver=$(echo ${TAG} | cut -d. -f1)
images=
for arch in amd64 aarch64 ; do
    abi=FreeBSD:${majorver}:${arch}
    c=$(sudo buildah from --arch=${arch} scratch)
    m=$(sudo buildah mount $c)

    echo Generating image for ${arch}

    echo Installing packages
    workdir=$(make_workdir)
    sudo env ABI=${abi} pkg --rootdir $m --repo-conf-dir ${workdir}/repos install -yq \
	 FreeBSD-runtime \
	 FreeBSD-rc \
	 FreeBSD-caroot \
	 FreeBSD-pkg-bootstrap \
	 FreeBSD-mtree

    echo Creating directory structure
    # run mtree to create directories with the right permissions etc.
    sudo mtree -deU -p $m/ -f $m/etc/mtree/BSD.root.dist > /dev/null
    sudo mtree -deU -p $m/usr -f $m/etc/mtree/BSD.usr.dist > /dev/null
    sudo mtree -deU -p $m/usr/include -f $m/etc/mtree/BSD.include.dist > /dev/null
    sudo mtree -deU -p $m/usr/lib -f $m/etc/mtree/BSD.debug.dist > /dev/null

    echo Bootstrap package management
    # bootstrap before installing the config for FreeBSD-base, otherwise
    # it will attempt to install pkg from FreeBSD-base instead of FreeBSD.
    mounts=
    if [ "${arch}" = "aarch64" ]; then
	# qemu helper for building aarch64 image on amd64
	mounts=--mount=type=bind,source=/usr/local/bin/qemu-aarch64-static,destination=/usr/local/bin/qemu-aarch64-static
    fi
    sudo buildah run ${mounts} $c pkg -y bootstrap
    sudo rm $m/usr/local/sbin/pkg-static.pkgsave
    sudo strip $m/usr/local/sbin/pkg-static

    # Installing pkgbase repo
    sudo mkdir -p $m/usr/local/etc/pkg/repos
    sudo cp ${workdir}/repos/base.conf $m/usr/local/etc/pkg/repos
    rm -rf ${workdir}

    sudo fetch --output=$m/usr/share/keys/pkg/trusted/alpha.pkgbase.live.pub \
	 https://alpha.pkgbase.live/alpha.pkgbase.live.pub

    sudo buildah unmount $c
    i=$(sudo buildah commit --rm $c)
    sudo buildah tag $i freebsd-minimal:${TAG}-${arch}
    images="${images} $i"
done

set -x

sudo buildah manifest rm freebsd-minimal:${TAG}
sudo buildah manifest create freebsd-minimal:${TAG} ${images}
