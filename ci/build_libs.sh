#!/usr/bin/env bash

set -euo pipefail

XFCE_BASE=https://gitlab.xfce.org
RELEASE=xfce-4.14

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

# list of git repos in build order
REPOS="${XFCE_BASE}/xfce/xfce4-dev-tools.git
  ${XFCE_BASE}/xfce/libxfce4util.git
  ${XFCE_BASE}/xfce/xfconf.git
  ${XFCE_BASE}/xfce/libxfce4ui.git
  ${XFCE_BASE}/xfce/exo.git
  ${XFCE_BASE}/xfce/garcon.git
  ${XFCE_BASE}/xfce/xfce4-panel.git
  ${XFCE_BASE}/xfce/thunar.git
"

for URL in ${REPOS}; do
    NAME=$(basename $URL .git)
    cd /git
    git clone $URL
    cd $NAME
    git checkout $RELEASE
    TAG=$(git describe --abbrev=0 --match "$NAME*" 2>/dev/null)
    echo "--- Building $NAME ($TAG) ---"
    git checkout -b build-$TAG $TAG
    ./autogen.sh $AUTOGEN_OPTIONS
    make -j${NPROC:-$(nproc)}
    make install
    echo "$(pwd): $(git describe)" >> /tmp/xfce_build_version_info.txt
    # Retain HTML docs in /docs
    if [[ -d "$(pwd)/docs" ]]; then
      HTMLPATH=$(find "$(pwd)/docs" -name html)
      if [[ ! -z "$HTMLPATH" ]]; then
        mkdir -p "/docs/$NAME"
        cp -a "$HTMLPATH/." "/docs/$NAME"
      fi
    fi
done

# cleanup
rm -rf /git/*
mv /tmp/xfce_build_version_info.txt /git/
