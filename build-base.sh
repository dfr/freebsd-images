#! /bin/sh

. lib.sh

fixup() {
    # copy /etc/passwd from FreeBSD-runtime
    d=$(mktemp -d -t freebsd-tmp)
    sudo env ABI=${abi} pkg --rootdir $d --repo-conf-dir ${workdir}/repos \
	 install -yq FreeBSD-runtime
    sudo pwd_mkdb -d $m/etc $d/etc/master.passwd
    sudo cp $d/etc/group $m/etc

    sudo chflags -R 0 $d
    sudo rm -rf $d

    # maybe remove openssl binary?
}

build_image $1 $2 freebsd-mtree freebsd-base fixup \
	    FreeBSD-clibs \
	    FreeBSD-caroot \
	    FreeBSD-zoneinfo
