FROM ubuntu:focal
MAINTAINER Xfce Development Team

ENV DEBIAN_FRONTEND noninteractive

# Enable source repositories
RUN sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list

# Set up dependencies
RUN apt-get update
RUN apt-get -y --no-install-recommends install libglib2.0-dev git libtool m4 automake intltool libx11-dev libgtk-3-dev libxfce4util-dev libxfce4ui-2-dev libwnck-3-dev libexo-2-dev gobject-introspection libgirepository1.0-dev \
  && apt-get -y --no-install-recommends install automake-1.15 make \
  && apt-get -y --no-install-recommends build-dep xfce4-panel thunar xfce4-settings xfce4-session xfdesktop4 xfwm4 xfce4-appfinder tumbler xfce4-terminal xfce4-clipman-plugin xfce4-screenshooter

# Remove automake 1.16 to avoid `config.status: error: Something went wrong bootstrapping makefile fragments`.
# If this is removed we should also remove the explicit install of automake-1.15 above.
RUN apt-get remove -y automake

# Build and install the latest tag for all Xfce core libraries
RUN mkdir /git
COPY ci/build_libs.sh /git/build_libs.sh
RUN chmod a+x /git/build_libs.sh

RUN /git/build_libs.sh
