# Ctags for GAP

This file describes how to set up Ctags to work with GAP source files.
Ctags is a tool that can be used to generate an index file of names found in
source files. This index file can then be used by editors to jump to the
definition of any indexed name.

Note that if you have Exuberant Ctags installed (if in doubt, run `ctags --version`)
and only want to generate tags for the gap-system/gap repository, then you do
not need set up anything. The symlink `.ctags` in the GAP root folder already
tells ctags all it needs to know, and you can create and update the tags by
running:

    make tags

If you want to use ctags in another GAP project or have Universal Ctags
installed, read on.

Run

  ctags --version

to see whether you are running Exuberant Ctags or Universal Ctags.
Append the content of the file `ctags_for_gap` to the file

    ~/.ctags

if you are running Exuberant Ctags. If you are running Universal Ctags then
append the content of the file `ctags_for_gap` to the file

    $XDG_CONFIG_HOME/ctags/gap.ctags

or

    $HOME/.config/ctags/gap.ctags

if `$XDG_CONFIG_HOME` is not defined.
Then run

    ctags --recurse lib/ src/

in the GAP installation directory. If you are running ctags in another project,
you may have to do

    ctags --recurse gap/ src/

instead. This creates a file

    tags

Many editors support ctags either natively or via a plugin (e.g. vim, emacs,
BBEdit, ...). For example, to use it in vim, start vim in the GAP root directory and
do

    :tag <function-name>

or, while your cursor is on the name of that function, press `<CTRL-]>`
to jump to the first definition of that function. If for example an operation has
several several methods installed, you can also do

    :ts <function-name>

or press `<g]>` or to get an overview over all tags found.

For instructions on how to regenerate tags automatically via git-hooks, for example
when running git commit, git clone, etc., you can have a look at:

    https://tbaggery.com/2011/08/08/effortless-ctags-with-git.html

