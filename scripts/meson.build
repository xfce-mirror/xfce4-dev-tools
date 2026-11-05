configure_file(
  configuration: configuration_data({
    'VERSION': meson.project_version(),
    'VERSION_MAJOR': version_parts[0],
    'VERSION_MINOR': version_parts[1],
    'VERSION_MICRO': version_parts[2],
    'prefix': get_option('prefix'),
    'datarootdir': get_option('prefix') / get_option('datadir'),
    'datadir': get_option('prefix') / get_option('datadir'),
    'LINGUAS': '@LINGUAS@',
    'REVISION': '@REVISION@',
  }),
  input: 'xdt-autogen.in',
  output: 'xdt-autogen',
  install: true,
  install_dir: get_option('prefix') / get_option('bindir'),
  install_mode: 'rwxr-xr-x',
)

install_data(
  'xdt-check-abi',
  'xdt-gen-visibility',
  install_dir: get_option('prefix') / get_option('bindir'),
  install_mode: 'rwxr-xr-x',
)
