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
	sudo ./build-mtree.sh $(BRANCH) $(TAG)

static:: mtree
	sudo ./build-static.sh $(BRANCH) $(TAG)

static-debug:: static
	sudo ./build-static-debug.sh $(BRANCH) $(TAG)

base:: static
	sudo ./build-base.sh $(BRANCH) $(TAG)

base-debug:: base
	sudo ./build-base-debug.sh $(BRANCH) $(TAG)

minimal:: base
	sudo ./build-minimal.sh $(BRANCH) $(TAG)

small:: minimal
	sudo ./build-small.sh $(BRANCH) $(TAG)

pkgbase::
	sudo ./build-pkgbase.sh $(BRANCH) $(TAG)
