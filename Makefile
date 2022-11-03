REGISTRIES ?=	docker.io/dougrabson quay.io/dougrabson
REPO ?=		release/13.1
TAG ?=		13.1

all:: minimal small
	sudo buildah rmi --prune > /dev/null

push::
	for reg in $(REGISTRIES); do \
		sudo buildah manifest push --all localhost/freebsd-minimal:$(TAG) docker://$$reg/freebsd-minimal:$(TAG); \
		sudo buildah manifest push --all localhost/freebsd-small:$(TAG) docker://$$reg/freebsd-small:$(TAG); \
	done

minimal::
	./build-minimal.sh $(REPO) $(TAG)

small::
	./build-small.sh $(REPO) $(TAG)
