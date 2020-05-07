FROM ubuntu:focal

ENV DEBIAN_FRONTEND noninteractive

# set up dependencies
RUN apt-get update
RUN apt-get install -y libglib2.0-dev git libtool m4 automake intltool libx11-dev libgtk-3-dev libxfce4util-dev libxfce4ui-2-dev libwnck-3-dev libexo-2-dev automake-1.15 make
# remove automake 1.16 to avoid `config.status: error: Something went wrong bootstrapping makefile fragments`
RUN apt-get remove -y automake

# replicate git repo
COPY . /

# configure and build dev tools
RUN ./autogen.sh
RUN make install
