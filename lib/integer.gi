#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Frank Celler, Stefan Kohl, Werner Nickel, Alice Niemeyer, Martin Schönert, Alex Wegner.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##


#############################################################################
##
#V  Integers  . . . . . . . . . . . . . . . . . . . . .  ring of the integers
##
BindGlobal( "Integers", Objectify( NewType(
    CollectionsFamily( CyclotomicsFamily ),
    IsIntegers and IsAttributeStoringRep ),
    rec() ) );

SetName( Integers, "Integers" );
SetString( Integers, "Integers" );
SetIsLeftActedOnByDivisionRing( Integers, false );
SetSize( Integers, infinity );
SetLeftActingDomain( Integers, Integers );
SetGeneratorsOfRing( Integers, [ 1 ] );
SetGeneratorsOfLeftModule( Integers, [ 1 ] );
SetIsFinitelyGeneratedMagma( Integers, false );
SetIsFiniteDimensional( Integers, true );
SetUnits( Integers, [ -1, 1 ] );
SetIsWholeFamily( Integers, false );


#############################################################################
##
#V  NonnegativeIntegers . . . . . . . . . .  semiring of nonnegative integers
##
BindGlobal( "NonnegativeIntegers", Objectify( NewType(
    CollectionsFamily( CyclotomicsFamily ),
    IsNonnegativeIntegers and IsAttributeStoringRep ),
    rec() ) );

SetName( NonnegativeIntegers, "NonnegativeIntegers" );
SetString( NonnegativeIntegers, "NonnegativeIntegers" );
SetSize( NonnegativeIntegers, infinity );
SetGeneratorsOfSemiringWithZero( NonnegativeIntegers, [ 1 ] );
SetGeneratorsOfAdditiveMagmaWithZero( NonnegativeIntegers, [ 1 ] );
SetIsFinitelyGeneratedMagma( NonnegativeIntegers, false );
SetRepresentativeSmallest( NonnegativeIntegers, 0 );
SetIsWholeFamily( NonnegativeIntegers, false );


#############################################################################
##
#V  PositiveIntegers  . . . . . . . . . . . . . semiring of positive integers
##
BindGlobal( "PositiveIntegers", Objectify( NewType(
    CollectionsFamily( CyclotomicsFamily ),
    IsPositiveIntegers and IsAttributeStoringRep ),
    rec() ) );

SetName( PositiveIntegers, "PositiveIntegers" );
SetString( PositiveIntegers, "PositiveIntegers" );
SetSize( PositiveIntegers, infinity );
SetGeneratorsOfSemiring( PositiveIntegers, [ 1 ] );
SetGeneratorsOfAdditiveMagma( PositiveIntegers, [ 1 ] );
SetIsFinitelyGeneratedMagma( PositiveIntegers, false );
SetRepresentativeSmallest( PositiveIntegers, 1 );
SetIsWholeFamily( PositiveIntegers, false );


#############################################################################
##
#R  IsCanonicalBasisIntegersRep
##
DeclareRepresentation(
    "IsCanonicalBasisIntegersRep",
    IsAttributeStoringRep,
    [] );
#T is this needed at all?


#############################################################################
##
#M  Basis( Integers )
##
InstallMethod( Basis,
    "for integers (delegate to `CanonicalBasis')",
    [ IsIntegers ], CANONICAL_BASIS_FLAGS,
    CanonicalBasis );


#############################################################################
##
#M  CanonicalBasis( Integers )
##
InstallMethod( CanonicalBasis,
    "for Integers",
    true,
    [ IsIntegers ], 0,
    function( Integers )
    local B;
    B:= Objectify( NewType( FamilyObj( Integers ),
                                IsFiniteBasisDefault
                            and IsCanonicalBasis
                            and IsCanonicalBasisIntegersRep ),
                   rec() );
    SetUnderlyingLeftModule( B, Integers );
    SetBasisVectors( B, [ 1 ] );

    return B;
    end );

InstallMethod( Coefficients,
    "for the canonical basis of Integers",
    IsCollsElms,
    [ IsBasis and IsCanonicalBasis and IsCanonicalBasisIntegersRep,
      IsCyc ], 0,
    function( B, v )
    if IsInt( v ) then
      return [ v ];
    else
      return fail;
    fi;
    end );


#############################################################################
##
#V  Primes  . . . . . . . . . . . . . . . . . . . . . .  list of small primes
##
BindGlobal( "Primes",
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
MakeImmutable( Primes );


#############################################################################
##
#V  Primes2 . . . . . . . . . . . . . . . . . . . . . . additional prime list
#V  ProbablePrimes2 . . . . . . . . . . . . . . . . . . additional prime list
##
##  Some primes in `Primes2' are taken from the tables of Richard Brent,
##  which are available at
##  ftp://ftp.comlab.ox.ac.uk/pub/Documents/techpapers/Richard.Brent/factors/
##
##  More factors of cyclotomic numbers are now available via the FactInt
##  package. This should be cleaned up.
##
InstallFlushableValue( Primes2, [
10047871, 10567201, 10746341, 12112549, 12128131, 12207031, 12323587,
12553493, 12865927, 13097927, 13264529, 13473433, 13821503, 13960201,
14092193, 14597959, 15216601, 15790321, 16018507, 18837001, 20381027,
20394401, 20515111, 20515909, 21207101, 21523361, 22253377, 22366891,
22996651, 23850061, 25781083, 26295457, 28325071, 28878847, 29010221,
29247661, 29423041, 29866451, 32234893, 32508061, 36855109, 41540861,
42521761, 43249589, 44975113, 47392381, 47763361, 48544121, 48912491,
49105547, 49892851, 51457561, 55527473, 56409643, 56737873, 59302051,
59361349, 59583967, 60816001, 62020897, 63512437, 65628751, 69566521,
75068993, 76066181, 85280581, 93507247, 96656723, 97685839,
106431697, 107367629, 109688713, 110211473, 112901153, 119782433, 127540261,
134818753, 134927809, 136151713, 147300841, 155072369, 160465489, 164511353,
177237331, 183794551, 184481113, 190295821, 190771747, 193707721, 195019441,
202029703, 206244761, 212601841, 212885833, 228511817, 231769777, 234750601,
272010961, 280314943, 283763713, 297315901, 305175781, 308761441, 319020217,
359390389, 407865361, 420778751, 424256201, 432853009, 457315063, 466344409,
510810301, 515717329, 527093491, 529510939, 536903681, 540701761, 550413361,
603926681, 616318177, 632133361, 715827883, 724487149, 745988807, 763539787,
815702161, 834019001, 852133201, 857643277, 879399649, 909139159,
1001523179, 1036745531, 1065264019, 1106131489, 1169382127, 1390636259,
1503418321, 1527007411, 1636258751, 1644512641, 1743831169, 1824179209,
1824726041, 1826934301, 1866013003, 1990415149, 2127357527, 2127431041,
2147483647, 2238236249, 2316281689, 2413941289, 2481791513, 2550183799,
2576743207, 2664097031, 2767631689, 2903110321, 2931542417, 3021012311,
3158528101, 3173389601, 3357897971, 3652120847, 4011586307, 4058036683,
4278255361, 4375578271, 4562284561, 4649919401, 4698932281, 4795973261,
4885168129, 5960555749, 6622733113, 6630274723, 6809710909, 6860024417,
7068569257, 7151459701, 7484047069, 7685542369, 7830118297, 7866608083,
8209475377, 8831418697, 9598959833,
10879733611, 11368765063, 11898664849, 12447002677, 13455809771, 13564461457,
13841169553, 13971969971, 14425532687, 15085812853, 15768033143, 15888756269,
16055056483, 16148168401, 17056050293, 17154094481, 17189128703, 19707683773,
22434744889, 23140471537, 23535794707, 24127552321, 25194773531, 25480398173,
25829691707, 25994736109, 27669118297, 27989941729, 28086211607, 30327152671,
32952799801, 33057806959, 35532364099, 39940132241, 43872038849, 45076044553,
47072139617, 50150933101, 54410972897, 56625998353, 56770350869, 60726444167,
61070817601, 62983048367, 65247271367, 69238518539, 70845409351, 76831835389,
77158673929, 77192844961, 78009515593, 83960385389, 86950696619, 87423871753,
88959882481, 99810171997,
115868130379, 125096112091, 127522693159, 128011456717, 128653413121,
129924628343, 131105292137, 152587500001, 158822951431, 159248456569,
164504919713, 165768537521, 168749965921, 213657222007, 229890275929,
241931001601, 269089806001, 282429005041, 301077652751, 332207361361,
368592716837, 374857981681, 386478495679, 392038110671, 402011881627,
441019876741, 447600088289, 461587317509, 487824887233, 531968664833,
555915824341, 593554036769, 598761682261, 641625222857, 654652168021,
761838257287, 810221830361, 840139875599, 918585913061,
1030330938209, 1047623475541, 1113491139767, 1133836730401, 1273880539247,
1284297400723, 1408429185797, 1534179947851, 1628744948329, 1654058017289,
1759217765581, 1856458657451, 2098303812601, 2454335007529, 2481357870461,
2549755542947, 2663568851051, 2738039191709, 2879347902817, 2932031007403,
3138426605161, 3203431780337, 3421169496361, 3740221981231, 4363953127297,
4432676798593, 4446437759531, 4534166740403, 4981857697937, 5625767248687,
6090817323763, 6493405343627, 6713103182899, 6740339310641, 7432339208719,
8090594434231, 8157179360521, 8737481256739, 8868050880709, 9361973132609,
9468940004449, 9857737155463,
10052678938039, 10979607179423, 13952598148481, 15798461357509,
15919793462773, 17175865789597, 18158209813151, 22125996444329,
22542470482159, 22735632934561, 23161037562937, 23792163643711,
24517014940753, 24587411156281, 28059810762433, 29078814248401,
31280679788951, 31479823396757, 32688470798197, 33232924804801,
42272797713043, 44479210368001, 45920153384867, 49971617830801,
57583418699431, 62911130477521, 67280421310721, 70601370627701,
71316922984999, 83181652304609, 89620825374601, 94404837727799,
95052547721497,
110133112994711, 140737471578113, 145295143558111, 150224123975857,
160026187716961, 204064664440913, 205367807127911, 242099935645987,
270547105429567, 303567967057423, 332584516519201, 434502978835771,
475384700124973, 500805747488153, 520518327319589, 560088668384411,
608459012088799, 637265428480297, 643170158708221, 707179356161321,
866802946161469, 926510094425921, 990643452963163,
1034150930241911, 1066818132868207, 1120648576818041, 1357105535093947,
1416258521793067, 1587855697992791, 1611479891519807, 1628413557556843,
1900857799450121, 1958423494433591, 2134387368610417, 2646507710984041,
2649263870814793, 2752135920929651, 2864226125209369, 3208002856867129,
4557772677741827, 4889988840047743, 5420506947192709, 6957533874046531,
9460375336977361, 9472026608675509,
11264087821629961, 12557612956332313, 13722816749522711, 14436295738510501,
18584774046020617, 18624275418445601, 20986207825565581, 21180247636732981,
22666879066355177, 27145365052629449, 32233368385529653, 39392783590192547,
46329453543600481, 50544702849929377, 59509429687890001, 60081451169922001,
70084436712553223, 76394148218203559, 77001139434480073, 79787519018560501,
96076791871613611,
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
36230454570129675721, 58523123221688392679, 60912916512835721519,
82064241848634269407, 86656268566282183151, 87274497124602996457,
105668621839502584913, 157571957584602258799, 162715052426691233701,
172827552198815888791, 195489390796456327201, 240031591394168814433,
266834785363181152127, 344120456368919234899, 358475907408445923469,
846041103974872866961,
2519545342349331183143, 3658524738455131951223, 3793685967117002179453,
3976656429941438590393, 5439042183600204290159, 8198241112969626815581,
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
] );
IsSSortedList( Primes2 );
# for 41^41-1
ADD_SET(Primes2, 5926187589691497537793497756719);
# for 89^89-1
ADD_SET(Primes2, 4330075309599657322634371042967428373533799534566765522517);
# for 97^97-1
ADD_SET(Primes2, 549180361199324724418373466271912931710271534073773);
ADD_SET(Primes2,  85411410016592864938535742262164288660754818699519364051241927961077872028620787589587608357877);

InstallFlushableValue(ProbablePrimes2, []);
IsSSortedList( ProbablePrimes2 );

if IsHPCGAP then
  ShareSpecialObj(Primes2);
  ShareSpecialObj(ProbablePrimes2);
fi;


#############################################################################
##
#F  BestQuoInt( <n>, <m> )
##
##  `BestQuoInt' returns the best quotient <q> of the integers  <n> and  <m>.
##  This is the quotient such that `<n>-<q>\*<m>' has minimal absolute value.
##  If there are two quotients whose remainders have the same absolute value,
##  then the quotient with the smaller absolute value is chosen.
##
InstallGlobalFunction(BestQuoInt,function ( n, m )
    if   0 <= m  and 0 <= n  then
        return QuoInt( n + QuoInt( m - 1, 2 ), m );
    elif 0 <= m  then
        return QuoInt( n - QuoInt( m - 1, 2 ), m );
    elif 0 <= n  then
        return QuoInt( n - QuoInt( m + 1, 2 ), m );
    else
        return QuoInt( n + QuoInt( m + 1, 2 ), m );
    fi;
end);


#############################################################################
##
#F  ChineseRem( <moduli>, <residues> )  . . . . . . . . . . chinese remainder
##
InstallGlobalFunction(ChineseRem,function ( moduli, residues )
    local   i, c, l, g;

    # combine the residues modulo the moduli
    i := 1;
    c := residues[1];
    l := moduli[1];
    while i < Length(moduli)  do
        i := i + 1;
        g := Gcdex( l, moduli[i] );
        if g.gcd <> 1  and (residues[i]-c) mod g.gcd <> 0  then
            Error("the residues must be equal modulo ",g.gcd);
        fi;
        c := l * (((residues[i]-c) / g.gcd * g.coeff1) mod moduli[i]) + c;
        l := moduli[i] / g.gcd * l;
    od;

    # reduce c into the range [0..l-1]
    c := c mod l;
    return c;
end);


#############################################################################
##
#F  CoefficientsQadic( <i>, <q> ) . . . . . .  <q>-adic representation of <i>
##
InstallMethod( CoefficientsQadic, "for two integers",
    true, [ IsInt, IsInt ], 0,
function( i, q )
    local i1, res, l, qq, i2;
    if q <= 1 then
        Error("2nd argument of CoefficientsQadic should be greater than 1\n");
    fi;
    if i < 0 then
        # if FR package is loaded and supplies an implementation
        # to return a periodic list for negative i
        TryNextMethod();
    fi;
    # represent the integer <i> as <q>-adic number
    if i = 0 then
        return [];
    elif i < q then
        return [i];
    elif i < q^2 then
        i1 := QuoInt(i, q);
        return [i - i1*q, i1];
    elif Log2Int(q)*100 > Log2Int(i) then
        # straight forward loop for result length < 100
        res := [];
        while i > 0 do
          i1 := QuoInt(i, q);
          Add(res, i - i1*q);
          i := i1;
        od;
    else
        # divide and conquer method for large i
        l := QuoInt(LogInt(i, q), 2)+1;
        qq := q^l;
        i2 := QuoInt(i,qq);
        i1 := i - i2*qq;
        res := CoefficientsQadic(i1, q);
        while Length(res) < l do
          Add(res, 0);
        od;
        Append(res, CoefficientsQadic(i2, q));
    fi;
    return res;
end);


#############################################################################
##
#F CoefficientsMultiadic( ints, int )
##
InstallGlobalFunction(CoefficientsMultiadic, function( ints, int )
    local vec, i;
    vec := List( ints, x -> 0 );
    for i in Reversed( [1..Length(ints)] ) do
        vec[i] := RemInt( int, ints[i] );
        int := QuoInt( int, ints[i] );
    od;
    return vec;
end);


#############################################################################
##
#F  DivisorsInt( <n> )  . . . . . . . . . . . . . . .  divisors of an integer
##
BindGlobal("DivisorsIntCache",
List([[1],[1,2],[1,3],[1,2,4],[1,5],[1,2,3,6],[1,7]], Immutable));
if IsHPCGAP then
  MakeImmutable(DivisorsIntCache);
fi;

InstallGlobalFunction(DivisorsInt,function ( n )
    local  divisors, factors, divs;

    # make <n> it nonnegative, handle trivial cases, and get prime factors
    if n < 0  then n := -n;  fi;
    if n = 0  then Error("DivisorsInt: <n> must not be 0");  fi;
    if n <= Length(DivisorsIntCache)  then
        return DivisorsIntCache[n];
    fi;
    factors := Factors(Integers, n );

    # recursive function to compute the divisors
    divs := function ( i, m )
        if Length(factors) < i     then return [ m ];
        elif m mod factors[i] = 0  then return divs(i+1,m*factors[i]);
        else return Concatenation( divs(i+1,m), divs(i+1,m*factors[i]) );
        fi;
    end;

    divisors := divs( 1, 1 );
    Sort( divisors );
    return Immutable(divisors);
end);


#############################################################################
##
#F  FactorsRho( <n>, <inc>, <cluster>, <limit> )   Pollards rho factorization
##
##  `FactorsInt' does trial divisions by the primes less than 1000 to  detect
##  all composites with a factor less than 1000 and primes less than 1000000.
##  After that it calls `FactorsRho(<n>,1,16,8192)' to do the hard work.
##
##  `FactorsRho'  will  return a  list  of factors   and a list  of composite
##  number.   Usually  `FactorsInt'  factors  integers  with   prime  factors
##  $\<1000$ faster.     However  for   integers  with  no   factor  $\<1000$
##  `FactorsRho' will be faster.
##
##  `FactorsRho' uses Pollards $\rho$ method to factor the integer $n = p q$.
##  For a small simple example lets assume we want to factor $667 = 23 * 29$.
##  `FactorsRho' first calls `IsPrimeInt' to avoid trying to factor a prime.
##
##  Then it uses the sequence defined by  $x_0=1, x_{i+1}=(x_i^2+1)$ mod $n$.
##  In our example this is $1, 2, 5, 26, 10, 101, 197, 124, 36, 630, .. $.
##
##  Modulo $p$ it takes on at most $p-1$ different values, thus it eventually
##  becomes recurrent, usually this happens after roughly $2 \sqrt{p}$ steps.
##  In our example modulo 23 we get $1, 2, 5, 3, 10, 9, 13, 9, 13, 9, .. $.
##
##  Thus there exist pairs $i, j$ such that $x_i = x_j$ mod $p$,  i.e.,  such
##  that $p$ divides $Gcd( n, x_j-x_i )$.  With a bit of luck no other factor
##  of $n$ divides $x_j - x_i$ so we find $p$ if we know such a pair.  In our
##  example $5, 7$ is the first pair, $x_7-x_5=23$, and $Gcd(667,23) = 23$.
##
##  Now it is too expensive to check all pairs, but there also must be  pairs
##  of the form $2^i-1, j$ with $3*2^{i-1} <= j < 4*2^{i-1}$.  In our example
##  $7, 13$ is the first such pair, $x_13-x_7=506$, and $Gcd(667,506) = 23$.
##
##  Thus by taking the gcds of $n$ and $x_j-x_i$ for such pairs, we will find
##  the factor $p$ after approximately $2 \sqrt{p} \<= 2 \sqrt^4{n}$ steps.
##
##  If $Gcd( n, x_j - x_i )$  is not a prime `FactorsRho'  will  call  itself
##  recursively with a different value for <inc>, i.e., it will try to factor
##  the gcd using a different sequence $x_{i+1} = (x_i^2 + inc)$ mod $n$.
##
##  Since the gcd computations are by far the most time consuming part of the
##  algorithm  one can save time by  clustering differences and computing the
##  gcd  only every <cluster>  iteration.  This slightly increases the chance
##  that a gcd is composite, but reduces the runtime by a large amount.
##
##  Finally `FactorsRho' accepts an argument <limit>  which is the number  of
##  iterations  performed by `FactorsRho' before giving up. The default value
##  is  8192  which corresponds to a few minutes  while guaranteeing that all
##  prime factors less than $10^6$ and most less than $10^9$ are found.
##
##  Better descriptions of the algorithm and related topics can be found  in:
##  J. Pollard, A Monte Carlo Method for Factorization, BIT 15, 1975, 331-334
##  R. Brent, An Improved Monte Carlo Method for Fact., BIT 20, 1980, 176-184
##  D. Knuth, Seminumerical Algorithms  (TACP II),  AddiWesl,  1973,  369-371
##
DeclareGlobalName( "FactorsRho" );
BindGlobal( "FactorsRho", function ( n, inc, cluster, limit )

    local   i,  sign,  factors,  composite,  x,  y,  k,  z,  g,  tmp,
            IsPrimeOrProbablyPrimeInt;

    # make $n$ positive and handle trivial cases
    sign := 1;
    if n < 0  then sign := -sign;  n := -n;  fi;
    if n < 4  then return [ [ sign * n ], [] ];  fi;
    factors   := [];
    composite := [];
    while n mod 2 = 0  do Add( factors, 2 );  n := n / 2;  od;
    while n mod 3 = 0  do Add( factors, 3 );  n := n / 3;  od;

    if   ValueOption("UseProbabilisticPrimalityTest") = true
    then IsPrimeOrProbablyPrimeInt := IsProbablyPrimeInt;
    else IsPrimeOrProbablyPrimeInt := IsPrimeInt; fi;

    if IsPrimeOrProbablyPrimeInt(n)  then Add( factors, n );  n := 1;  fi;

    # initialize $x_0$
    x := 1;  z := 1;  i := 0;

    # loop until we have factored $n$ completely or run out of patience
    while 1 < n  and 2^i <= limit  do

        # $y = x_{2^i-1}$
        y := x;  i := i + 1;

        # $x_{2^i}, .., x_{3*2^{i-1}-1}$ need not be compared to $x_{2^i-1}$
        for k  in [1..2^(i-1)]  do
            x := (x^2 + inc) mod n;
        od;

        # compare $x_{3*2^{i-1}}, .., x_{4*2^{i-1}-1}$ with $x_{2^i-1}$
        for k  in [1..2^(i-1)]  do
            x := (x^2 + inc) mod n;
            z := z * (x - y) mod n;

            # from time to time compute the gcd
            if k mod cluster = 0  then
                g := GcdInt( n, z );

                # if it is > 1 we have found a factor which need not be prime
                if g > 1  then
                    tmp := FactorsRho(g,inc+1,QuoInt(cluster+1,2),limit);
                    factors   := Concatenation( factors,   tmp[1] );
                    composite := Concatenation( composite, tmp[2] );

                    n := n / g;
                    if IsPrimeOrProbablyPrimeInt(n)  then
                        Add( factors, n );  n := 1;
                    fi;
                fi;
            fi;
        od;
    od;

    # add <n> to the list of composite numbers
    if 1 < n  then
        Add( composite, n );
    fi;

    # sort the list of factors and composite numbers and return it
    Sort(factors);
    Sort(composite);
    if 0 < Length(factors)  then
        factors[1] := sign * factors[1];
    else
        composite[1] := sign * composite[1];
    fi;
    return [ factors, composite ];

end );


#############################################################################
##
#F  FactorsInt( <n> ) . . . . . . . . . . . . . . prime factors of an integer
#F  FactorsInt( <n> : RhoTrials := <trials>)
#F  FactorsInt( <n> : quiet)
##
##  In the second form, FactorsRho is called with a limit of <trials>
##  on the number of trials is performs. The  default is 8192.
##
##  The option `quiet' makes the function return even if the `rho'
##  factorization failed and return the factorization found so far.
##
InstallGlobalFunction(FactorsInt,function ( n )

    local  sign,  factors,  p,  tmp, n_orig, len, rt, tmp2;

    n_orig := n;

    # make $n$ positive and handle trivial cases
    sign := 1;
    if n < 0  then sign := -sign;  n := -n;  fi;
    if n < 4  then return [ sign * n ];  fi;
    factors := [];

    # do trial divisions by the primes less than 1000
    # faster than anything fancier because $n$ mod <small int> is very fast
    for p  in Primes  do
        while n mod p = 0  do Add( factors, p );  n := n / p;  od;
        if n < (p+1)^2 and 1 < n  then Add(factors,n);  n := 1;  fi;
        if n = 1  then factors[1] := sign*factors[1];  return factors;  fi;
    od;

    # do trial divisions by known primes
    atomic readonly Primes2 do
    for p  in Primes2  do
        while n mod p = 0  do Add( factors, p );  n := n / p;  od;
        if p^2 > n then break; fi;
        if n = 1  then factors[1] := sign*factors[1];  return factors;  fi;
    od;
    od;

    # do trial divisions by known probable primes (and issue warning, if found)
    tmp := [];
    atomic readonly ProbablePrimes2 do
    for p  in ProbablePrimes2  do
        while n mod p = 0  do
          AddSet(tmp, p);
          Add( factors, p );
          n := n / p;
        od;
        if n = 1  then break; fi;
    od;
    od;
    if Length(tmp) > 0 then
        Info(InfoPrimeInt, 1 ,
        "FactorsInt: used the following factor(s) which are probably primes:");
        for p in tmp do
          Info(InfoPrimeInt, 1, "      ", p);
        od;
    fi;
    if n = 1  then factors[1] := sign*factors[1];  return factors;  fi;


    # handle perfect powers
    p := SmallestRootInt( n );
    if p < n  then
        while 1 < n  do
            Append( factors, FactorsInt(p) );
            n := n / p;
        od;
        Sort( factors );
        factors[1] := sign * factors[1];
        return factors;
    fi;

    # let `FactorsRho' do the work
      if ValueOption("RhoTrials") <> fail then
        tmp := FactorsRho( n, 1, 16,  ValueOption("RhoTrials") );
      else
        tmp := FactorsRho( n, 1, 16, 8192 );
      fi;
    if 0 < Length(tmp[2])  then
      if ValueOption("quiet")<>true then
        len := Length(tmp[2]);
        if IsPackageMarkedForLoading("FactInt", "")  then
##            # in general cases we should proceed with the found factors:
##            while len > 0 do
##              Append(tmp[1], Factors(tmp[2][len]));
##              Unbind(tmp[2][len]);
##              len := len-1;
##            od;
          # but this way we miss that FactInt can detect certain numbers of
          # special shape for which it uses lookup tables, therefore for the
          # moment:
          return Factors(n_orig);
        else
          Error( "sorry,  cannot factor ", tmp[2],
            "\ntype 'return;' to try again with a larger number of trials in\n",
            "FactorsRho (or use option 'RhoTrials')\n");
          if ValueOption("RhoTrials") <> fail then
            rt := 5 * ValueOption("RhoTrials");
          else
            rt := 5 * 8192;
          fi;
          while len > 0 do
            tmp2 := FactorsInt(tmp[2][len]: RhoTrials := rt);
            Append(tmp[1], tmp2);
            Unbind(tmp[2][len]);
            len := len-1;
          od;
        fi;
      else
        factors := Concatenation( factors, tmp[2] );
      fi;
    fi;
    factors := Concatenation( factors, tmp[1] );
    Sort( factors );
    factors[1] := sign * factors[1];
    return factors;
end);


#############################################################################
##
#F  PrimeDivisors( <n> ) . . . . . . . . . . . . . . list of prime divisors
##
##  delegating to Factors
##
InstallMethod( PrimeDivisors, "for integer", [ IsInt ], function(n)
  if n = 0 then
    Error( "<n> must be non zero" );
  fi;
  if n < 0 then
    n := -n;
  fi;
  if n = 1 then
    return [];
  fi;
  return Set(Factors(Integers,n));
end);


#############################################################################
##
#M  PartialFactorization( <n>, <effort> ) . . . . . . . . . .  generic method
##
InstallMethod( PartialFactorization,
               "generic method", true, [ IsInt, IsInt ], 0,

  function ( n, effort )

    local  N, sign, factors, p, k, root, rootfactors, rhotrials,
           tmp, CheckAndSortFactors;

    CheckAndSortFactors := function ( )
      factors    := SortedList(factors);
      factors[1] := sign*factors[1];
      if   Product(factors) <> N
      then Error("PartialFactorization: Internal error, wrong result!"); fi;
    end;

    N := n;
    if effort < 0 then effort := 5; fi;

    # make $n$ positive and handle trivial cases
    sign := 1;
    if n < 0  then sign := -sign;  n := -n;  fi;
    if n < 4  then return [ sign * n ];  fi;
    factors := [];

    # least effort: do trial divisions by the primes less than 100
    if effort = 0 then
      for p in Primes{[1..25]} do
        while n mod p = 0 do Add( factors, p ); n := n / p; od;
        if n < (p+1)^2 and 1 < n then Add(factors,n); n := 1; fi;
        if n = 1 then CheckAndSortFactors(); return factors; fi;
      od;
      Add(factors,n); CheckAndSortFactors(); return factors;
    fi;

    # do trial divisions by the primes less than 1000
    # faster than anything fancier because $n$ mod <small int> is very fast
    for p in Primes do
      while n mod p = 0 do Add( factors, p ); n := n / p; od;
      if n < (p+1)^2 and 1 < n then Add(factors,n);  n := 1; fi;
      if n = 1 then CheckAndSortFactors(); return factors; fi;
    od;

    if effort <= 1 then
      Add(factors,n); CheckAndSortFactors();
      return factors;
    fi;

    # do trial divisions by known primes
    atomic readonly Primes2 do
    for p in Primes2 do
      while n mod p = 0 do Add( factors, p ); n := n / p; od;
      if n = 1 then CheckAndSortFactors(); return factors; fi;
    od;
    od;

    # do trial divisions by known probable primes
    tmp := [];
    atomic readonly ProbablePrimes2 do
    for p in ProbablePrimes2 do
      while n mod p = 0 do
        AddSet(tmp, p);
        Add( factors, p );
        n := n / p;
      od;
      if n = 1 then break; fi;
    od;
    od;

    if n = 1 then CheckAndSortFactors(); return factors; fi;

    # handle perfect powers
    root := SmallestRootInt( n );
    if root < n then
      rootfactors := PartialFactorization(root,effort);
      k           := LogInt(n,root);
      rootfactors := Concatenation(List([1..k],i->rootfactors));
      factors     := SortedList(Concatenation(factors,rootfactors));
      CheckAndSortFactors();
      return factors;
    fi;

    if effort = 2 or IsProbablyPrimeInt(n) then
      Add(factors,n); CheckAndSortFactors(); return factors;
    fi;

    # if effort >= 3, use `FactorsRho'
    if ValueOption("RhoTrials") <> fail then
      tmp := FactorsRho(n,1,16,ValueOption("RhoTrials"):
                        UseProbabilisticPrimalityTest);
    else
      if   effort  = 3 then rhotrials := 256;
      elif effort  = 4 then rhotrials := 2048;
      elif effort >= 5 then rhotrials := 8192; fi;
      tmp := FactorsRho(n,1,16,rhotrials:UseProbabilisticPrimalityTest);
    fi;
    factors := SortedList(Concatenation(factors,tmp[1],tmp[2]));
    CheckAndSortFactors();
    return factors;
  end );


#############################################################################
##
#M  PartialFactorization( <n> ) . . . . . partial factorization of an integer
##
InstallOtherMethod( PartialFactorization,
                    "for integers", true, [ IsInt ], 0,
                    n -> PartialFactorization(n,5) );


#############################################################################
##
#F  Gcdex( <m>, <n> ) . . . . . . . . . . greatest common divisor of integers
##
InstallGlobalFunction(Gcdex,function ( m, n )
    local   f, g, h, fm, gm, hm, q;
    if 0 <= m  then f:=m; fm:=1; else f:=-m; fm:=-1; fi;
    if 0 <= n  then g:=n; gm:=0; else g:=-n; gm:=0;  fi;
    while g <> 0  do
        q := QuoInt( f, g );
        h := g;          hm := gm;
        g := f - q * g;  gm := fm - q * gm;
        f := h;          fm := hm;
    od;
    if n = 0  then
        return rec( gcd := f, coeff1 := fm, coeff2 := 0,
                              coeff3 := gm, coeff4 := 1 );
    else
        return rec( gcd := f, coeff1 := fm, coeff2 := (f - fm * m) / n,
                              coeff3 := gm, coeff4 := (0 - gm * m) / n );
    fi;
end);


#############################################################################
##
#F  IsEvenInt( <n> )  . . . . . . . . . . . . . . . . . . test if <n> is even
##
InstallGlobalFunction( IsEvenInt, n -> n mod 2 = 0 );


#############################################################################
##
#F  IsOddInt( <n> ) . . . . . . . . . . . . . . . . . . .  test if <n> is odd
##
InstallGlobalFunction( IsOddInt, n -> n mod 2 = 1 );


#############################################################################
##
#F  IsPrimePowerInt( <n> )  . . . . . . . . . . . test for a power of a prime
##
InstallGlobalFunction( IsPrimePowerInt, function(n)
    local   k, r, s, p, l, q, i;

    # check the argument
    if   n >  1 then k := 2;  s :=  1;
    elif n < -1 then k := 3;  s := -1;  n := -n;
    else return false;
    fi;

    # exclude small divisors, and thereby large exponents
    for p in Primes do
        if p*p > n then return true; fi; # n is prime
        r := PVALUATION_INT(n, p);
        if r > 0 then
            if s = -1 and IsEvenInt(r) then return false; fi;
            return n = p^r;
        fi;
    od;
    l := LogInt( n, p );

    # loop over the possible prime divisors of exponents
    # use Fermat's little theorem to cast out impossible ones:
    # for suppose we had r such that n = r^k. Then by Fermat,
    # n^((q-1)/k) = r^(q-1) is congruent 0 or 1 mod q
    i := Position(Primes, k);
    while k <= l  do
        q := 2*k+1;  while not IsPrimeInt(q)  do q := q+2*k;  od;
        if PowerModInt( n, (q-1)/k, q ) <= 1  then
            r := RootInt( n, k );
            if r ^ k = n  then
                n := r;
                l := QuoInt( l, k );
                continue;
            fi;
        fi;
        if i <> fail and i < Length(Primes) then
            i := i + 1;
            k := Primes[i];
        else
            # need more primes...
            k := NextPrimeInt( k );
            # since we are now beyond the primes in Primes, for which we
            # checked whether they divide n, we might now just as well
            # test if k divides n, too
            r := PVALUATION_INT(n, k);
            if r > 0 then
                if s = -1 and IsEvenInt(r) then return false; fi;
                return n = k^r;
            fi;
        fi;
    od;

    return IsPrimeInt(n);
end);


#############################################################################
##
#F  LcmInt( <m>, <n> )  . . . . . . . . . . least common multiple of integers
##
InstallGlobalFunction(LcmInt, LCM_INT);


#############################################################################
##
#F  LogInt( <n>, <base> ) . . . . . . . . . . . . . . logarithm of an integer
##
InstallGlobalFunction(LogInt,function ( n, base )
    local   log, p;

    # check arguments
    if not IsInt(n) or n    <= 0  then
        Error("<n> must be a positive integer");
    fi;
    if not IsInt(base) or base <= 1  then
        Error("<base> must be an integer greater than 1");
    fi;

    # `log(b)' returns $log_b(n)$ and divides `n' by `b^log(b)'
##      log := function ( b )
##          local   i;
##          if b > n  then return 0;  fi;
##          i := log( b^2 );
##          if b > n  then return 2 * i;
##          else  n := QuoInt( n, b );  return 2 * i + 1;  fi;
##      end;
##
##      return log( base );
  if n < base then
    return 0;
  elif base = 2 then
    return Log2Int(n);
  elif base = 8 then
    return QuoInt(Log2Int(n), 3);
  elif base = 16 then
    return QuoInt(Log2Int(n), 4);
  elif IsSmallIntRep(n) then
    log := 1;
    p := base * base;
    while p <= n do
      log := log + 1;
      p := p * base;
    od;
    return log;
  elif base = 10 then
    log := QuoInt(Log2Int(n) * 10^6 , 3321929);
    return log + LogInt(QuoInt(n, 10^log), 10);
  else
    log := QuoInt(Log2Int(n), Log2Int(base)+1);
    if log = 0 then
      log := 1;
    fi;
    return log + LogInt(QuoInt(n, base^log), base);
  fi;
end);

#############################################################################
##
#F  NextPrimeInt( <n> ) . . . . . . . . . . . . . . . . . . next larger prime
##
InstallGlobalFunction(NextPrimeInt,function ( n )
    if   -3 = n             then n := -2;
    elif -3 < n  and n < 2  then n :=  2;
    elif n mod 2 = 0        then n := n+1;
    else                         n := n+2;
    fi;
    while not IsPrimeInt(n)  do
        if n mod 6 = 1  then n := n+4;
        else                 n := n+2;
        fi;
    od;
    return n;
end);


#############################################################################
##
#F  PowerModInt(<r>,<e>,<m>)  . . . . . . power of one integer modulo another
##
InstallGlobalFunction(PowerModInt, POWERMODINT);


#############################################################################
##
#F  PrevPrimeInt( <n> ) . . . . . . . . . . . . . . .  previous smaller prime
##
##  `PrevPrimeInt' returns the largest prime  which is strictly smaller  than
##  the integer <n>.
##
InstallGlobalFunction(PrevPrimeInt,function ( n )
    if    3 = n             then n :=  2;
    elif -2 < n  and n < 3  then n := -2;
    elif n mod 2 = 0        then n := n-1;
    else                         n := n-2;
    fi;
    while not IsPrimeInt(n)  do
        if n mod 6 = 5  then n := n-4;
        else                 n := n-2;
        fi;
    od;
    return n;
end);


#############################################################################
##
#F  PrimePowerInt( <n> )  . . . . . . . . . . . . . . . . prime powers of <n>
##
InstallGlobalFunction(PrimePowersInt,function( n )
    if n = 1  then
        return [];
    elif n = 0  then
        Error( "<n> must be non zero" );
    elif n < 0  then
        n := -1 * n;
    fi;
    return Flat(Collected(Factors(Integers,n)));

end);


#############################################################################
##
#F  RootInt( <n> )  . . . . . . . . . . . . . . . . . . .  root of an integer
#F  RootInt( <n>, <k> )
##
InstallGlobalFunction(RootInt,function ( arg )
    local   n, k, r, s, t;

    # get the arguments
    if   Length(arg) = 1  then n := arg[1];  k := 2;
    elif Length(arg) = 2  then n := arg[1];  k := arg[2];
    else Error("usage: `Root( <n> )' or `Root( <n>, <k> )'");
    fi;

    # ask the kernel to compute the root; this can only fail for
    # huge values of k and enormously huge values of n
    r := ROOT_INT(n, k);
    if r <> fail then
        return r;
    fi;

    # r is the first approximation, s the second, we need: root <= s < r
    r := n;  s := 2^( QuoInt( LogInt(n,2), k ) + 1 ) - 1;

    # do Newton iterations until the approximations stop decreasing
    while s < r  do
        r := s;  t := r^(k-1);  s := QuoInt( n + (k-1)*r*t, k*t );
    od;

    # and that's the integer part of the root
    return r;
end);


#############################################################################
##
#F  AbsInt( <n> ) . . . . . . . . . . . . . . .  absolute value of an integer
##
#InstallGlobalFunction( AbsInt, ABS_INT );
InstallGlobalFunction( AbsInt, ABS_RAT ); # support rationals for backwards compatibility


#############################################################################
##
#F  AbsoluteValue( <n> )
##
InstallMethod( AbsoluteValue, "rationals", [IsRat], ABS_RAT );


#############################################################################
##
#F  SignInt( <n> )  . . . . . . . . . . . . . . . . . . .  sign of an integer
##
#InstallGlobalFunction( SignInt, SIGN_INT );
InstallGlobalFunction( SignInt, SIGN_RAT ); # support rationals for backwards compatibility


#############################################################################
##
#F  SmallestRootInt( <n> )  . . . . . . . . . . . smallest root of an integer
##
InstallGlobalFunction(SmallestRootInt,function ( n )
    local   k, r, s, p, l, q, i;

    # check the argument
    if   n > 0  then k := 2;  s :=  1;
    elif n < 0  then k := 3;  s := -1;  n := -n;
    else return 0;
    fi;

    # exclude small divisors, and thereby large exponents
    for p in Primes do
        if p*p > n then return s * n; fi;
        if n mod p = 0 then break; fi;
    od;
    l := LogInt( n, p );

    # loop over the possible prime divisors of exponents
    # use Fermat's little theorem to cast out impossible ones:
    # for suppose we had r such that n = r^k. Then by Fermat,
    # n^((q-1)/k) = r^(q-1) is congruent 0 or 1 mod q
    i := Position(Primes, k);
    while k <= l  do
        q := 2*k+1;  while not IsPrimeInt(q)  do q := q+2*k;  od;
        if PowerModInt( n, (q-1)/k, q ) <= 1  then
            r := RootInt( n, k );
            if r ^ k = n  then
                n := r;
                l := QuoInt( l, k );
                continue;
            fi;
        fi;
        if i <> fail and i < Length(Primes) then
            i := i + 1;
            k := Primes[i];
        else
            k := NextPrimeInt( k );
        fi;
    od;

    return s * n;
end);


#############################################################################
##
#M  RingByGenerators( <elms> ) . . . . . . .  ring generated by some integers
##
InstallMethod( RingByGenerators,
    "method that catches the cases of `Integers' and subrings of `Integers'",
    [ IsCyclotomicCollection ],
    SUM_FLAGS, # test this before doing anything else
    function( elms )
      if ForAll( elms, IsInt ) then
        # check that the number of generators is bigger than one
        # to avoid infinite recursion
        if Length( elms ) > 1 then
          return RingByGenerators( [ Gcd(elms) ] );
        elif elms[1] = 1 then
          return Integers;
        else
          TryNextMethod();
        fi;
      else
        TryNextMethod();
      fi;
    end );


#############################################################################
##
#M  RingWithOneByGenerators( <elms> ) . . . . ring generated by some integers
##
InstallMethod( RingWithOneByGenerators,
    "method that catches the cases of `Integers'",
    [ IsCyclotomicCollection ],
    SUM_FLAGS, # test this before doing anything else
    function( elms )
      if ForAll( elms, IsInt ) then
        return Integers;
      else
        TryNextMethod();
      fi;
    end );


#############################################################################
##
#M  DefaultRingByGenerators( <elms> ) default ring generated by some integers
##
InstallMethod( DefaultRingByGenerators,
    "method that catches the cases of `(Gaussian)Integers' and cycl. fields",
    [ IsCyclotomicCollection ],
    SUM_FLAGS, # test this before doing anything else
    function( elms )
      if ForAll( elms, IsInt ) then
        return Integers;
      elif ForAll( elms, IsGaussInt ) then
        return GaussianIntegers;
      else
        return DefaultField( elms );
      fi;
    end );


#############################################################################
##
#M  DefaultRingByGenerators( <mats> ) .  for a list of n x n integer matrices
##
InstallMethod( DefaultRingByGenerators,
               "for lists of n x n integer matrices", true,
               [ IsCyclotomicCollCollColl and IsFinite ],

  function ( mats )
    local d;
    if IsEmpty(mats) or not ForAll(mats,IsRectangularTable and IsMatrix) then
       TryNextMethod();
    fi;
    d := Length( mats[1] );
    if d=0 then
       TryNextMethod();
    fi;
    if not ForAll( mats, m -> Length(m)=d and Length(m[1])=d ) then
       TryNextMethod();
    fi;
    if not ForAll( mats, m -> ForAll( m, r -> ForAll(r,IsInt))) then
       TryNextMethod();
    fi;
    return FullMatrixAlgebra(Integers,d);
  end );


#############################################################################
##
#M  Enumerator( Integers )
##
##  $a_n = \frac{n}{2}$ if $n$ is even, and
##  $a_n = \frac{1-n}{2}$ otherwise.
##
InstallMethod( Enumerator,
    "for integers",
    [ IsIntegers ],
    Integers -> EnumeratorByFunctions( Integers,
        rec( ElementNumber := function( e, n )
               if n mod 2 = 0 then
                 return n / 2;
               else
                 return ( 1 - n ) / 2;
               fi;
               end,

             NumberElement := function( e, x )
               local pos;
               if not IsInt( x ) then
                 return fail;
               elif 0 < x then
                 pos:= 2 * x;
               else
                 pos:= -2 * x + 1;
               fi;
               return pos;
               end ) ) );


#############################################################################
##
#M  EuclideanDegree( Integers, <n> ) . . . . . . . . . . . . . absolute value
##
InstallMethod( EuclideanDegree,
    "for integers",
    true,
    [ IsIntegers, IsInt ], 0,
    function ( Integers, n )
    if n < 0  then
        return -n;
    else
        return n;
    fi;
    end );


#############################################################################
##
#M  EuclideanQuotient( Integers, <n>, <m> )   . . . . . .  Euclidean quotient
##
InstallMethod( EuclideanQuotient,
    "for integers",
    true,
    [ IsIntegers, IsInt, IsInt ], 0,
    function ( Integers, n, m )
    return QuoInt( n, m );
    end );


#############################################################################
##
#M  EuclideanRemainder( Integers, <n>, <m> )  . . . . . . Euclidean remainder
##
InstallMethod( EuclideanRemainder,
    "for integers",
    true,
    [ IsIntegers, IsInt, IsInt ], 0,
    function ( Integers, n, m )
    return RemInt( n, m );
    end );


#############################################################################
##
#M  Factors( Integers, <n> )  . . . . . . . . . . factorization of an integer
##
InstallMethod( Factors,
    "for integers",
    true,
    [ IsIntegers, IsInt ], 0,
    function ( Integers, n )
    return FactorsInt( n );
    end );


#############################################################################
##
#M  IsIrreducibleRingElement( Integers, <n> )
##
InstallMethod( IsIrreducibleRingElement,
    "for integers",
    true,
    [ IsIntegers, IsInt ], 0,
    function ( Integers, n )
    return IsPrimeInt( n );
    end );


#############################################################################
##
#M  IsPrime( Integers, <n> )  . . . . . .  test whether an integer is a prime
##
InstallMethod( IsPrime,
    "for integers",
    true,
    [ IsIntegers, IsInt ], 0,
    function ( Integers, n )
    return IsPrimeInt( n );
    end );


#############################################################################
##
#M  Iterator( Integers )
##
##  uses the succession $0, 1, -1, 2, -2, 3, -3, \ldots$, that is,
##  $a_n = \frac{n}{2}$ if $n$ is even, and $a_n = \frac{1-n}{2}$
##  otherwise.
##
InstallMethod( Iterator,
    "for `Integers'",
    [ IsIntegers ],
    Integers -> IteratorByFunctions( rec(
        NextIterator := function( iter )
            iter!.counter:= iter!.counter + 1;
            if iter!.counter mod 2 = 0 then
              return iter!.counter / 2;
            else
              return ( 1 - iter!.counter ) / 2;
            fi;
            end,
        IsDoneIterator := ReturnFalse,
        ShallowCopy := iter -> rec( counter:= iter!.counter ),
        PrintObj := function(iter)
            local msg;
            msg := "<iterator of Integers at ";
            if iter!.counter mod 2 = 0 then
              Append(msg, String(iter!.counter / 2));
            else
              Append(msg, String((1 - iter!.counter) / 2));
            fi;
            Append(msg,">");
            Print(msg);
          end,
        counter := 0 ) ) );


#############################################################################
##
#M  Iterator( PositiveIntegers )
##
InstallMethod( Iterator,
    "for `PositiveIntegers'",
    [ IsPositiveIntegers ],
    IsPositiveIntegers -> IteratorByFunctions( rec(
        NextIterator := function( iter )
            iter!.counter:= iter!.counter + 1;
              return iter!.counter;
            end,
        IsDoneIterator := ReturnFalse,
        ShallowCopy := iter -> rec( counter:= iter!.counter ),

        counter := 0 ) ) ); # 0, since we first increment then return


#############################################################################
##
#M  LcmOp( Integers, <n>, <m> ) . . . . . . least common multiple of integers
##
InstallMethod( LcmOp,
    "for integers",
    true,
    [ IsIntegers, IsInt, IsInt ], 0,
    function ( Integers, n, m )
    return LcmInt( n, m );
    end );


#############################################################################
##
#M  Log( <n>, <base> )
##
InstallMethod( Log,
    "for two integers",
    true,
    [ IsInt, IsInt ], 0,
    LogInt );


#############################################################################
##
#M  PowerMod( Integers, <r>, <e>, <m> ) . . . power of an integer mod another
##
InstallMethod( PowerMod,
    "for integers",
    true,
    [ IsIntegers, IsInt, IsInt, IsInt ], 0,
    function ( Integers, r, e, m )
    return PowerModInt( r, e, m );
    end );


#############################################################################
##
#M  Quotient( <Integers>, <n>, <m> )  . . . . . . .  quotient of two integers
##
InstallMethod( Quotient,
    "for integers",
    true,
    [ IsIntegers, IsInt, IsInt ], 0,
    function ( Integers, n, m )
    local   q;
    if m = 0 then
        return fail;
    fi;
    q := QuoInt( n, m );
    if n <> q * m  then
        q := fail;
    fi;
    return q;
    end );


#############################################################################
##
#M  QuotientMod( Integers , <r>, <s>, <m> ) . . . . . . . quotient modulo <m>
##
InstallMethod( QuotientMod,
    "for integers",
    true,
    [ IsIntegers, IsInt, IsInt, IsInt ], 0,
    function ( Integers, r, s, m )
    local g;
    if m = 1 then
        return 0;
    else
        r := r mod m;
        if r = 0 then return 0; fi;  # as required by QuotientMod documentation
        s := s mod m;
        if s = 0 then return fail; fi;

        g := GcdInt( r, s );
        r := r / g;
        s := s / g;
        g := GcdInt( g, m );
        m := m / g;
        if GcdInt( s, m ) <> 1 then
            return fail;
        fi;
        return r * INVMODINT(s, m) mod m;
    fi;
    end );


#############################################################################
##
#M  QuotientRemainder( Integers, <n>, <m> ) . . . . . . . . . . . quo and rem
##
InstallMethod( QuotientRemainder,
    "for integers",
    true,
    [ IsIntegers, IsInt, IsInt ], 0,
    function ( Integers, n, m )
      local q;
      q := QuoInt(n,m);
      #T kernel function should compute remainder at same time
      return [ q, n - q * m ];
    end );


#############################################################################
##
#M  Random( Integers )  . . . . . . . . . . . . . . . . . . .  random integer
##
##  returns pseudo random integers between $-10$ and $10$
##  distributed according to a binomial distribution.
##
##  \begintt
##  gap> Random( Integers );
##  1
##  gap> Random( Integers );
##  -4
##  \endtt
##
##  To generate uniformly distributed integers from a range, use the
##  construct `Random( [ <low> .. <high> ] )'.
##
BindGlobal( "NrBitsInt", function ( n )
    local   nr, nr64;
    nr64:=[0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4,1,2,2,3,2,3,3,4,2,3,3,4,3,4,4,5,
           1,2,2,3,2,3,3,4,2,3,3,4,3,4,4,5,2,3,3,4,3,4,4,5,3,4,4,5,4,5,5,6];
    nr := 0;
    while 0 < n  do
        nr := nr + nr64[ n mod 64 + 1 ];
        n := QuoInt( n, 64 );
    od;
    return nr;
end );

InstallMethodWithRandomSource(Random,
    "for a random source and `Integers'", true,
    [IsRandomSource, IsIntegers],
    0,
    function( rg, Integers )
    return NrBitsInt( Random( rg, 0, 2^20-1 ) ) - 10;
    end );



#############################################################################
##
#M  Root( <n>, <k> )
##
InstallMethod( Root,
    "for two integers",
    true,
    [ IsInt, IsInt ], 0,
    RootInt );


#############################################################################
##
#M  RoundCyc( <cyc> ) . . . . . . . . . . cyclotomic integer near to <cyc>
##
InstallMethod( RoundCyc, "Integer", true, [ IsInt ], 0,  x->x );


#############################################################################
##
#M  RoundCycDown( <cyc> ) . . . . . . . . . . cyclotomic integer near to <cyc>
##
InstallMethod( RoundCycDown, "Integer", true, [ IsInt ], 0,  x->x );


#############################################################################
##
#M  StandardAssociate( Integers, <n> )  . . . . . . . . . . .  absolute value
##
InstallMethod( StandardAssociate,
    "for integers",
    true,
    [ IsIntegers, IsInt ], 0,
    function ( Integers, n )
    if n < 0  then
        return -n;
    else
        return n;
    fi;
    end );

#############################################################################
##
#M  StandardAssociateUnit( Integers, <n> )
##
InstallMethod( StandardAssociateUnit,
    "for integers",
    true,
    [ IsIntegers, IsInt ], 0,
    function ( Integers, n )
    if n < 0 then
        return -1;
    else
        return 1;
    fi;
    end );


#############################################################################
##
#M  Valuation( <n>, <m> )
##
InstallOtherMethod( Valuation,
    "for two integers",
    IsIdenticalObj,
    [ IsInt, IsInt ],
    0,
function( n, m )
    if n = 0  then
        return infinity;
    fi;
    return PVALUATION_INT( n, m );
end );


#############################################################################
##
#M  \in( <n>, <Integers> )  . . . . . . . . . .  membership test for integers
##
InstallMethod( \in,
    "for integers",
    IsElmsColls,
    [ IsCyclotomic, IsIntegers ], 0,
    function( n, Integers )
    return IsInt( n );
    end );


#############################################################################
##
#M  \in( <n>, <PositiveIntegers> )
##
InstallMethod( \in,
    "for positive integers",
    IsElmsColls,
    [ IsCyclotomic, IsPositiveIntegers ], 0,
    function( n, PositiveIntegers )
    return IsPosInt( n );
    end );


#############################################################################
##
#M  \in( <n>, <NonnegativeIntegers> )
##
InstallMethod( \in,
    "for nonnegative integers",
    IsElmsColls,
    [ IsCyclotomic, IsNonnegativeIntegers ], 0,
    function( n, NonnegativeIntegers )
    return IsPosInt( n ) or IsZeroCyc( n );
    end );


#############################################################################
##
#F  PrintFactorsInt( <n> )  . . . . . . . . print factorization of an integer
##
InstallGlobalFunction(PrintFactorsInt,function ( n )
    Print( StringPP( n ) );
end);

#############################################################################
##
#M  Iterator( <posint> ) . . . . . . . . . . . . .give more informative error
##
##  This method is mainly there to trap the "natural" error
##  for i in 3 do ... od;
##

InstallOtherMethod(Iterator, "more helpful error for integers", true,
        [IsPosInt], 0,
        function(n)
    Error("You cannot loop over the integer ",n,
          " did you mean the range [1..",n,"]");
end);

##  The behaviour of View(String) for large integers can be configured via a
##  user preference.
DeclareUserPreference( rec(
  name:= "MaxBitsIntView",
  description:= [
    "Maximal bit length of integers to <C>View</C> unabbreviated.  \
Default is about <M>30</M> lines of a <M>80</M> character wide terminal.  \
Set this to <C>0</C> to avoid abbreviated ints."
    ],
  default:= 8000,
  check:= val -> IsInt( val ) and 0 <= val,
  ) );
##  give only a short info if |n| is larger than 2^GAPInfo.MaxBitsIntView
InstallMethod(ViewString, "for integer", [IsInt], function(n)
  local mb, l, start, trail;
  mb := UserPreference("MaxBitsIntView");
  if not IsSmallIntRep(n) and mb <> fail and
      mb > 64 and Log2Int(n) > mb then
    if n < 0 then
      l := LogInt(-n, 10);
      trail := String(-n mod 1000);
    else
      l := LogInt(n, 10);
      trail := String(n mod 1000);
    fi;
    start := String(QuoInt(n, 10^(l-2)));
    while Length(trail) < 3 do
      trail := Concatenation("0", trail);
    od;
    return Concatenation("<integer ",start,"...",trail," (",
                         String(l+1)," digits)>");
  else
    return String(n);
  fi;
end);
