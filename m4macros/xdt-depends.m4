dnl Copyright (c) 2002-2015
dnl         The Xfce development team. All rights reserved.
dnl
dnl Written for Xfce by Benedikt Meurer <benny@xfce.org>.
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
dnl xdt-depends
dnl -----------
dnl  Contains M4 macros to check for software dependencies.
dnl  Partly based on prior work of the XDG contributors.
dnl



dnl We need recent a autoconf version
AC_PREREQ([2.69])



dnl XDT_PROG_PKG_CONFIG()
dnl
dnl Checks for the freedesktop.org pkg-config
dnl utility and sets the PKG_CONFIG environment
dnl variable to the full path if found.
dnl
AC_DEFUN([XDT_PROG_PKG_CONFIG],
[
  # minimum supported version of pkg-config
  xdt_cv_PKG_CONFIG_MIN_VERSION=0.9.0

  m4_ifdef([PKG_PROG_PKG_CONFIG],
    [
      PKG_PROG_PKG_CONFIG([$xdt_cv_PKG_CONFIG_MIN_VERSION])

      if test x"$PKG_CONFIG" = x""; then
        echo
        echo "*** Your version of pkg-config is too old. You need atleast"
        echo "*** pkg-config $xdt_cv_PKG_CONFIG_MIN_VERSION or newer. You can download pkg-config"
        echo "*** from the freedesktop.org software repository at"
        echo "***"
        echo "***    https://www.freedesktop.org/wiki/Software/pkg-config/"
        echo "***"
        exit 1;
      fi
    ],
    [
      echo
      echo "*** The pkg-config utility could not be found on your system."
      echo "*** Make sure it is in your path, or set the PKG_CONFIG"
      echo "*** environment variable to the full path to pkg-config."
      echo "*** You can download pkg-config from the freedesktop.org"
      echo "*** software repository at"
      echo "***"
      echo "***    https://www.freedesktop.org/wiki/Software/pkg-config/"
      echo "***"
      exit 1
    ])
])



dnl XDT_CHECK_PACKAGE(varname, package, version, [action-if], [action-if-not])
dnl
dnl Checks if "package" >= "version" is installed on the
dnl target system, using the pkg-config utility. If the
dnl dependency is met, "varname"_CFLAGS, "varname"_LIBS,
dnl "varname"_VERSION and "varname"_REQUIRED_VERSION
dnl will be set and marked for substition.
dnl
dnl "varname"_REQUIRED_VERSION will be set to the value of
dnl "version". This is mostly useful to automatically
dnl place the correct version information into the RPM
dnl .spec file.
dnl
dnl In addition, if the dependency is met, "action-if" will
dnl be executed if given.
dnl
dnl If the package check fails, "action-if-not" will be
dnl executed. If this parameter isn't specified, a diagnostic
dnl message will be printed and the configure script will
dnl be terminated with exit code 1.
dnl
AC_DEFUN([XDT_CHECK_PACKAGE],
[
  XDT_PROG_PKG_CONFIG()

  AC_MSG_CHECKING([for $2 >= $3])
  if $PKG_CONFIG "--atleast-version=$3" "$2" >/dev/null 2>&1; then
    $1_VERSION=`$PKG_CONFIG --modversion "$2"`
    AC_MSG_RESULT([$$1_VERSION])

    AC_MSG_CHECKING([$1_CFLAGS])
    $1_CFLAGS=`$PKG_CONFIG --cflags "$2"`
    AC_MSG_RESULT([$$1_CFLAGS])

    AC_MSG_CHECKING([$1_LIBS])
    $1_LIBS=`$PKG_CONFIG --libs "$2"`
    AC_MSG_RESULT([$$1_LIBS])

    $1_REQUIRED_VERSION=$3

    AC_SUBST([$1_VERSION])
    AC_SUBST([$1_CFLAGS])
    AC_SUBST([$1_LIBS])
    AC_SUBST([$1_REQUIRED_VERSION])

    if test x"$1" = x"GLIB"; then
      dnl Use GLib structured logging, see https://docs.gtk.org/glib/logging.html
      dnl XFCE apps&libraries can override this setting after XDT_CHECK_PACKAGE(GLIB)
      dnl using AC_DEFINE.
      dnl Note that it requires GLIB_VERSION_MAX_ALLOWED >= GLIB_VERSION_2_56 to work
      dnl properly in GLib logging macros (not documented, see glib/gmessages.h).
      AC_DEFINE(G_LOG_USE_STRUCTURED, 1, [Use GLib structured logging])
    fi

    ifelse([$1], GLIB, [
      dnl Report uses of GLib functions newer than $3 as C compiler warnings.
      dnl XFCE apps&libraries can override this setting after XDT_CHECK_PACKAGE(GLIB)
      dnl using AC_DEFINE, in which case it is recommended to override both MAX and MIN.
      AC_MSG_NOTICE([setting GLIB_VERSION_MAX_ALLOWED and GLIB_VERSION_MIN_REQUIRED according to $3])
      m4_pushdef([SUFFIX], translit($3, `.', `_'))
      m4_define([SUFFIX], ifelse(regexp(SUFFIX, [[0-9]+_[0-9]+_[0-9]+]), -1, SUFFIX, patsubst(SUFFIX, [_[0-9]+$])))
      AC_DEFINE(GLIB_VERSION_MAX_ALLOWED, m4_format(GLIB_VERSION_%s, SUFFIX), m4_format(Prevent post %s APIs, SUFFIX))
      AC_DEFINE(GLIB_VERSION_MIN_REQUIRED, m4_format(GLIB_VERSION_%s, SUFFIX), m4_format(Ignore post %s APIs, SUFFIX))
      m4_popdef([SUFFIX])
    ])

    ifelse([$4], , , [$4])
  elif $PKG_CONFIG --exists "$2" >/dev/null 2>&1; then
    xdt_cv_version=`$PKG_CONFIG --modversion "$2"`
    AC_MSG_RESULT([found, but $xdt_cv_version])

    ifelse([$5], ,
    [
      echo "*** The required package $2 was found on your system,"
      echo "*** but the installed version ($xdt_cv_version) is too old."
      echo "*** Please upgrade $2 to atleast version $3, or adjust"
      echo "*** the PKG_CONFIG_PATH environment variable if you installed"
      echo "*** the new version of the package in a nonstandard prefix so"
      echo "*** pkg-config is able to find it."
      exit 1
    ], [$5])
  else
    AC_MSG_RESULT([not found])

    ifelse([$5], ,
    [
      echo "*** The required package $2 was not found on your system."
      echo "*** Please install $2 (atleast version $3) or adjust"
      echo "*** the PKG_CONFIG_PATH environment variable if you"
      echo "*** installed the package in a nonstandard prefix so that"
      echo "*** pkg-config is able to find it."
      exit 1
    ], [$5])
  fi
])



dnl XDT_CHECK_OPTIONAL_PACKAGE(varname, package, version, optionname, helpstring, [default])
dnl
dnl Checks for an optional dependency on "package" >= "version". "default"
dnl can be "yes" or "no" (defaults to "yes" if not specified) and controls
dnl whether configure should check this dependency by default, or only if
dnl the user explicitly enables it using a command line switch.
dnl
dnl This macro automatically adds a commandline switch based on the "optionname"
dnl parameter (--enable-optionname/--disable-optionname), which allows the
dnl user to explicitly control whether this optional dependency should be
dnl enabled or not. The "helpstring" parameter gives a brief(!) description
dnl about this dependency.
dnl
dnl If the user chose to enable this dependency and the required package
dnl was found, this macro defines the variable "varname"_FOUND and sets it
dnl to the string "yes", in addition to the 4 variables set by XDT_CHECK_PACKAGE.
dnl But "varname"_FOUND will not be marked for substition. Furthermore,
dnl a CPP define HAVE_"varname" will be placed in config.h (or added to
dnl the cc command line, depending on your configure.ac) and set to
dnl 1.
dnl
AC_DEFUN([XDT_CHECK_OPTIONAL_PACKAGE],
[
  AC_REQUIRE([XDT_PROG_PKG_CONFIG])

  AC_ARG_ENABLE([$4],
AS_HELP_STRING([--enable-$4],[Enable checking for $5 (default=m4_default([$6], [yes]))])
AS_HELP_STRING([--disable-$4],[Disable checking for $5]),
    [xdt_cv_$1_check=$enableval], [xdt_cv_$1_check=m4_default([$6], [yes])])

  if test x"$xdt_cv_$1_check" = x"yes"; then
    if $PKG_CONFIG --exists "$2 >= $3" >/dev/null 2>&1; then
      XDT_CHECK_PACKAGE([$1], [$2], [$3],
      [
        AC_DEFINE([HAVE_$1], [1], [Define if $2 >= $3 present])
        $1_FOUND="yes"
      ])
    else
      AC_MSG_CHECKING([for optional package $2 >= $3])
      AC_MSG_RESULT([not found])
    fi
  else
    AC_MSG_CHECKING([for optional package $2])
    AC_MSG_RESULT([disabled])
  fi

  AM_CONDITIONAL([HAVE_$1], [test x"$$1_FOUND" = x"yes"])
])



dnl XDT_FEATURE_DEPENDENCY(varname, package, version)
dnl
dnl Used only as an argument to XDT_CHECK_OPTIONAL_FEATURE(), this macro
dnl declares a dependency required for the feature to be enabled.
dnl
dnl If the dependency is checked and found, variables and substitutions will be
dnl created and set as in XDT_CHECK_PACKAGE(), plus varname_FOUND will be set
dnl to "yes", and HAVE_varname will be set in config.h.
dnl
dnl Note that, unlike with XDT_CHECK_OPTIONAL_PACKAGE(), no automake
dnl conditional is set for this dependency.
dnl
dnl See XDT_CHECK_OPTIONAL_FEATURE() for more information.
dnl
AC_DEFUN([XDT_FEATURE_DEPENDENCY],
[
  AC_REQUIRE([XDT_PROG_PKG_CONFIG])

  if test x"$xdt_feature_deps_check_only" = x"yes"; then
    if ! $PKG_CONFIG --exists "$2 >= $3" >/dev/null 2>&1; then
      if test x"$xdt_feature_deps_missing" = x""; then
        xdt_feature_deps_missing="$2 >= $3"
      else
        xdt_feature_deps_missing="$xdt_feature_deps_missing, $2 >= $3"
      fi
    fi
  else
    XDT_CHECK_PACKAGE([$1], [$2], [$3],
    [
      AC_DEFINE([HAVE_$1], [1], [Define if $2 >= $3 present])
      $1_FOUND="yes"
    ])
  fi
])



dnl XDT_CHECK_OPTIONAL_FEATURE(varname, optionname, dependency-checks, [helpstring], [default])
dnl
dnl Introduces an --enable-optionname/--disable-optionname flag pair for a
dnl named feature. If neither flag is provided, the feature will be enabled or
dnl disabled depending on whether or not dependency-checks succeed or fail.
dnl If --enable-optionname is provided, the configure script will error out if
dnl the dependencies are not met.  If --disable-optionname is provided, the
dnl feature will be disabled, and dependencies will not be checked.
dnl
dnl The dependency-checks argument should be a series of
dnl XDT_FEATURE_DEPENDENCY() macro calls, passed as a single quoted argument to
dnl XDT_CHECK_OPTIONAL_FEATURE().
dnl
dnl If helpstring is not provided, optionname is used instead.
dnl
dnl The default is "auto", and semantics are as described above. If default is
dnl set to "yes", then the feature will be required unless --disable-optionname
dnl is passed to configure.  If default is set to "no", the feature will not be
dnl built unless --enable-optionname is passed.
dnl
dnl If the feature is enabled and dependencies are met, ENABLE_varname will be
dnl defined in config.h. Additionally, an automake conditional called
dnl ENABLE_varname will be created, and a shell variable called ENABLE_varname
dnl will set to "yes" or "no".
dnl
dnl Example usage:
dnl
dnl XDT_CHECK_OPTIONAL_FEATURE([WAYLAND],
dnl                            [wayland],
dnl                            [
dnl                              XDT_FEATURE_DEPENDENCY([GDK_WAYLAND], [gdk-wayland-3.0], [3.24.0])
dnl                              XDT_FEATURE_DEPENDENCY([GTK_LAYER_SHELL], [gtk-layer-shell-0], [0.7.0])
dnl                            ],
dnl                            [the Wayland windowing system])
dnl
dnl Note that there are no commas between the XDT_FEATURE_DEPENDENCY()
dnl invocations; they should all form a single "argument" to
dnl XDT_CHECK_OPTIONAL_FEATURE().
dnl
dnl Also note that you must quote the dependency-checks argument with square
dnl brackets, or you will get syntax errors in the generated configure script.
dnl
AC_DEFUN([XDT_CHECK_OPTIONAL_FEATURE],
[
  AC_ARG_ENABLE([$2],
AS_HELP_STRING([--enable-$2], [Enable support for m4_default($4, $2) (default=m4_default([$5], [auto]))])
AS_HELP_STRING([--disable-$2], [Disable support for m4_default($4, $2)]),
    [xdt_cv_$1_enabled=$enableval], [xdt_cv_$1_enabled=m4_default([$5], [auto])])

  if test x"$xdt_cv_$1_enabled" != x"no"; then
    xdt_feature_deps_check_only=yes
    xdt_feature_deps_missing=
    $3
    if test x"$xdt_feature_deps_missing" = x""; then
      xdt_feature_deps_check_only=
      $3
      ENABLE_$1="yes"
      AC_DEFINE([ENABLE_$1], [1], [Define if m4_default($4, $2) is enabled])
      AC_MSG_CHECKING([if m4_default($4, $2) is enabled])
      AC_MSG_RESULT([yes])
    else
      AC_MSG_CHECKING([if m4_default($4, $2) is enabled])
      AC_MSG_RESULT([dependencies missing: $xdt_feature_deps_missing])
      if test x"$xdt_cv_$1_enabled" = x"yes"; then
        AC_MSG_ERROR([support for m4_default($4, $2) was required, but dependencies were not met])
      else
        ENABLE_$1="no"
      fi
    fi
    xdt_feature_deps_check_only=
    xdt_feature_deps_missing=
  else
    ENABLE_$1="no"
    AC_MSG_CHECKING([if m4_default($4, $2) is enabled])
    AC_MSG_RESULT([disabled])
  fi

  AM_CONDITIONAL([ENABLE_$1], [test x"$ENABLE_$1" = x"yes"])
])



dnl XDT_CHECK_PACKAGE_BINARY(varname, package, pkgvarname, [binname])
dnl
dnl Finds a program by looking for a variable named pkgvarname in the
dnl pkg-config file for package. If found, varname (both a shell variable and
dnl automake substitution) is set to the name of the binary (and possibly full
dnl path, if that is how it is specified in the pkg-config file). If not found,
dnl or not present and executable, configure will exit with an error.
dnl
dnl Users can also override this detection by specfying a varname on the
dnl configure command line. In that case, the provided value is still checked
dnl to ensure it exists and is executable.
dnl
dnl If binname is not provided (for documentation purposes), pkgvarname will be
dnl used instead.
dnl
dnl Example usage:
dnl
dnl XDT_CHECK_PACKAGE_BINARY([GLIB_GENMARSHAL], [glib-2.0], [glib_genmarshal], [glib-genmarshal])
dnl
AC_DEFUN([XDT_CHECK_PACKAGE_BINARY],
[
  AC_REQUIRE([XDT_PROG_PKG_CONFIG])

  AC_ARG_VAR([$1], [Location of program ]m4_default($4, $3))
  AC_MSG_CHECKING([for m4_default($4, $3)])

  if test x"$$1" = x""; then
    $1=`$PKG_CONFIG --variable=$3 $2`
  fi
  if test x"$$1" != x"" -a -x "$$1"; then
    AC_MSG_RESULT([$$1])
  else
    AC_MSG_ERROR([could not find m4_default($4, $3). You can run:
./configure $1=/path/to/m4_default($4, $3)
to provide a custom location for it.])
  fi
])



dnl XDT_CHECK_LIBX11()
dnl
dnl Executes various checks for X11. Sets LIBX11_CFLAGS, LIBX11_LDFLAGS
dnl and LIBX11_LIBS (and marks them for substitution). In addition
dnl HAVE_LIBX11 is set to 1 in config.h, if the X window system and
dnl the development files are detected on the target system.
dnl
AC_DEFUN([XDT_CHECK_LIBX11],
[
  AC_REQUIRE([AC_PATH_XTRA])

  LIBX11_CFLAGS= LIBX11_LDFLAGS= LIBX11_LIBS=
  if test x"$no_x" != x"yes"; then
    AC_CHECK_LIB([X11], [main],
    [
      AC_DEFINE([HAVE_LIBX11], [1], [Define if libX11 is available])
      LIBX11_CFLAGS="$X_CFLAGS"
      for option in $X_PRE_LIBS $X_EXTRA_LIBS $X_LIBS; do
      	case "$option" in
        -L*)
          path=`echo $option | sed 's/^-L//'`
          if test x"$path" != x""; then
            LIBX11_LDFLAGS="$LIBX11_LDFLAGS -L$path"
          fi
          ;;
        *)
          LIBX11_LIBS="$LIBX11_LIBS $option"
          ;;
        esac
      done
      if ! echo $LIBX11_LIBS | grep -- '-lX11' >/dev/null; then
        LIBX11_LIBS="$LIBX11_LIBS -lX11"
      fi
    ], [], [$X_CFLAGS $X_PRE_LIBS $X_EXTRA_LIBS $X_LIBS])
  fi
  AC_SUBST([LIBX11_CFLAGS])
  AC_SUBST([LIBX11_LDFLAGS])
  AC_SUBST([LIBX11_LIBS])
])



dnl XDT_CHECK_LIBX11_REQUIRE()
dnl
dnl Similar to XDT_CHECK_LIBX11(), but terminates with an error if
dnl the X window system and development files aren't detected on the
dnl target system.
dnl
AC_DEFUN([XDT_CHECK_LIBX11_REQUIRE],
[
  AC_REQUIRE([XDT_CHECK_LIBX11])
  
  if test x"$no_x" = x"yes"; then
    AC_MSG_ERROR([X Window system libraries and header files are required])
  fi
])



dnl XDT_CHECK_LIBSM()
dnl
dnl Checks whether the session management library is present on the
dnl target system, and sets LIBSM_CFLAGS, LIBSM_LDFLAGS and LIBSM_LIBS
dnl properly. In addition, HAVE_LIBSM will be set to 1 in config.h
dnl if libSM is detected.
dnl
AC_DEFUN([XDT_CHECK_LIBSM],
[
  AC_REQUIRE([XDT_CHECK_LIBX11])

  LIBSM_CFLAGS= LIBSM_LDFLAGS= LIBSM_LIBS=
  if test x"$no_x" != x"yes"; then
    AC_CHECK_LIB([SM], [SmcSaveYourselfDone],
    [
      AC_DEFINE([HAVE_LIBSM], [1], [Define if libSM is available])
      LIBSM_CFLAGS="$LIBX11_CFLAGS"
      LIBSM_LDFLAGS="$LIBX11_LDFLAGS"
      LIBSM_LIBS="$LIBX11_LIBS"
      if ! echo $LIBSM_LIBS | grep -- '-lSM' >/dev/null; then
        LIBSM_LIBS="$LIBSM_LIBS -lSM -lICE"
      fi
    ], [], [$LIBX11_CFLAGS $LIBX11_LDFLAGS $LIBX11_LIBS -lICE])
  fi
  AC_SUBST([LIBSM_CFLAGS])
  AC_SUBST([LIBSM_LDFLAGS])
  AC_SUBST([LIBSM_LIBS])
])



dnl XDT_CHECK_LIBXPM()
dnl
dnl Checks if the Xpm library is present on the target system, and
dnl sets LIBXPM_CFLAGS, LIBXPM_LDFLAGS and LIBXPM_LIBS. In addition,
dnl HAVE_LIBXPM will be set to 1 in config.h if libXpm is detected.
dnl
AC_DEFUN([XDT_CHECK_LIBXPM],
[
  AC_REQUIRE([XDT_CHECK_LIBX11])

  LIBXPM_CFLAGS= LIBXPM_LDFLAGS= LIBXPM_LIBS=
  if test "$no_x" != "yes"; then
    AC_CHECK_LIB([Xpm], [main],
    [
      AC_DEFINE([HAVE_LIBXPM], [1], [Define if libXpm is available])
      LIBXPM_CFLAGS="$LIBX11_CFLAGS"
      LIBXPM_LDFLAGS="$LIBX11_LDFLAGS"
      LIBXPM_LIBS="$LIBX11_LIBS"
      if ! echo $LIBXPM_LIBS | grep -- '-lXpm' >/dev/null; then
        LIBXPM_LIBS="$LIBXPM_LIBS -lXpm"
      fi
    ], [], [$LIBX11_CFLAGS $LIBX11_LDFLAGS $LIBX11_LIBS -lXpm])
  fi
  AC_SUBST([LIBXPM_CFLAGS])
  AC_SUBST([LIBXPM_LDFLAGS])
  AC_SUBST([LIBXPM_LIBS])
])



dnl XDT_CHECK_LIBXPM_REQUIRE()
dnl
dnl Similar to XDT_CHECK_LIBXPM(), but fails if the Xpm library isn't
dnl present on the target system.
dnl
AC_DEFUN([XDT_CHECK_LIBXPM_REQUIRE],
[
  AC_REQUIRE([XDT_CHECK_LIBX11_REQUIRE])
  AC_REQUIRE([XDT_CHECK_LIBXPM])

  if test x"$LIBXPM_LIBS" = x""; then
    AC_MSG_ERROR([The Xpm library was not found on your system])
  fi
])

