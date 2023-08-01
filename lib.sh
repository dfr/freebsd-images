REPOBASE=/zboot/iocage/jails/pkgbase/root/usr/obj/build/src
REPOURL=http://pkgbase.home.rabson.org/packages
ARCHES="amd64 aarch64"

get_majorver() {
    local tag=$1; shift
    echo ${tag} | cut -d. -f1
}

# Parse arguments and set branch, tag, has_caroot_data
parse_args() {
    while getopts "B:R:A:" arg; do
	case ${arg} in
	    B)
		REPOBASE="${OPTARG}"
		;;
	    R)
		REPOURL="${OPTARG}"
		;;
	    A)
		ARCHES="${OPTARG}"
		;;
	    *)
		echo "Unknown argument"
	esac
    done
    shift $(( ${OPTIND} - 1 ))
    if [ $# -ne 2 ]; then
	echo "usage: build-foo.sh [-B <repo dir>] [-R <repo url>] [-A <arches>] <branch> <tag>" > /dev/stderr
	exit 1
    fi
    branch=$1; shift
    tag=$1; shift
    set -- $(find ${REPOBASE}/${branch}/repo/FreeBSD:$(get_majorver ${tag}):amd64/latest -name 'FreeBSD-caroot-data*')
    if [ $# -gt 0 ]; then
	has_caroot_data=yes
    else 
	has_caroot_data=no
    fi
}

get_apl_path() {
    local branch=$1
    case ${branch} in
	releng/*)
	    ver=$(echo ${branch} | cut -d/ -f2)
	    echo "release/${ver}"
	    ;;
	stable/*)
	    echo "stable"
	    ;;
	main)
	    echo "current"
	    ;;
	*)
	    echo "unsupported branch for alpha.pkgbase.live: ${branch}" > /dev/stderr
	    exit 1
	    ;;
    esac
}

make_workdir() {
    local branch=$1
    local abi=$2
    local c=$3
    local workdir=$(mktemp -d -t freebsd-image)
    mkdir ${workdir}/repos
    cat > ${workdir}/repos/base.conf <<EOF
# FreeBSD pkgbase repo for building the images

FreeBSD-base: {
  url: "${REPOURL}/${branch}/\${ABI}/latest",
  signature_type: "pubkey",
  pubkey: "/usr/local/etc/ssl/pkgbase.pub",
  enabled: yes
}
EOF
    cat > ${workdir}/alpha.pkgbase.live.conf <<EOF
# FreeBSD pkgbase repo

FreeBSD-base: {
  url: "https://alpha.pkgbase.live/$(get_apl_path ${branch})/\${ABI}/latest",
  signature_type: "pubkey",
  pubkey: "/usr/local/etc/pkg/keys/alpha.pkgbase.live.pub"
  enabled: yes
}
EOF
    # Extract FreeBSD-runtime into the workdir to get the version and let
    # builder scripts copy fragments into an image
    mkdir ${workdir}/runtime
    sudo env ABI=${abi} pkg --rootdir ${workdir}/runtime --repo-conf-dir ${workdir}/repos \
	 install -yq FreeBSD-runtime
    
    # Add labels to the container
    local ver=$(sudo chroot ${workdir}/runtime freebsd-version)
    sudo buildah config --label "org.opencontainers.image.url=https://www.freebsd.org" $c
    sudo buildah config --label "org.opencontainers.image.version=${ver}" $c
    sudo buildah config --label "org.opencontainers.image.licenses=BSD2CLAUSE" $c

    echo ${workdir}
}

install_pkgbase_repo() {
    local workdir=$1
    local m=$2
    sudo cp ${workdir}/alpha.pkgbase.live.conf $m/usr/local/etc/pkg/repos/pkgbase.conf
    sudo mkdir -p $m/usr/local/etc/pkg/keys || return $?
    sudo fetch --output=$m/usr/local/etc/pkg/keys/alpha.pkgbase.live.pub \
	 https://alpha.pkgbase.live/alpha.pkgbase.live.pub || return $?
}

clean_workdir() {
    local workdir=$1
    sudo chflags -R 0 ${workdir}
    sudo rm -rf ${workdir}
}

# build an mtree directories only image
# usage: build_mtree <image name>
build_mtree() {
    local name=$1; shift

    local majorver=$(get_majorver ${tag})
    local images=
    for arch in ${ARCHES}; do
	local abi=FreeBSD:${majorver}:${arch}
	local c=$(sudo buildah from --arch=${arch} scratch)
	local workdir=$(make_workdir ${branch} ${abi} $c)
	local m=$(sudo buildah mount $c)

	echo Generating freebsd-mtree for ${arch}

	echo Creating directory structure
	# Install mtree package to a temp directory since it also pulls in
	# FreeBSD-runtime
	mkdir ${workdir}/tmp
	sudo env ABI=${abi} pkg --rootdir ${workdir}/tmp --repo-conf-dir ${workdir}/repos \
	     install -yq FreeBSD-mtree || exit $?
	sudo mtree -deU -p $m/ -f ${workdir}/tmp/etc/mtree/BSD.root.dist > /dev/null
	sudo mtree -deU -p $m/usr -f ${workdir}/tmp/etc/mtree/BSD.usr.dist > /dev/null
	sudo mtree -deU -p $m/usr/include -f ${workdir}/tmp/etc/mtree/BSD.include.dist > /dev/null
	sudo mtree -deU -p $m/usr/lib -f ${workdir}/tmp/etc/mtree/BSD.debug.dist > /dev/null

	# Cleanup
	sudo chflags -R 0 ${workdir}/tmp || exit $?
	sudo rm -rf ${workdir}/tmp || exit $?

	sudo buildah unmount $c
	i=$(sudo buildah commit --rm $c localhost/${name}:${tag}-${arch})
	images="${images} $i"
	clean_workdir ${workdir}
    done
    if sudo buildah manifest exists localhost/${name}:${tag}; then
	sudo buildah manifest rm localhost/${name}:${tag} || exit $?
    fi
    sudo buildah manifest create localhost/${name}:${tag} ${images} || exit $?
}

# usage: build_image <from image> <image name> <fixup func> packages...
build_image() {
    local from=$1; shift
    local name=$1; shift
    local fixup=$1; shift

    local majorver=$(get_majorver ${tag})
    local images=
    for arch in ${ARCHES}; do
	abi=FreeBSD:${majorver}:${arch}
	c=$(sudo buildah from --arch=${arch} ${from}:${tag}-${arch})
	local workdir=$(make_workdir ${branch} ${abi} $c)
	m=$(sudo buildah mount $c)

	echo Generating ${name} for ${arch}

	echo Installing packages
	sudo env ABI=${abi} pkg --rootdir $m --repo-conf-dir ${workdir}/repos \
	     install -y "$@" || exit $?
	
	# Cleanup
	${fixup} $m $c $workdir || exit $?
	sudo env ABI=${abi} pkg --rootdir $m --repo-conf-dir ${workdir}/repos clean -ayq || exit $?

	sudo buildah unmount $c || exit $?
	i=$(sudo buildah commit --rm $c localhost/${name}:${tag}-${arch})
	images="${images} $i"
	clean_workdir ${workdir}
    done
    if sudo buildah manifest exists localhost/${name}:${tag}; then
	sudo buildah manifest rm localhost/${name}:${tag} || exit $?
    fi
    sudo buildah manifest create localhost/${name}:${tag} ${images} || exit $?
}
