dnl
dnl Copyright (c) 2002-2022
dnl         The Xfce development team. All rights reserved.
dnl
dnl Written for Xfce by Benedikt Meurer <benny@xfce.org>.
dnl

dnl ***************************
dnl *** Version information ***
dnl ***************************

XDT_VERSION_INIT([4.18.0])

dnl # DO NOT MODIFY ANYTHING BELOW THIS LINE, UNLESS YOU KNOW WHAT
dnl # YOU ARE DOING.


dnl ***************************
dnl *** Initialize autoconf ***
dnl ***************************
AC_INIT([xfce4-dev-tools], [xdt_version],
        [https://gitlab.xfce.org/xfce/xfce4-dev-tools/])
AC_COPYRIGHT([Copyright (c) 2002-2022 The Xfce development team. All rights reserved.])
AC_CONFIG_MACRO_DIR([m4])
AC_REVISION([xdt_version_build])

dnl substitute version info
AC_SUBST([VERSION_MAJOR], [xdt_version_major])
AC_SUBST([VERSION_MINOR], [xdt_version_minor])
AC_SUBST([VERSION_MICRO], [xdt_version_micro])
VERSION_REVISION=ifelse(xdt_version_tag(), [git], [xdt_version_tag()-xdt_version_build()], [])
AC_SUBST([VERSION_REVISION])

dnl ***************************
dnl *** Initialize automake ***
dnl ***************************
AM_INIT_AUTOMAKE([1.11 dist-bzip2 tar-ustar no-dist-gzip foreign])
AM_MAINTAINER_MODE()
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

dnl ********************************
dnl *** Check for basic programs ***
dnl ********************************
AC_PROG_CC()
AM_PROG_CC_C_O()
AC_PROG_INSTALL()

dnl **************************
dnl *** Initialize libtool ***
dnl **************************
LT_PREREQ([2.4])
LT_INIT([disable-static])

dnl ***************************************
dnl *** Check for standard header files ***
dnl ***************************************
AC_CHECK_HEADERS([libintl.h locale.h memory.h stdio.h stdlib.h string.h])

dnl ***********************************
dnl *** Check for required packages ***
dnl ***********************************
PKG_CHECK_MODULES([GLIB], [glib-2.0 >= 2.66.0])

dnl **********************
dnl *** Generate files ***
dnl **********************
AC_CONFIG_FILES([
Makefile
helpers/Makefile
m4macros/Makefile
scripts/Makefile
scripts/xdt-autogen
xdt-csource/Makefile
docs/Makefile
tests/Makefile
tests/data/Makefile
])
AC_OUTPUT

dnl vi:set ts=2 sw=2 et ai:
