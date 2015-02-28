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
dnl xdt-xfce
dnl --------
dnl  Xfce specific M4 macros.
dnl



dnl XDT_XFCE_PANEL_PLUGIN(varname, [version = 4.9.0])
dnl
dnl This macro is intended to be used by panel plugin writers. It
dnl detects the xfce4-panel package on the target system and sets
dnl "varname"_CFLAGS, "varname"_LIBS, "varname"_REQUIRED_VERSION
dnl and "varname"_VERSION properly. The parameter "version"
dnl specifies the minimum required version of xfce4-panel (defaults
dnl to 4.9.0 if not given).
dnl
dnl In addition, this macro defines "varname"_PLUGINSDIR (and
dnl marks it for substitution), which points to the directory
dnl where the panel plugin should be installed to. You should
dnl use this variable in your Makefile.am.
dnl
AC_DEFUN([XDT_XFCE_PANEL_PLUGIN],
[
  dnl Check for the xfce4-panel package
  XDT_CHECK_PACKAGE([$1], [xfce4-panel-1.0], [m4_default([$2], [4.11.0])])

  dnl Check where to put the plugins to
  AC_MSG_CHECKING([where to install panel plugins])
  $1_PLUGINSDIR=$libdir/xfce4/panel-plugins
  AC_SUBST([$1_PLUGINSDIR])
  AC_MSG_RESULT([$$1_PLUGINSDIR])
])

dnl XFCE_PANEL_PLUGIN(varname, version)
dnl
dnl Simple wrapper for XDT_XFCE_PANEL_PLUGIN(varname, version). Kept
dnl for backward compatibility. Will be removed in the future.
dnl
AC_DEFUN([XFCE_PANEL_PLUGIN],
[
  XDT_XFCE_PANEL_PLUGIN([$1], [$2])
])
