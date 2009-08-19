#!/bin/sh
#
# $Id$
#
# Copyright (c) 2002-2005
#         The Xfce development team. All rights reserved.
#
# Written for Xfce by Benedikt Meurer <benny@xfce.org>.
#

# substitute revision and date
if test -d .git; then
  revision=$(git rev-parse --short HEAD)
fi
if test "x$revision" = "x"; then
  revision=UNKNOWN
fi
sed -e "s/@REVISION@/${revision}/g" < "configure.in.in" > "configure.in"

if (type xdt-autogen) >/dev/null 2>&1; then
  exec xdt-autogen "$@"
else
  (aclocal &&
   automake --add-missing --copy --gnu &&
   autoconf) || exit 1

  if test x"${NOCONFIGURE}" = x""; then
    (./configure --enable-maintainer-mode "$@" &&
     echo "Now type \"make\" to build.") || exit 1
  else
    echo "Skipping configure process."
  fi
fi

# vi:set ts=2 sw=2 et ai:
