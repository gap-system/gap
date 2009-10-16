##########################################################################
##
##	kbtest.g
##	Testing for: 
##		- Knuth Bendix Rewriting System implementation
##		- Todd Coxter
##
##########################################################################
##########################################################################

# (things that take more than a few seconds are preeceded by # ) 

##################################
#	Basic finite examples
#
##################################

f := FreeSemigroup("x1","x2");;
x1 := GeneratorsOfSemigroup(f)[1];;
x2 := GeneratorsOfSemigroup(f)[2];;
g := f/[[x1^2,x1],[x2^2,x2],[x1*x2,x2*x1]];;
y1 := GeneratorsOfSemigroup(g)[1];;
y2 := GeneratorsOfSemigroup(g)[2];;
y1*y2 = y2*y1;											# true
y1 = y2;														# false
Elements(g);												# [ x1, x2, x1*x2 ] 
k := KnuthBendixRewritingSystem(g);;
IsConfluent(k); 										# true
phi := IsomorphismTransformationSemigroup(g);;
Size(Source(phi)) = Size(Range(phi));		# true
csi := HomomorphismTransformationSemigroup(g,
	RightMagmaCongruenceByGeneratingPairs(g, [[y1,y2]]));;
Size(Source(csi)) >= Size(Range(csi));		# true	

f:=FreeSemigroup(2);
x:=GeneratorsOfSemigroup(f);
r:=[ [x[1]*x[2],x[1]],[x[1]*x[2],x[2]] ];
g:=f/r;;
k:=KnuthBendixRewritingSystem(g);
IsReduced(k);												# false
IsConfluent(k);											# false
MakeConfluent(k);
IsReduced(k);												# true
IsConfluent(k);											# true
Elements(g);												# [ s1 ]
Rules(k);														# [ [ s2, s1 ], [ s1^2, s1 ] ]
phi:=IsomorphismTransformationSemigroup(g);
Elements(Range(phi)); 							# [ Transformation( [ 2, 2 ] ) ]

#################################
# Examples from Sims' book
#################################

# example 5.1, page 72
######################
f:=FreeMonoid("a","b","c","d");
a:=GeneratorsOfMonoid(f)[1];
b:=GeneratorsOfMonoid(f)[2];
c:=GeneratorsOfMonoid(f)[3];
d:=GeneratorsOfMonoid(f)[4];
e:=Identity(f);
m:=f/[ [a*b,e],[b*a,e],[c*d,e],[d*c,e],[c*a,a*c] ];
k:=KnuthBendixRewritingSystem(m);
Rules(k);
MakeConfluent(k);		
time; 															# 430
Rules(k);
# Elements(m); 			# this should not stop, because semigroup is infinite. 
 
# example 5.3, page 72
######################
f:=FreeMonoid("a","b");
a:=GeneratorsOfMonoid(f)[1];
b:=GeneratorsOfMonoid(f)[2];
e:=Identity(f);
m:=f/[[a*a,e],[b*b*b,e],[a*b*a*b*a*b,e]];
k:=KnuthBendixRewritingSystem(m);
Rules(k);
MakeConfluent(k);							# time = 400
Rules(k);
Elements(m);									# [ <identity ...>, a, b, a*b, b*a, b^2, 
															# a*b*a, a*b^2, b*a*b, b^2*a, b*a*b^2, b^2*a*b ]
time;													# 630
Size(m);											# 12
phi:=IsomorphismTransformationSemigroup(m);
Size(Range(phi));							# 12

# example 5.4, page 73
######################
f:=FreeMonoid("a","b","c");
a:=GeneratorsOfMonoid(f)[1];
b:=GeneratorsOfMonoid(f)[2];
c:=GeneratorsOfMonoid(f)[3];
e:=Identity(f);
m:=f/[[a*a,e],[b*c,e],[b*b*b,e],[a*b*a*b*a*b,e]];
k:=KnuthBendixRewritingSystem(m);
Rules(k);
MakeConfluent(k);							#	1020
Rules(k);
Elements(m);									# [ <identity ...>, a, b, c, a*b, a*c, b*a, 
															# c*a, a*b*a, a*c*a, b*a*c, c*a*b ]
time;													# 1040
Size(m);											# 12
phi:=IsomorphismTransformationSemigroup(m);
Size(Range(phi));							# 12

##############################################################
#
# Examples with well-know groups and semigroups
#
##############################################################

# C4
##############
f:=FreeMonoid("a","b","c");
a:=GeneratorsOfMonoid(f)[1];
b:=GeneratorsOfMonoid(f)[2];
c:=GeneratorsOfMonoid(f)[3];
c4:=f/[ [a*a,a],[b*b,b],[c*c,c],
  [a*b*a,b*a*b],[b*a*b,b*a],[b*c*b,c*b*c],[c*b*c,c*b],
  [a*c,c*a]];
Size(c4);  										# 14
time;													# 2430
Elements(c4);									# [ <identity ...>, a, b, c, a*b, a*c, b*a, 
															# b*c, c*b, a*b*c, a*c*b, b*a*c, c*b*a, b*a*c*b ]
phi:=IsomorphismTransformationSemigroup(m);
Size(Range(phi));             # 12

#	C5 
##############
f:=FreeMonoid("a","b","c","d");
a:=GeneratorsOfMonoid(f)[1];
b:=GeneratorsOfMonoid(f)[2];
c:=GeneratorsOfMonoid(f)[3];
d:=GeneratorsOfMonoid(f)[4];
c5:=f/[ [a*a,a],[b*b,b],[c*c,c],[d*d,d],
  [a*b*a,b*a*b],[b*a*b,b*a],[b*c*b,c*b*c],[c*b*c,c*b],
  [c*d*c,d*c*d],[d*c*d,d*c],
  [a*c,c*a],[a*d,d*a],[b*d,d*b]];
# Size(c5);											# 42
# time;													# 22460
phi := IsomorphismTransformationSemigroup( c5 );
Size( Range(phi) );						# 42
time;													# 40

# C6
##############
f:=FreeMonoid("a","b","c","d","e");
a:=GeneratorsOfMonoid(f)[1];
b:=GeneratorsOfMonoid(f)[2];
c:=GeneratorsOfMonoid(f)[3];
d:=GeneratorsOfMonoid(f)[4];
e:=GeneratorsOfMonoid(f)[5];
c6:=f/[ [a*a,a],[b*b,b],[c*c,c],[d*d,d],[e*e,e],
  [a*b*a,b*a*b],[b*a*b,b*a],[b*c*b,c*b*c],[c*b*c,c*b],
  [c*d*c,d*c*d],[d*c*d,d*c],[d*e*d,e*d*e],[e*d*e,e*d],
  [a*c,c*a],[a*d,d*a],[b*d,d*b],[a*e,e*a],[b*e,e*b],[c*e,e*c]];
# Elements(c6);		
# time;													# 203970  
# Size(c6); 										# 132 
phi := IsomorphismTransformationSemigroup( c6 );
Size( Range(phi) );           # 132 
time;                         # 420 


# C7
##############
m:=FreeMonoid("a","b","c","d","e","f");
a:=GeneratorsOfMonoid(m)[1];
b:=GeneratorsOfMonoid(m)[2];
c:=GeneratorsOfMonoid(m)[3];
d:=GeneratorsOfMonoid(m)[4];
e:=GeneratorsOfMonoid(m)[5];
f:=GeneratorsOfMonoid(m)[6];
c7:=m/[ [a*a,a],[b*b,b],[c*c,c],[d*d,d],[e*e,e],[f*f,f],
  [a*b*a,b*a*b],[b*a*b,b*a],[b*c*b,c*b*c],[c*b*c,c*b],
  [c*d*c,d*c*d],[d*c*d,d*c],[d*e*d,e*d*e],[e*d*e,e*d],
	[e*f*e,f*e*f],[f*e*f,f*e],
  [a*c,c*a],[a*d,d*a],[b*d,d*b],[a*e,e*a],[b*e,e*b],[c*e,e*c],
	[a*f,f*a],[b*f,f*b],[c*f,f*c],[d*f,f*d] ];
# Size(c7); 										# 429 
phi := IsomorphismTransformationSemigroup( c7 );
Size( Range(phi) );           # 429 
time;                         # 4570 

# C4+
##############
f:=FreeMonoid("a","b","c");
a:=GeneratorsOfMonoid(f)[1];
b:=GeneratorsOfMonoid(f)[2];
c:=GeneratorsOfMonoid(f)[3];
c4plus:=f/[ [a*a,a],[b*b,b],[c*c,c],
  [a*b*a,b*a*b],[b*a*b,a*b],[b*c*b,c*b*c],[c*b*c,b*c],
  [a*c,c*a]];
Size(c4plus);									# 14
time;													# 2270
phi := IsomorphismTransformationSemigroup( c4plus );
Size( Range(phi) );           # 14 
time;                         # 10 

# C5+
##############
f:=FreeMonoid("a","b","c","d");
a:=GeneratorsOfMonoid(f)[1];
b:=GeneratorsOfMonoid(f)[2];
c:=GeneratorsOfMonoid(f)[3];
d:=GeneratorsOfMonoid(f)[4];
c5plus:=f/[ [a*a,a],[b*b,b],[c*c,c],[d*d,d],
  [a*b*a,b*a*b],[b*a*b,a*b],[b*c*b,c*b*c],[c*b*c,b*c],
  [c*d*c,d*c*d],[d*c*d,c*d],
  [a*c,c*a],[a*d,d*a],[b*d,d*b]];
# Size(c5plus); 								# 42
# time;													# 22090
phi := IsomorphismTransformationSemigroup( c5plus );
Size( Range(phi) );           # 42 
time;                         # 50 

# C6+
##############
f:=FreeMonoid("a","b","c","d","e");
a:=GeneratorsOfMonoid(f)[1];
b:=GeneratorsOfMonoid(f)[2];
c:=GeneratorsOfMonoid(f)[3];
d:=GeneratorsOfMonoid(f)[4];
e:=GeneratorsOfMonoid(f)[5];
c6plus:=f/[ [a*a,a],[b*b,b],[c*c,c],[d*d,d],[e*e,e],
  [a*b*a,b*a*b],[b*a*b,a*b],[b*c*b,c*b*c],[c*b*c,b*c],
  [c*d*c,d*c*d],[d*c*d,c*d],[d*e*d,e*d*e],[e*d*e,d*e],
  [a*c,c*a],[a*d,d*a],[b*d,d*b],[a*e,e*a],[b*e,e*b],[c*e,e*c]];
# Elements(c6plus);	
# time;													# 205200 
# Size(c6plus); 								# 132
phi := IsomorphismTransformationSemigroup( c6plus );
Size( Range(phi) );           # 132 
time;                         # 840 

# C7+
##############
m:=FreeMonoid("a","b","c","d","e","f");
a:=GeneratorsOfMonoid(m)[1];
b:=GeneratorsOfMonoid(m)[2];
c:=GeneratorsOfMonoid(m)[3];
d:=GeneratorsOfMonoid(m)[4];
e:=GeneratorsOfMonoid(m)[5];
f:=GeneratorsOfMonoid(m)[6];
c7plus:=m/[ [a*a,a],[b*b,b],[c*c,c],[d*d,d],[e*e,e],[f*f,f],
  [a*b*a,b*a*b],[b*a*b,a*b],[b*c*b,c*b*c],[c*b*c,b*c],
  [c*d*c,d*c*d],[d*c*d,c*d],[d*e*d,e*d*e],[e*d*e,d*e],
  [e*f*e,f*e*f],[f*e*f,e*f],
  [a*c,c*a],[a*d,d*a],[b*d,d*b],[a*e,e*a],[b*e,e*b],[c*e,e*c],
  [a*f,f*a],[b*f,f*b],[c*f,f*c],[d*f,f*d] ];
# Size(c7plus); 								# 429
# time;													# 1816500 
phi := IsomorphismTransformationSemigroup( c7plus );
Size( Range(phi) );           # 429 
time;                         # 4340 

# O4
##############
f:=FreeSemigroup("a","b","c","x","y","z");
a:=GeneratorsOfSemigroup(f)[1];
b:=GeneratorsOfSemigroup(f)[2];
c:=GeneratorsOfSemigroup(f)[3];
x:=GeneratorsOfSemigroup(f)[4];
y:=GeneratorsOfSemigroup(f)[5];
z:=GeneratorsOfSemigroup(f)[6];
o4:=f/[ [a*a,a],[b*b,b],[c*c,c],
  [a*b*a,b*a*b],[b*a*b,b*a],[b*c*b,c*b*c],[c*b*c,c*b],[a*c,c*a],
	[x*x,x],[y*y,y],[z*z,z],[x*y*x,y*x*y],[y*x*y,x*y],[y*z*y,z*y*z],[z*y*z,y*z],
  [x*z,z*x], [x*a,a],[y*b,b],[z*c,c],[a*x,x],[b*y,y],[c*z,z],
  [a*z,z*a],[b*x,x*b],[c*x,x*c],[c*y,y*c],[y*a,y],[z*b,z],[a*y,a],[b*z,b] ] ;
# Size(o4);											# 34 
# time; 												# 29060 
phi := IsomorphismTransformationSemigroup( o4 );
Size( Range(phi) );           # 34 
time;                         # 40 

# O5
##############
f:=FreeSemigroup("a","b","c","d","x","y","z","w");
a:=GeneratorsOfSemigroup(f)[1];
b:=GeneratorsOfSemigroup(f)[2];
c:=GeneratorsOfSemigroup(f)[3];
d:=GeneratorsOfSemigroup(f)[4];
x:=GeneratorsOfSemigroup(f)[5];
y:=GeneratorsOfSemigroup(f)[6];
z:=GeneratorsOfSemigroup(f)[7];
w:=GeneratorsOfSemigroup(f)[8];
o5:=f/[ [a*a,a],[b*b,b],[c*c,c],[d*d,d],
 	[a*b*a,b*a*b],[b*a*b,b*a],[b*c*b,c*b*c],[c*b*c,c*b],
  [c*d*c,d*c*d],[d*c*d,d*c], [a*c,c*a],[a*d,d*a],[b*d,d*b],
  [x*x,x],[y*y,y],[z*z,z], [x*y*x,y*x*y],[y*x*y,x*y],
	[y*z*y,z*y*z],[z*y*z,y*z], [z*w*z,w*z*w],[w*z*w,z*w],
  [x*z,z*x],[x*w,w*x],[y*w,w*y], [x*a,a],[y*b,b],[z*c,c],[w*d,d],
  [a*x,x],[b*y,y],[c*z,z],[d*w,w], [a*z,z*a],[b*x,x*b],[c*x,x*c],[c*y,y*c],
  [a*w,w*a],[b*w,w*b],[d*x,x*d],[d*y,y*d],[d*z,z*d],
  [y*a,y],[z*b,z],[a*y,a],[b*z,b], [w*c,w],[c*w,c] ];
# Elements(o5);									
# time;													# 628260 
# Size(o5); 										# 125
phi := IsomorphismTransformationSemigroup( o5 );
Size( Range(phi) );           # 125 
time;                         # 510 

# building O5 from transformations 
a1:=Transformation([1,1,3,4,5]);
a2:=Transformation([2,2,3,4,5]);
a3:=Transformation([1,2,2,4,5]);
a4:=Transformation([1,3,3,4,5]);
a5:=Transformation([1,2,3,3,5]);
a6:=Transformation([1,2,4,4,5]);
a7:=Transformation([1,2,3,4,4]);
a8:=Transformation([1,2,3,5,5]);
O5:=Semigroup(a1,a2,a3,a4,a5,a6,a7,a8);
Size(O5);											# 125

# S3
################
f:=FreeMonoid("a","b");
a:=GeneratorsOfMonoid(f)[1];
b:=GeneratorsOfMonoid(f)[2];
e:=Identity(f);
s3:=f/[ [a*a,e],[b*b,e],[a*b*a*b*a*b,e] ];
Elements(s3);	 								# [ <identity ...>, a, b, a*b, b*a, a*b*a ]
time;													# 320 
Size(s3);											# 6
phi := IsomorphismTransformationSemigroup( s3 );
Size( Range(phi) );           # 6 
time;                         # 10

# S4 
################
f:=FreeMonoid("a","b","c");
a:=GeneratorsOfMonoid(f)[1];
b:=GeneratorsOfMonoid(f)[2];
c:=GeneratorsOfMonoid(f)[3];
e:=Identity(f);
s4:=f/[ [a*a,e],[b*b,e],[c*c,e],
[a*b*a*b*a*b,e],[b*c*b*c*b*c,e],[a*c,c*a] ];
Elements(s4);									
time;													# 4770 
Size(s4);											# 24
phi := IsomorphismTransformationSemigroup( s4 );
Size( Range(phi) );           # 24 
time;                         # 10

# S5
################
f:=FreeMonoid("a","b","c","d");
a:=GeneratorsOfMonoid(f)[1];
b:=GeneratorsOfMonoid(f)[2];
c:=GeneratorsOfMonoid(f)[3];
d:=GeneratorsOfMonoid(f)[4];
e:=Identity(f);
s5:=f/[ [a*a,e],[b*b,e],[c*c,e],[d*d,e],
  [a*b*a*b*a*b,e],[b*c*b*c*b*c,e],[c*d*c*d*c*d,e],
  [a*c,c*a],[a*d,d*a],[b*d,d*b]  ];
# Elements(s5);									
# time;													# 102530 
# Size(s5);											# 120
phi := IsomorphismTransformationSemigroup( s5 );
Size( Range(phi) );           # 120
time;                         # 280 

# D3
################
f:=FreeSemigroup("a","b");
a:=GeneratorsOfSemigroup(f)[1];
b:=GeneratorsOfSemigroup(f)[2];
d3:=f/[ [a*a*a,a],[a*a,b*b*b],[a*b*b*a,b]];
Elements(d3);									# [ a, b, a^2, a*b, b*a, b^2 ]
time;													# 240
Size(d3);											# 6
phi := IsomorphismTransformationSemigroup( d3 );
Size( Range(phi) );           # 6 
time;                         # 10
 
#######################
f := FreeSemigroup("x");
x := GeneratorsOfSemigroup(f)[1];
g := f/[[x^100000,x ]];
x := GeneratorsOfSemigroup(g)[1];          
c := RightMagmaCongruenceByGeneratingPairs(g, [[x^100,x]]);
ct := CosetTableOfFpSemigroup(c);
time;
ct := CosetTableOfFpSemigroup(c);
time;

######################
#testing basic wreath product ordering
f := FreeSemigroup("a","b","c","d");;
a := GeneratorsOfSemigroup(f)[1];;
b := GeneratorsOfSemigroup(f)[2];;
c := GeneratorsOfSemigroup(f)[3];;
d := GeneratorsOfSemigroup(f)[4];;
IsBasicWreathLessThanOrEqual( a^3, a*d);					# true
IsBasicWreathLessThanOrEqual( a^3, a^4);					# true
IsBasicWreathLessThanOrEqual( a*b*c*d, a^4);			# false
IsBasicWreathLessThanOrEqual( a*b*c*d, b*b*c*d);	# true
IsBasicWreathLessThanOrEqual( b*b*c*c, d);     		# true 

# the heisenberg group
f := FreeGroup( "gamma", "beta", "alpha");
x := GeneratorsOfGroup( f );
alpha := x[3]; beta := x[2]; gamma := x[1];
r := [];
Add( r, alpha^-1 * beta^-1 * alpha * beta * gamma^-1);
Add( r, alpha^-1 * gamma^-1 * alpha * gamma );
Add( r, beta^-1 * gamma^-1 * beta * gamma );
g := f/r;
phi := IsomorphismFpSemigroup( g );
s := Range( phi );
kbrws := KnuthBendixRewritingSystem( s, IsBasicWreathLessThanOrEqual );
MakeConfluent( kbrws );

