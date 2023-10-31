#!/usr/bin/env bash

set -euo pipefail

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

# list of git repos in build order
REPOS="${XFCE_BASE}/xfce/xfce4-dev-tools.git
  ${XFCE_BASE}/xfce/libxfce4util.git
  ${XFCE_BASE}/xfce/xfconf.git
  ${XFCE_BASE}/xfce/libxfce4ui.git
  ${XFCE_BASE}/xfce/libxfce4windowing.git
  ${XFCE_BASE}/xfce/exo.git
  ${XFCE_BASE}/xfce/garcon.git
  ${XFCE_BASE}/xfce/xfce4-panel.git
  ${XFCE_BASE}/xfce/thunar.git
  ${XFCE_BASE}/xfce/tumbler.git
"

for URL in ${REPOS}; do
    NAME=$(basename $URL .git)
    cd /git
    git clone --recurse-submodules $URL
    cd $NAME
    # We build higher version possible tag, whatever branch it comes from
    TAG=$(git tag --sort=version:refname | grep  "$NAME-" | tail -1)
    echo "--- Building $NAME ($TAG) ---"
    git checkout -b build-$TAG $TAG
    ./autogen.sh $AUTOGEN_OPTIONS
    make -j${NPROC:-$(nproc)}
    make install
    echo "$(pwd): $(git describe)" >> /tmp/xfce_build_version_info.txt
    # Retain HTML docs in /docs
    if [[ -d "$(pwd)/docs" ]]; then
      # Special case for thunar because it has docs for thunar and thunarx
      if [[ "$NAME" == "thunar" ]]; then
        mkdir -p "/docs/$NAME"{,x}
        cp -a docs/reference/thunar/html/. "/docs/$NAME"
        cp -a docs/reference/thunarx/html/. "/docs/$NAME"x
      # Ditto for libxfce4windowing
      elif [[ "$NAME" == "libxfce4windowing" ]]; then
        mkdir -p "/docs/$NAME"{,ui}
        cp -a docs/reference/libxfce4windowing/html/. "/docs/$NAME"
        cp -a docs/reference/libxfce4windowingui/html/. "/docs/$NAME"ui
      else
        HTMLPATH=$(find "$(pwd)/docs" -name html)
        if [[ ! -z "$HTMLPATH" ]]; then
          mkdir -p "/docs/$NAME"
          cp -a "$HTMLPATH/." "/docs/$NAME"
        fi
      fi
    fi
done

# cleanup
rm -rf /git/*
mv /tmp/xfce_build_version_info.txt /git/
