These tests are designed to check the GAP -> C compiler

Most of the cleverness is in ./run_single_compiled_test.sh, which
compiles a GAP file using gac, loads it into GAP, and then runs
a function 'runtest'.

./run_single_compiled_test.sh : Run a single test, after compiling it
./run_single_test.sh : Run a single test without compiling it
./run_compile_tests.sh : Run all tests with and without compiling
./regenerate_tests.sh : Regenerate the '.out' files
