# Copyright (c) 2002-2015
#         The Xfce development team. All rights reserved.
#
# Written for Xfce by Benedikt Meurer <benny@xfce.org>.
#

ACLOCAL_AMFLAGS = -I m4 -I m4macros ${ACLOCAL_FLAGS}

SUBDIRS =     \
  docs        \
  helpers     \
  m4macros    \
  scripts     \
  xdt-csource \
  tests

distclean-local:
	rm -rf *.cache *~

.PHONY: ChangeLog

ChangeLog: Makefile
	(GIT_DIR=$(top_srcdir)/.git git log > .changelog.tmp \
	&& mv .changelog.tmp ChangeLog; rm -f .changelog.tmp) \
	|| (touch ChangeLog; echo 'Git directory not found: installing possibly empty changelog.' >&2)

dist-hook: ChangeLog

EXTRA_DIST =								\
	HACKING \
	README.md
