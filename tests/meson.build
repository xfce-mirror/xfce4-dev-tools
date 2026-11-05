test_xdt_csource_data = custom_target(
  'test-xdt-csource-data.c',
  input: [
    'data' / 'data.bin',
    'data' / 'data.txt',
  ],
  output: 'test-xdt-csource-data.c',
  command: [xdt_csource, '--extern', '--build-list', 'data_bin', '@INPUT0@', 'data_txt', '@INPUT1@'],
  capture: true,
)

e = executable(
  'test-xdt-csource',
  sources: [
    'test-xdt-csource.c',
    test_xdt_csource_data,
  ],
  include_directories: [
    include_directories('..'),
  ],
  dependencies: [
    glib,
  ],
  install: false,
)

test('test-xdt-csource', e)
