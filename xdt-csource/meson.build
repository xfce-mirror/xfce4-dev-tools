xdt_csource = executable(
  'xdt-csource',
  'main.c',
  sources: [
    xfce_revision_h,
  ],
  c_args: [
    '-DG_LOG_DOMAIN="@0@"'.format('xdt-csource'),
  ],
  include_directories: [
    include_directories('..'),
  ],
  dependencies: [
    glib,
  ],
  install: true,
  install_dir: get_option('prefix') / get_option('bindir'),
)
