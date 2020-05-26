#!/bin/sh

XFCE_BASE=https://gitlab.xfce.org

AUTOGEN_OPTIONS="--disable-debug --enable-maintainer-mode --host=x86_64-linux-gnu
                --build=x86_64-linux-gnu --prefix=/usr --libdir=/usr/lib/x86_64-linux-gnu
                --libexecdir=/usr/lib/x86_64-linux-gnu --sysconfdir=/etc --localstatedir=/var --enable-gtk-doc"

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
    git checkout $TAG
    ./autogen.sh $AUTOGEN_OPTIONS
    make -j8
    make install
    echo "$(pwd): $(git describe)" >> /git/xfce_build_version_info.txt
done
