FROM ubuntu:24.04
MAINTAINER Xfce Development Team

ENV DEBIAN_FRONTEND noninteractive

# Set up dependencies for xfce components
RUN apt-get update \
  && apt-get -y --no-install-recommends install build-essential git libglib2.0-bin python3-distutils-extra python3-dev python-gi-dev libxss-dev libxml2-utils libgtk-3-dev gtk-doc-tools libx11-dev libglib2.0-dev libwnck-3-dev intltool liburi-perl libapr1-dev libaprutil1-dev x11-xserver-utils libvte-2.91-dev dbus-x11 cmake libpcre2-dev libsoup2.4-dev libsoup-3.0-dev libtool \
  libgtksourceview-4-dev libgtk-4-dev libgtksourceview-5-dev libtag1-dev xvfb autopoint gir1.2-gstreamer-1.0 libgstreamer-gl1.0-0 libgstreamer-plugins-base1.0-0 libgstreamer-plugins-base1.0-dev libgstreamer1.0-0 libgstreamer1.0-dev \
  libxss-dev libindicator3-dev libayatana-indicator3-dev libxmu-dev libburn-dev libisofs-dev  libpulse-dev libkeybinder-3.0-dev libmpd-dev valac libvala-0.56-dev gobject-introspection libgirepository1.0-dev librsvg2-dev libtagc0-dev libdbusmenu-gtk3-dev libgtop2-dev libnotify-dev libxklavier-dev libexif-dev libgexiv2-dev libgudev-1.0-dev libupower-glib-dev libclutter-1.0-dev libsensors-dev libical-dev libjson-c-dev \
  libwayland-bin libwayland-dev libgtk-layer-shell-dev \
  libcurl4-openssl-dev libffmpegthumbnailer-dev libgsf-1-dev libpoppler-glib-dev libopenrawgnome-dev libgepub-0.7-dev libgspell-1-dev \
  polkitd clang-format clang clang-tools meson python3-dbus python3-pexpect python3-psutil desktop-file-utils \
  libdbus-glib-1-dev libdisplay-info-dev libyaml-dev libcanberra-gtk3-dev libgladeui-dev xserver-xorg-input-libinput-dev libcolord-dev libpolkit-gobject-1-dev libqrencode-dev libutempter-dev libxpresent-dev libxnvctrl-dev libaccountsservice-dev libasound2-dev libsndio-dev \
  && rm -rf /var/lib/apt/lists/*

# Build and install the latest tag for all Xfce core libraries
RUN mkdir /git
COPY ci/build_libs.sh /git/build_libs.sh
RUN chmod a+x /git/build_libs.sh

RUN /git/build_libs.sh
