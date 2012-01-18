#############################################################################
##
#W fields.gi       Alnuth -  ALgebraic NUmber THeory         Bjoern Assmann
##

#############################################################################
##
## ExampleMatField provides somes examples of fields which are generated
## by matrices in GL(d,Z) or GL(d,Q)
##
ExampleMatField := function(n)
   if n = 1 then
       return FieldByMatricesNC(ExamUnimod(1){[1..4]});
   elif n = 2 then 
       return FieldByMatricesNC(ExamUnimod(2){[1..4]});
   elif n = 3 then
       return FieldByMatricesNC(ExamUnimod(3){[1..4]});
   elif n = 4 then 
       return FieldByMatricesNC(ExamUnimod(1));
   elif n = 5 then 
       return FieldByMatricesNC(ExamUnimod(2));
   elif n = 6 then 
       return FieldByMatricesNC(ExamUnimod(3));
   elif n = 7 then
       return FieldByMatricesNC(ExamRationals(1));
   elif n = 8 then
       return FieldByMatricesNC(ExamRationals(2));
   elif n = 9 then
       return FieldByMatricesNC(ExamRationals(3));
   else
       return fail;
   fi;
end;


