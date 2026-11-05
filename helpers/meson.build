configure_file(
  configuration: configuration_data({
    'GSED': sed.full_path(),
    'GMAKE': make.full_path(),
    'MESON': meson_program.full_path(),
  }),
  input: 'xfce-do-release.in',
  output: 'xfce-do-release',
  install: true,
  install_dir: get_option('prefix') / get_option('bindir'),
  install_mode: 'rwxr-xr-x',
)

install_data(
  'xfce-build',
  'xfce-get-release-notes',
  'xfce-get-translations',
  'xfce-update-news',
  install_dir: get_option('prefix') / get_option('bindir'),
  install_mode: 'rwxr-xr-x',
)
