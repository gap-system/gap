# How to produce release notes for GAP essentially automatically

(This text arose from discussions and experiments during the
GAP Days "Spring" in February 2021.)

## What are GAP release notes?

For each release of GAP since version 4.3, we provide **release notes** in the file `CHANGES.md` of the GAP root directory.  This file contains one section about each release.

Since GAP 4.8, these notes contain references to the github pull requests
that describe the changes.

Up to version 4.11.1, the relevant part of `CHANGES.md` has been put together manually, by evaluating the pull merged requests in question and then structuring this information.

Since then, we intend to extend `CHANGES.md` as automatically as possible, and this file shall help to achieve this.

(Up to version 4.10.0, GAP release notes were available also via the GAPDoc book "Changes".  We have stopped providing this format of release notes because preparing it was very time consuming.  However, this format had for example the advantage that its HTML links into the GAP Reference Manual or into package manuals allowed one to easily access information about new or changed GAP functions etc.  It would be good to revive this feature of the "CHANGES" manual, provided it can be achieved essentially automatically.)


## How shall GAP release notes look?

The aim of GAP release notes is to give users an overview of **important** changes since the previous version.  This means that this overview does not show a complete list of **all** changes (if one is interested in a complete list then one can consult the history in github), and that the listed changes are shown in a structured way.

We show the subset of those merged pull requests that belong to the release in question and are regarded as relevant for the release notes.  For each of these pull requests, one line is shown, containing the number (as a link to the pull request in github) and the title.  Pull requests with related topics are grouped together under suitable subheadings.  These groups are ordered according to decreasing "severity".  Of course it is not possible to define such a general linear ordering, but we want each pull request to appear **only once** in the release notes, not in several groups according to several aspects it belongs to.

Note that a file with release notes that is expected to be **read** must be **short**; other tools would be needed for **evaluating** the release notes (searching/filtering facilities according to various aspects).

Besides the list of relevant pull requests, the release notes contain also the lists of changed GAP packages:
- omitted packages (which had been distributed with the previous GAP version but are not distributed with the current one),
- changed packages (which are distributed with both the previous and the current GAP version, but with different package versions),
- new packages (which had not been distributed with the previous GAP version but are distributed with the current one).

For each package in question, there is one entry that shows package name (with a link to the package homepage), version, authors, abstract,

Note that the information about packages cannot be extracted from pull requests. It depends on the archives of packages that are distributed with GAP.
(Since the release of GAP 4.11.1, scripts in `dev/releases` can be used to extract the metadata of all packages that belong to a given version of GAP or to a given package archive, hence the differences between two releases can be computed.)


## How are release notes created from the github pull requests?

The main idea is to use the *labels* that are assigned to the pull requests.
Currently the following labels are regarded as relevant for the creation of release notes.

- Pull requests with the label `release notes: not needed` shall **not** be listed in the release notes.
  Thus the release notes are composed from all those merged pull requests that belong to the release in question (are assigned to the release branch or have a `backport-to-...-DONE` label for the release) AND do NOT have the label `release notes: not needed`.

- For pull requests with the label `release notes: use title`, the text for the release notes is given by the title of the pull request.
  For all other pull requests, the text for the release notes can be extracted from the pull request body.  The pull request template (see `.github/pull_request_template.md`) contains the markers `## Text for release notes` and `## (End of text for release notes)`, thus the relevant text is expected between these markers, and can be extracted automatically.

- Up to now, also the labels `release notes: needed` and `release notes: added` have been used.
  The first one means that the text for release notes can be found in the body and has not yet been added to `CHANGES.md`, the second one means that the text has been added to `CHANGES.md`.
  I think that these two labels are obsolete in the new workflow where one can automatically create the current state of the `CHANGES.md` section about the forthcoming release **at any time**.

- The above labels describe whether a pull request is relevant at all, and if yes then how it is treated.
  The following labels describe the ordering of the groups of pull requests and the subheadings of these groups.  Each pull request gets assigned to the **first** group/subheading that corresponds to one of its labels.

| | subheading | labels | meaning |
| - |------------- | ------- | -------- |
| 1 | New features and major changes | `release notes: highlight` | PRs introducing changes that should be highlighted at the top of the release notes |
| 2 | Fixed bugs that could lead to incorrect results | `kind: bug: wrong result` | PRs fixing bugs that result in mathematically or otherwise wrong results |
| 3 | Removed or obsolete functionality | `topic: obsolete functionality` | PRs changing `lib/obsolete.g*` (move functions there or remove something from there) |
| 4 | Fixed bugs that could lead to crashes or unexpected error messages | `kind: bug: crash` | PRs fixing bugs that may cause GAP to crash |
| 4 | Fixed bugs that could lead to crashes or unexpected error messages | `kind: bug: unexpected error` | PRs fixing bugs that may cause GAP to run into an unexpected error |
| 5 | Other fixed bugs | `kind: bug:` | PRs fixing bugs |
| 6 | Improved and extended functionality | `kind: enhancement` OR `kind: new feature` OR `kind: performance` | PRs implementing enhancements |
| 7 | Improvements in the experimental way to allow 3rd party code to link GAP as a library (libgap) | `topic: libgap` | PRs that are related to libgap |
| 8 | Improvements in for the **Julia** integration | `topic: julia` | PRs that are related to the Julia integration |
| 9 | Changed documentation | `topic: documentation` | PRs improving the documentation |
| 10 | Packages | `topic: packages` | PRs related to package handling, or specific to a package (for packages w/o issue tracker) |
| 11 | Other changes | `release notes: needed` OR `release notes: added` | PRs relevant for the release notes but without a label that fits --in each case, think about assigning such a label or introducing a new one |

- For empty groups of pull requests, the subheading need not appear in `CHANGES.md`.

- If the group "Other changes" is too large then we should decide whether other labels (most likely some `topic: ...` labels) can be used to define useful groups; in this case, a subheading has to be defined for this label.
  (There will be a script for creating the current `CHANGES.md` section in the `dev` subdirectory of the main GAP directory, the change of the rules should be made in this script.)

- Concerning the ordering, I think that somebody who reads the release notes of a new GAP version will be first interested in highlights, then in bugs which may affect one's computations (wrong results), then in removed functionality (which may break old private code), then in general improvements.

  I think there is no way to satisfy all perspectives of what is most important, in particular concerning the `topic: ...` labels.
  Note that `CHANGES.md` is just **one** way to present the changes, eventually we should put the source data (pull request number, release notes text, labels) into the GAP distribution, and provide a tool for evaluating the data inside a GAP session.

- For convenience, consistency checks can be executed, via suitable queries (restricted to the merged pull requests that belong to the forthcoming release), for example:
  - There should be no pull requests without the labels `release notes: not needed` and `release notes: use title` AND without release notes text in the body.

- The three sections on changes packages in the forthcomiing release (see above) will appear below the groups of pull requests that are defined by the above labels.
  (There will be a script that extracts the information from suitable text files related to the package archives.)


## How to deal with github pull requests in a release notes friendly way?

The following is intended for those who create or review pull requests.

- If your pull request should not be mentioned in the release notes then add the label `release notes: not needed`, and you are done.

- Otherwise, try to find a short title that describes the pull request in the release notes; use appropriate markup in the title (e.g., backquotes for surrounding function names).  In this case, add the label `release notes: use title`.

- Otherwise, make sure that the body of the pull request contains the relevant text below the line `## Text for release notes`.
  (In the old workflow, the label `release notes: needed` should be added. I think this should be abolished.)

- Choose as many suitable (release notes relevant) labels as you want. Keep in mind that the pull request will appear just in the first applicable group of pull requests in `CHANGES.md`.

