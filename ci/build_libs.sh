#!/usr/bin/env bash

XFCE_BASE=https://gitlab.xfce.org

AUTOGEN_OPTIONS="--disable-debug --enable-maintainer-mode --host=x86_64-linux-gnu \
                --build=x86_64-linux-gnu --prefix=/usr --libdir=/usr/lib/x86_64-linux-gnu \
                --libexecdir=/usr/lib/x86_64-linux-gnu --sysconfdir=/etc --localstatedir=/var --enable-gtk-doc"

# (BUILD_TYPE BRANCH URL NAME) tuples:
REPOS=( "${XFCE_BASE}/xfce/xfce4-dev-tools.git xfce4-dev-tools")
REPOS+=("${XFCE_BASE}/xfce/libxfce4util.git libxfce4util")
REPOS+=("${XFCE_BASE}/xfce/xfconf.git xfconf")
REPOS+=("${XFCE_BASE}/xfce/libxfce4ui.git libxfce4ui")
REPOS+=("${XFCE_BASE}/xfce/exo.git exo")
REPOS+=("${XFCE_BASE}/xfce/garcon.git garcon")
REPOS+=("${XFCE_BASE}/xfce/xfce4-panel.git xfce4-panel")

for tuple in "${REPOS[@]}"; do
    set -- $tuple
    URL=$1
    NAME=$2
    cd /git
    git clone $URL
    cd $NAME
    TAG=$(git describe --abbrev=0 --match "$NAME*" 2>/dev/null)
    echo "--- Building $NAME ($TAG) ---"
    git checkout $TAG
    ./autogen.sh $AUTOGEN_OPTIONS
    make -j8
    make install
    echo "$(pwd): $(git describe)" >> /git/xfce_build_version_info.txt
done
