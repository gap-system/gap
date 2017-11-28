These tests are designed to check the GAP -> C compiler

./run_compiled_dynamic.sh : Run a single test, after compiling it
   into a dynamic module and loading it
./run_compiled_static.sh : Run a single test, after compiling it
   into a static module and loading it
./run_interpreted.sh : Run a single test without compiling it

./run_all.sh : Run all tests with and without compiling
./regenerate_tests.sh : Regenerate the '.out' files
