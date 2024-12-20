# Meson project template

Files in this directory help you get started porting your build system
from autotools to [meson](https://mesonbuild.com).  Meson
(intentionally) does not support any means of extending itself (or
adding custom "modules"), so each project cannot rely on any shared
build code (like we had with our Xfce-specific M4 macros).

The [Meson documentation](https://mesonbuild.com/Overview.html) is
fairly comprehensive, so that's a good place to learn about how to do
various things in Meson.

To get started, copy the `meson.build` and `meson_options.txt` files
into the root of your repository, and start editing both of them.  Below
you'll find a more detailed description of what's in those files, and
how to use meson.

# Files Provided Here

## `meson.build`

Use this as a starting point for your project's root `meson.build` file.
You will also need `meson.build` files in each project subdirectory that
will list executables and/or libraries to be built and possibly
installed, as well as other program data (like icons or default
configuration) that need to be installed as well.

The root `meson.build` file needs a bit of boilerplate to get things
started, so it's provided here.  Feel free to change whatever you need
to change, or add other checks or dependencies.  And of course add
`subdir()` directives at the end to include `meson.build` files in
project subdirectories.

## `meson_options.txt`

The sample `meson_options.txt` file includes some options, commented
out, that you might need, depending on your project.  Feel free to
uncomment any you need, and delete any you don't.  The particular option
names used in the sample file might trigger things in the CI build, so
please use the sample names provided.

If you are used to having `--enable-$FEATURE` or `--disable-$FEATURE`
configure switches (or similar options prefixed with `--with-`) in your
autotools project, you should add these to the `meson_options.txt` file.

Perhaps confusingly, user-specified options of this form are usually
passed to `meson setup` using `-D` syntax.  For example:

```
meson setup -Dsome-feature=enabled -Dother-thing=false
```

For features that can be autodetected at compile time, use the option
type `feature` instead of `boolean`, which can then end up being set to
`auto`, `enabled`, or `disabled`.

See [here](https://mesonbuild.com/Build-options.html) for more
information.

## `xfce-revision.h.in`

In our autotools build, we have a macro that automatically appends the
git SHA1 hash to the project's version number for development builds.

While this is possible to do with meson, it requires quite a few more
moving parts:

1. We need to provide a `version.sh` script that can print the full
   version string, which will need to run `git describe` and have some
   fallback logic.
2. Since the script relies fully on git for the version number -- that
   is, it gets not just the SHA1 hash, but also the entire version
   string -- a git checkout (as well as the git binary) is a hard
   requirement for any build.  For release tarballs, we can use meson's
   `add_dist_script()` functionality to rewrite the `meson.build` file
   to have a hard-coded version number, and will no longer have to call
   the `version.sh` script, meaning a git checkout is no longer needed.
3. However, that only works if the tarball was created using `meson
   dist`.  Some distro packagers don't use our published tarballs, and
   instead call the GitLab API to fetch the files in the git repo (for a
   particular tag) directly.  This method leaves out the `.git/` dir,
   and the `version.sh` script cannot function without one, so builds
   fail.

Ultimately, after much discussion, we've decided to just drop this
functionality entirely.  Project versions should be hard-coded in the
`meson.build` file, and the `xfce-do-release` script will add/remove a
`-dev` suffix when cutting a new release.

The project-root `meson.build` template provided here includes a call to
`vcs_tag()`, which writes a `xfce-revision.h` file with a single
`REVISION` macro that expands to the git SHA1 hash of the current
commit.  The `vcs_tag()` call returns a custom target; you will need to
include it as a source file in your `executable()` or `library()`
declarations, and then `#include` the header in any source file that
needs it.  The `meson.build` template sets `HAVE_XFCE_REVISION_H` if you
need to conditionally include it.

# Build-time File Generation

## pkgconfig

If you need to build and install pkgconfig `.pc` files, use Meson's
[pkgconfig module](https://mesonbuild.com/Pkgconfig-module.html).

## i18n

To migrate `.po` file building from autotools, you can use Meson's [i18n
module](https://mesonbuild.com/i18n-module.html).  The short version of
it is this:

Make sure you have a `LINGUAS` file with each supported language in it.

Don't do this yet, because it will break the autotools build, but
eventually you'll need to rename your `POTFILES.in` file to `POTFILES`,
and possibly change the file paths in it so that they're relative to the
root of your project, not to the `po/` directory.  (`POTFILES` is only
used when generating the full list of strings that need to be
translated, so you won't need this yet anyway.)

Create a `meson.build` file with some quite simple contents:

```
i18n = import('i18n')
i18n.gettext(meson.project_name(), preset: 'glib')
```

Finally, you can remove `Makevars`, `Makefile.*` and any other files in the `po/`
directory that autotools used.

If you need to build the `.pot` file, you can run:

```
meson compile -Cbuild ${PROJECT_NAME}-pot
```

### Building non-source files with translations

Meson can handle this too, e.g.:

```
i18n = import('i18n')
i18n.merge_file(
  output: 'foo.desktop',
  input: 'foo.desktop.in',
  po_dir: '../po',
  type: 'desktop',
  install: true,
  install_dir: get_option('prefix') / get_option('datadir') / 'applications',
)
```

Meson can also handle translatable XML files, using `type: 'xml'`.

## gtk-doc

If you are building a library, check out the gtk-doc functionality in
Meson's [GNOME
module](https://mesonbuild.com/Gnome-module.html#gnomegtkdoc).

You should add a build option in `meson_options.txt`, and name it
`gtk-doc`, as a boolean option, set to `false` by default.  Please use
this convention for Xfce libraries, as that is what the build
container's build process will expect.

## GObject introspection

If you are building a library that ships GObject types, you may want to
also build and ship a GObject introspection description file.  Check out
the gir functionality in Meson's [GNOME
module](https://mesonbuild.com/Gnome-module.html#gnomegenerate_gir).

You should add a build option in `meson_options.txt`, and name it
`introspection`, as a boolean option, set to `true` by default.

## Vala API

If you are building a library that also ships a GObject introspection
description file, you may want to also build and ship a Vala API
description file.  Check out the Vala functionality in Meson's [GNOME
module](https://mesonbuild.com/Gnome-module.html#gnomegenerate_vapi).

You should add a build option in `meson_options.txt`, and name it
`vala`, as a feature option, set to `auto` by default.  You should also
check for the existence of the `vapigen` program, and assert that the
GObject introspection file is also being built, as it is a dependency.

## Other generated sources

Some types of generated sources have built-in functionality.  For
example, Meson's [GNOME
module](https://mesonbuild.com/Gnome-module.html) contains convenience
functions for `glib-compile-resources`, `glib-mkenums`,
`glib-genmarshal`, `gdbus-codegen` and more.

If you can't find something built-in, you can use Meson's
`custom_target()` or `generator()`.  See
[here](https://mesonbuild.com/Generating-sources.html) for more
information.

Don't forget: when you generate sources, the function that generates
them will return an object (usually a string or an array) that you'll
need to use to ensure the sources get built.  Usually you'll pass that
in the list of sources when you call `executable()` or `library()`.

One other thing to remember is that in our autotools builds we sometimes
use `MAINTAINER_MODE` and `EXTRA_DIST` to include some files in the dist
tarball that are generated (the idea being that it allows people who
build from source to be missing some possibly-less-common build tools).
This functionality isn't present in meson, so users will have to have
all build tools present on their system.  In practice this is not really
a big deal, and eliminating `MAINTAINER_MODE` is probably a good thing
anyway.

# Other Migration Notes

## Checking for system headers

In general I would recommend removing a lot of the old checks for system
headers we've accumulated (along with their corresponding `#ifdef`
guards in the code), as some of them are a little silly: like what
system that we actually build for and care about doesn't have
`string.h`?  But for header checking in general, you can add something
like this to your toplevel `meson.build`:

```meson
headers = [
  'stdint.h'
  'sys/mman.h'
]
header_cflags = []
foreach header : headers
  if cc.check_header(header)
    header_cflags += '-DHAVE_@0@=1'.format(header.replace('.', '_').replace('/', '_').replace('-', '_').to_upper())
  endif
endforeach
add_project_arguments(header_cflags, language: 'c')
```

## Checking for library functions

If you need to check that the system has a particular function in its
standard library (or in some other library), you can use the
`has_function()` method on the compiler object.  If you leave out the
`dependencies`, it will search only in `libc`.  You can create dependent
libraries to search in either using the `dependency()` function, or by
using `find_library()` on the compiler object.

## `libm`

`libm` is a strange creature, and is mostly only required on glibc-based
systems when you are using "advanced" mathematics functions.  To check
for it, use `find_library()`:

```meson
libm = cc.find_library('m', required: false)
```

(Where `cc` is the C compiler object.)  You can include it as a regular
dependency in your `executable()` or `library()` function call.

## Shipping meson build files with autotools

Your autotools build will not include the meson build files in the dist
tarball unless you manually add them to `EXTRA_DIST`.  Be sure to also
include `meson_options.txt` as well as `xfce-revision.h.in`.

For `po/meson.build`, include it in the `EXTRA_DIST` in the root
`Makfile.am`, using its full relative path.  The makefile machinery in
the `po/` dir will get overwritten by `autogen.sh`.

For gtk-doc directories, at the very bottom of `Makefile.am`, *after*
the line that includes the `gtk-doc.make` file, add an `EXTRA_DIST`
assignment, but make sure it is a `+=` assignment, as `gtk-doc.make`
will set it as well in order to include its own files.  Alternatively,
you can also do the same as for `po/meson.build`, and use the root
`Makefile.am`, or `docs/Makefile.am`.  If you are shipping an entities
file (e.g. `gtkdocentities.ent.in`), be sure to include that as well.

# Verifying Your Migration

After you've finished writing your meson build files, you should make
sure it does the same thing as your autotools build.  One simple way to
do that:

```bash
./autogen.sh --prefix=/usr --libdir=/usr/lib/$(gcc -dumpmachine) --enable-gtk-doc
make install DESTDIR=$(pwd)/dest-autotools
(cd dest-autotools && find . | grep -v '\.la$' | sort > ../files-autotools)
rm -rf dest-autotools

meson setup --prefix=/usr -Dgtk-doc=true  # leave out the last bit if your project doesn't have gtk-doc
meson install -Cbuild --destdir=$(pwd)/dest-meson
(cd dest-meson && find . | sort  > ../files-meson)
rm -rf dest-meson

diff -u files-autotools files-meson
```

If the `diff` is empty, then you're at least installing the same files
to the same locations.  A couple notes on this:

* We pass `--libdir` to `autogen.sh` because autotools doesn't do a
  multiarch-type install by default, but meson does.
* We filter out `.la` files from the autotools build, because meson
  doesn't use libtool to build libraries.

You can also run `make distcheck` and `meson dist -Cbuild` and compare
the files in the generated tarballs.  This check is a bit less
important; as long as your project builds, and the list of files that
actually gets installed is the same, you're probably fine.  Meson will
likely be putting more stuff in the dist tarball than autotools was,
anyway.

## Verifying GIR and VAPI files

If your project also builds GObject-introspection and Vala API
descriptions, ensure that those are also the same.  Small changes in how
arguments are passed to the GIR and VAPI generators can change the
output it ways that will affect user code.

In particular, for GIR generation, be sure to pass the
`identifier_prefix` and `symbol_prefix` options in the exact same order
that they're passed for the autotools build, as `vapigen` will use the
first prefix when deciding what namespace to use for the generated
Vala bindings.
