DOCKER=docker.io/dougrabson
QUAY=quay.io/dougrabson

tag_image() {
    local id=$1
    local name=$2
    for reg in $DOCKER $QUAY; do
	sudo buildah tag $id $reg/$name:13.1
    done
    sudo buildah tag $id $name:13.1
}
