FROM ubuntu:focal

ENV DEBIAN_FRONTEND noninteractive

# set up dependencies
RUN apt-get update

RUN apt-get install -y --no-install-recommends libglib2.0-dev git libtool m4 automake intltool libx11-dev libgtk-3-dev libxfce4util-dev libxfce4ui-2-dev libwnck-3-dev libexo-2-dev \
  && apt-get install -y --no-install-recommends automake-1.15 make \
  && apt-get -y --no-install-recommends build-dep xfce4-panel thunar xfce4-settings xfce4-session xfdesktop4 xfwm4 xfce4-appfinder tumbler xfce4-terminal xfce4-clipman-plugin xfce4-screenshooter \
# remove automake 1.16 to avoid `config.status: error: Something went wrong bootstrapping makefile fragments`.
# If this is removed we should also , remove the explicit install of automake-1.15 above
RUN apt-get remove -y automake

# replicate git repo
COPY . /

# configure and build dev tools
RUN ./autogen.sh
RUN make install
