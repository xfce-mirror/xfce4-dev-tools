FROM ubuntu:focal
MAINTAINER Xfce Development Team

ENV DEBIAN_FRONTEND noninteractive

# Enable source repositories
RUN sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list

# Set up dependencies for the "xfce" and "app" groups
RUN apt-get update \
  && apt-get -y --no-install-recommends install git libglib2.0-bin build-essential libgtk-3-dev gtk-doc-tools libx11-dev libglib2.0-dev libwnck-3-dev intltool liburi-perl x11-xserver-utils libvte-2.91-dev dbus-x11 cmake libsoup2.4-dev libpcre2-dev libgtksourceview-3.0-dev libtag1-dev \
  && apt-get -y --no-install-recommends install libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
  python-distutils-extra  libxss-dev libindicator3-dev libxmu-dev libburn-dev libisofs-dev  libpulse-dev libkeybinder-3.0-dev libmpd-dev valac libvala-0.48-dev gobject-introspection libgirepository1.0-dev librsvg2-dev libtagc0-dev libdbusmenu-gtk3-dev libgtop2-dev libtool libnotify-dev libxklavier-dev libexif-dev libgudev-1.0-dev libupower-glib-dev

# Build and install the latest tag for all Xfce core libraries
RUN mkdir /git
COPY ci/build_libs.sh /git/build_libs.sh
RUN chmod a+x /git/build_libs.sh

RUN /git/build_libs.sh
