gap> START_TEST("atomic_compare.tst");

# Comparisons of atomic lists
gap> a := AtomicList([]);
<atomic list of size 0>
gap> a = a;
true
gap> a < a;
false
gap> b := AtomicList([]);
<atomic list of size 0>
gap> a = b;
Error, atomic lists cannot be compared with other lists
gap> a < b;
Error, atomic lists cannot be compared with other lists
gap> a < 2;
false
gap> 2 < a;
true
gap> a < [1,2,3];
Error, atomic lists cannot be compared with other lists
gap> a < "abc";
Error, atomic lists cannot be compared with other lists
gap> a = 2;
false
gap> a = true;
false
gap> a = false;
false
gap> a = fail;
false
gap> a < true;
false
gap> a = rec();
false
gap> a = AtomicRecord();
false
gap> ShallowCopy(a);
Error, atomic objects cannot be copied
gap> StructuralCopy(a);
Error, atomic objects cannot be copied

# Comparisons of atomic lists
gap> a := FixedAtomicList([]);
<fixed atomic list of size 0>
gap> a = a;
true
gap> a < a;
false
gap> b := FixedAtomicList([]);
<fixed atomic list of size 0>
gap> a = b;
Error, atomic lists cannot be compared with other lists
gap> a < b;
Error, atomic lists cannot be compared with other lists
gap> a < 2;
false
gap> 2 < a;
true
gap> a < [1,2,3];
Error, atomic lists cannot be compared with other lists
gap> a < "abc";
Error, atomic lists cannot be compared with other lists
gap> a = 2;
false
gap> a = true;
false
gap> a = false;
false
gap> a = fail;
false
gap> a < true;
false
gap> a = rec();
false
gap> a = AtomicRecord();
false
gap> ShallowCopy(a);
Error, atomic objects cannot be copied
gap> StructuralCopy(a);
Error, atomic objects cannot be copied
gap> AtomicList([]) = FixedAtomicList([]);
Error, atomic lists cannot be compared with other lists
gap> AtomicList([]) < FixedAtomicList([]);
Error, atomic lists cannot be compared with other lists

# Atomic Records
gap> a := AtomicRecord(rec());
rec(  )
gap> a = a;
true
gap> a < a;
false
gap> b := AtomicRecord(rec());
rec(  )
gap> a = b;
Error, atomic records cannot be compared with other records
gap> a < b;
Error, atomic records cannot be compared with other records
gap> a < 2;
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `<' on 2 arguments
gap> 2 < a;
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `<' on 2 arguments
gap> a < [1,2,3];
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `<' on 2 arguments
gap> a = 2;
false
gap> a = [1,2,3];
false
gap> a = true;
false
gap> a = false;
false
gap> a = fail;
false
gap> a < true;
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `<' on 2 arguments
gap> a < false;
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `<' on 2 arguments
gap> a < fail;
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `<' on 2 arguments
The 2nd argument is 'fail' which might point to an earlier problem
gap> true < a;
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `<' on 2 arguments
gap> false < a;
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `<' on 2 arguments
gap> fail < a;
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `<' on 2 arguments
The 1st argument is 'fail' which might point to an earlier problem
gap> ShallowCopy(a);
Error, atomic objects cannot be copied
gap> StructuralCopy(a);
Error, atomic objects cannot be copied

gap> STOP_TEST("atomic_compare.tst");
