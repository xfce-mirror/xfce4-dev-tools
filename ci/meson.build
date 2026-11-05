sed_script = '/missing in gtk.cfg: added in @0@/,/<\/def>/{/<\/def>/!d}'.format(cppcheck_version)
configure_file(
  input: 'xfce.cfg.in',
  output: 'xfce.cfg',
  command: [sed, sed_script, '@INPUT@'],
  capture: true,
  install: true,
  install_dir: cppcheck_cfg_prefix / 'cppcheck' / 'cfg',
)

