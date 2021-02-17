# The GAP etc/ directory

Here is an overview of the files in this directory. Most of them
contain comments with a more detailed description of what they do.

## Files for GAP developers

The following are tools for people working on the GAP code base itself

- `ffgen.c`: used by the GAP build system
- `tags.sh`: used by the `make tags` build target

## Files for GAP package authors

- `Makefile.gappkg`: build rules intended for use by GAP packages with a kernel extension
- `convert.pl`: script to convert old style gapmacro-based GAP manual TeX files to HTML

## Files for all GAP users

- `log2html.g`: Utility to convert GAP log files to XHTML 1.0 Strict.
- `gaplog.css`: used by `log2html.g`
- `emacs`: used to contain GAP integration for emacs
- `vim`: GAP integration for vim
- `xrmtcmd.c`: for use by the GAP help system on X-Window, to control `xdvi`
