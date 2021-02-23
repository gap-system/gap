# How To Make a GAP Release for version 4.X.Y
 
**This release process assumes the following**
- A stable branch of GAP has been identified or agreed upon. This branch will be identified here as `stable-4.X.Y` and the Release Notes in Changes.md have been created.
- You have a clone of the [GAP repository](https://github.com/gap-system/gap)
- You can compile this version of GAP (some dependencies for that are listed below, more might be need)
- You have a clone of the [GapWWW repository](https://github.com/gap-system/GapWWW)

## Dependencies
Before starting the release process, the scripts have the following dependencies. Make sure you have the following installed and up to date
- Python (version >=3.6) which can be installed using your favourite package manager or from [Python.org](https://www.python.org)
### Python Modules
The following (non-standard) python modules need to be installed, you can do this using `pip3` (`pip3 install <MODULENAME>`)
- `PyGithub`
- `requests`
- `python-dateutil`

### Command line tools
The following command line tools are needed, please install them using your favourite package manager
- `curl`
- `git`
- `make`
- `autoconf`

## Release Process -- The quick guide

If the GitHub token is in an ENVIRONMENT variable called `GITHUB_TOKEN` then nothing needs to be done. 
Otherwise a flag containing the token is needed when running `make_github_release.py`.


1. Go into the gap-system/gap (repository) directory 
2. Commit and tag release in git (using command line)
    ```
    git tag -m "Version Z.X.Y" vZ.X.Y
    git push --tags
    ```  
    Note that `Z` will most likely be 4.
3. Run `make_tarball.py`
4. Run `make_github_release.py`
5. Change to the gap-system/GapWWW (repository) directory
6. Run `update_website.py` 
7. [optional] Remove the `tmp` directories (in GapWWW and gap directories)

## Release Process -- The more detailed guide

If the GitHub token is in an ENVIRONMENT variable called `GITHUB_TOKEN` then nothing needs to be done. 
Otherwise a flag containing the token is needed when running `make_github_release.py`.


1. Go into the gap-system/gap (repository) directory  
    This should be obvious why
2. Commit and tag release in git (using command line)  
    ```
    git tag -m "Version Z.X.Y" vZ.X.Y
    git push --tags
    ```
    Note that `Z` will most likely be 4.
3. Run `make_tarball.py`  
    - Exports repository content into new tmp directory via `git archive`
    - Makes and configures GAP to check that it is available (and this is needed for the manuals)
    - Fetches the pkg tar ball
    - Builds the manuals
    - Cleans everything up
    - Builds the tar ball(s) and checksum files
4. Run `make_github_release.py`  
    - Creates the release on GitHub which matches the tag
    - Uploads the tar balls as assets 
    - Removes the tmp directory from user
5. Change to the gap-system/GapWWW (repository) directory  
   This should be obvious why
6. Run `update_website.py` 
   - Fetches the release assets, extracts and configures/builds GAP in a tmp directory
   - Extracts info from the built and rewrites various YAML files
   - Extracts info about packages and updates YAML files
   - Commits, pushes and creates pull request to GapWWW
7. [optional] Remove the `tmp` directories (in GapWWW and gap directories)