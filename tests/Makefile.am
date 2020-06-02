
SUBDIRS =								\
	data

AM_CPPFLAGS =								\
	-I$(top_srcdir)							\
	-DG_LOG_DOMAIN=\"xdt-tests\"

TESTS =									\
	test-xdt-csource						

check_PROGRAMS =							\
	test-xdt-csource						

test_xdt_csource_SOURCES =						\
	test-xdt-csource.c						\
	test-xdt-csource-data.c

test_xdt_csource_CFLAGS =						\
	$(GLIB_CFLAGS)

test_xdt_csource_LDADD =						\
	$(GLIB_LIBS)

DISTCLEANFILES = test-xdt-csource-data.c
BUILT_SOURCES = test-xdt-csource-data.c

test-xdt-csource-data.c: Makefile $(srcdir)/data/data.bin $(srcdir)/data/data.txt
	$(top_builddir)/xdt-csource/xdt-csource --extern --build-list data_bin $(srcdir)/data/data.bin data_txt $(srcdir)/data/data.txt > test-xdt-csource-data.c

clean-local:
	rm -f *.core core core.*

# vi:set ts=8 sw=8 noet ai nocindent syntax=automake:
