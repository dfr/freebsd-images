#REGISTRIES ?=	docker.io/dougrabson quay.io/dougrabson
REGISTRIES ?=	registry.home.rabson.org/dougrabson
BRANCH ?=	releng/13.2
TAG ?=		13.2

all:: base minimal small pkgbase

push::
.for reg in $(REGISTRIES)
.for img in base minimal small pkgbase
	sudo buildah manifest push --all \
		localhost/freebsd-${img}:$(TAG) \
		docker://${reg}/freebsd-${img}:$(TAG)
.endfor
.endfor

mtree::
	./build-mtree.sh $(BRANCH) $(TAG)

base:: mtree
	./build-base.sh $(BRANCH) $(TAG)

base-debug:: mtree
	./build-base.sh $(BRANCH) $(TAG)

minimal:: base
	./build-minimal.sh $(BRANCH) $(TAG)

small:: minimal
	./build-small.sh $(BRANCH) $(TAG)

pkgbase::
	./build-pkgbase.sh $(BRANCH) $(TAG)
