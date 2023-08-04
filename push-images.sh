#! /bin/sh

img=$1; shift
reg=$1; shift

tag=$(podman image inspect localhost/${img}:latest \
     | jq --raw-output '.[0].Annotations["org.opencontainers.image.version"]')

set -x

for arch in "$@"; do
    buildah push localhost/${img}:latest-${arch} docker://${reg}/${img}:${tag}-${arch}
    buildah push localhost/${img}:latest-${arch} docker://${reg}/${img}:latest-${arch}
done

buildah manifest push --all localhost/${img}:latest docker://${reg}/${img}:${tag}
buildah manifest push --all localhost/${img}:latest docker://${reg}/${img}:latest

