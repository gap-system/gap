# Checked PreImages* variants for a mapping by function with infinite source
# and a preimage function must not compute the whole image.
gap> f := MappingByFunction(Integers, Integers, x->2*x, false, y->y/2);;
gap> PreImagesRepresentative(f, 4);
2
gap> PreImagesRepresentative(f, 3);
fail
gap> PreImagesElm(f, 3);
[  ]
gap> PreImagesSet(f, [ 3, 5 ]);
[  ]
gap> PreImages(f, 3);
[  ]
gap> PreImagesRepresentative(f, 1/2);
Error, <elm> is not in the range of <map>
