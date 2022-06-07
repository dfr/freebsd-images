DOCKER :=	docker.io/dougrabson
QUAY :=		quay.io/dougrabson

REPO :=		/usr/obj/usr/src/repo/FreeBSD:13:amd64/latest
VER :=		13.1


all:: minimal small pkgbase
	sudo buildah rmi --prune > /dev/null

push::
	for reg in $(DOCKER) $(QUAY); do \
		sudo buildah push $$reg/freebsd-minimal:13.1; \
		sudo buildah push $$reg/freebsd-small:13.1; \
	done

minimal::
	./build-minimal.sh $(REPO) $(VER)

small::
	./build-small.sh $(REPO) $(VER)

pkgbase::
	./build-pkgbase.sh $(REPO) $(VER)
