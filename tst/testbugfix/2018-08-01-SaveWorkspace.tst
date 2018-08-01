#
# SaveWorkspace used to return 'true' even if it failed to open the
# output file. Also, the error message was not trailed by a newline.
# See https://github.com/gap-system/gap/issues/2673
gap> SaveWorkspace("fantasy-dir/test");
Couldn't open file fantasy-dir/test to save workspace
fail
