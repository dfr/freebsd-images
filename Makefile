REGISTRIES ?=	docker.io/dougrabson quay.io/dougrabson
BRANCH ?=	releng/13.2
VER ?=		13.2
ARCHES ?=	amd64 aarch64
PKG ?=		pkg

IMAGES =	static static-debug base base-debug minimal small pf

all:: $(IMAGES)

push::
.for reg in $(REGISTRIES)
.for img in $(IMAGES)
	sudo ./push-images.sh freebsd$(VER)-${img} ${reg} # $(ARCHES)
.endfor
.endfor

mtree::
	sudo ./build-mtree.sh -P $(PKG) -A "$(ARCHES)" $(BRANCH) $(VER)

static:: mtree
	sudo ./build-static.sh -P $(PKG) -A "$(ARCHES)" $(BRANCH) $(VER)

static-debug:: static
	sudo ./build-static-debug.sh -P $(PKG) -A "$(ARCHES)" $(BRANCH) $(VER)

base:: static
	sudo ./build-base.sh -P $(PKG) -A "$(ARCHES)" $(BRANCH) $(VER)

base-debug:: base
	sudo ./build-base-debug.sh -P $(PKG) -A "$(ARCHES)" $(BRANCH) $(VER)

minimal:: base
	sudo ./build-minimal.sh -P $(PKG) -A "$(ARCHES)" $(BRANCH) $(VER)

small:: minimal
	sudo ./build-small.sh -P $(PKG) -A "$(ARCHES)" $(BRANCH) $(VER)

pf:: small
	sudo ./build-pf.sh -P $(PKG) -A "$(ARCHES)" $(BRANCH) $(VER)
