DOCKER :=	docker.io/dougrabson
QUAY :=		quay.io/dougrabson

REPO ?=		release/13.1
TAG ?=		13.1


all:: minimal small
	sudo buildah rmi --prune > /dev/null

push::
	for reg in $(DOCKER) $(QUAY); do \
		sudo buildah push $$reg/freebsd-minimal:$(TAG); \
		sudo buildah push $$reg/freebsd-small:$(TAG); \
	done

minimal::
	./build-minimal.sh $(REPO) $(TAG)

small::
	./build-small.sh $(REPO) $(TAG)
