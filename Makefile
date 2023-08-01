REGISTRIES ?=	docker.io/dougrabson quay.io/dougrabson
BRANCH ?=	releng/13.2
TAG ?=		13.2

IMAGES= static static-debug base base-debug minimal small

all:: $(IMAGES)

push::
.for reg in $(REGISTRIES)
.for img in $(IMAGES)
	sudo buildah manifest push --all \
		localhost/freebsd-${img}:$(TAG) \
		docker://${reg}/freebsd-${img}:$(TAG)
.endfor
.endfor

mtree::
	./build-mtree.sh $(BRANCH) $(TAG)

static:: mtree
	./build-static.sh $(BRANCH) $(TAG)

static-debug:: static
	./build-static-debug.sh $(BRANCH) $(TAG)

base:: static
	./build-base.sh $(BRANCH) $(TAG)

base-debug:: base
	./build-base-debug.sh $(BRANCH) $(TAG)

minimal:: base
	./build-minimal.sh $(BRANCH) $(TAG)

small:: minimal
	./build-small.sh $(BRANCH) $(TAG)

pkgbase::
	./build-pkgbase.sh $(BRANCH) $(TAG)
