# Bug with non-square matrices in ElementaryDivisorsMat, added by MH on 2012/4/3.
# Since ElementaryDivisorsMat just calls SmithNormalFormIntegerMat when
# the base ring R equals Integers, we use GaussianIntegers instead to
# ensure the generic ElementaryDivisorsMat method is tested.
gap> ElementaryDivisorsMat(GaussianIntegers, [ [ 20, -25, 5 ] ]);
[ 5, 0, 0 ]
