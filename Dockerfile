FROM ubuntu:focal
MAINTAINER Xfce Development Team

ENV DEBIAN_FRONTEND noninteractive

# Enable source repositories
RUN sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list

# Set up dependencies for the "xfce" and "app" groups
RUN apt-get update
RUN apt-get -y --no-install-recommends install libglib2.0-dev git libtool m4 automake intltool libx11-dev libgtk-3-dev libxfce4util-dev libxfce4ui-2-dev libwnck-3-dev libexo-2-dev gobject-introspection libgirepository1.0-dev \
  && apt-get -y --no-install-recommends build-dep xfce4-panel thunar xfce4-settings xfce4-session xfdesktop4 xfwm4 xfce4-appfinder tumbler \
  && apt-get -y --no-install-recommends build-dep catfish gigolo mousepad parole ristretto xfburn xfce4-dict xfce4-notifyd xfce4-screensaver xfce4-screenshooter xfce4-taskmanager xfce4-terminal \
  && apt-get -y --no-install-recommends build-dep xfce4-clipman-plugin \
  && apt-get -y --no-install-recommends install libmpd-dev valac libdbusmenu-gtk3-dev

# Build and install the latest tag for all Xfce core libraries
RUN mkdir /git
COPY ci/build_libs.sh /git/build_libs.sh
RUN chmod a+x /git/build_libs.sh

RUN /git/build_libs.sh
