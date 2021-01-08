dnl Copyright (c) 2002-2020
dnl         The Xfce development team. All rights reserved.
dnl
dnl Written for Xfce by Natanael Copa <ncopa@alpinelinux.org>
dnl
dnl This program is free software; you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation; either version 2 of the License, or
dnl (at your option) any later version.
dnl
dnl This program is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
dnl GNU General Public License for more details.
dnl
dnl You should have received a copy of the GNU General Public License along
dnl with this program; if not, write to the Free Software Foundation, Inc.,
dnl 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
dnl
dnl xdt-version
dnl --------
dnl  Version initialization M4 macros.
dnl


dnl XDT_VERSION_INIT(SEMVER, [TAG])
dnl
dnl This macro takes care of setting up the version numbering.
dnl
dnl It will define the following macros based on SEMVER and TAG:
dnl
dnl  - xdt_version
dnl  - xdt_version_major
dnl  - xdt_version_minor
dnl  - xdt_version_micro
dnl  - xdt_version_tag
dnl  - xdt_version_build
dnl  - xdt_debug_default
dnl
dnl If TAG isn't specified, the xdt_version_tag and xdt_version_git
dnl will be empty and xdt_debug_default will be set to "minimum",
dnl otherwise the xdt_version_build will contain a git hash and
dnl xdt_debug_default will be set to "yes"
dnl
dnl Example usage:
dnl
dnl XDT_VERSION_INIT([4.15.3],[git])
dnl AC_INIT([xfce4-someproject],[xdt_version()])
dnl ...
dnl XDT_FEATURE_DEBUG([xdt_debug_default])
dnl

AC_DEFUN([XDT_VERSION_INIT],
[
  m4_define([xdt_version_tag], [$2])

  dnl set git revision in xdt_version_build if TAG is set
  m4_define([xdt_version_build], [ifelse(xdt_version_tag(), [git],
    [esyscmd([
      if test -d .git; then
        revision=$(git rev-parse --short HEAD 2>/dev/null)
      fi
      printf "%s" "${revision:-UNKNOWN}"
    ])])])

  dnl define xdt_debug_default to "yes" if TAG is set
  m4_define([xdt_debug_default], [ifelse(xdt_version_tag(), [git], [yes], [minimum])])

  dnl define xdt_version string
  m4_define([xdt_version], [$1][ifelse(xdt_version_tag(), [git], [xdt_version_tag()-xdt_version_build()], [xdt_version_tag()])])

  dnl define major, minor and micro
  m4_define([xdt_version_major], [esyscmd([
    version="$1"
    printf "%s" "${version%%.*}"
  ])])

  m4_define([xdt_version_minor], [esyscmd([
    version="$1"
    case "$version" in
      *.*)
        major="${version%%.*}"
        minor_micro="${version#${major}.}"
        printf "%s" "${minor_micro%%.*}"
        ;;
    esac
  ])])

  m4_define([xdt_version_micro], [esyscmd([
    version="$1"
    case "$version" in
      *.*.*)
        major=${version%%.*}
        minor_micro=${version#${major}.}
        minor="${minor_micro%%.*}"
        reminder=${version#${major}.${minor}.}
        printf "%s" "${reminder%%.*}"
        ;;
    esac
  ])])
])

