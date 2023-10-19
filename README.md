FreeBSD Container Images
========================

Scripts for building FreeBSD container images using pkgbase:

Build images for FreeBSD-13.2-RELEASE:
```
sudo ./build.sh -b releng/13.2:13
```

or FreeBSD-13-STABLE:
```
sudo ./build.sh -b stable/13:13
```

or FreeBSD-current:
```
sudo ./build.sh -b main:15
```

The argument to build.sh has two parts separated by a colon.  The first part is
the FreeBSD branch to build and the second part is the matching ABI version. The
scripts combine the branch name with a base URL to get a URL for a pkg
repository that matches the branch. In my home lab build infrastructure, the
base URL is
[http://pkgbase.home.rabson.org/packages](http://pkgbase.home.rabson.org/packages)
and the packages for e.g. 13-STABLE on amd64 are in
[http://pkgbase.home.rabson.org/packages/stable/13/FreeBSD:13:amd64/latest](http://pkgbase.home.rabson.org/packages/stable/13/FreeBSD:13:amd64/latest).

Images have the FreeBSD branch version embedded in the name (e.g. 13.2 for
releng/13.2 or 13 for stable/13) and the image tag is set to the pkgbase package
version, typically something like 13.snap20231018202743 or 13.2p4. The latest
tag is used to mark the most recent build.

The following images are provided:

- freebsd${ver}-static
  - This contains SSL certificates, timezone data and a few other config
    files. It is intended to be used with statically linked workloads.
- freebsd${ver}-static-debug
  - This adds /rescue to freebsd-static to help with debugging.
- freebsd${ver}-base
  - This builds on freebsd-static and adds base system dynamic libraries as well
    as openssl libraries to support dynamically linked workloads.
- freebsd${ver}-base-debug
  - This adds /rescue to freebsd-base to help with debugging.
- freebsd${ver}-minimal
  - This adds core system utilities and package management to support
    shall-based workloads.
- freebsd${ver}-small
  - This adds a wider set of system utilities for broader support of shall-based
    workloads.
	
