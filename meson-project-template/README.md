# Meson project template

File in this directory help you get started porting your build system
from autotools to [meson](https://mesonbuild.com).  Meson
(intentionally) does not support any means of extending itself (or
adding custom "modules"), so each project cannot rely on any shared
build code (like we had with our Xfce-specific M4 macros).

The [Meson documentation](https://mesonbuild.com/Overview.html) is
fairly comprehensive, so that's a good place to learn about how to do
various things in Meson.

# Template Files

## `meson.build`

Use this as a starting point for your project's root `meson.build` file.
You will also need `meson.build` files in each project subdirectory that
will list executables and/or libraries to be built and possibly
installed, as well as other program data (like icons or default
configuration) that need to be installed as well.

However, the root `meson.build` file needs a bit of boilerplate to get
things started, so it's provided here.  Feel free to change whatever you
need to change, or add other checks or dependencies.  And of course add
`subdir()` directives at the end to include `meson.build` files in
project subdirectories.

###

## `print-version`

Meson doesn't have a built-in way to dynamically change the package
version based on the git commit hash (for non-release commits, anyway).

The `print-version` script will use `git describe` to determine the
version number of the package.  If the current `HEAD` is not a release
tag, `git-$GIT_SHORT_HASH` will be appended to the version number.

The line in the `meson.build` template that sets the project version is
already set up to call this script and insert the resulting version.

# Other Migration Notes

## Build options

If you are used to having a `--enable-foo` or `--disable-foo` configure
switch (or similar options prefixed with `--with-`) in your autotools
project, you should replace that with an `option()` declaration in the
`meson_options.txt` file (placed the root of your project).  See
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

### Building .desktop files with translations

Meson can handle this too, e.g.:

```
i18n = import('i18n')
i18n.merge_file(
  output: 'foo.desktop',
  input: 'foo.desktop.in',
  po_dir: '../po',
  type: 'desktop',
  install: true,
  install_dir: get_option('datadir') / 'applications',
)
```

## gtk-doc

If you are building a library, check out the gtk-doc functionality in
Meson's [GNOME
module](https://mesonbuild.com/Gnome-module.html#gnomegtkdoc).

You should add a build option in `meson_options.txt`, and name it
`gtk-doc`, as a boolean option, set to `false` by default.  Please use
this convention for Xfce libraries, as that is what the build
container's build process will expect.

NB: I have had some issues with it, though.  For example, the generated
docs for some reason don't list signals and GObject properties in them,
while the same setup using autotools works properly.

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
them will return an object that you'll need to use to ensure the sources
get built.  Usually you'll pass that in the list of sources when you
call `executable()` or `library()`.
