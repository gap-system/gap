GAP has three main GAP manuals (they are called "main" to distinguish them from package 
manuals that are maintained by the authors of the respective packages):
* **GAP Tutorial**
* **GAP Reference Manual**
* **Changes from Earlier Versions**

These manuals are written in GAPDoc format, provided by the 
[GAPDoc package](http://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc/index.html). 
Their source is contained in the directories `doc/tut`, `doc/ref` and `doc/changes` 
respectively. Some documentation is also stored in the library files to be kept 
close to the code it describes. It is included in the manual using the mechanism 
documented [here](https://www.gap-system.org/Manuals/pkg/GAPDoc-1.5.1/doc/chap4.html).

The official GAP distribution includes all documentation, so there is no need to 
build it after GAP installation. However, if you need to build the development 
version of main GAP manuals from this repository, you need to perform the following 
steps:
* build GAP by calling `./configure; make`
* ensure that the GAPDoc package is present in the `pkg` subdirectory (for example, 
  by creating a symlink `pkg` pointing to the `pkg` directory of the installation of 
  the latest GAP release).
* build manuals by calling `make doc`

This will build all three manuals. Each of them will be built twice to ensure that 
cross-references between manuals are resolved. The build log will be saved in 
`make_manuals.out` files in each of the three directories `changes`, `ref` and `tut`. 
You may check it for further warnings, for example, about unresolved references. 

Each of these three directories contains a file `makedocrel.g`. You may read it into 
GAP if you want to build faster just one manual to see how your changes look like, 
or if GAPDoc reports an error in the XML code that you want to debug. Then you may 
call `make doc` as a final check at a later stage.
