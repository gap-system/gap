Please use the following template to submit a pull request, filling
in at least the "Text for release notes" and/or "Further details".
Thank You!

# Description

## Text for release notes 

If this pull request should be mentioned in the release notes, 
please provide a short description matching the style of the GAP
`CHANGES.md` file in the root directory.

## Further details

If necessary, please provide further details here.

# Checklist for pull request reviewers

- [ ] proper formatting

If your code contains kernel C code, run `clang-format` on it; the 
simplest way is to use `git clang-format`, e.g. like this (don't
forget to commit the resulting changes):

    git clang-format $(git merge-base HEAD master)

- [ ] usage of relevant labels

   1. either `release notes: not needed` or `release notes: to be added`
   2. at least one of the labels `bug` or `enhancement` or `new feature`
   3. for changes meant to be backported to `stable-4.X` add the `backport-to-4.X` label
   4. consider adding any of the labels `build system`, `documentation`, `kernel`, `library`, `tests`

- [ ] runnable tests
- [ ] lines changed in commits are sufficiently covered by the tests
- [ ] adequate pull request title
- [ ] well formulated text for release notes
- [ ] relevant documentation updates
- [ ] sensible comments in the code

