dnl
dnl Copyright (c) 2002-2022
dnl         The Xfce development team. All rights reserved.
dnl
dnl Written for Xfce by Benedikt Meurer <benny@xfce.org>.
dnl

dnl ***************************
dnl *** Version information ***
dnl ***************************

XDT_VERSION_INIT([4.21.2])

dnl # DO NOT MODIFY ANYTHING BELOW THIS LINE, UNLESS YOU KNOW WHAT
dnl # YOU ARE DOING.


dnl ***************************
dnl *** Initialize autoconf ***
dnl ***************************
AC_INIT([xfce4-dev-tools], [xdt_version],
        [https://gitlab.xfce.org/xfce/xfce4-dev-tools/])
AC_COPYRIGHT([Copyright (c) 2002-2026 The Xfce development team. All rights reserved.])
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

AC_CANONICAL_HOST

dnl ********************************
dnl *** Check for basic programs ***
dnl ********************************
AC_PROG_CC()
AM_PROG_CC_C_O()
AC_PROG_INSTALL()
AC_PROG_SED()

dnl **********************
dnl *** Check xsltproc ***
dnl **********************
AC_CHECK_PROG([XSLTPROC], [xsltproc],yes)
AS_IF([test x"$XSLTPROC" != x"yes"], [AC_MSG_ERROR([package 'xsltproc' missing])])

dnl **************************
dnl *** Initialize libtool ***
dnl **************************
LT_PREREQ([2.4])
LT_INIT([disable-static])

dnl ****************************************
dnl *** Check for host specific programs ***
dnl ****************************************
case "${host_os}" in
    freebsd*)
      AC_CHECK_PROGS(GSED, [gsed], no)
      AS_IF([test x"$GSED" = x"no"], [AC_MSG_ERROR([GNU sed (gsed) missing])])

      AC_CHECK_PROGS(GMAKE, [gmake], no)
      AS_IF([test x"$GMAKE" = x"no"], [AC_MSG_ERROR([GNU make (gmake) missing])])
      ;;
    *)
      GSED="sed"
      GMAKE="make"
      ;;
esac

AC_CHECK_PROGS(MESON, [meson], no)
AS_IF([test x"$MESON" = x"no"], [AC_MSG_ERROR([meson missing])])

AC_SUBST(GSED)
AC_SUBST(GMAKE)
AC_SUBST(MESON)

dnl cppcheck cfg files are installed in $libdir on ubuntu and $datadir on arch, so let's add this option
AC_ARG_WITH([cppcheck-cfg-prefix],
            [AS_HELP_STRING([--with-cppcheck-cfg-prefix=PATH],
                            [Path prefix under which the xfce.cfg file will be installed (default: $libdir)])],
            [CPPCHECK_CFG_PREFIX="$withval"],
            [CPPCHECK_CFG_PREFIX="$libdir"])
AC_SUBST([CPPCHECK_CFG_PREFIX])

dnl Parts of "$CPPCHECK_CFG_PREFIX/cppcheck/cfg/gtk.cfg" were added only after version 2.19, which is the
dnl version we use in CI, so don't add them for users if they use cppcheck >= 2.20, as it would conflict
CPPCHECK_VERSION="0"
if test -f "$CPPCHECK_CFG_PREFIX/cppcheck/cfg/gtk.cfg"; then
    dnl https://github.com/cppcheck-opensource/cppcheck/commit/40f6f6ad90c987ca6ffcd72881128acab9ed8997
    if grep -q '<define name="G_FILE_ATTRIBUTE_STANDARD_TYPE' "$CPPCHECK_CFG_PREFIX/cppcheck/cfg/gtk.cfg"; then
        CPPCHECK_VERSION="2.21.0"
    dnl https://github.com/cppcheck-opensource/cppcheck/commit/8c762adcdd9e63e89ddeeb90ccfee5a225ae8a77
    elif grep -q '<define name="GLIB_CHECK_VERSION' "$CPPCHECK_CFG_PREFIX/cppcheck/cfg/gtk.cfg"; then
        CPPCHECK_VERSION="2.20.0"
    fi
fi
AC_SUBST([CPPCHECK_VERSION])

dnl ***************************************
dnl *** Check for standard header files ***
dnl ***************************************
AC_CHECK_HEADERS([libintl.h locale.h memory.h stdio.h stdlib.h string.h])

dnl ***********************************
dnl *** Check for required packages ***
dnl ***********************************
PKG_CHECK_MODULES([GLIB], [glib-2.0 >= 2.72.0])

dnl **********************
dnl *** Generate files ***
dnl **********************
AC_CONFIG_FILES([
Makefile
helpers/Makefile
helpers/xfce-do-release
m4macros/Makefile
scripts/Makefile
scripts/xdt-autogen
xdt-csource/Makefile
ci/Makefile
docs/Makefile
tests/Makefile
tests/data/Makefile
])
AC_OUTPUT

dnl vi:set ts=2 sw=2 et ai:
