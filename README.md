FreeBSD Container Images
========================

Experimental scripts for building FreeBSD container images using
pkgbase:

```
# Prepare the pkgbase package set
N=<cpu count>
pushd /usr/src
make -j$N buildworld
make -j$N buildkernel
make -j$N packages
popd

# Build local container images from those packages
make all
```
