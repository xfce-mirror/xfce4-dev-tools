# Autotools `configure` Generation

The `xdt-autogen` script should be used to generate your `configure`
script from the `configure.ac` template.  Dropping an `autogen.sh`
script into the root of your project with the following content should
do it:

```sh
#!/bin/sh

export XDT_AUTOGEN_REQUIRED_VERSION="4.18.0"

(type xdt-autogen) >/dev/null 2>&1 || {
  cat >&2 <<EOF
autogen.sh: You don't seem to have the Xfce development tools installed on your system,
            which are required to build this software.
            Please install the xfce4-dev-tools package first; it is available
            from your distribution or https://www.xfce.org/.
EOF
  exit 1
}

exec xdt-autogen "$@"
```

As you can see, you can require a minimum version of `xdt-autogen` by
setting `XDT_AUTOGEN_REQUIRED_VERSION` before running it.

# Symbol Visibility and ABI checking

The scripts `xdt-check-abi` and `xdt-gen-visibility` can be used to
manage the ABI of your shared library.

## `xdt-check-abi`

The first script is a checker: it takes as its first argument a symbols
file (described later), and as its second argument the final compiled
library file.  It will exit 0 on success, or 1 on failure, and print out
a diff between the expected and actual ABI.

## `xdt-gen-visibility`

The second script generates aliases and attributes to set up GNU
visibility for the functions in your library.  It needs to generate both
a header and source file.  To summarize:

1. Create a symbols file that lists all symbols you wish to export from
   the library.
2. Use the script to generate a header, which must be included as the
   *last* `#include` statement in the list of includes in any source
   file that defines public symbols.
3. Use the script to generate a source file, which must be included at
   the very bottom of each source file that defines public symbols.
   Right before this include, you'll need to define a preprocessor macro
   to "enable" the declarations for the current file.
4. You should check to ensure the compiler in use supports visibility
   attributes, and you can also allow the person building to disable
   this functionality.
5. You should add `-fvisibilty=hidden` to the compiler command line.
   This sets the default visibility to "hidden"; the generated source
   and header files will explicitly "unhide" symbols that should be made
   public.
6. You must add `-DENABLE_SYMBOL_VISIBILITY=1` to the compiler command
   line, or otherwise cause that preprocessor macro to be defined.
7. Optionally, you can also include the header (again, as the last
   `#include` statement) in any source file that doesn't export public
   symbols, but *uses* any of those public symbols, and the generated
   function calls or variable accesses will be made more efficiently.

Details for autotools and meson, as well as the format of the symbols
file, are below.

### Build system integration

#### For autotools

In `configure.ac`:

```autoconf
AC_ARG_ENABLE([visibility],
              AS_HELP_STRING([--disable-visibility],
                             [Do not use ELF visibility attributes]),
              [enable_visibility=$enableval], [enable_visibility=yes])
have_gnuc_visibility=no
if test "x$enable_visibility" != "xno"; then
  XDT_SUPPORTED_FLAGS([xdt_vis_test_cflags], [-Wall -Werror -Wno-unused-parameter -fvisibility=hidden])
  saved_CFLAGS="$CFLAGS"
  CFLAGS="$CFLAGS $xdt_vis_test_cflags"
  AC_MSG_CHECKING([whether $CC supports the GNUC visibility attribute])
  AC_COMPILE_IFELSE([AC_LANG_SOURCE(
  [
    void test_default(void);
    void test_hidden(void);
    void __attribute__((visibility("default"))) test_default(void) {}
    void __attribute__((visibility("hidden"))) test_hidden(void) {}
    int main(int argc, char **argv) {
      test_default();
      test_hidden();
      return 0;
    }
  ])],
  [
    have_gnuc_visibility=yes
    AC_MSG_RESULT([yes])
  ],
  [
    AC_MSG_RESULT([no])
  ])
  CFLAGS="$saved_CFLAGS"
fi
if test "x$have_gnuc_visibility" = "xyes"; then
  CPPFLAGS="$CPPFLAGS -DENABLE_SYMBOL_VISIBILITY=1"
  CFLAGS="$CFLAGS -fvisibility=hidden"
fi
```

In `Makefile.am`:

```make
libexample_la_SOURCES = \
	# ... other sources ... \
	libexample-visibility.c \
	libexample-visibilty.h

%-visibility.h: %.symbols Makefile
	$(AM_V_GEN) xdt-gen-visibility --kind=header $< $@

%-visibility.c: %.symbols Makefile
	$(AM_V_GEN) xdt-gen-visibility --kind=source $< $@

BUILT_SOURCES = \
	libexample-visibility.c \
	libexample-visibilty.h

CLEANFILES = \
	libexample-visibility.c \
	libexample-visibilty.h

EXTRA_DIST = \
	libexample.symbols
```

While the generated source file does not need to be linked into the
final library (in fact doing so is a no-op, as the `#ifdef` statements
in the file will effectively make it an empty file when compiled that
way), the simplest way to ensure that the files are generated and
up-to-date is to include them as source files.

#### For meson

In the root `meson_options.txt`:

```
option(
  'visibility',
  type: 'boolean',
  value: true,
  description: 'Build with GNU symbol visibility',
)

```

In the project root's `meson.build`:

```meson
python3 = find_program('python3', required: true)
xdt_gen_visibility = find_program('xdt-gen-visibility', required: true)

gnu_symbol_visibility = 'default'
visibility_defines = []
if get_option('visibility')
    gnu_symbol_visibility = 'hidden'
    visibility_defines += '-DENABLE_SYMBOL_VISIBILITY=1'
endif
```

And in the `meson.build` where the library is built:

```meson
libexample_generated_files += custom_target(
  'libexample-visibility.h',
  input: 'libexample.symbols',
  output: 'libexample-visibility.h',
  command: [xdt_gen_visibility, '--kind=header', '@INPUT@', '@OUTPUT@'],
)
libexample_generated_files += custom_target(
  'libexample-visibility.c',
  input: 'libexample.symbols',
  output: 'libexample-visibility.c',
  command: [xdt_gen_visibility, '--kind=source', '@INPUT@', '@OUTPUT@'],
)

library(
  'libexample',
  [
    # ... source files ...
  ] + libexample_generated_files,
  # ...
  extra_args: visibility_defines,
  gnu_symbol_visibility: gnu_symbol_visibility,
  # ...
)
```

While the generated source file does not need to be linked into the
final library (in fact doing so is a no-op, as the `#ifdef` statements
in the file will effectively make it an empty file when compiled that
way), the simplest way to ensure that the files are generated and
up-to-date is to include them as source files.

### Inclusion in source files

The script assumes you are using header guards in your headers that look
like, e.g.:

```c
#ifndef __THE_FILE_NAME_H__
#define __THE_FILE_NAME_H__

// ...

#endif
```

If you are not, you will need to pass the `--ifdef-guard-format` option
to the script.  See the `--help` output for more information on format
options.  For reference, the default format is
`__{file_stem_upper_snake}_{file_type_upper}__`.

For the `.c` source files themselves, you will need to add the generated
header as the *last* `#include` statement.  This point is very
important!  If you are using a source-code formatting tool that
rearranges includes, ensure that you've configured it in a way such that
the visibility header will be sorted last.

Then at the *very bottom* of the file, as the last two lines, add:

```c
#define __THE_FILE_NAME_C__
#include <libexample-visibility.c>
```

If you aren't using the default `ifdef-guard-format`, you should use the
format you specified there as the format for this `#define`. Of course,
replace `THE_FILE_NAME` with the actual file stem, in whatever format
you've specified.

And yes, you're including the `.c` file, not a header, and the `#define`
includes the letter "C" (or "c"), and not "H" (or "h").

## The `.symbols` file

The symbols file, used by both the ABI checker and the visibility
header/source generator, should be broken up into sections based on the
C source file the symbol is defined in.  To start a new section, use a
comment formatted like this:

```
# file:the-file-name-stem`
```

Note that the file name should *not* include the `.c` suffix.

Following that should be a list of symbols to export, one per line.  If
the symbol is a variable (rather than a function), prefix the name with
`var:`.

You can add "attributes" as well.  After the symbol, put a space
separated list of tokens prefixed with `attr:`.  Here is a more complete
example:

```
# file:libexample-config
libexample_check_version
var:libexample_major_version
var:libexample_micro_version
var:libexample_minor_version

# file:ex-util
ex_do_something attr:G_GNUC_CONST
ex_do_something_else attr:G_GNUC_CONST attr:G_GNUC_PURE
ex_do_yet_another_thing
```

Blank lines and lines starting with a "#" (aside from the `file:` lines)
are ignored.
