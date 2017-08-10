gap> START_TEST("hashkeybag.tst");
gap> HashKeyBag((1,2),0,0,0);
0
gap> HashKeyBag([1,2,3],0,0,0);
0
gap> IsSmallIntRep(HashKeyBag([1,2,3],0,0,100));
true
gap> HashKeyBag([1,2,3],0,0,1000) = HashKeyBag([1,2,3],0,0,-1);
true
gap> HashKeyBag([1,2,3],0,0,1000) = HashKeyBag([1,2,3],0,0,2000);
true
gap> HashKeyBag([1,2,3],0,0,-1) = HashKeyWholeBag([1,2,3],0);
true
gap> HashKeyBag([1,2,3],-99,0,-1) = HashKeyWholeBag([1,2,3],-99);
true
gap> HashKeyBag([1,2,3],0,1,-1) <> HashKeyWholeBag([1,2,3],0);
true
gap> HashKeyBag((1,2),0,0,1) <> HashKeyBag((1,2),1,0,1);
true
gap> HashKeyBag((1,2),0,0,1) <> HashKeyBag((1,2),1,1,1);
true
gap> HashKeyBag((1,2),0,0,1) <> HashKeyBag((1,2),1,0,2);
true
gap> STOP_TEST("hashkeybag.tst");

