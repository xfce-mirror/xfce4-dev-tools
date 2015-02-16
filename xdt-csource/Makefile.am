# Copyright (c) 2002-2015
#         The Xfce development team. All rights reserved.
#

AM_CPPFLAGS = 								\
	-I$(top_srcdir)							\
	-DG_LOG_DOMAIN=\"xdt-csource\"

bin_PROGRAMS =								\
	xdt-csource

xdt_csource_SOURCES =							\
	main.c

xdt_csource_CFLAGS =							\
	$(GLIB_CFLAGS)

xdt_csource_LDFLAGS =							\
	-no-undefined

xdt_csource_LDADD =							\
	$(GLIB_LIBS)

# require to make dist in tests/
dist-hook: all

# vi:set ts=8 sw=8 noet ai nocindent syntax=automake:
