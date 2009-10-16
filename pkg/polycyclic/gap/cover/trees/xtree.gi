WIDTH := 25;
DEPTH := 40;
SSIZE := [1000, 700];

PrintScale := function( Sheet, p, s, r, l )
    local y, i, t;

    # the top line
    Text( Sheet, FONTS.normal, 20, 30, "|G|" );
    Text( Sheet, FONTS.normal, 100, 30, "tree" );

    # the first columns
    y := 30;
    for i in [s..l] do
        y := y + 40;
        t := Concatenation( String(p), "^", String(i+r));
        Text( Sheet, FONTS.normal, 20, y, t );
        #Text( Sheet, FONTS.normal, 60, y, String(i) );
    od;
end;

StringIt := function(t)
    if IsString(t) then return t; fi;
    if IsInt(t) then return String(t); fi;
    if IsList(t) then 
       return Concatenation(List(t, x->Concatenation("-",String(x))));
    fi;
end;

PrintVertex := function( Sheet, cl, nr, tx, pa, ty )
    local x, y;

    # set up x and y values
    x := 100 + WIDTH * (nr-1);
    y := 70  + DEPTH * cl;

    # print vertex
    if ty=1 then
        Disc( Sheet, x, y, 3 );
    elif ty = 2 then 
        Circle( Sheet, x, y, 3 );
    elif ty = 3 then 
        Box( Sheet, x, y, 3, 3 );
    elif ty = 4 then 
        Rectangle( Sheet, x, y, 3, 3 );
    fi;

    # print line
    Line( Sheet, pa[1], pa[2], x-pa[1], y-pa[2] );

    # add text
    if not IsBool(tx) then 
        Text( Sheet, FONTS.small, x+2, y, StringIt(tx) ); 
    fi;

    # return place
    return [x, y];
end;

CoclassPGroup := function(G)
    local n,c;
    n := Length(Factors(Size(G)));
    c := Length(LowerCentralSeries(G))-1;
    return n-c;
end;

DrawCoverTree := function( G, r )
    local Title, Sheet, grp, res, nex, des, sub, p, i, j, c, m, d, g, v, H;

    # set up graphic sheet 
    Title := Concatenation( "Cover tree for ", StringIt(AbelianInvariants(G)));
    Sheet := GraphicSheet( Title, SSIZE[1], SSIZE[2] );

    # set up for iteration
    grp := [[G,[100, 70]]];
    res := [[G]];
    AddSExtension(G);
    p := PrimePGroup(G);
    i := 0;

    # init tree
    if CoclassPGroup(G) < r then 
        Circle( Sheet, 100, 70, 3 );
    else
        Disc( Sheet, 100, 70, 3 );
    fi;
    
    # compute iterated descendants
    repeat
        nex := [];
        j := 1;
        i := i+1;
        for H in grp do
 
            # get invars
            c := CoclassPGroup(H[1]);
            m := H[1]!.mord;
            d := c+Length(Factors(m))-1;

            # check
            if m > 1 and d <= r then 

                # compute covers 
                des := SchurCovers(H[1]);
                for g in des do AddSExtension(g); od;

                # filter
                if d < r then 
                    des := Filtered(des, x -> x!.mord > 1);
                    des := Filtered(des, x -> d+Length(Factors(x!.mord))-1<=r);
                    for g in des do
                        repeat
                            v := PrintVertex( Sheet, i, j, false, H[2],2); 
                            j := j + 1;
                        until not IsBool(v); 
                        Add( nex, [g, v] );
                    od;
                fi;

                if d = r then 

                    # non-terminal
                    sub := Filtered(des, x -> x!.mord = p);
                    for g in sub do
                        repeat
                            v := PrintVertex( Sheet, i, j, false, H[2],1); 
                            j := j + 1;
                        until not IsBool(v); 
                        Add( nex, [g, v] );
                    od;

                    # terminal with non-triv. Schu-Mu
                    sub := Filtered(des, x -> x!.mord > p);
                    if Length(sub)>0 then
                        repeat    
                            v := PrintVertex(Sheet,i,j,Length(sub),H[2],3); 
                            j := j + 1;
                        until not IsBool(v); 
                    fi;
                    
                    # terminal with triv. Schu-Mu
                    sub := Filtered(des, x -> x!.mord = 1);
                    if Length(sub)>0 then
                        repeat    
                            v := PrintVertex(Sheet,i,j,Length(sub),H[2],1); 
                            j := j + 1;
                        until not IsBool(v); 
                    fi;
                fi;
            fi;
        od;

        # reset for next level
        grp := nex;
    until Length(grp)=0;
end;

DrawSubtree := function( Sheet, root, v, tree )
    local  x, y, w, j;    

    # get x and y
    x := v;
    y := root[2]+40;

    # draw vertex
    if tree[1] = 1 then 
        Disc( Sheet, x, y, 3 );
    elif tree[1] = 2 then 
        Circle( Sheet, x, y, 3 );
    elif tree[1] = 3 then 
        Diamond( Sheet, x, y, 3, 3 );
    fi;

    # draw line
    Line( Sheet, root[1], root[2], x-root[1], y-root[2] );

    # add text
    if tree[3] > 1 then 
        Text( Sheet, FONTS.small, x+2, y, StringIt(tree[3]) ); 
    fi;

    # init recursion
    w := v;
    if Length(tree[2]) > 0 then 
        for j in [1..Length(tree[2])] do
            if IsBound(tree[2][j]) then 
                w := DrawSubtree( Sheet, [x,y], w, tree[2][j]) + 25;
            fi;
        od;
        if j = Length(tree[2]) then w := w-25; fi;
    fi;

    # return maximal x-value
    return w;
end;

DrawRootedTree := function( grps )
    local Sheet, v, d, j;

    Sheet := GraphicSheet( "Tree", 1000, 700 );
    
    # draw root
    if grps[1] = 1 then 
        Disc( Sheet, 70, 100, 3 );
    elif grps[1] = 2 then 
        Circle( Sheet, 70, 100, 3 );
    elif grps[1] = 3 then 
        Diamond( Sheet, 70, 100, 3, 3 );
    fi;

    v := 70;
    for j in [1..Length(grps[2])] do
        if IsBound(grps[2][j]) then 
            v := DrawSubtree( Sheet, [70,100], v, grps[2][j] )+25;
        fi;
    od;

end;

CollectedTree := function(tree)
    local i, j, des;

    Print("collect tree ",tree,"\n");

    # catch the trivial case
    if Length(tree)=0 then return []; fi;

    des := List(tree[2], x -> x{[1,2]});

    # loop over descendants and collect
    for i in [1..Length(des)] do
        j := Position(des, des[i]);
        if j < i then 
            tree[2][j][3] := tree[2][j][3] + 1;
            tree[2][i] := false;
        fi;
    od;
    tree[2] := Filtered(tree[2], x -> not IsBool(x));
    Print("  and got ",tree,"\n\n");
 
    # recurse
    for i in [1..Length(tree[2])] do
        tree[2][i] := CollectedTree(tree[2][i]);
    od;

    return tree;
end;

ConstCoverTree := function( G, r )
    local p, o, grps, t, H, c, m, d, new, des, i, j;

    # set up
    p := PrimePGroup(G);
    o := CoverCode(G); o[4] := CoclassPGroup(G);
    t := 0;

    # init list
    grps := [o];

    # compute iterated descendants
    while t < Length(grps) do
        t := t+1;

        # get invars
        c := grps[t][4];
        m := grps[t][2];
        d := c+Length(Factors(m))-1;

        # compute covers 
        if m > 1 and d<=r then 
            H := CodeCover(grps[t]);
            new := SchurCovers(H); 
            for i in [1..Length(new)] do
                new[i] := CoverCode(new[i]); 
                new[i][4] := d;
            od;
            Append(grps, new);
            des := [Length(grps)-Length(new)+1 .. Length(grps)];
        else
            des := [];
        fi;

        # replace grps[t]
        if c < r then 
            grps[t] := [1, des];
        fi;

        if c = r then 
            if m = 1 then 
                grps[t] := [3, []];
            else
                grps[t] := [2, des];
            fi;
        fi;
    od;

    # reverse tree structure
    for t in Reversed([1..Length(grps)]) do
        if Length(grps[t][2])>0 then 
            des := List(grps[t][2], x -> grps[x]);
            for i in grps[t][2] do Unbind(grps[i]); od;
            grps[t][2] := des;
        fi;
        grps[t][3] := 1;
    od;

    # collect tree structure
    grps := CollectedTree(grps[1]);

    # draw tree
    DrawRootedTree( grps );
end;


