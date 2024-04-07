project(
  YOUR_PROJECT_NAME_HERE_QUOTED,
  'c',
  version: run_command(['./print-version'], capture: true, check: true).stdout().strip(),
  license: 'GPL-2',
  meson_version: '>= 1.0.0',
  default_options: [
    'c_std=gnu99',
    'buildtype=debugoptimized',
    'warning_level=2',
  ]
)

pkgdatadir = get_option('datadir') / meson.project_name()

pkgconfig = import('pkgconfig')
gnome = import('gnome')
i18n = import('i18n')

dependency_versions = {
  'glib': '>= 2.66.0',
  'gtk': '>= 3.24.0',
  'libx11': '>= 1.6.7',
  'xfce4': '>= 4.18.0',
}

glib = dependency('glib-2.0', version: dependency_versions['glib'])
gtk = dependency('gtk+-3.0', version: dependency_versions['gtk'])
libx11 = dependency('x11', version: dependency_versions['libx11'])
libxfce4util = dependency('libxfce4util-1.0', version: dependency_versions['xfce4'])
libxfce4ui = dependency('libxfce4ui-2', version: dependency_versions['xfce4'])
xfconf = dependency('libxfconf-0', version: dependency_versions['xfce4'])
libxfce4panel = dependency('libxfce4panel-2.0', version: dependency_versions['xfce4'])
garcon = dependency('garcon-1', version: dependency_versions['xfce4'])
garcon_gtk3 = dependency('garcon-gtk3-1', version: dependency_versions['xfce4'])
exo = dependency('exo-2', version: dependency_versions['xfce4'])

cc = meson.get_compiler('c')

extra_cflags = []
extra_cflags_check = [
  '-Wmissing-declarations',
  '-Wmissing-noreturn',
  '-Wold-style-definition',
  '-Wredundant-decls',
  '-Wpointer-arith',
  '-Winit-self',
  '-Wshadow',
  '-Wmissing-include-dirs',
  '-Wundef',
  '-Wformat',
  '-Wformat-security',
  '-Wformat-y2k',
  '-Wnested-externs',
  '-Wno-unused-parameter',
  '-Wno-declaration-after-statement',
  '-Werror=implicit-function-declaration',
]

buildtype = get_option('buildtype')
if buildtype == 'debug' or buildtype == 'debugoptimized'
  extra_cflags_check += '-fstack-protector-strong'
  extra_cflags += '-DDEBUG=1'

  if buildtype == 'debug'
    extra_cflags += [
      '-DG_ENABLE_DEBUG',
      '-DDEBUG_TRACE=1',
    ]
  endif
elif buildtype == 'release' or buildtype == 'minsize' or buildtype == 'plain'
  extra_cflags += '-DNDEBUG'

  if buildtype == 'minsize'
    extra_cflags += [
      '-DG_DISABLE_CAST_CHECKS',
      '-DG_DISABLE_ASSERT',
    ]
  endif
endif

if dependency_versions.has_key('glib')
  glib_version_parts = dependency_versions['glib'].split(' ')
  glib_min_version_parts = glib_version_parts[1].split('.')
  glib_min_version_define = 'GLIB_VERSION_@0@_@1@'.format(glib_min_version_parts[0], glib_min_version_parts[1])
  extra_cflags += [
    '-DGLIB_VERSION_MIN_REQUIRED=@0@'.format(glib_min_version_define),
    '-DGLIB_VERSION_MAX_ALLOWED=@0@'.format(glib_min_version_define),
  ]
endif

extra_cflags += [
  '-DPACKAGE="@0@"'.format(meson.project_name()),
  '-DPACKAGE_NAME="@0@"'.format(meson.project_name()),
  '-DVERSION="@0@"'.format(meson.project_version()),
  '-DPACKAGE_STRING="@0@ @1@"'.format(meson.project_name(), meson.project_version()),
  '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
  '-DDATADIR="@0@"'.format(get_option('prefix') / get_option('datadir')),
  '-DLOCALEDIR="@0@"'.format(get_option('prefix') / get_option('localedir')),
  '-DPACKAGE_DATADIR="@0@"'.format(get_option('prefix') / pkgdatadir),
  '-DPACKAGE_LOCALE_DIR="@0@"'.format(get_option('prefix') / get_option('localedir')),
]

git_rev = run_command('git', 'rev-parse', '--short', 'HEAD', capture: true, check: false).stdout().strip()
if git_rev == ''
  git_rev = 'UNKNOWN'
endif
extra_cflags += '-DREVISION="@0@"'.format(git_rev)

add_project_arguments(cc.get_supported_arguments(extra_cflags_check), language: 'c')
add_project_arguments(extra_cflags, language: 'c')
