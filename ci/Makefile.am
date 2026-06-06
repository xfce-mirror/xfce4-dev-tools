cppcheckdir = $(CPPCHECK_CFG_PREFIX)/cppcheck/cfg

cppcheck_DATA = \
	xfce.cfg

xfce.cfg: xfce.cfg.in
	$(SED) "/missing in gtk.cfg: added in $(CPPCHECK_VERSION)/,/<\/def>/{/<\/def>/!d}" < $< > $@

EXTRA_DIST = \
	$(cppcheck_DATA)
