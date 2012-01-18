#############################################################################
##
#A  testall.tst            Example package                Alexander Konovalov
##
##  To create a test file, place GAP prompts, input and output exactly as
##  they must appear in the GAP session. Do not remove lines containing 
##  START_TEST and STOP_TEST statements.
##
##  The first line starts the test. START_TEST reinitializes the caches and 
##  the global random number generator, in order to be independent of the 
##  reading order of several test files. Furthermore, the assertion level 
##  is set to 2 by START_TEST and set back to the previous value in the 
##  subsequent STOP_TEST call.
##
##  The argument of STOP_TEST may be an arbitrary identifier string.
## 
gap> START_TEST("Example package: testall.tst");

# Note that you may use comments in the test file
# and also separate parts of the test by empty lines

# First load the package without banner (the banner must be suppressed to 
# avoid reporting discrepancies in the case when the package is already 
# loaded)
gap> LoadPackage("example",false);
true

# Check that the data are consistent  
gap> a:=Set(RecNames(FruitCake));
[ "cookingTime", "ingredients", "method", "name", "notes", "ovenTemp", "tin" ]
gap> List(a, t -> Length(FruitCake.(t)));
[ 17, 9, 6, 10, 2, 16, 46 ]


#############################################################################
# tasting the FruitCake :)
gap> Recipe( FruitCake );

                               Fruit Cake Recipe

Notes:
1. 1 cup is approx. 225ml
2. 1 bottle is 750ml

Oven Temp: 160 C then 150 C.

Cooking Time: 2/3 + 1 1/2 hours.

Tin: 18cm square or 20cm round, greased and papered.

Ingredients:
            3/4 cup sugar (optional)
            1/3 bottle brandy
    2 1/2 + 1/3 cups mixed fruit + mixed peel + glace cherries + figs
              1 tsp nutmeg (or mixed spice)
              1 tsp bicarbonate of soda (NaHCO3)
      1/2 - 3/4 cup butter (125g - 200g)
              2 beaten eggs
              1 cup SR flour (i.e. flour with yeast added)
              1 cup plain flour

Method:
1. Preheat oven to 160 C.
2. Collect ingredients.
3. In a saucepan place (sugar,) water, fruit, peel,  cherries,  diced
   figs, nutmeg, soda, brandy and butter and stir them until boiling.
   Allow to cool for 5 minutes.
4. Sift flours and stir in the flour and eggs, and mix thoroughly.
5. Place in  tin  and  bake  at 160 C  for  40 minutes.  Then reduce
   temperature to 150 C and continue to bake cake for 1 1/2 hours.
6. Allow to stand in tin for 15 mins. Then turn on to cake rack to cool.

## The first argument of STOP_TEST should be the name of the test file.
## The number is a proportionality factor that is used to output a 
## "GAPstone" speed ranking after the file has been completely processed.
## For the files provided with the distribution this scaling is roughly 
## equalized to yield the same numbers as produced by the test file 
## tst/combinat.tst. For package tests, you may leave it unchnaged. 
gap> STOP_TEST( "testall.tst", 10000 );

#############################################################################
##
#E
