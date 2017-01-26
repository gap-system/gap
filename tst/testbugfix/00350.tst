# 2017-01-09 (MH); see also issue #817
gap> HashKeyBag(4,1,1,-1); # should not crash anymore
4
gap> HashKeyBag(Z(4),1,1,-1); # should not crash anymore
Error, HASHKEY_BAG: <obj> must not be an FFE
