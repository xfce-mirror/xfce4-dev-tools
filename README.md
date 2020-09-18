[![License](https://img.shields.io/badge/License-GPL%20v2-blue.svg)](https://gitlab.xfce.org/xfce/xfce4-dev-tools/-/blob/master/COPYING)

# xfce4-dev-tools


The Xfce development tools are a collection of tools and macros for
Xfce developers and people that want to build Xfce from git. In addition,
it contains the Xfce developer's handbook.

----

## `xfce-build` containerized build environment

This project also contains the code to build and deploy xfce-build to the 
[xfce-build area on Docker Hub](https://hub.docker.com/repository/docker/xfce/xfce-build/). 
This container is the build environment used by Xfce to build the various projects.
It can also be used as your own build environment as follows:

```bash
docker run --rm -u $(id -u ${USER}):$(id -g ${USER}) \
  --volume $(pwd):/tmp xfce/xfce-build:master /bin/bash \
  -c "cd /tmp; ./autogen.sh && make distcheck"
```

The steps to build the container are encoded in the [`Dockerfile`](https://gitlab.xfce.org/xfce/xfce4-dev-tools/-/blob/master/Dockerfile) in
this repository, and is built via the build job in [`.gitlab-ci.yml`](https://gitlab.xfce.org/xfce/xfce4-dev-tools/-/blob/master/.gitlab-ci.yml).

## CI templates for Xfce

The [CI folder](ci/) contains the `build_project.yml` template for building the various
Xfce projects, as well as supporting scripts such as `build_libs.sh` which handles
building any needed dependencies. This helps us avoid repeating the same build
code in each project.

----

### Homepage

[Xfce4-dev-tools documentation](https://docs.xfce.org/xfce/xfce4-dev-tools/start)

### Changelog

See [NEWS](https://gitlab.xfce.org/xfce/xfce4-dev-tools/-/blob/master/NEWS) for details on changes and fixes made in the current release.

### Source Code Repository

[Xfce4-dev-tools source code](https://gitlab.xfce.org/xfce/xfce4-dev-tools)

### Download a Release Tarball

[Xfce4-dev-tools archive](https://archive.xfce.org/src/xfce/xfce4-dev-tools)
    or
[Xfce4-dev-tools tags](https://gitlab.xfce.org/xfce/xfce4-dev-tools/-/tags)

### Installation

From source: 

    % cd xfce4-dev-tools
    % ./autogen.sh
    % make
    % make install

From release tarball:

    % tar xf xfce4-dev-tools-<version>.tar.bz2
    % cd xfce4-dev-tools-<version>
    % ./configure
    % make
    % make install

### Reporting Bugs

Visit the [reporting bugs](https://docs.xfce.org/xfce/xfce4-dev-tools/bugs) page to view currently open bug reports and instructions on reporting new bugs or submitting bugfixes.

