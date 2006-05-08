dnl $Id$
dnl
dnl Copyright (c) 2002-2006
dnl         The Xfce development team. All rights reserved.
dnl
dnl Written for Xfce by Benedikt Meurer <benny@xfce.org>.
dnl
dnl This program is free software; you can redistribute it and/or modify it
dnl under the terms of the GNU General Public License as published by the Free
dnl Software Foundation; either version 2 of the License, or (at your option)
dnl any later version.
dnl
dnl This program is distributed in the hope that it will be useful, but WITHOUT
dnl ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
dnl FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
dnl more details.
dnl
dnl You should have received a copy of the GNU General Public License along with
dnl this program; if not, write to the Free Software Foundation, Inc., 59 Temple
dnl Place, Suite 330, Boston, MA  02111-1307  USA
dnl
dnl xdt-depends
dnl -----------
dnl  Contains M4 macros to check for software dependencies.
dnl  Partly based on prior work of the XDG contributors.
dnl



dnl We need recent a autoconf version
AC_PREREQ([2.53])



dnl XDT_FEATURE_DEBUG()
dnl
AC_DEFUN([XDT_FEATURE_DEBUG],
[
  AC_ARG_ENABLE([debug],
AC_HELP_STRING([--enable-debug[=yes|no|full]], [Build with debugging support])
AC_HELP_STRING([--disable-debug], [Include no debugging support [default]]),
  [], [enable_debug=no])

  AC_MSG_CHECKING([whether to build with debugging support])
  if test x"$enable_debug" != x"no"; then
    AC_DEFINE([DEBUG], [1], [Define for debugging support])
    
    xdt_cv_additional_CFLAGS="-Wall"
    xdt_cv_additional_CFLAGS="$xdt_cv_additional_CFLAGS -DXFCE_DISABLE_DEPRECATED"
    
    if test x"$enable_debug" = x"full"; then
      AC_DEFINE([DEBUG_TRACE], [1], [Define for tracing support])
      xdt_cv_additional_CFLAGS="-g3 -Werror $xdt_cv_additional_CFLAGS"
      AC_MSG_RESULT([full])
    else
      xdt_cv_additional_CFLAGS="-g $xdt_cv_additional_CFLAGS"
      AC_MSG_RESULT([yes])
    fi

    CFLAGS="$CFLAGS $xdt_cv_additional_CFLAGS"
    CXXFLAGS="$CXXFLAGS $xdt_cv_additional_CFLAGS"
  else
    AC_MSG_RESULT([no])
  fi
])



dnl BM_DEBUG_SUPPORT()
dnl
AC_DEFUN([BM_DEBUG_SUPPORT],
[
dnl # --enable-debug
  AC_REQUIRE([XDT_FEATURE_DEBUG])

dnl # --enable-profiling
  AC_ARG_ENABLE([profiling],
AC_HELP_STRING([--enable-profiling],
    [Generate extra code to write profile information])
AC_HELP_STRING([--disable-profiling],
    [No extra code for profiling (default)]),
    [], [enable_profiling=no])

  AC_MSG_CHECKING([whether to build with profiling support])
  if test x"$enable_profiling" != x"no"; then
    CFLAGS="$CFLAGS -pg"
    LDFLAGS="$LDFLAGS -pg"
    AC_MSG_RESULT([yes])
  else
    AC_MSG_RESULT([no])
  fi

dnl # --enable-gcov
  AC_ARG_ENABLE([gcov],
AC_HELP_STRING([--enable-gcov],
    [compile with coverage profiling instrumentation (gcc only)])
AC_HELP_STRING([--disable-gcov],
    [do not generate coverage profiling instrumentation (default)]),
    [], [enable_gcov=no])

  AC_MSG_CHECKING([whether to compile with coverage profiling instrumentation])
  if test x"$enable_gcov" != x"no"; then
    CFLAGS="$CFLAGS -fprofile-arcs -ftest-coverage"
    AC_MSG_RESULT([yes])
  else
    AC_MSG_RESULT([no])
  fi

dnl # --disable-asserts
  AC_ARG_ENABLE([asserts],
AC_HELP_STRING([--disable-asserts], [Disable assertions [DANGEROUS]]),
    [], [enable_asserts=yes])

  AC_MSG_CHECKING([whether to disable assertions])
  if test x"$enable_asserts" = x"no"; then
    AC_MSG_RESULT([yes])
    CPPFLAGS="$CPPFLAGS -DG_DISABLE_CHECKS -DG_DISABLE_ASSERT"
    CPPFLAGS="$CPPFLAGS -DG_DISABLE_CAST_CHECKS"
  else
    AC_MSG_RESULT([no])
  fi

dnl # --enable-final
  AC_REQUIRE([AC_PROG_LD])
  AC_ARG_ENABLE([final],
AC_HELP_STRING([--enable-final], [Build final version]),
    [], [enable_final=yes])

  AC_MSG_CHECKING([whether to build final version])
  if test x"$enable_final" = x"yes"; then
    AC_MSG_RESULT([yes])
    AC_MSG_CHECKING([whether $LD accepts -O1])
    case `$LD -O1 -v 2>&1 </dev/null` in
    *GNU* | *'with BFD'*)
      LDFLAGS="$LDFLAGS -Wl,-O1"
      AC_MSG_RESULT([yes])
    	;;
    *)
      AC_MSG_RESULT([no])
    	;;
    esac
  else
    AC_MSG_RESULT([no])
  fi
])
