man_MANS = \
	xdt-csource.1

if MAINTAINER_MODE
%.1: %.xml
	xsltproc --nonet http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl $<
endif

EXTRA_DIST = \
	$(man_MANS) \
	xdt-csource.xml

# vi:set ts=8 sw=8 noet ai softtabstop=0 syntax=automake:
