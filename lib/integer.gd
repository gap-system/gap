#############################################################################
##
#W  integer.gd                  GAP library                     Werner Nickel
#W                                                           & Alice Niemeyer
#W                                                         & Martin Schoenert
#W                                                              & Alex Wegner
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file declares the operations for integers.
##
Revision.integer_gd :=
    "@(#)$Id$";


#############################################################################
##

#C  IsIntegers  . . . . . . . . . . . . . . . defining category of 'Integers'
#V  Integers  . . . . . . . . . . . . . . . . . . . . .  ring of the integers
##
IsIntegers := NewCategory( "IsIntegers",
    IsEuclideanRing and IsFLMLOR );
Integers := "2b defined";


#############################################################################
##

#C  IsGaussianIntegers  . . . . . . . defining category of 'GaussianIntegers'
#V  GaussianIntegers  . . . . . . . . . . . . . . . ring of Gaussian integers
##
IsGaussianIntegers := NewCategory( "IsGaussianIntegers",
    IsEuclideanRing and IsFLMLOR );
GaussianIntegers := "2b defined";


#############################################################################
##

#V  Primes  . . . . . . . . . . . . . . . . . . . . . .  list of small primes
##
##  'Primes' is a strictly sorted list of the 168 primes less than 1000.
##
##  This is used in 'IsPrimeInt' and 'FactorsInt' to cast out small primes
##  quickly.
##
Primes := Immutable(
  [   2,  3,  5,  7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61,
     67, 71, 73, 79, 83, 89, 97,101,103,107,109,113,127,131,137,139,149,151,
    157,163,167,173,179,181,191,193,197,199,211,223,227,229,233,239,241,251,
    257,263,269,271,277,281,283,293,307,311,313,317,331,337,347,349,353,359,
    367,373,379,383,389,397,401,409,419,421,431,433,439,443,449,457,461,463,
    467,479,487,491,499,503,509,521,523,541,547,557,563,569,571,577,587,593,
    599,601,607,613,617,619,631,641,643,647,653,659,661,673,677,683,691,701,
    709,719,727,733,739,743,751,757,761,769,773,787,797,809,811,821,823,827,
    829,839,853,857,859,863,877,881,883,887,907,911,919,929,937,941,947,953,
    967,971,977,983,991,997 ] );


#############################################################################
##
#V  Primes2 . . . . . . . . . . . . . . . . . . . . . . additional prime list
##
##  'Primes2' contains those primes found by 'IsPrimeInt' that are not in
##  'Primes'.  'Primes2' is kept sorted, but may contain holes.
##
##  'IsPrimeInt' and 'FactorsInt' use this list to  cast out already found
##  primes quickly.
##  If 'IsPrimeInt' is called only for random integers this list would be
##  quite useless.
##  However, users do not behave randomly.
##  Instead, it is not uncommon to factor the same integer twice.
##  Likewise, once we have tested that $2^{31}-1$ is prime, factoring
##  $2^{62}-1$ is very cheap, because the former divides the latter.
#T I do not catch the point: $2^{62}-1$ is not a prime because $62$ is not
#T a prime, no matter whether we have tested whether $2^{31}-1$ is prime ...
##
##  This list is initialized to contain all the prime factors of the integers
##  $2^n-1$ with $n < 201$,  $3^n-1$ with $n < 101$,  $5^n-1$ with $n < 101$,
##  $7^n-1$ with $n < 91$, $11^n-1$ with $n < 79$, and $13^n-1$ with $n < 37$
##  that are larger than $10^7$.
##
Primes2 := [
10047871, 10567201, 10746341, 12112549, 12128131, 12207031, 12323587,
12553493, 12865927, 13097927, 13264529, 13473433, 13821503, 13960201,
14092193, 14597959, 15216601, 15790321, 16018507, 18837001, 20381027,
20394401, 20515111, 20515909, 21207101, 21523361, 22253377, 22366891,
22996651, 23850061, 25781083, 26295457, 28325071, 28878847, 29010221,
29247661, 29423041, 29866451, 32234893, 32508061, 36855109, 41540861,
42521761, 43249589, 44975113, 47392381, 47763361, 48544121, 48912491,
49105547, 49892851, 51457561, 55527473, 56409643, 56737873, 59302051,
59361349, 59583967, 60816001, 62020897, 65628751, 69566521, 75068993,
76066181, 85280581, 93507247, 96656723, 97685839,
106431697, 107367629, 109688713, 110211473, 112901153, 119782433, 127540261,
134818753, 134927809, 136151713, 147300841, 160465489, 164511353, 177237331,
183794551, 184481113, 190295821, 190771747, 193707721, 195019441, 202029703,
206244761, 212601841, 212885833, 228511817, 231769777, 234750601, 272010961,
283763713, 297315901, 305175781, 308761441, 319020217, 359390389, 407865361,
420778751, 424256201, 432853009, 457315063, 466344409, 510810301, 515717329,
527093491, 529510939, 536903681, 540701761, 550413361, 603926681, 616318177,
632133361, 715827883, 724487149, 745988807, 815702161, 834019001, 852133201,
857643277, 879399649,
1001523179, 1036745531, 1065264019, 1106131489, 1169382127, 1390636259,
1503418321, 1527007411, 1636258751, 1644512641, 1743831169, 1824179209,
1824726041, 1826934301, 1866013003, 1990415149, 2127431041, 2147483647,
2238236249, 2316281689, 2413941289, 2481791513, 2550183799, 2576743207,
2664097031, 2767631689, 2903110321, 2931542417, 3158528101, 3173389601,
3357897971, 4011586307, 4058036683, 4278255361, 4375578271, 4562284561,
4649919401, 4698932281, 4795973261, 4885168129, 5960555749, 6809710909,
7068569257, 7151459701, 7484047069, 7685542369, 7830118297, 7866608083,
8209475377, 8831418697, 9598959833,
10879733611, 11898664849, 12447002677, 13455809771, 13564461457, 13841169553,
13971969971, 14425532687, 15085812853, 15768033143, 15888756269, 16148168401,
17154094481, 17189128703, 19707683773, 22434744889, 23140471537, 23535794707,
24127552321, 25480398173, 25829691707, 25994736109, 27669118297, 27989941729,
28086211607, 30327152671, 32952799801, 33057806959, 35532364099, 39940132241,
43872038849, 45076044553, 47072139617, 50150933101, 54410972897, 56625998353,
60726444167, 61070817601, 62983048367, 70845409351, 76831835389, 77158673929,
77192844961, 78009515593, 83960385389, 86950696619, 88959882481, 99810171997,
115868130379, 125096112091, 127522693159, 128011456717, 128653413121,
131105292137, 152587500001, 158822951431, 159248456569, 164504919713,
165768537521, 168749965921, 229890275929, 241931001601, 269089806001,
282429005041, 332207361361, 374857981681, 386478495679, 392038110671,
402011881627, 441019876741, 447600088289, 487824887233, 531968664833,
555915824341, 593554036769, 598761682261, 641625222857, 654652168021,
761838257287, 810221830361, 840139875599, 918585913061,
1030330938209, 1047623475541, 1113491139767, 1133836730401, 1273880539247,
1534179947851, 1628744948329, 1654058017289, 1759217765581, 1856458657451,
2098303812601, 2454335007529, 2481357870461, 2549755542947, 2663568851051,
2879347902817, 2932031007403, 3138426605161, 3203431780337, 3421169496361,
3740221981231, 4363953127297, 4432676798593, 4446437759531, 4534166740403,
4981857697937, 5625767248687, 6090817323763, 6493405343627, 6713103182899,
6740339310641, 7432339208719, 8090594434231, 8157179360521, 8737481256739,
8868050880709, 9361973132609, 9468940004449, 9857737155463,
10052678938039, 10979607179423, 13952598148481, 15798461357509,
18158209813151, 22125996444329, 22542470482159, 22735632934561,
23161037562937, 23792163643711, 24517014940753, 24587411156281,
28059810762433, 29078814248401, 31280679788951, 31479823396757,
33232924804801, 42272797713043, 44479210368001, 45920153384867,
49971617830801, 57583418699431, 62911130477521, 67280421310721,
70601370627701, 71316922984999, 83181652304609, 89620825374601,
110133112994711, 140737471578113, 145295143558111, 150224123975857,
204064664440913, 205367807127911, 242099935645987, 270547105429567,
303567967057423, 332584516519201, 434502978835771, 475384700124973,
520518327319589, 560088668384411, 608459012088799, 637265428480297,
643170158708221, 707179356161321, 926510094425921, 990643452963163,
1034150930241911, 1066818132868207, 1120648576818041, 1357105535093947,
1416258521793067, 1587855697992791, 1611479891519807, 1628413557556843,
1958423494433591, 2134387368610417, 2646507710984041, 2649263870814793,
2752135920929651, 2864226125209369, 4889988840047743, 5420506947192709,
6957533874046531, 9460375336977361, 9472026608675509,
12557612956332313, 13722816749522711, 14436295738510501, 18584774046020617,
18624275418445601, 20986207825565581, 21180247636732981, 22666879066355177,
27145365052629449, 46329453543600481, 50544702849929377, 59509429687890001,
60081451169922001, 70084436712553223, 76394148218203559, 77001139434480073,
79787519018560501, 96076791871613611,
133088039373662309, 144542918285300809, 145171177264407947,
153560376376050799, 166003607842448777, 177722253954175633,
196915704073465747, 316825425410373433, 341117531003194129,
380808546861411923, 489769993189671059, 538953023961943033,
581283643249112959, 617886851384381281, 625552508473588471,
645654335737185721, 646675035253258729, 658812288653553079,
768614336404564651, 862970652262943171, 909456847814334401,
1100876018364883721, 1195857367853217109, 1245576402371959291,
1795918038741070627, 2192537062271178641, 2305843009213693951,
2312581841562813841, 2461243576713869557, 2615418118891695851,
2691614274040036601, 3011347479614249131, 3358335487319458201,
3421093417510114543, 3602372010909260861, 3747607031112307667,
3999088279399464409, 4710883168879506001, 5079304643216687969,
5559917315850179173, 5782172113400990737, 6106505825833677713,
6115909044841454629, 9213624084535989031, 9520972806333758431,
10527743181888260981, 14808607715315782481, 18446744069414584321,
26831423036065352611, 32032215596496435569, 34563155350221618511,
36230454570129675721, 58523123221688392679, 82064241848634269407,
86656268566282183151, 87274497124602996457,
157571957584602258799, 162715052426691233701, 172827552198815888791,
195489390796456327201, 240031591394168814433, 344120456368919234899,
358475907408445923469, 846041103974872866961,
2519545342349331183143, 3658524738455131951223, 3976656429941438590393,
5439042183600204290159, 8198241112969626815581,
11600321878916922053491, 12812432238302009985937, 17551032119981679046729,
18489605314740987765913, 27665283091695977275201, 42437717969530394595211,
57912614113275649087721, 61654440233248340616559, 63681511996418550459487,
105293313660391861035901, 155285743288572277679887, 201487636602438195784363,
231669654363683130095909, 235169662395069356312233, 402488219476647465854701,
535347624791488552837151, 604088623657497125653141, 870035986098720987332873,
950996059627210897943351,
1412900479108654932024439, 1431185706701868962383741,
2047572230657338751575051, 2048568835297380486760231,
2741672362528725535068727, 3042645634792541312037847,
3745603812007166116831643, 4362139336229068656094783,
4805345109492315767981401, 5042939439565996049162197,
7289088383388253664437433, 8235109336690846723986161,
9680647790568589086355559, 9768997162071483134919121,
9842332430037465033595921,
11053036065049294753459639, 11735415506748076408140121,
13842607235828485645766393, 17499733663152976533452519,
26273701844015319144827917, 75582488424179347083438319,
88040095945103834627376781,
100641220283951395639601683, 140194179307171898833699259,
207617485544258392970753527, 291280009243618888211558641,
303309617049998388989376043, 354639323684545612988577649,
618970019642690137449562111, 913242407367610843676812931,
7222605228105536202757606969, 7248808599285760001152755641,
8170509011431363408568150369, 8206973609150536446402438593,
9080418348371887359375390001,
14732265321145317331353282383, 15403468930064931175264655869,
15572244900182528777225808449, 18806327041824690595747113889,
21283620033217629539178799361, 37201708625305146303973352041,
42534656091583268045915654719, 48845962828028421155731228333,
123876132205208335762278423601, 134304196845099262572814573351,
172974812463239310024750410929, 217648180992721729506406538251,
227376585863531112677002031251,
1786393878363164227858270210279, 2598696228942460402343442913969,
2643999917660728787808396988849, 3340762283952395329506327023033,
5465713352000770660547109750601,
28870194250662203210437116612769, 70722308812401674174993533367023,
78958087694609321439660131899631, 88262612316754526107621113329689,
162259276829213363391578010288127, 163537220852725398851434325720959,
177635683940025046467781066894531,
2679895157783862814690027494144991, 3754733257489862401973357979128773,
5283012903770196631383821046101707, 5457586804596062091175455674392801,
10052011757370829033540932021825161, 11419697846380955982026777206637491,
38904276017035188056372051839841219,
1914662449813727660680530326064591907, 7923871097285295625344647665764672671,
9519524151770349914726200576714027279,
10350794431055162386718619237468234569,
170141183460469231731687303715884105727,
1056836588644853738704557482552056406147,
6918082374901313855125397665325977135579,
235335702141939072378977155172505285655211,
360426336941693434048414944508078750920763,
1032670816743843860998850056278950666491537,
1461808298382111034194027645506019619578037,
79638304766856507377778616296087448490695649,
169002145064468556765676975247413756542145739,
8166146875847876762859119015147004762656450569,
18607929421228039083223253529869111644362732899,
33083146850190391025301565142735000331370209599,
138497973518827432485604572537024087153816681041,
673267426712748387612994804392183645147042355211,
1489459109360039866456940197095433721664951999121,
4884164093883941177660049098586324302977543600799,
466345922275629775763320748688970211803553256223529,
26828803997912886929710867041891989490486893845712448833,
153159805660301568024613754993807288151489686913246436306439,
1051153199500053598403188407217590190707671147285551702341089650185945215953
];


#############################################################################
##

#F  AbsInt( <n> ) . . . . . . . . . . . . . . .  absolute value of an integer
##
##  'AbsInt' returns the absolute value of the integer <n>, i.e., <n> if <n>
##  is positive, -<n> if <n> is negative and 0 if <n> is 0 (see "SignInt").
##
AbsInt :=function ( n )
    if 0 <= n  then return  n;
    else            return -n;
    fi;
end;
#T attribute 'Abs' ?
#T should be internal method!


#############################################################################
##
#F  BestQuoInt( <n>, <m> )
##
##  'BestQuoInt'  returns the best quotient <q>  of the integers <n> and <m>.
##  This is the quotient such that '<n>-<q>\*<m>' has minimal absolute value.
##  If there are two quotients whose remainders have the same absolute value,
##  then the quotient with the smaller absolute value is choosen.
##
BestQuoInt := NewOperationArgs( "BestQuoInt" );


#############################################################################
##
#F  ChineseRem( <moduli>, <residues> )  . . . . . . . . . . chinese remainder
##
##  'ChineseRem' returns the combination   of   the  <residues>  modulo   the
##  <moduli>, i.e., the  unique integer <c>  from '[0..Lcm(<moduli>)-1]' such
##  that  '<c>  = <residues>[i]' modulo '<moduli>[i]'   for  all  <i>, if  it
##  exists.  If no such combination exists 'ChineseRem' signals an error.
##  
##  Such a combination does exist if and only if
##  '<residues>[<i>]=<residues>[<k>]'  mod 'Gcd(<moduli>[<i>],<moduli>[<k>])'
##  for every pair <i>, <k>.  Note  that this implies that such a combination
##  exists if the  moduli  are pairwise relatively prime.  This is called the
##  Chinese remainder theorem.
##  
ChineseRem := NewOperationArgs( "ChineseRem" );


#############################################################################
##
#F  CoefficientsQadic( <i>, <q> ) . . . . . .  <q>-adic representation of <i>
##
CoefficientsQadic := NewOperationArgs( "CoefficientsQadic" );


#############################################################################
##
#F  DivisorsInt( <n> )  . . . . . . . . . . . . . . .  divisors of an integer
##
##  'DivisorsInt' returns a list of all divisors  of  the  integer  <n>.  The
##  list is sorted, so that it starts with 1 and  ends  with <n>.  We  define
##  that 'Divisors( -<n> ) = Divisors( <n> )'.
##
##  Since the  set of divisors of 0 is infinite calling 'DivisorsInt( 0 )'
##  causes an error.
##  
##  'DivisorsInt' may call 'FactorsInt' (see "FactorsInt") to obtain the
##  prime factors.
##  'Sigma' (see "Sigma") computes the sum, 'Tau' (see "Tau") the number of
##  positive divisors.
##  
DivisorsInt := NewOperationArgs( "DivisorsInt");


#############################################################################
##
#F  FactorsInt( <n> ) . . . . . . . . . . . . . . prime factors of an integer
##
##  'FactorsInt' returns a list of prime factors of the integer <n>.
##
##  If the <i>th power of a prime divides <n> this prime appears <i> times.
##  The list is sorted, that is the smallest prime factors come first.
##  The first element has the same sign as <n>, the others are positive.
##  For any integer <n> it holds that 'Product( FactorsInt( <n> ) ) = <n>'.
##  
##  Note that 'FactorsInt' uses a probable-primality test (see "IsPrimeInt").
##  Thus 'FactorsInt' might return a list which contains composite integers.
##  
##  The time taken by   'FactorsInt'  is approximately  proportional to   the
##  square root of the second largest prime factor  of <n>, which is the last
##  one that 'FactorsInt'  has to find,   since the largest  factor is simply
##  what remains when all others have been removed.  Thus the time is roughly
##  bounded by  the fourth  root of <n>.   'FactorsInt' is guaranteed to find
##  all factors   less than  $10^6$  and will find  most    factors less than
##  $10^{10}$.    If <n>    contains   multiple  factors   larger  than  that
##  'FactorsInt' may not be able to factor <n> and will then signal an error.
##  
FactorsInt := NewOperationArgs( "FactorsInt" );


#############################################################################
##
#F  Gcdex( <m>, <n> ) . . . . . . . . . . greatest common divisor of integers
##
Gcdex := NewOperationArgs( "Gcdex" );


#############################################################################
##
#F  IsEvenInt( <n> )  . . . . . . . . . . . . . . . . . . test if <n> is even
##
IsEvenInt := function( n )
    return n mod 2 = 0;
end;


#############################################################################
##
#F  IsOddInt( <n> ) . . . . . . . . . . . . . . . . . . .  test if <n> is odd
##
IsOddInt := function( n )
    return n mod 2 = 1;
end;


#############################################################################
##
#F  IsPrimeInt( <n> ) . . . . . . . . . . . . . . . . . . .  test for a prime
##
##  'IsPrimeInt' returns 'false'  if it can  prove that <n>  is composite and
##  'true' otherwise.
##  By  convention 'IsPrimeInt(0) = IsPrimeInt(1) = false'
##  and we define 'IsPrimeInt( -<n> ) = IsPrimeInt( <n> )'.
##  
##  'IsPrimeInt' will return  'true' for all   prime $n$.  'IsPrimeInt'  will
##  return 'false' for all composite $n \< 10^{13}$ and for all composite $n$
##  that have   a factor  $p \<  1000$.   So for  integers $n    \< 10^{13}$,
##  'IsPrimeInt' is  a    proper primality test.    It  is  conceivable  that
##  'IsPrimeInt' may  return 'true' for some  composite $n > 10^{13}$, but no
##  such $n$ is currently known.  So for integers $n > 10^{13}$, 'IsPrimeInt'
##  is a  probable-primality test.  If composites  that fool  'IsPrimeInt' do
##  exist,  they would be  extremly rare, and finding one  by  pure chance is
##  less likely than finding a bug in {\GAP}.
##  
##  'IsPrimeInt' is a deterministic algorithm, i.e., the computations involve
##  no random numbers, and repeated calls will always return the same result.
##  'IsPrimeInt' first   does trial divisions  by the  primes less than 1000.
##  Then it tests  that  $n$  is a   strong  pseudoprime w.r.t. the base   2.
##  Finally it  tests whether $n$ is  a Lucas pseudoprime w.r.t. the smallest
##  quadratic nonresidue of  $n$.  A better  description can be found in  the
##  comment in the library file 'integer.gi'.
##  
##  The time taken by 'IsPrimeInt' is approximately proportional to the third
##  power  of  the number  of  digits of <n>.   Testing numbers  with several
##  hundreds digits is quite feasible.
##  
IsPrimeInt := NewOperationArgs( "IsPrimeInt" );


#############################################################################
##
#F  IsPrimePowerInt( <n> )  . . . . . . . . . . . test for a power of a prime
##
##  'IsPrimePowerInt' returns 'true' if the integer <n>  is a prime power and
##  'false' otherwise.
##
##  $n$ is a *prime power* if there exists a prime $p$ and a positive integer
##  $i$ such that $p^i = n$.  If $n$ is negative the  condition is that there
##  must exist a negative prime $p$ and an odd positive integer $i$ such that
##  $p^i = n$.  1 and -1 are not prime powers.
##  
##  Note    that 'IsPrimePowerInt'      uses       'SmallestRootInt'     (see
##  "SmallestRootInt") and a probable-primality test (see "IsPrimeInt").
##  
IsPrimePowerInt := NewOperationArgs( "IsPrimePowerInt" );


#############################################################################
##
#F  LcmInt( <m>, <n> )  . . . . . . . . . . least common multiple of integers
##
LcmInt := NewOperationArgs( "LcmInt" );


#############################################################################
##
#F  LogInt( <n>, <base> ) . . . . . . . . . . . . . . logarithm of an integer
##
##  'LogInt'   returns  the  integer part  of  the logarithm of  the positive
##  integer  <n> with  respect to   the positive integer   <base>, i.e.,  the
##  largest  positive integer <exp> such  that $base^{exp}  \<= n$.  'LogInt'
##  will signal an error if either <n> or <base> is not positive.
##  
LogInt := NewOperationArgs( "LogInt" );


#############################################################################
##
#F  MoebiusMu( <n> )  . . . . . . . . . . . . . .  Moebius inversion function
##
##  'MoebiusMu'  computes the value  of  Moebius  inversion function for  the
##  integer <n>.   This  is 0 for  integers  which are not squarefree,  i.e.,
##  which are divided by a square $r^2$.  Otherwise it is 1 if <n> has a even
##  number and -1 if <n> has an odd number of prime factors.
##
##  The importance   of $\mu$ stems  from the   so called  inversion formula.
##  Suppose $f(n)$  is a function  defined on the  positive integers and  let
##  $g(n)=\sum_{d \mid n}{f(d)}$. Then $f(n)=\sum_{d \mid n}{\mu(d) g(n/d)}$.
##  As a special case we have  $\phi(n) = \sum_{d  \mid n}{\mu(d) n/d}$ since
##  $n = \sum_{d \mid n}{\phi(d)}$ (see "Phi").
##  
##  'MoebiusMu' usually   spends  all of   its    time   factoring <n>   (see
##  "FactorsInt").
##
MoebiusMu := NewOperationArgs( "MoebiusMu" );


#############################################################################
##
#F  NextPrimeInt( <n> ) . . . . . . . . . . . . . . . . . . next larger prime
##
##  'NextPrimeInt' returns the smallest prime  which is strictly larger  than
##  the integer <n>.
##
##  Note  that     'NextPrimeInt'  uses  a    probable-primality  test   (see
##  "IsPrimeInt").
##  
NextPrimeInt := NewOperationArgs( "NextPrimeInt" );


#############################################################################
##
#F  PowerModInt(<r>,<e>,<m>)  . . . . . . power of one integer modulo another
##
PowerModInt := NewOperationArgs( "PowerModInt" );


#############################################################################
##
#F  PrevPrimeInt( <n> ) . . . . . . . . . . . . . . .  previous smaller prime
##
##  'PrevPrimeInt' returns the largest prime  which is  strictly smaller than
##  the integer <n>.
##  
##  Note  that    'PrevPrimeInt'   uses   a  probable-primality    test  (see
##  "IsPrimeInt").
##  
PrevPrimeInt := NewOperationArgs( "PrevPrimeInt" );


#############################################################################
##
#F  PrimePowerInt( <n> )  . . . . . . . . . . . . . . . . prime powers of <n>
##
PrimePowerInt := NewOperationArgs( "PrimePowerInt" );


#############################################################################
##
#F  RootInt( <n> )  . . . . . . . . . . . . . . . . . . .  root of an integer
#F  RootInt( <n>, <k> )
##
##  'RootInt' returns the integer part of the <k>th root  of the integer <n>.
##  If the optional integer argument <k> is not given it defaults to 2, i.e.,
##  'RootInt' returns the integer part of the square root in this case.
##  
##  If  <n> is positive  'RootInt' returns  the  largest positive integer $r$
##  such that $r^k \<=  n$.  If <n>  is negative and  <k>  is  odd  'RootInt'
##  returns '-RootInt( -<n>,  <k> )'.  If  <n> is negative   and <k> is  even
##  'RootInt' will cause an error.  'RootInt' will also cause an error if <k>
##  is 0 or negative.
##
RootInt := NewOperationArgs( "RootInt" );


#############################################################################
##
#F  Sigma( <n> )  . . . . . . . . . . . . . . . sum of divisors of an integer
##
##  'Sigma' returns the sum of the positive divisors of the integer <n>.
##
##  'Sigma' is a multiplicative arithmetic function, i.e., if $n$ and $m$ are
##  relative prime we have $\sigma(n m) = \sigma(n) \sigma(m)$.
##
##  Together with the formula $\sigma(p^e) = (p^{e+1}-1) / (p-1)$ this allows
##  us to compute $\sigma(n)$.
##
##  Integers  $n$ for which $\sigma(n)=2 n$ are called perfect.  Even perfect
##  integers are exactly of the form $2^{n-1}(2^n-1)$ where $2^n-1$ is prime.
##  Primes of the form  $2^n-1$ are called *Mersenne  primes*, the known ones
##  are obtained for $n =$ 2, 3, 5, 7, 13, 17, 19, 31, 61, 89, 107, 127, 521,
##  607, 1279, 2203, 2281, 3217, 4253, 4423, 9689, 9941, 11213, 19937, 21701,
##  23209,  44497, 86243, 110503, 132049,  216091, 756839, and 859433.  It is
##  not known whether odd  perfect integers  exist, however \cite{BC89}  show
##  that any such integer must have at least 300 decimal digits.
##  
##  'Sigma' usually spends most of its time factoring <n> (see "FactorsInt").
##  
Sigma := NewOperationArgs( "Sigma" );


#############################################################################
##
#F  SignInt( <n> )  . . . . . . . . . . . . . . . . . . .  sign of an integer
##
##  'SignInt' returns the sign of the integer <n>, i.e., 1 if <n> is
##  positive, -1 if <n> is negative and 0 if <n> is 0 (see "AbsInt").
##
SignInt := function ( n )
    if   0 =  n  then
        return 0;
    elif 0 <= n  then
        return 1;
    else
        return -1;
    fi;
end;
#T attribute 'Sign' (also for e.g. permutations)?
#T should be internal method!


#############################################################################
##
#F  SmallestRootInt( <n> )  . . . . . . . . . . . smallest root of an integer
##
##  'SmallestRootInt' returns the smallest root of the integer <n>.
##  
##  The  smallest  root of an  integer $n$  is  the  integer $r$  of smallest
##  absolute  value for which  a  positive integer $k$ exists such  that $n =
##  r^k$.
##  
SmallestRootInt := NewOperationArgs( "SmallestRootInt" );


#############################################################################
##
#F  Tau( <n> )  . . . . . . . . . . . . . .  number of divisors of an integer
##
##  'Tau' returns the number of the positive divisors of the integer <n>.
##
##  'Tau' is a multiplicative arithmetic function, i.e., if $n$ and  $m$  are
##  relative prime we have $\tau(n m) = \tau(n) \tau(m)$.
##  Together with the formula $\tau(p^e) = e+1$ this allows us to compute
##  $\tau(n)$.
##  'Tau' usually spends most of its time factoring <n> (see "FactorsInt").
##
Tau := NewOperationArgs( "Tau" );


#############################################################################
##
#F  PrintFactorsInt( <n> )  . . . . . . . . print factorization of an integer
##
PrintFactorsInt := NewOperationArgs( "PrintFactorsInt" );


#############################################################################
##

#E  integer.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##



