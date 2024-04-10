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

MESON_SETUP_OPTIONS="
  --buildtype=release
  --prefix=/usr
  --libdir=$libdir
  --libexecdir=$libexecdir
  --sysconfdir=/etc
  --localstatedir=/var
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
    if [ -x autogen.sh ]; then
      BUILDDIR_PREFIX=.
      ./autogen.sh $AUTOGEN_OPTIONS
      make -j${NPROC:-$(nproc)}
      make install
    elif [ -f meson.build ]; then
      BUILDDIR_PREFIX=build
      # Passing unknown options to 'meson setup' is a fatal error
      if [ -f meson_options.txt ] && grep -q "'gtk-doc'" meson_options.txt; then
        GTK_DOC_OPT='-Dgtk-doc=true'
      else
        GTK_DOC_OPT=''
      fi
      meson setup $MESON_SETUP_OPTIONS $GTK_DOC_OPT "$BUILDDIR_PREFIX"
      meson compile -C"$BUILDDIR_PREFIX"
      meson install -C"$BUILDDIR_PREFIX" --skip-subprojects
    else
      echo "No supported build system found for $NAME" >&2
      exit 1
    fi
    echo "$(pwd): $(git describe)" >> /tmp/xfce_build_version_info.txt
    # Retain HTML docs in /docs
    if [[ -d "$(pwd)/docs" ]]; then
      # Special case for thunar because it has docs for thunar and thunarx
      if [[ "$NAME" == "thunar" ]]; then
        mkdir -p "/docs/$NAME"{,x}
        cp -a "$BUILDDIR_PREFIX/docs/reference/thunar/html/." "/docs/$NAME"
        cp -a "$BUILDDIR_PREFIX/docs/reference/thunarx/html/." "/docs/$NAME"x
      # Ditto for libxfce4windowing
      elif [[ "$NAME" == "libxfce4windowing" ]]; then
        mkdir -p "/docs/$NAME"{,ui}
        cp -a "$BUILDDIR_PREFIX/docs/reference/libxfce4windowing/html/." "/docs/$NAME"
        cp -a "$BUILDDIR_PREFIX/docs/reference/libxfce4windowingui/html/." "/docs/$NAME"ui
      else
        HTMLPATH=$(find "$(pwd)/$BUILDDIR_PREFIX/docs" -name html)
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
