These tests are designed to check GAP's output in the break loop.

Most of the cleverness is in ./run_gap.sh, where we make sure we capture
all of GAP's output, stop GAP attaching to the terminal, and rewrite any
filenames which occur in output.

./run_gap.sh : This runs GAP, capturing it's input/output
./run_error_tests.sh : This runs all the tests
./regenerate_error_tests.sh : Regenerate all outputs
