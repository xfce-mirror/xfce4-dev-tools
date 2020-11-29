#!/bin/sh

XFCE_BASE=https://gitlab.xfce.org

: ${libdir:="/usr/lib/x86_64-linux-gnu"}
: ${libexecdir:="/usr/lib/x86_64-linux-gnu"}

AUTOGEN_OPTIONS="
  --disable-debug
  --enable-maintainer-mode
  --prefix=/usr
  --libdir=$libdir
  --libexecdir=$libexecdir
  --sysconfdir=/etc
  --localstatedir=/var
  --enable-gtk-doc
"

CFLAGS="
  -Wall
  -Wno-deprecated-declarations
  -Werror=implicit-function-declaration
  -Werror=return-type
"

# list of git repos in build order
REPOS="${XFCE_BASE}/xfce/xfce4-dev-tools.git
  ${XFCE_BASE}/xfce/libxfce4util.git
  ${XFCE_BASE}/xfce/xfconf.git
  ${XFCE_BASE}/xfce/libxfce4ui.git
  ${XFCE_BASE}/xfce/exo.git
  ${XFCE_BASE}/xfce/garcon.git
  ${XFCE_BASE}/xfce/xfce4-panel.git
"

for URL in ${REPOS}; do
    NAME=$(basename $URL .git)
    cd /git
    git clone $URL
    cd $NAME
    TAG=$(git describe --abbrev=0 --match "$NAME*" 2>/dev/null)
    echo "--- Building $NAME ($TAG) ---"
    git checkout -b build-$TAG $TAG
    env "CFLAGS=${CFLAGS}" ./autogen.sh $AUTOGEN_OPTIONS
    make -j${NPROC:-$(nproc)}
    make install
    echo "$(pwd): $(git describe)" >> /tmp/xfce_build_version_info.txt
done

# cleanup
rm -rf /git/*
mv /tmp/xfce_build_version_info.txt /git/
