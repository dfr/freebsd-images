FreeBSD Container Images
========================

Scripts for building FreeBSD container images using pkgbase:

Build images for FreeBSD-14.0-RELEASE:
```
sudo ./build.sh -b releng/14.0:14.0
```

or FreeBSD-14-STABLE:
```
sudo ./build.sh -b stable/14:14
```

or FreeBSD-current:
```
sudo ./build.sh -b main:15
```

The argument to build.sh has two parts separated by a colon.  The first part is
the FreeBSD branch to build and the second part is the matching ABI version. The
scripts combine the branch name with a base URL to get a URL for a pkg
repository that matches the branch. The default is to use the project's pkgbase
repository at [https://pkg.freebsd.org](https://pkg.freebsd.org).

The base URL is used with the pkg ABI (e.g. FreeBSD:14:amd64) and a repository
name to create the URL used to fetch packages.
For instance, the packages for 14-STABLE on amd64 are in
[https://pkg.freebsd/org/FreeBSD:14:amd64/base_latest](https://pkg.freebsd/org/FreeBSD:14:amd64/base_latest)
and 14.0-RELEASE would be in 
[https://pkg.freebsd/org/FreeBSD:14:amd64/base_release_0](https://pkg.freebsd/org/FreeBSD:14:amd64/base_release_0).

Images have the FreeBSD branch version embedded in the name (e.g. 14.0 for
releng/14.0 or 14 for stable/14) and the image tag is set to the pkgbase package
version, typically something like 15.snap20231107201926 or 14.0.
The latest tag is used to mark the most recent build.

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
