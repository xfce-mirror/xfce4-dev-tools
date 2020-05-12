## What is it?

The Xfce development tools are a collection of tools and macros for
Xfce developers and people that want to build Xfce from Git In addition
it contains the Xfce developer's handbook.

This project also contains the code to build and deploy xfce-build to the 
[xfce-build area on Docker Hub](https://hub.docker.com/repository/docker/xfce/xfce-build/). 
This container is the build environment used by Xfce to build the various projects.
It can also be used as your own build environment as follows:

```bash
docker run --rm -u $(id -u ${USER}):$(id -g ${USER}) \
  --volume $(pwd):/tmp xfce/xfce-build:master /bin/bash \
  -c "cd /tmp; ./autogen.sh && make distcheck"
```

The steps to build the container are encoded in the [`Dockerfile`](Dockerfile) in
this repository, and is built via the build job in [`.gitlab-ci.yml`](.gitlab-ci.yml).


## How to report bugs?

Bugs should be reported to the [Xfce bugtracking system](http://bugzilla.xfce.org), 
product Xfce development tools). You will need to create an account for yourself.

Please read the file [`HACKING`](HACKING) for information on where to send changes
or bugfixes for this package.
