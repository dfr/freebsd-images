REPOBASE=/zboot/iocage/jails/pkgbase/root/usr/obj/build/src

make_workdir() {
    local branch=$1
    local d=$(mktemp -d -t freebsd-image)
    mkdir $d/repos
    cat > $d/repos/base.conf <<EOF
# FreeBSD pkgbase repo for building the images

FreeBSD-base: {
  url: "http://pkgbase.home.rabson.org/packages/${branch}/\${ABI}/latest",
  signature_type: "pubkey",
  pubkey: "/usr/local/etc/ssl/pkgbase.pub",
  enabled: yes
}
EOF
    echo $d
}

# build an mtree directories only image
# usage: build_mtree <branch> <tag> <image name>
build_mtree() {
    local branch=$1; shift
    local tag=$1; shift
    local name=$1; shift

    local majorver=$(echo ${tag} | cut -d. -f1)
    local images=
    for arch in amd64 aarch64 ; do
	abi=FreeBSD:${majorver}:${arch}
	c=$(sudo buildah from --arch=${arch} scratch)
	m=$(sudo buildah mount $c)

	echo Generating freebsd-mtree for ${arch}

	echo Creating directory structure
	# Install mtree package to a temp directory since it also pulls in
	# FreeBSD-runtime
	workdir=$(make_workdir ${branch})
	mkdir ${workdir}/tmp
	sudo env ABI=${abi} pkg --rootdir ${workdir}/tmp --repo-conf-dir ${workdir}/repos \
	     install -yq FreeBSD-mtree
	sudo mtree -deU -p $m/ -f ${workdir}/tmp/etc/mtree/BSD.root.dist > /dev/null
	sudo mtree -deU -p $m/usr -f ${workdir}/tmp/etc/mtree/BSD.usr.dist > /dev/null
	sudo mtree -deU -p $m/usr/include -f ${workdir}/tmp/etc/mtree/BSD.include.dist > /dev/null
	sudo mtree -deU -p $m/usr/lib -f ${workdir}/tmp/etc/mtree/BSD.debug.dist > /dev/null

	# Cleanup
	sudo chflags -R 0 ${workdir}
	sudo rm -rf ${workdir}

	sudo buildah unmount $c
	i=$(sudo buildah commit --rm $c localhost/${name}:${tag}-${arch})
	images="${images} $i"
    done
    if sudo buildah manifest exists localhost/${name}:${tag}; then
	sudo buildah manifest rm localhost/${name}:${tag}
    fi
    sudo buildah manifest create localhost/${name}:${tag} ${images}
}

# usage: build_image <branch> <tag> <from image> <image name> <fixup func> packages...
build_image() {
    local branch=$1; shift
    local tag=$1; shift
    local from=$1; shift
    local name=$1; shift
    local fixup=$1; shift

    local majorver=$(echo ${tag} | cut -d. -f1)
    local images=
    for arch in amd64 aarch64 ; do
	abi=FreeBSD:${majorver}:${arch}
	c=$(sudo buildah from --arch=${arch} ${from}:${tag}-${arch})
	m=$(sudo buildah mount $c)

	echo Generating ${name} for ${arch}

	echo Installing packages
	workdir=$(make_workdir ${branch})
	sudo env ABI=${abi} pkg --rootdir $m --repo-conf-dir ${workdir}/repos \
	     install -yq "$@"
	
	# Cleanup
	${fixup} $m $c
	sudo env ABI=${abi} pkg --rootdir $m --repo-conf-dir ${workdir}/repos clean -ayq
	rm -rf ${workdir}

	sudo buildah unmount $c
	i=$(sudo buildah commit --rm $c localhost/${name}:${tag}-${arch})
	images="${images} $i"
    done
    if sudo buildah manifest exists localhost/${name}:${tag}; then
	sudo buildah manifest rm localhost/${name}:${tag}
    fi
    sudo buildah manifest create localhost/${name}:${tag} ${images}
}
