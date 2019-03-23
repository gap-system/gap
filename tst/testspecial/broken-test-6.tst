gap> # continuation prompt followed by a tab leads to an error
gap> f := function()
>	local a;
>	if a = 0 then
>		Error("a is zero");
>	fi;
> end;;
