dnl $Id$
dnl
dnl Copyright (c) 2002-2005
dnl         The Xfce development team. All rights reserved.
dnl
dnl Written for Xfce by Benedikt Meurer <benny@xfce.org>.
dnl
dnl xdt-xfce
dnl --------
dnl  Xfce specific M4 macros.
dnl


dnl This requires a recent version of autoconf
AC_PREREQ([2.53])



dnl XDT_LC_MESSAGES()
dnl
dnl Checks whether <locale.h> defines LC_MESSAGES on
dnl the target system. If both <locale.h> is present
dnl and it defines LC_MESSAGES, this macro sets
dnl HAVE_LC_MESSAGES to 1 in config.h.
dnl
AC_DEFUN([XDT_LC_MESSAGES],
[
  AC_CHECK_HEADERS([locale.h])
  if test x"$ac_cv_header_locale_h" = x"yes"; then
    AC_CACHE_CHECK([for LC_MESSAGES],
      [xdt_cv_val_LC_MESSAGES],
      [AC_TRY_LINK([#include <locale.h>],
        [return LC_MESSAGES],
        [xdt_cv_val_LC_MESSAGES=yes],
        [xdt_cv_val_LC_MESSAGES=no])])
    if test x"$xdt_cv_val_LC_MESSAGES" = x"yes"; then
      AC_DEFINE([HAVE_LC_MESSAGES], [1], [Define if your <locale.h> file defines LC_MESSAGES.])
    fi
  fi
])



dnl XDT_PATH_PROG_WITH_TEST(varname, progname, test, [value-if-not-found], [path])
dnl
AC_DEFUN([XDT_PATH_PROG_WITH_TEST],
[
  dnl Extract the first word of "$2", so it can be a program name with args.
  set dummy $2;
  ac_word=[$]2

  AC_MSG_CHECKING([for $ac_word])
  AC_CACHE_VAL([ac_cv_path_$1],
  [
    case "[$]$1" in
    /*)
      ac_cv_path_$1="[$]$1" # Let the user override the test with a path.
      ;;
      
    *)
      IFS="${IFS= 	}";
      ac_save_ifs="$IFS";
      IFS="${IFS}:"
      for ac_dir in ifelse([$5], , [$PATH], [$5]); do
        test -z "$ac_dir" && ac_dir=.
        if test -f $ac_dir/$ac_word; then
          if [$3]; then
            ac_cv_path_$1="$ac_dir/$ac_word"
            break
          fi
        fi
      done
      IFS="$ac_save_ifs"
      
      dnl If no 4th arg is given, leave the cache variable unset,
      dnl so AC_PATH_PROGS will keep looking.
      ifelse([$4], , , [  test -z "[$]ac_cv_path_$1" && ac_cv_path_$1="$4"])
      ;;
    esac
  ])
  
  $1="$ac_cv_path_$1"
  if test ifelse([$4], , [-n "[$]$1"], ["[$]$1" != "$4"]); then
    AC_MSG_RESULT([$]$1)
  else
    AC_MSG_RESULT([no])
  fi
  AC_SUBST([$1])
])



dnl XDT_WITH_NLS()
dnl
AC_DEFUN([XDT_WITH_NLS],
[
  dnl NLS is obligatory
  USE_NLS=yes
  AC_SUBST([USE_NLS])

  xdt_cv_have_gettext=no

  CATOBJEXT=NONE
  XGETTEXT=:
  INTLLIBS=

  AC_CHECK_HEADER([libintl.h],
  [
    xdt_cv_func_dgettext_libintl="no"
    xdt_cv_libintl_extra_libs=""

    dnl First check in libc
    AC_CACHE_CHECK([for dgettext in libc], [xdt_cv_func_dgettext_libc],
    [
      AC_TRY_LINK([#include <libintl.h>],
        [return (int) dgettext ("","")],
        [xdt_cv_func_dgettext_libc=yes],
        [xdt_cv_func_dgettext_libc=no])
    ])
  
    if test x"$xdt_cv_func_dgettext_libc" = x"yes" ; then
      AC_CHECK_FUNCS([bind_textdomain_codeset])
    fi

    dnl If we don't have everything we want, check in libintl
    if test x"$xdt_cv_func_dgettext_libc" != x"yes" \
        || test x"$ac_cv_func_bind_textdomain_codeset" != x"yes" ; then 
      AC_CHECK_LIB([intl], [bindtextdomain],
      [
        AC_CHECK_LIB([intl], [dgettext], [xdt_cv_func_dgettext_libintl=yes])
      ])
      
      if test x"$xdt_cv_func_dgettext_libintl" != x"yes" ; then
        AC_MSG_CHECKING([if -liconv is needed to use gettext])
        AC_MSG_RESULT([])
        AC_CHECK_LIB([intl], [dcgettext],
        [
          xdt_cv_func_dgettext_libintl=yes
    			xdt_cv_libintl_extra_libs=-liconv
        ], [:],[-liconv])
      fi

      dnl If we found libintl, then check in it for bind_textdomain_codeset();
      dnl we'll prefer libc if neither have bind_textdomain_codeset(),
      dnl and both have dgettext
      if test x"$xdt_cv_func_dgettext_libintl" = x"yes" ; then
        xdt_save_LIBS="$LIBS"
        LIBS="$LIBS -lintl $xdt_cv_libintl_extra_libs"
        unset ac_cv_func_bind_textdomain_codeset
        AC_CHECK_FUNCS([bind_textdomain_codeset])
        LIBS="$xdt_save_LIBS" 
        
        if test x"$ac_cv_func_bind_textdomain_codeset" = x"yes"; then
          xdt_cv_func_dgettext_libc=no
        else
          if test x"$xdt_cv_func_dgettext_libc" = x"yes"; then
            xdt_cv_func_dgettext_libintl=no
          fi
        fi
      fi
    fi

    if test x"$xdt_cv_func_dgettext_libc" = x"yes" \
        || test x"$xdt_cv_func_dgettext_libintl" = x"yes"; then
      xdt_cv_have_gettext=yes
    fi
  
    if test x"$xdt_cv_func_dgettext_libintl" = x"yes"; then
      INTLLIBS="-lintl $xdt_cv_libintl_extra_libs"
    fi
    
    if test x"$xdt_cv_have_gettext" = x"yes"; then
      AC_DEFINE([HAVE_GETTEXT], [1], [Define if the GNU gettext() function is already present or preinstalled.])
      XDT_PATH_PROG_WITH_TEST([MSGFMT], [msgfmt],[test -z "`$ac_dir/$ac_word -h 2>&1 | grep 'dv '`"], [no])
      if test x"$MSGFMT" != x"no"; then
        xdt_save_LIBS="$LIBS"
        LIBS="$LIBS $INTLLIBS"
        AC_CHECK_FUNCS([dcgettext])
        AC_PATH_PROG([GMSGFMT], [gmsgfmt], [$MSGFMT])
        XDT_PATH_PROG_WITH_TEST([XGETTEXT], [xgettext], [test -z "`$ac_dir/$ac_word -h 2>&1 | grep '(HELP)'`"], [:])
        AC_TRY_LINK([], [extern int _nl_msg_cat_cntr; return _nl_msg_cat_cntr],
        [
          CATOBJEXT=.gmo 
          DATADIRNAME=share
        ],
        [
          case $host in
          *-*-solaris*)
        	  dnl On Solaris, if bind_textdomain_codeset is in libc,
        	  dnl GNU format message catalog is always supported,
            dnl since both are added to the libc all together.
        	  dnl Hence, we'd like to go with DATADIRNAME=share and
        	  dnl and CATOBJEXT=.gmo in this case.
            AC_CHECK_FUNC([bind_textdomain_codeset],
            [
              CATOBJEXT=.gmo
              DATADIRNAME=share
            ],
            [
              CATOBJEXT=.mo
              DATADIRNAME=lib
            ])
            ;;
            
          *)
            CATOBJEXT=.mo
            DATADIRNAME=lib
	          ;;
	        esac
        ])
        LIBS="$xdt_save_LIBS"
        INSTOBJEXT=.mo
      else
        xdt_cv_have_gettext=no
      fi
    fi
  ])

  if test x"$xdt_cv_have_gettext" = x"yes"; then
    AC_DEFINE([ENABLE_NLS], [1], [always defined to indicate that i18n is enabled])
  fi

  dnl Test whether we really found GNU xgettext.
  if test x"$XGETTEXT" != x":"; then
    dnl If it is not GNU xgettext we define it as : so that the
    dnl Makefiles still can work.
    if $XGETTEXT --omit-header /dev/null 2>/dev/null; then
      : ;
    else
      AC_MSG_RESULT([found xgettext program is not GNU xgettext; ignore it])
      XGETTEXT=":"
    fi
  fi

  dnl We need to process the po/ directory.
  POSUB=po

  AC_OUTPUT_COMMANDS(
  [
    case "$CONFIG_FILES" in
    *po/Makefile.in*)
      sed -e "/POTFILES =/r po/POTFILES" po/Makefile.in > po/Makefile
    esac
  ])

  dnl These rules are solely for the distribution goal.  While doing this
  dnl we only have to keep exactly one list of the available catalogs
  dnl in configure.in.
  for lang in $ALL_LINGUAS; do
    GMOFILES="$GMOFILES $lang.gmo"
    POFILES="$POFILES $lang.po"
  done

  dnl Make all variables we use known to autoconf.
  AC_SUBST([CATALOGS])
  AC_SUBST([CATOBJEXT])
  AC_SUBST([DATADIRNAME])
  AC_SUBST([GMOFILES])
  AC_SUBST([INSTOBJEXT])
  AC_SUBST([INTLLIBS])
  AC_SUBST([PO_IN_DATADIR_TRUE])
  AC_SUBST([PO_IN_DATADIR_FALSE])
  AC_SUBST([POFILES])
  AC_SUBST([POSUB])
])



dnl XDT_GNU_GETTEXT([linguas])
dnl
AC_DEFUN([XDT_GNU_GETTEXT],
[
  AC_REQUIRE([AC_PROG_CC])
  AC_REQUIRE([AC_HEADER_STDC])
  AC_REQUIRE([XDT_LC_MESSAGES])
  AC_REQUIRE([XDT_WITH_NLS])

  if test x"$xdt_cv_have_gettext" = x"yes"; then
    ifelse([$1], ,
    [
      LINGUAS=
    ],
    [
      AC_MSG_CHECKING([for catalogs to be installed])
      NEW_LINGUAS=
      for presentlang in $1; do
        useit=no
        if test x"%UNSET%" != x"${LINGUAS-%UNSET%}"; then
          desiredlanguages="$LINGUAS"
        else
          desiredlanguages="$1"
        fi
        
        for desiredlang in $desiredlanguages; do
          dnl Use the presentlang catalog if desiredlang is
          dnl   a. equal to presentlang, or
          dnl   b. a variant of presentlang (because in this case,
          dnl     presentlang can be used as a fallback for messages
          dnl     which are not translated in the desiredlang catalog).
          case "$desiredlang" in
          "$presentlang"*)
            useit=yes;;
          esac
        done
        
        if test x"$useit" = x"yes"; then
          NEW_LINGUAS="$NEW_LINGUAS $presentlang"
        fi
      done
      
      LINGUAS=$NEW_LINGUAS
      AC_MSG_RESULT([$LINGUAS])
     fi 
     
     dnl Construct list of names of catalog files to be constructed.
     if test x"$LINGUAS" != x""; then
      for lang in $LINGUAS; do
        CATALOGS="$CATALOGS $lang$CATOBJEXT";
      done
    ])
  fi

  dnl If the AC_CONFIG_AUX_DIR macro for autoconf is used we possibly
  dnl find the mkinstalldirs script in another subdir but ($top_srcdir).
  dnl Try to locate is.
  MKINSTALLDIRS=
  if test -n "$ac_aux_dir"; then
    MKINSTALLDIRS="$ac_aux_dir/mkinstalldirs"
  fi
  if test -z "$MKINSTALLDIRS"; then
    MKINSTALLDIRS="\$(top_srcdir)/mkinstalldirs"
  fi
  AC_SUBST([MKINSTALLDIRS])

  dnl Generate list of files to be processed by xgettext which will
  dnl be included in po/Makefile.
  test -d po || mkdir po
  if test "x$srcdir" != "x."; then
    if test "x`echo $srcdir | sed 's@/.*@@'`" = "x"; then
      posrcprefix="$srcdir/"
    else
      posrcprefix="../$srcdir/"
    fi
  else
    posrcprefix="../"
  fi
  rm -f po/POTFILES
  sed \
    -e "/^#/d" -e "/^\$/d" \
    -e "s,.*,	$posrcprefix& \\\\," \
    -e "\$s/\(.*\) \\\\/\1/" \
    < $srcdir/po/POTFILES.in > po/POTFILES
])



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
  AC_DEFINE([GETTEXT_PACKAGE], ["$GETTEXT_PACKAGE"], [Name of default gettext domain])
  AC_SUBST([GETTEXT_PACKAGE])

  dnl gettext and stuff
  XDT_GNU_GETTEXT([$1])

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
  AC_MSG_RESULT([$localdir])
  AC_SUBST([localdir])
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

