# How to release GAP version X.Y.Z
 
**These instructions assume the following**
- It has been agreed to make a release called `X.Y.Z` from the `stable-X.Y` branch.
	- Note that most likely `X=4` for the foreseeable future.
- All changes to be included in the release are now present in the `stable-X.Y` branch.
	- This includes the release notes for version `X.Y.Z` being included in `CHANGES.md`.


## The release process for GAP -- the quick guide

This is the way the process should happen in practice, with the help of GitHub Actions. Instructions for achieving the same without GitHub Actions are given later (in case GitHub Actions breaks or disappears).

1. Access your local clone of the GAP repository.
2. Make sure that your clone is up to date with `gap-system/gap`.
3. Create an annotated tag `vX.Y.Z` in your clone at the appropriate commit in the `stable-X.Y` branch, and push the tag to `gap-system/gap`. For example:
    ```
    git tag -m "Version X.Y.Z" vX.Y.Z stable-X.Y
    git push origin vX.Y.Z
    ```  
4. Wait. Pushing the tag will trigger the “[Wrap releases](https://github.com/gap-system/gap/actions/workflows/release.yml)” GitHub Actions workflow on `gap-system/gap`, which wraps the release archives and Windows installers, and creates a release on GitHub with the archives and installers attached. This takes around 90 minutes.
5. Once the “Wrap releases” workflow is finished, either manually dispatch the “[Sync](https://github.com/gap-system/GapWWW/actions/workflows/sync.yml)” GitHub Actions workflow on `gap-system/GapWWW`, or wait overnight for it to happen on schedule.
	- This Workflow creates a pull request to `gap-system/GapWWW`, which updates the GAP website according to the release data hosted on `gap-system/gap`.  Check that the result is sensible.
6. When it is time to publicise the new GAP release, merge the pull request to GapWWW.
7. There are currently additional steps required for the changes to appear on <https://www.gap-system.org>, which could be automated but are currently not; these are described in steps 10–13 below.


## The release process for GAP -- the more detailed guide

In practice, you should use the process described above. The following information is mostly relevant for people who may wish to maintain/update/upgrade the release system for GAP.

A GitHub access token is required for the scripts to interact with GitHub; see the [GitHub access token](#github-access-token) section below. 

### Dependencies
Before starting the release process, the scripts have the following dependencies. Make sure you have the following available:
- All tools required to build GAP (as outlined in the GAP root `README.md`)
- The `git` command line tool
- The `curl` command line tool
- Python (version >= 3.6)
- Several python modules, including (e.g. installed using `pip3` (`pip3 install <MODULENAME>`):
  - `PyGithub`
  - `requests`
  - `python-dateutil`


### Steps

1. Access your local clone of the GAP repository.
2. Make sure that your clone is up to date with `gap-system/gap`.
3. Create an annotated tag `vX.Y.Z` in your clone at the appropriate commit in the `stable-X.Y` branch, and push the tag to `gap-system/gap`. For example:
    ```
    git tag -m "Version X.Y.Z" vX.Y.Z stable-X.Y
    git push origin vX.Y.Z
    ```  
4. Pushing the tag will trigger the “[Wrap releases](https://github.com/gap-system/gap/actions/workflows/release.yml)” GitHub Actions workflow on `gap-system/gap`. This does the following steps:
   1. Check out GAP at the appropriate commit.
   2. Run `make_archives.py` from the GAP root directory, which:
      - Exports the repository content into a new temporary directory `tmp/` via `git archive`.
	  - Patches the release version and dates in `configure.ac`.
      - Builds GAP and HPC-GAP.
      - Fetches the appropriate GAP package tarballs.
      - Builds GAP's manuals.
	  - Builds the json package.
      - Creates `package-infos.json.gz`, which contains JSON metadata of all distributed packages.
      - Creates `help-links.json.gz`, which contains JSON data for cross-referencing between manuals, and is used by the GAP website.
      - Cleans everything up.
      - Builds the tarballs and zips of GAP and its packages.
      - Writes a file `MANIFEST` which contains a list of all files to be uploaded.
   3. Run `make_github_release.py vX.Y.Z tmp/` from the GAP root directory; `tmp/` is the path to the temporary directory created by `make_archives.py`.
      - Creates the release on GitHub which matches the tag.
      - Uploads the archives listed in the `MANIFEST` file as assets, along with a corresponding `.sha256` file.
   4. Create some Windows installers and uploads them to the GitHub release, too. A Windows computer is required for this step.
5. Access your local clone of the `GapWWW` repository.
6. Make sure that your clone is up to date with `gap-system/GapWWW`.
7. Check out the master branch.
8. Run `update_website.py` in root directory of `GapWWW` (see `update_website.py --help`). This:
   - Fetches the GitHub releases data from `gap-system/gap`.
   - Deletes, modifies, and adds various JSON and HTML files according to this data.
9. Inspect the changes, and commit and push them to the master branch to `gap-system/GapWWW`.
10. Run `GapWWW`'s `etc/extract-manuals.py` script as internally documented, and move its resulting `Manuals` directory to the `~/test.gap-system.org` directory of the GAP web server, overwriting the existing one.
11. Deploy <https://test.gap-system.org>, as described in the `README` of `GapWWW`.
12. Check that <https://test.gap-system.org> is functioning as expected.
13. Repeat the final three steps, but with `www` instead of `test`.


## GitHub access token
<a name="github-access-token"></a>

Various scripts in the same folder as this README need limited read/write access to the GAP repository in order to interact with the GitHub API, including to create a release and upload release archives. In order to do this, the scripts need to authenticate with GitHub, for which is reuired a so-called "personal access token".
You can generate such a token as follows (see also [the GitHub documentation](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token)):

1. Go to <https://github.com/settings/tokens>.
2. Click **Generate new token**.
3. Select the scope "public_repo", and give your token a descriptive name.
4. Click **Generate token** at the bottom of the page.
5. Copy the token to your clipboard. For security reasons, after you navigate off the page, you will not be able to see the token again. You therefore should store the token somewhere, such as in the file mentioned in option 4 of the forthcoming list.

The scripts that require an access token look for one in the following places, with the following precedence:
1. The argument `--token`, if supported and given.
2. The environment variable `GITHUB_TOKEN`, if set.
3. The current git configuration, via `git config --get github.token`.
4. The contents of the file `~/.github_shell_token`, if existent and non-empty.
