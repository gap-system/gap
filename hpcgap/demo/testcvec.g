LoadPackage("UnitTests");
dir := DirectoriesLibrary("demo");

# Run parametrized test suites

# The 1st argument q is the order of the field GF(q)
# The 2nd argument is the length of the vector

for q in [2,3,5] do
  for d in [1..3] do
    if d<>3 or q<256 then
      Print("===================================\n");
      Print("Testing q = ", q, " and d = ", d, "\n");
      suite := InstantiateTestSuite(Filename(dir,"testcvec.unit"), q, d );
      RunTestSuite(suite);
    fi;
  od;
od;
