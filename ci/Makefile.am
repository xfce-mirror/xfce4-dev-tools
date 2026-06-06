cppcheckdir = $(CPPCHECK_CFG_PREFIX)/cppcheck/cfg

cppcheck_DATA = \
	xfce.cfg

xfce.cfg: xfce.cfg.in
	$(SED) "/missing in gtk.cfg: added in $(CPPCHECK_VERSION)/,/<\/def>/{/<\/def>/!d}" < $< > $@

DISTCLEANFILES = \
	$(cppcheck_DATA)

EXTRA_DIST = \
	xfce.cfg.in
