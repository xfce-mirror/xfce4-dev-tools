# Meson project template

Files in this directory help you get started porting your build system
from autotools to [meson](https://mesonbuild.com).  Meson
(intentionally) does not support any means of extending itself (or
adding custom "modules"), so each project cannot rely on any shared
build code (like we had with our Xfce-specific M4 macros).

The [Meson documentation](https://mesonbuild.com/Overview.html) is
fairly comprehensive, so that's a good place to learn about how to do
various things in Meson.

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
include it as a dependency in your `executable()` or `library()`
declarations, and then `#include` the header in any source file that
needs it.

# Other Migration Notes

## Build options

If you are used to having `--enable-$FEATURE` or `--disable-$FEATURE`
configure switches (or similar options prefixed with `--with-`) in your
autotools project, you should replace that with `option()` declarations
in the `meson_options.txt` file (placed the root of your project).  See
[here](https://mesonbuild.com/Build-options.html) for more information.

Perhaps confusingly, user-specified options of this form are usually
passed to `meson setup` using `-D` syntax.  For example:

```
meson setup -Dsome-feature=enabled -Dother-thing=false
```

For features that can be autodetected at compile time, use the option
type `feature` instead of `boolean`, which can then end up being set to
`auto`, `enabled`, or `disabled`.

## pkgconfig

If you need to build and install pkgconfig `.pc` files, use Meson's
[pkgconfig module](https://mesonbuild.com/Pkgconfig-module.html).

## i18n

To migrate `.po` file building from autotools, you can use Meson's [i18n
module](https://mesonbuild.com/i18n-module.html).  The short version of
it is this:

Make sure you have a `LINGUAS` file with each supported language in it.
If you have a `POTFILES.in`, rename it to `POTFILES`; the filenames
listed in it should be relative to the root of your project.  (If you
don't have a `POTFILES`, create one.)

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

## Other generated sources

Some types of generated sources have built-in functionality.  For
example, Meson's [GNOME
module](https://mesonbuild.com/Gnome-module.html) contains convenience
functions for `glib-compile-resources`, `glib-mkenums`,
`glib-genmarshal`, and more.  It can also build gobject-introspection
bundles and generate GDBus code.

If you can't find something built-in, you can use Meson's
`custom_target()` or `generator()`.  See
[here](https://mesonbuild.com/Generating-sources.html) for more
information.

Don't forget: when you generate sources, the function that generates
them will return an object (usually a string or an array) that you'll
need to use to ensure the sources get built.  Usually you'll pass that
in the list of sources when you call `executable()` or `library()`.
