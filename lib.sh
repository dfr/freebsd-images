DOCKER=docker.io/dougrabson
QUAY=quay.io/dougrabson

make_workdir() {
    local d=$(mktemp -d -t freebsd-image)
    mkdir $d/repos
    cat > $d/repos/base.conf <<EOF
# FreeBSD pkgbase repo

FreeBSD-base: {
  url: "https://alpha.pkgbase.live/${REPO}/\${ABI}/latest",
  signature_type: "pubkey",
  pubkey: "/usr/share/keys/pkg/trusted/alpha.pkgbase.live.pub",
  enabled: yes
}
EOF
    echo $d
}


tag_image() {
    local id=$1
    local name=$2
    for reg in $DOCKER $QUAY; do
	sudo buildah tag $id $reg/$name:${TAG}
    done
    sudo buildah tag $id $name:${TAG}
}
