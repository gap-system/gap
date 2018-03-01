# Test for parser regression; the following code caused a segfault for
# a time. See https://github.com/gap-system/gap/issues/2226

#
gap> F:=function(x)
>   if true then
>     # Does not matter what is here
>   elif x=1 then
>     Assert(1, x=1);
>   fi;
> end;;

#
gap> F:=function(x)
>   if true then
>     # Does not matter what is here
>   elif x=1 then
>     Assert(1, x=1, "msg");
>   fi;
> end;;

#
gap> F:=function(x)
>   if true then
>     # Does not matter what is here
>   elif x=1 then
>     Info(InfoWarning, 1, "hi");
>   fi;
> end;;
