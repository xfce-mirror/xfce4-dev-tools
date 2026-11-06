project(
  'xfce4-dev-tools',
  'c',
version : '4.21.2-dev',
  license : 'GPL-2.0-or-later',
  meson_version : '>= 0.57.0',
  default_options : ['c_std=gnu11', 'buildtype=debugoptimized', 'warning_level=2']
)

project_namespace = 'xfce'
pkgdatadir = get_option('prefix') / get_option('datadir') / meson.project_name()
copyright_year = '2026'

cc = meson.get_compiler('c')
fs = import('fs')

dependency_versions = {
  'glib': '>= 2.80.0',
}

glib = dependency('glib-2.0', version: dependency_versions['glib'])

xsltproc = find_program('xsltproc', required: true)
meson_program = find_program('meson', required: true)
if host_machine.system() == 'freebsd'
  sed = find_program('gsed', required: true)
  make = find_program('gmake', required: true)
else
  sed = find_program('sed', required: true)
  make = find_program('make', required: true)
endif

cppcheck_cfg_prefix = get_option('cppcheck-cfg-prefix')
if cppcheck_cfg_prefix == ''
  cppcheck_cfg_prefix = get_option('prefix') / get_option('libdir')
endif

# parts of "$CPPCHECK_CFG_PREFIX/cppcheck/cfg/gtk.cfg" were added only after version 2.19, which is the
# version we use in CI, so don't add them for users if they use cppcheck >= 2.20, as it would conflict
cppcheck_version = '0'
gtk_cfg = cppcheck_cfg_prefix / 'cppcheck' / 'cfg' / 'gtk.cfg'
if fs.exists(gtk_cfg)
  contents = fs.read(gtk_cfg)
  # https://github.com/cppcheck-opensource/cppcheck/commit/8df3087f48aa70a2e0e54ec05324f7147ec3e0b6
  if contents.contains('<define name="G_DEFINE_ENUM_TYPE')
    cppcheck_version = '2.22.1'
  # https://github.com/cppcheck-opensource/cppcheck/commit/40f6f6ad90c987ca6ffcd72881128acab9ed8997
  elif contents.contains('<define name="G_FILE_ATTRIBUTE_STANDARD_TYPE')
    cppcheck_version = '2.21.0'
  # https://github.com/cppcheck-opensource/cppcheck/commit/8c762adcdd9e63e89ddeeb90ccfee5a225ae8a77
  elif contents.contains('<define name="GLIB_CHECK_VERSION')
    cppcheck_version = '2.20.0'
  endif
endif

feature_cflags = []

headers = [
  'libintl.h',
  'locale.h',
  'memory.h',
  'stdlib.h',
  'string.h',
]
foreach header : headers
  if cc.check_header(header)
    feature_cflags += '-DHAVE_@0@=1'.format(header.underscorify().to_upper())
  endif
endforeach

extra_cflags = []
extra_cflags_check = [
  '-Wmissing-declarations',
  '-Wmissing-noreturn',
  '-Wold-style-definition',
  '-Wredundant-decls',
  '-Wpointer-arith',
  '-Wcast-align',
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
  '-Wno-missing-field-initializers',
  '-Werror=implicit-function-declaration',
  '-Wno-error=deprecated-declarations',
]

optimization = get_option('optimization')
if get_option('debug') and optimization in ['0', 'g']
  extra_cflags_check += '-fstack-protector-strong'
  extra_cflags += [
    '-DDEBUG=1',
    '-DDEBUG_TRACE=1',
    '-DG_ENABLE_DEBUG',
  ]
elif optimization in ['3', 's']
  extra_cflags += [
    '-DNDEBUG',
    '-DG_DISABLE_CAST_CHECKS',
    '-DG_DISABLE_ASSERT',
  ]
endif

if dependency_versions.has_key('glib')
  glib_version_parts = dependency_versions['glib'].split(' ')
  glib_min_version_parts = glib_version_parts[1].split('.')
  glib_min_version_define = 'GLIB_VERSION_@0@_@1@'.format(glib_min_version_parts[0], glib_min_version_parts[1])
  extra_cflags += [
    '-DGLIB_VERSION_MIN_REQUIRED=@0@'.format(glib_min_version_define),
    '-DGLIB_VERSION_MAX_ALLOWED=@0@'.format(glib_min_version_define),
    '-DG_LOG_USE_STRUCTURED=1',
  ]
endif

version_parts = meson.project_version().split('-dev')[0].split('.')
version_short = '@0@.@1@'.format(version_parts[0], version_parts[1])

extra_cflags += [
  '-DPACKAGE="@0@"'.format(meson.project_name()),
  '-DPACKAGE_NAME="@0@"'.format(meson.project_name()),
  '-DPACKAGE_VERSION="@0@"'.format(meson.project_version()),
  '-DVERSION="@0@"'.format(meson.project_version()),
  '-DVERSION_SHORT="@0@"'.format(version_short),
  '-DPACKAGE_STRING="@0@ @1@"'.format(meson.project_name(), meson.project_version()),
  '-DPACKAGE_DATADIR="@0@"'.format(pkgdatadir),
  '-DCOPYRIGHT_YEAR="@0@"'.format(copyright_year),
  '-DPACKAGE_LOCALE_DIR="@0@"'.format(get_option('prefix') / get_option('localedir')),
  '-DPACKAGE_BUGREPORT="https://gitlab.xfce.org/@0@/@1@/-/issues"'.format(project_namespace, meson.project_name()),
  '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
  '-DPREFIX="@0@"'.format(get_option('prefix')),
  '-DBINDIR="@0@"'.format(get_option('prefix') / get_option('bindir')),
  '-DDATADIR="@0@"'.format(get_option('prefix') / get_option('datadir')),
  '-DINCLUDEDIR="@0@"'.format(get_option('prefix') / get_option('includedir')),
  '-DLIBDIR="@0@"'.format(get_option('prefix') / get_option('libdir')),
  '-DLIBEXECDIR="@0@"'.format(get_option('prefix') / get_option('libexecdir')),
  '-DLOCALEDIR="@0@"'.format(get_option('prefix') / get_option('localedir')),
  '-DLOCALSTATEDIR="@0@"'.format(get_option('prefix') / get_option('localstatedir')),
  '-DSBINDIR="@0@"'.format(get_option('prefix') / get_option('sbindir')),
  '-DSYSCONFDIR="@0@"'.format(get_option('prefix') / get_option('sysconfdir')),
  '-DHAVE_XFCE_REVISION_H=1',
]

add_project_arguments(cc.get_supported_arguments(extra_cflags_check), language: 'c')
add_project_arguments(extra_cflags, language: 'c')
add_project_arguments(feature_cflags, language: 'c')

xfce_revision_h = vcs_tag(
  command: ['git', 'rev-parse', '--short', 'HEAD'],
  fallback: 'UNKNOWN',
  input: 'xfce-revision.h.in',
  output: 'xfce-revision.h',
  replace_string: '@REVISION@',
)

subdir('ci')
subdir('docs')
subdir('helpers')
subdir('m4macros')
subdir('scripts')
subdir('xdt-csource')
subdir('tests')
