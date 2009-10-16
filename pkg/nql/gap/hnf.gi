############################################################################
##
#W hnf.gi			NQL				René Hartung
##
#H   @(#)$Id: hnf.gi,v 1.4 2008/11/10 15:42:50 gap Exp $
##
Revision.("nql/gap/hnf_gi"):=
  "@(#)$Id: hnf.gi,v 1.4 2008/11/10 15:42:50 gap Exp $";


############################################################################
##
#F  NQL_PowerRelationsOfHNF ( <rec> )
##
## computes the power relations w.r.t. the Hermite normal form <rec>.
##
InstallGlobalFunction( NQL_PowerRelationsOfHNF,
  function(HNF)
  local i,j,	# loop variables
	A;	# matrix of power relations w.r.t. HNF

  A:=ShallowCopy(HNF.mat);

  # determine the power relations a_i^m_i=w(a_{i+1}..a_n) from the 
  # Hermite normal form 
  for i in [1..Length(HNF.Heads)] do
    if A[i][HNF.Heads[i]]>1 then 
      for j in [1..i-1] do
        if A[j][HNF.Heads[i]]<>0 then
          if IsInt(A[j][HNF.Heads[i]]/A[i][HNF.Heads[i]]) then 
            A[j]:=A[j]-A[j][HNF.Heads[i]]/A[i][HNF.Heads[i]] * A[i];
          elif A[j][HNF.Heads[i]]>0 then    
            A[j]:=A[j]-(QuoInt(A[j][HNF.Heads[i]],A[i][HNF.Heads[i]])+1) * A[i];
          elif A[j][HNF.Heads[i]]<-A[i][HNF.Heads[i]] then 
            A[j]:=A[j]-(QuoInt(A[j][HNF.Heads[i]],A[i][HNF.Heads[i]])) * A[i];
          fi;
        fi;
  
        if NQL_TEST_ALL then 
          if not A[j][HNF.Heads[i]]<=0 or 
             not A[j][HNF.Heads[i]]>-A[i][HNF.Heads[i]] then 
            Error("in NQL_PowerRelationsOfHNF");
          fi;
        fi;
      od;
    fi;
  od;

  return(A);
  end);

############################################################################
##
#F  NQL_ReduceHNF ( <mat> , <int> )
##
## if a new reduced row is added to the Hermite normal form, it has to be 
## reduced again.
##
InstallGlobalFunction( NQL_ReduceHNF,
  function(HNF,n)
  local corner,	# corner entries in HNF
	column,	# corresponding column in HNF
  	row,	# corresponding row in HNF
	q;	# quotient of 
 
  # after adding a row to the HNF we have to reduce the 
  # old HNF
  for corner in [n..Length(HNF.Heads)] do
    column:=HNF.Heads[corner];
    for row in [1..corner-1] do
      if IsInt(HNF.mat[row][column]/HNF.mat[corner][column]) then 
        q:=HNF.mat[row][column]/HNF.mat[corner][column];
        HNF.mat[row]:=HNF.mat[row]-q*HNF.mat[corner];
      elif HNF.mat[row][column]<0 then 
        q:=-QuoInt(HNF.mat[row][column],HNF.mat[corner][column])+1;
        HNF.mat[row]:=HNF.mat[row]+q*HNF.mat[corner];
      elif HNF.mat[row][column]>=HNF.mat[corner][column] then
        q:=QuoInt(HNF.mat[row][column],HNF.mat[corner][column]);
        HNF.mat[row]:=HNF.mat[row]-q*HNF.mat[corner];
      fi;
    od;
  od;

  end);

############################################################################
##
#F  NQL_AddRow ( <mat> , <evec> )
##
## adds the row <evec> to the Hermite normal form <mat> and returns
## whether <mat> has changed.
##
InstallGlobalFunction( NQL_AddRow,
  function(HNF,ev)
  local evn,		# reduced <ev>
	lcm,		# least common multiple
	i,j,k,l,q,	# loop variables
	Changed,	# did <ev> changed the HNF?
	B,b;		# check variables

  if NQL_TEST_ALL then 
    B:=ShallowCopy(HNF.mat);
    b:=ShallowCopy(ev);
  fi;
  
  Changed:=false;
  
  if IsZero(ev) then 
    return(false);
  fi;
  
  # the HNF does not contain any row
  if HNF.mat=[] then 
    if ev[PositionNonZero(ev)]>0 then 
      Add(HNF.mat,ev);
    else
      Add(HNF.mat,-ev);
    fi;
    Add(HNF.Heads,PositionNonZero(ev));
    return(true);
  fi;
  
  # reduce <ev> and the HNF
  i:=1;
  while i<=Length(ev) do 
    if ev[i]<>0 then 
      if not i in HNF.Heads then 
        # new corner-entry
  
        # Determine the entry in which <ev> will be added
        j:=Length(HNF.Heads)+1;
        for k in [1..Length(HNF.Heads)] do 
          if i<HNF.Heads[k] then 
            j:=k; 
            break;
          fi; 
        od;   
  
        if j>Length(HNF.Heads) then 
          # new position at the end
          Append(HNF.Heads,[i]);
          if ev[i]>0 then 
            Append(HNF.mat,[ev]);
          else 
            Append(HNF.mat,[-ev]);
          fi;  
        else 
          # at before the j-th element
  
          # move the element behind the j-th position
          for k in [Length(HNF.Heads),Length(HNF.Heads)-1..j] do
            HNF.mat[k+1]:=HNF.mat[k];
            HNF.Heads[k+1]:=HNF.Heads[k];
          od;
           
          # add the row in the j-th position
          if ev[i]>0 then 
            HNF.mat[j]:=ev;
          else
            HNF.mat[j]:=-ev;
          fi;
          HNF.Heads[j]:=i;
        fi;
        
        # since we have changed the HNF we have to reduce the remaining part
        NQL_ReduceHNF(HNF,j);  
  
        Changed:=true;
        break;
      else
        # there is a row with the same first non-zero entry
        l:=Position(HNF.Heads,i);
  
        # reduce the given vector or the HNF
        if IsInt(ev[i]/HNF.mat[l][i]) then 
          # reduce the given vector
          ev:=ev-ev[i]/HNF.mat[l][i] * HNF.mat[l];
        elif IsInt(HNF.mat[l][i]/ev[i]) then 
          # reduce the HNF
          evn:=ShallowCopy(HNF.mat[l]);
          if ev[i]>0 then 
            HNF.mat[l]:=ev;
          else
            HNF.mat[l]:=-ev;
          fi;
          ev:=evn;
         
          NQL_ReduceHNF(HNF,l);
       
          Changed:=true;
        else
          # both can be reduce
          q:=GcdRepresentation(HNF.mat[l][i],ev[i]);
          lcm:=Lcm(HNF.mat[l][i],ev[i]);
          if q[1]=0 then
            Error("strange GcdRepresentation in hnf.gi\n");
          fi;
          evn:=lcm/HNF.mat[l][i] *  HNF.mat[l]-lcm/ev[i] * ev;
  
          HNF.mat[l]:=q[1]*HNF.mat[l]+q[2]*ev;
  
          NQL_ReduceHNF(HNF,l);
  
          k:=PositionNonZero(evn);
          if IsBound(evn[k]) and evn[k]<0 then 
            ev:=-evn;
          else 
            ev:=evn;
          fi;
  
          Changed:=true;
        fi;
      fi;
    else
      i:=i+1;
    fi;
  od;
  
  if NQL_TEST_ALL then 
    if not Filtered(HermiteNormalFormIntegerMat(Concatenation(B,[b])),
                    x->not IsZero(x))=HNF.mat then 
      Error("in NQL_AddRow: wrong Hermite normal form!");
    fi;
    if not List(HNF.mat,x->PositionNonZero(x))=HNF.Heads then 
      Error("in NQL_AddRow: wrong heads");
    fi;
  fi;
  
  return(Changed);
  end);

############################################################################
##
#F  NQL_RowReduce( <ev>, <HNF> )
##
## reduces the exponent vector <ev> via the Hermite normal form <HNF>.
##
InstallGlobalFunction( NQL_RowReduce,
  function(ev,HNF)
  local i,l;	# loop variables
  
  if HNF.mat=[] then 
    return(ev);
  fi;
  
  # reduce a vector with the HNF
  for i in [1..Length(ev)] do
   if ev[i]<>0 then 
     l:=Position(HNF.Heads,i);
     if l<>fail then 
       if IsInt(ev[i]/HNF.mat[l][i]) then 
         ev:=ev-ev[i]/HNF.mat[l][i]*HNF.mat[l];
       elif ev[i]>0 then
         ev:=ev-(QuoInt(ev[i],HNF.mat[l][i]))*HNF.mat[l];
       elif ev[i]<0 then
         ev:=ev-(QuoInt(ev[i],HNF.mat[l][i])-1)*HNF.mat[l];
       fi;
     fi;
   fi;
  od;

  return(ev);
  end);
