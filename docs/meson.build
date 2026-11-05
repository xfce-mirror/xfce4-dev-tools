custom_target(
  'xdt-csource.1',
  input: 'xdt-csource.xml',
  output: 'xdt-csource.1',
  command: [xsltproc, '--nonet', '--output', '@OUTPUT@', 'http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl', '@INPUT@'],
  install: true,
  install_dir: get_option('prefix') / get_option('mandir') / 'man1',
)
