
/*This program is designed to calculate stabilizers for iteration 
of p-group generation in cases where the automorphism group of the 
starting group is insoluble. The input file for this program is 
created using the p-group generation algorithm implementation
within the p-Quotient Program (PQP). The program is handed a matrix 
group representing the action of the general linear group or the 
appropriate subgroup thereof on a finite p-group. The action of
the automorphisms extended to a characteristic subgroup of the 
p-multiplicator of the group is also represented as a subgroup 
of the appropriate general linear group. The generators of the 
stabilizers of each orbit representative are determined as words 
in the original generators of the automorphism group. This is done 
by building up images under the action of random words in the defining 
generators,  where the individual letters in a word are selected on a 
random basis. When the stabilizer has been determined within the 
automorphism group, a composition series with cyclic factors is 
calculated if it is soluble. Appropriate information is written out 
to create a file for input to PQP*/

/*compute the image of the matrix under the action of the automorphism*/

matimage := procedure( f, p, nsteps, nmrgens, m, rvec, ~ivec )

        ivec := [f!0];

        for i := 1 to nsteps  do
                entry := (i-1)*nmrgens;
                for j := 1 to nmrgens  do
                        add := 0;
                        for k := 1 to nmrgens  do
                                matent := ((j-1)*nmrgens)+k;
                                add := add+(m[matent]*rvec[entry+k]);
                        end for;
                        ivec[entry+j] := add;
                end for;
        end for;
        for row := 1 to nsteps  do

                zero := true;
                col := row-1;
                while (zero) do
                        col := col+1;
                        valueofi := nsteps + 1;
                        for i := row to nsteps  do
                                entry := ((i-1)*nmrgens)+col;
                                if (ivec[entry] ne 0) then
                                        zero := false;
                                        valueofi := i;
                                        break;
                                end if;
                        end for;
                end while;

                i := valueofi;
                if (i gt row) then
                        for j := col to nmrgens  do
                                prev := ((row-1)*nmrgens)+j;
                                entry := ((i-1)*nmrgens)+j;
                                temp := ivec[entry];
                                ivec[entry] := ivec[prev];
                                ivec[prev] := temp;
                        end for;
                end if;

                hold := (row-1)*nmrgens;
                x := ivec[hold+col]^(-1);

                for j := col to nmrgens  do
                        entry := hold+j;
                        ivec[entry] := ivec[entry]*x;
                end for;

                for i := 1 to nsteps  do
                        if (i eq row) then
                                continue;
                        end if;
                        entry := ((i-1)*nmrgens)+col;
                        y :=  p-ivec[entry];
                        for j := col to nmrgens  do
                                entry := ((i-1)*nmrgens)+j;
                                ivec[entry] := ivec[entry]+(ivec[hold+j]*y);
                        end for;
                end for;
        end for;

end procedure;


labmat := procedure( f, p, label, len, holdid, nmrids, nsteps, nmrgens, ~reps )

        l := label;
        idpos := [0];
        update := [0];
        reps := [f!0];

        valueofidnmr := nmrids + 1;
        for idnmr := 1 to nmrids  do
                totlen := p^len[idnmr];
                if (l le totlen) then
                        valueofidnmr := idnmr;
                        break;
                end if;
                l := l-totlen;
        end for;

        idnmr := valueofidnmr;
        if nmrgens ge 10 then
                mult := 100;
        else
                mult := 10;
        end if;
        fac := mult^(nsteps-1);
        hold := holdid[idnmr];
        for j := 1 to nsteps  do
                idpos[j] :=  hold div fac; 
                hold :=  hold-(( hold div fac ) *fac);
                fac :=  fac div mult; 
        end for;

        matlen := nmrgens*nsteps;
        for i := 1 to matlen  do
                reps[i] := f!0;
        end for;

        for i := 1 to nsteps  do
                x := ((i-1)*nmrgens)+idpos[i];
                reps[x] := f!1;
        end for;

        nmrent := 0;
        idpos[nsteps+1] := 0;
        for i := 1 to nsteps  do
                hold := i+1;
                for j := idpos[i]+1 to nmrgens  do
                        if (j ne idpos[hold]) then
                                nmrent := nmrent+1;
                                update[nmrent] := (i*100)+j;
                        else
                                hold := hold+1;
                        end if;
                end for;
        end for;

        l := l-1;
        fac :=  totlen div p; 
        for k := 1 to nmrent  do
                entry :=  l div fac; 
                l :=  l-(( l div fac )*fac);
                fac :=  fac div p; 
                if (entry ne 0) then
                        u := update[ (nmrent+1)-k]; 
                        rownmr := u div 100;
                        colnmr :=   u-((u div 100)*100);
                        x := ((rownmr-1)*nmrgens)+colnmr;
                        for e := 1 to entry  do
                                reps[x] := reps[x]+(f!1);
                        end for;
                end if;
        end for;

end procedure;


shift := procedure( g, temp, noofge, ~hold )

        ltemp := noofge;
        lhold := #(hold);
        if hold[1] eq ( Id(g) ) then
                lhold := 0;
        end if;
        for i := lhold+1 to lhold+ltemp  do
                hold[i] := Id(g);
        end for;
        for i := 1 to lhold  do
                hold[( (ltemp+lhold)-i )+1] := hold[( lhold-i )+1];
        end for;
        for i := 1 to ltemp  do
                hold[i] := temp[i];
        end for;
end procedure;

/*procedure shift*/

/*given a soluble group G, this procedure calculates a composition series 
for the group together with a system of generators of the series which 
ascend the series in cyclic steps. The system of generators is obtained 
starting at the top and working down the series*/

compseries := function( g )

        k := g;

        compgens := [ Id(g) ];
        temp := [ Id(g) ];
        noofge := 0;

        while Order(k) ne 1 do
                d := DerivedGroup(k);
                sqprim := FactoredOrder( k / d  );
                done := false;
                totord := Order( k / d );

                /*set up the generators of K in a sequence*/
                genset := Generators(k);
                gen := Setseq(genset);
                l := #(gen);
                m := d;
                nprime := #(sqprim);

                for i := 1 to nprime  do

                        offset := (i);
                        p := sqprim[offset][1];
                        n := sqprim[offset][2];

                        step := p^n;
                        done := false;
                        reqord := Order(m)*step;
                        remain :=  totord div step; 

                        for j := 1 to l  do
                                found := false;
                                valueofq := n + 1;
                                for q := 0 to n  do
                                        expn := p^q;
                                        if  (gen[j]^(remain*expn)) in m then
                                                found := true;
                                                valueofq := q;
                                                break;
                                        end if;
                                end for;
                                if not found then
                                        continue;
                                end if;
                                q := valueofq;
                                for r := 0 to q-1  do
                                        expn := p^((q-1)-r );
                                        noofge := noofge+1;
                                        temp[noofge] := gen[j]^(remain*expn);
                                        m :=  sub< g | m, temp[noofge] > ;
                                        // if Order(m) eq reqord then
// BUG FIX EOB
                                        if Order(m) ge reqord then
                                                done := true;
                                        end if;
                                end for;
                                if (done) then
                                        break;
                                end if;
                        end for;

                end for;
                shift( g, temp, noofge, ~compgens );
                noofge := 0;
                k := d;

        end while;
return compgens;

end function;
/*compgen*/


/*verify the cyclic factor group structure of the composition series 
given in COMPGEN setting error equal to true if any failure*/

verify := procedure( g, compge, ~Error )

        Error := false;

        subgp := sub< g | compge[1] > ;

        for i := 2 to #(compge)  do
                orig := subgp;
                subgp := sub< g | subgp, compge[i] > ;
                facgp := quo< subgp | orig >  ;
                if not IsPrime(Order(facgp)) then
                        Error := true;
                        return;
                end if;
        end for;

end procedure;


/*now process each orbit rep in turn to obtain its stabilizer*/

autg := sub < glnp | gen >;
ordaut := Order(autg);

autqg := sub< glqp |  genq  > ;

rvec := f![0];
ivec := rvec;
ord := [0];
qgen := [[f!0]];
for i := 1 to t  do
        qgen[i] := Eltseq(genq[i]);
end for;

nmrorb := #(r);

for n := 1 to nmrorb  do

        reqord := ordaut div orblen[n]; 
        labmat( f, p, r[n], len, holdid, nmrids, nsteps, nmrgens, ~rvec );
        stab := [ Id(glnp) ];
        done := false;
        stabgp := sub< glnp | stab >;
        nmrsta := 0;
        for i := 1 to t  do

                if (genq[i] ne (Id(autqg))) then
                        matimage( f, p, nsteps, nmrgens, qgen[i], rvec, ~ivec );
                end if;

                if ((genq[i] eq (Id(autqg))) or (ivec eq rvec)) then
                        stabge := gen[i]^(-1);
                        if not ( stabge in stabgp ) then
                                nmrsta := nmrsta+1;
                                stab[nmrsta] := stabge;
                                stabgp :=  sub< glnp | stabgp, stabge > ;
                        end if;
                        // if (Order(stabgp) eq reqord) then
// BUG FIX EOB 
                        if (Order(stabgp) ge reqord) then
                                done := true;
                                break;
                        end if;
                end if;
                ord[i] := Order(genq[i]);
        end for;

        pathle := 1;
        rangen := [0];
        l := 0;
        prevl := 0;
        lastpo := 0;
        lastg := 0;
        nlastg := 0;
        sol := 0;
        orbelt := [rvec];
        found := false;
        while (not done) do
                while (not found) do

                        j := Random([1..t]);
                        if (j eq lastg) then
                                if (nlastg ne (ord[j]-1)) then
                                        found := true;
                                        nlastg := nlastg+1;
                                end if;
                        else
                                lastg := j;
                                nlastg := 1;
                                found := true;
                        end if;

                end while;
                found := false;
                l := l+1;
                rangen[l] := j;
                matimage( f, p, nsteps, nmrgens, qgen[j], rvec, ~ivec );

                pos := 0;
                for k := 1 to pathle  do
                        if (ivec eq orbelt[k]) then
                                pos := k;
                                break;
                        end if;
                end for;

                if (pos ne 0) then
                        stabge := Id(glnp);
                        for k := 1 to lastpo  do
                                stabge := stabge*(gen[rangen[k]]^(-1));
                        end for;
                        for k := prevl+1 to l  do
                                stabge := stabge*(gen[rangen[k]]^(-1));
                        end for;
                        for k := 1 to pos-1  do
                                stabge := stabge*gen[rangen[ pos-k ]];
                        end for;
                        if not ( stabge in stabgp ) then
                                nmrsta := nmrsta+1;
                                stab[nmrsta] := stabge;
                                stabgp :=  sub< glnp | stabgp, stab[nmrsta] > ;
                                // if Order(stabgp) eq reqord then
// BUG FIX EOB 
                                if (Order(stabgp) ge reqord) then
                                        done := true;
                                end if;
                        end if;
                        lastpo := pos-1;
                        prevl := l;
                end if;
                pathle := pathle+1;
                orbelt[pathle] := ivec;
                rvec := ivec;

        end while;

        /*if stabilizer is soluble then calculate composition series*/
        if IsSoluble(stabgp) then
                sol := -1;
                stab := compseries( stabgp );

                /*verify accuracy of composition series calculation*/
                verify( stabgp, stab, ~Error );
                if Error then
                   print "*** Error in composition series calculation for orbit rep", n, "***";
                end if;
        end if;

        nsj := #(stab);
        print sol;
        print nsj;
        for i := 1 to nsj  do
                print stab[i];
        end for;
end for;

/*for n*/
