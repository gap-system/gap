# Developer guidelines

This document contains information potentially relevant for GAP developers.
Please also check out the file `CONTRIBUTING.md` for getting started working
on GAP. In contrast, this file here contains more specialized information that
you can use like a reference manual.


## Branches

At any time, there are two primary branches in the GAP git repository:

- `master`: all new changes go into this; pull requests usually target it
- `stable-4.X` (where `X` is some number): stable releases of the
  `4.X.*` series are made from this branch

We are using GitHub's "branch protection" feature to restrict direct pushes
to these branches. All changes should go through pull requests, to ensure
that tests are run automatically and are passing (hard experience taught us
that even "trivial" and "obviously correct" changes can break things).

Note that we only make releases from the most recent release branch; older
release branches are kept around but we do not expect to e.g. make a new
GAP 4.12.x release after 4.13.0 has been released, and so on.


### Making changes to the release branch via backports

By default all changes go into the `master` branch. Once a release 4.X.Y
is out, to get changes into the 4.X.(Y+1) release, the usual process is
to first land them into the `master` branch, and have them "backported"
later on the `stable-4.X` branch.

The process for backporting is as follows:
1. someone adds the `backport-to-4.X` label to the pull request (if you
   don't have permission, just ask for someone, e.g. @fingolfin, to add
   the label)
2. some time after the PR has been merged into `master`, and before the
   next stable release, someone will go through the list of merged PRs
   with this label, and backport them (usually by opening a dedicated
   backporting PR, which may contain the content of multiple PRs being
   backported).
3. After a PR has been backported this way, the `backport-to-4.X` label
   is replaced by a `backport-to-4.X-DONE` label, to avoid
   processing it again (this is also important for our scripts which generate
   the changelog updates for releases).


### Making changes to the release branch directly

Sometimes changes really are only for `stable-4.X` and not for `master`,
usually because the two branches diverged sufficiently (e.g. code may have
been rewritten in a major way on `master` which does not lend itself to
backporting, but we still want to fix a bug in the old implementation for
the release branch). In that case, you can create a pull request which
directly targets the `stable-4.X` branch (the target
branch can be selected on GitHub during the creation of pull requests). When making such a pull request, it's
a good idea to point it out (and the reason) in the PR description.


## Code formatting

Some simple rules for formatting code
- no tabs
- no trailing whitespace
- all source files should end with a newline

This is automatically done if your editor honours our `.editorconfig`
file. See <https://editorconfig.org> for a list of editors supporting
this and how to configure them.

For historical reasons we have no particular rule for formatting code
beyond the above. To avoid a chaotic mess, please adapt your
contributions to the surrounding code. So if you insert something into a
function that uses 2-space indentation, also use that.

Please refrain from reformatting code as you edit it, as this makes it
much harder to review your changes. If you really must reformat
something, do so in a separate commit which only contains formatting
changes.

For completely new kernel code in C/C++, you can use `clang-format` to
format it. If you edit existing code, you can try `git clang-format`
(which reformats only code that is already modified). But here, too,
please avoid large-scale reformatting, and keep reformatting in separate
commits. The following command can sometimes help format just the code
you modified anyway:

    git clang-format $(git merge-base master)


## Continuous integration (CI)

For every commit to our primary branches, and also for all pull requests, we
use [GitHub Actions][GHA] to run the GAP test suite, in order to detect
regressions early.

Which tests are run is controlled by the files `.github/workflows/CI.yml` and
`.github/workflows/release.yml`. The syntax for these files and more is explained
in the [GitHub Actions documentation][GHA].

See also `dev/ci.sh` and other `dev/ci-*.sh` files for the scripts that are
being run as part of these CI tests.


## Discussions

GAP uses Slack, a multi user chat system, for discussions. Everyone can
join via a web browser or a dedicated client (e.g for Android or iOS).
Just follow the link <https://gap-system.org/slack>.

There is also an open developer list with currently very low volume.
You can subscribe to it at <https://lists.uni-kl.de/gap/info/gap>.


## Pull requests

Contributions to GAP should be done in the form of GitHub pull requests.
Then our test suite (see "Testing" below) is automatically run as part of
the "Continuous integration (CI)" tests (again see elsewhere in this file
for details).

By default, your pull requests should target the `master` branch (see the
section "Branches" for details).

We use labels on branches to help us generated release notes for new GAP
versions. If you are a new contributor, don't worry about that, we'll take
care of it (in fact you won't even have the access rights to set them --
again, don't worry about that).

If you do have the permissions to set labels, here are some guidelines:
1. Always add one of the "release notes" labels.
2. If the change is meant to be backported to the stable branch,
   add a "backports" label (see elsewhere in this document for details).
3. Consider adding one of the "kind" label to indicate whether the change
   is a bug fix, enhancement or whatever else.
4. Other labels are mostly optional and can help categorize things for
   the release notes. You are invited to set them but it's not a must.

Some other notes for pull requests
- please read the section on "Code formatting"
- try to focus your pull request, i.e. ideally don't change multiple
  unrelated things in one PR (this makes reviewing your changes easier).


## Releases

For details on how GAP releases are made, see `dev/releases/README.md`.


## Testing

GAP includes a test suite inside the `tst` directory, which is split into
multiple parts.

- `testinstall`: quick test suite that one can test frequently.
   Run via  `./gap tst/testinstall.g`
- `teststandard`: slower but more comprehensive test suite.
   Run via  `./gap tst/teststandard.g`
- `testextra`: very slow test suite that tests even more
   Run via  `./gap tst/testextra.g`
- `testbugfix`: additional small test files that are created to verify
   specific bugfixes work as intended
   Run via  `./gap tst/testbugfix.g`


## Tracking down regressions

The script `dev/bisect.sh` can be very helpful in tracking down which commit
introduced a regression. Please read the extensive comments in the file to
learn what it does and how to use it. 


## Vendored dependencies

GAP contains copies of some third party software, mostly to make it easier to
build GAP "out of the box", with its minimal dependencies included.
GAP maintainers may wish to update these dependencies from time to time.

- `extern/gmp`: copy of [GMP](https://gmplib.org), the GNU Multiple Precision
  Arithmetic Library
- `extern/zlib`:  copy of [zlib](http://zlib.net), a compression library used to
  implement transparent reading and writing of .gz compressed files.
- `hpcgap/extern/gc`: copy of the [Boehm garbage collector](https://www.hboehm.info/gc/)
  used by HPC-GAP
- `hpcgap/extern/libatomic_ops`: copy of `libatomic_ops`, a subproject of Boehm GC;
  should thus be kept in sync with that.
- `cnf/config.guess` and `cnf/config.sub`: used by our `configure` script.
  Ideally `autoconf` or `autoreconf` should automatically install the latest
  versions of these, but this doesn't happen (presumably due to a bug in `autoconf`).
  They can be updated by running the `update-config.sh` script inside the `cnf`
  directory.

---

[GHA]: https://docs.github.com/en/actions
