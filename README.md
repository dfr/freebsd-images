FreeBSD Container Images
========================

Scripts for building FreeBSD container images using pkgbase:

Build images for FreeBSD-13.2-RELEASE:
```
make BRANCH=releng/13.2 TAG=13.2
```

or FreeBSD-13-STABLE:
```
make BRANCH=stable/13 TAG=13
```

or FreeBSD-current:
```
make BRANCH=main TAG=14
```

The following images are provided:

- freebsd-static
  - This contains SSL certificates, timezone data and a few other config
    files. It is intended to be used with statically linked workloads.
- freebsd-static-debug
  - This adds /rescue to freebsd-static to help with debugging.
- freebsd-base
  - This builds on freebsd-static and adds base system dynamic libraries as well
    as openssl libraries to support dynamically linked workloads.
- freebsd-base-debug
  - This adds /rescue to freebsd-base to help with debugging.
- freebsd-minimal
  - This adds core system utilities and package management to support
    shall-based workloads.
- freebsd-small
  - This adds a wider set of system utilities for broader support of shall-based
    workloads.
	
