# Contributing to GAP

We invite everyone to contribute by submitting patches, pull requests,
bug reports, and code reviews. We would like to make the contributing process as easy as
possible.


## Packages versus contributions to the "core" system

One way of contributing to GAP is to write a
[GAP package](https://www.gap-system.org/Packages/packages.html) and send it
to us to consider for redistribution with GAP.  This is appropriate if your
contribution adds a body of functionality for some area of mathematics (or
some coherent batch of system functionality). A package is also appropriate
if you plan to continue to develop your code in the future. You will retain
control of your code and be recorded as author and maintainer of it.

Packages are not an appropriate way to release fixes or extremely small
changes, or to impose your own preferences for, for instance, how things
should be printed.


## Issue reporting and code contributions

* Before you report an issue, or wish to add functionality, please try
  and check to see if there are existing
  [issues](https://github.com/gap-system/gap/issues) or
  [pull requests](https://github.com/gap-system/gap/pulls).
  We do not want you wasting your time duplicating somebody else's work.
* For substantial changes it is also advisable to contact us before
  you start work to discuss your ideas.
* You should be prepared to wait until your pull request or patch
  has been discussed and authorized prior to its inclusion. We might
  also ask for you to adapt your changes to make them suitable for
  inclusion.
* To help increase the chance of your pull request being accepted:
  * Run the tests.
  * Update the documentation, tests, examples, guides, and whatever
    else is affected by your contribution.
  * Use appropriate code formatting for both C and GAP.
* *The Campsite Rule*
  A basic rule when contributing to GAP is the **campsite rule**:
  leave the codebase in better condition than you found it.
  Please clean up any messes that you find, and don't
  leave behind new messes for the next contributor.


## Making Changes

GAP development follows a straightforward branching model. We prefer using
the GitHub infrastructure. If you would like to contribute, but do not want
to create a GitHub account, see below for an alternative.

* Make sure you are familiar with [Git](https://git-scm.com/book)
  * see for example the [Atlassian Git Tutorials](https://www.atlassian.com/git/tutorials/)
    for an excellent introduction to Git.
* Make sure you have a [GitHub account](https://github.com/signup/free).
* Make sure you are familiar with [GAP](https://www.gap-system.org/).
* Fork our [main development repository](https://github.com/gap-system/gap) on github
* Clone your fork to a chosen directory on your local machine using HTTPS:

        $ git clone https://github.com/<your github user name>/gap.git

* This will create a folder called `gap` (in the location where you ran `git
  clone`) containing the source files, folders and the Git repository.  The
  clone automatically sets up a remote alias named `origin` pointing to your
  fork on GitHub, which you can verify with:

        $ git remote -v

* Add `gap-system/gap` as a remote upstream

        $ git remote add upstream https://github.com/gap-system/gap.git

* Ensure your existing clone is up-to-date with current `HEAD` e.g.

        $ git fetch upstream
        $ git merge upstream/master

* Create and checkout onto a topic (or feature) branch on which to base your work.
  * This is typically done from the local `master` branch.
  * For your own sanity, please avoid working on the local `master` branch.
    Instead, create a new branch for your work:

        $ git branch fix/master/my_contrib master
        $ git checkout fix/master/my_contrib

    A shorter way of doing the above is

        $ git checkout -b fix/master/my_contrib master

    which creates the topic branch and checks out that branch immediately after.
* Make commits of logical units.
* Check for unnecessary whitespace with

        $ git diff --check

* Make sure your commit messages are along the lines of:

        Short (50 chars or less) summary of changes

        More detailed explanatory text, if necessary.  Wrap it to about 72
        characters or so.  In some contexts, the first line is treated as the
        subject of an email and the rest of the text as the body.  The blank
        line separating the summary from the body is critical (unless you omit
        the body entirely); tools like rebase can get confused if you run the
        two together.

        Further paragraphs come after blank lines.

        - Bullet points are okay, too

        - Typically a hyphen or asterisk is used for the bullet, preceded by a
          single space, with blank lines in between, but conventions vary here

* Make sure you have added any necessary tests for your changes.
* Run some tests to assure nothing else was accidentally broken.

        $ make check

* Push your changes to a topic branch in your fork of the repository.

        $ git push origin fix/master/my_contrib

* Go to GitHub and submit a pull request to GAP.

From there you will have to wait on one of the GAP committers to respond to
the request. This response might be an accept or some changes, improvements or
alternatives will be suggested. We do not guarantee that all requests will be
accepted. You may want to read the section discussing the reviewing process
below to make the review of your pull request go smoothly.


## Making changes without Github account

If you do not want to open a GitHub account you can still clone the GAP
repository like so:

    git clone https://github.com/gap-system/gap.git

Make your changes and commits, create a patch containing the commits you
want to send, and use git's [`send-email` feature](https://git-scm.com/docs/git-send-email)
to email the patch to <gap@gap-system.org>.  You can refer to
[this tutorial](https://burzalodowa.wordpress.com/2013/10/05/how-to-send-patches-with-git-send-email/)
on how to do this.


## The reviewing process

Before any change is incorporated into the code base, it must undergo a
mandatory code review. Typically, this is done for each pull request (PR) via
the GitHub code review facilities. In order to be mergeable into the code
base, a PR must have at least one approving code review from a core GAP
developer with write access to the GAP code repository.

However, everybody is very welcome to submit code reviews! This helps the core
developers a lot, and is a step towards becoming one of them yourself.

To review some code, start by browsing the list of open pull requests (PRs) at
<https://github.com/gap-system/gap/pulls> and look for a PR you would like to
review. Once you have chosen one, you can comment on its content, and even
individual lines changed by it, by following the instructions given on
<https://help.github.com/articles/reviewing-proposed-changes-in-a-pull-request/>

You can use the lists below as checklists for how to write your review.
Please be careful to criticize constructively and not use dismissive language
(see e.g. Brian Lee's section on `Rewording Feedback` in his
[blog post](https://medium.com/unpacking-trunk-club/designing-awesome-code-reviews-5a0d9cd867e3)).

### Before you dive into the code

This section is based on <https://lornajane.net/posts/2015/code-reviews-before-you-even-run-the-code>.

* Is it clear what feature / fix the contribution addresses?
* If based on an issue, does it relate to exactly one issue?
* Do the commit messages look good? Should some commits be squashed / broken up?
* Does the list of changed files look sensible?
  You can check for possibly unintentional changes to files by doing:
  * On Github, use the `Files changed` tab
    (and collapse the source diffs if you want).
  * If you have cloned the PR use `git log --stat`.
* Eyeball the diff for
  * Large commented / unused sections of code
  * Strange variable or function names
  * Duplicate code

### Dive into the code

* Is the code correct?
* Is the code commented where necessary?
* Do the continuous integration tests pass?
* Are there tests if necessary?
* Does the new code fit in with documented behaviour?
* Are new features documented if necessary?
* Double check whether the changes should be included into the release notes.
  If not, label the issue / PR accordingly.


## Contact

GAP uses Slack, a multi user chat system, for discussions. Everyone can
join via a web browser or a dedicated client (e.g for Android or iOS).
Just follow the link <https://gap-system.org/slack>.

There is also an open developer list with currently very low volume.
You can subscribe to it at <https://lists.uni-kl.de/gap/info/gap>.


## Additional Resources

* [GAP Tutorial](https://docs.gap-system.org/doc/tut/chap0_mj.html)
* [GAP Manual](https://docs.gap-system.org/doc/ref/chap0_mj.html)
* [GAP Homepage](https://www.gap-system.org/)
* [GAP on GitHub: Quickstart](https://github.com/gap-system/gap-git-cheat-sheet/raw/master/gap-git-cheat-sheet.pdf)
* [Atlassian Git Tutorials](https://www.atlassian.com/git/tutorials/)
* [Using Pull Requests](https://help.github.com/articles/using-pull-requests)
* [General GitHub Documentation](https://help.github.com/)

Heavily adapted from the contributing files from the
[Puppet project](https://github.com/puppetlabs/puppet),
[Factory Girl Rails](https://github.com/thoughtbot/factory_girl_rails/blob/master/CONTRIBUTING.md),
and [Idris](https://github.com/idris-lang/Idris-dev).
