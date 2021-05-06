#!/bin/sh
#
# Copyright (c) 2002-2021
#         The Xfce development team. All rights reserved.
#
# Written for Xfce by Benedikt Meurer <benny@xfce.org>.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
mkdir -p m4
autoreconf --verbose --install --force || exit 1

if test x"${NOCONFIGURE}" = x""; then
  (./configure --enable-maintainer-mode "$@" &&
   echo "Now type \"make\" to build.") || exit 1
else
  echo "Skipping configure process."
fi

# vi:set ts=2 sw=2 et ai:
