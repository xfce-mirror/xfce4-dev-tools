dnl $Id$
dnl
dnl Copyright (c) 2002-2005
dnl         The Xfce development team. All rights reserved.
dnl
dnl Written for Xfce by Benedikt Meurer <benny@xfce.org>.
dnl
dnl xdt-i18n
dnl --------
dnl  Internalization M4 macros.
dnl


dnl XDT_I18N(LINGUAS [, PACKAGE])
dnl
dnl This macro takes care of setting up everything for i18n support.
dnl
dnl If PACKAGE isn't specified, it defaults to the package tarname; see
dnl the description of AC_INIT() for an explanation of what makes up
dnl the package tarname. Normally, you don't need to specify PACKAGE,
dnl but you can stick with the default.
dnl
AC_DEFUN([XDT_I18N],
[
  dnl Substitute GETTEXT_PACKAGE variable
  GETTEXT_PACKAGE=m4_default([$2], [AC_PACKAGE_TARNAME()])
  AC_DEFINE_UNQUOTED([GETTEXT_PACKAGE], ["$GETTEXT_PACKAGE"], [Name of default gettext domain])
  AC_SUBST([GETTEXT_PACKAGE])

  dnl gettext and stuff
  ALL_LINGUAS="$1"
  AM_GLIB_GNU_GETTEXT()

  dnl This is required on some Linux systems
  AC_CHECK_FUNC([bind_textdomain_codeset])

  dnl Determine where to install locale files
  AC_MSG_CHECKING([for locales directory])
  AC_ARG_WITH([locales-dir], 
  [
    AC_HELP_STRING([--with-locales-dir=DIR], [Install locales into DIR])
  ], [localedir=$withval],
  [
    if test x"$CATOBJEXT" = x".mo"; then
      localedir=$libdir/locale
    else
      localedir=$datadir/locale
    fi
  ])
  AC_MSG_RESULT([$localedir])
  AC_SUBST([localedir])

  dnl Determine additional xgettext flags
  AC_MSG_CHECKING([for additional xgettext flags])
  if test x"$XGETTEXT_ARGS" = x""; then
    XGETTEXT_ARGS="--keyword=O_";
  else
    XGETTEXT_ARGS="$XGETTEXT_ARGS --keyword=O_";
  fi
  AC_SUBST([XGETTEXT_ARGS])
  AC_MSG_RESULT([$XGETTEXT_ARGS])
])



dnl BM_I18N(PACKAGE, LINGUAS)
dnl
dnl Simple wrapper for XDT_I18N(LINGUAS, PACKAGE). Kept for
dnl backward compatibility. Will be removed in the
dnl future.
dnl
AC_DEFUN([BM_I18N],
[
  XDT_I18N([$2], [$1])
])

