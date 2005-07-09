dnl $Id$
dnl
dnl Copyright (c) 2002-2005
dnl         The Xfce development team. All rights reserved.
dnl
dnl Written for Xfce by Benedikt Meurer <benny@xfce.org>.
dnl

dnl Version information
m4_define([xdt_version_major], [4])
m4_define([xdt_version_minor], [3])
m4_define([xdt_version_micro], [1])
m4_define([xdt_version_tag], [svn])
m4_define([xdt_version], [xdt_version_major().xdt_version_minor().xdt_version_micro()xdt_version_tag()])


dnl # DO NOT MODIFY ANYTHING BELOW THIS LINE, UNLESS YOU KNOW WHAT
dnl # YOU ARE DOING.


dnl Initialize autoconf
AC_INIT([xfce4-dev-tools], [xdt_version()], [xfce4-dev@xfce.org])
AC_COPYRIGHT([Copyright (c) 2002-2005
        The Xfce development team. All rights reserved.

Written for Xfce by Benedikt Meurer <benny@xfce.org>.])
AC_REVISION([$Id$])

dnl Initialize the other autotools
AM_INIT_AUTOMAKE([AC_PACKAGE_TARNAME()], [AC_PACKAGE_VERSION()])
AM_MAINTAINER_MODE()

dnl Check for basic programs
AC_PROG_INSTALL

dnl Generate files
AC_OUTPUT([
Makefile
xfce4-dev-tools.spec
m4macros/Makefile
scripts/Makefile
])

dnl vi:set ts=2 sw=2 et ai:
