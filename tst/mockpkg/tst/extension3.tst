# runs because extension3 is loaded
gap> ForAny(GAPInfo.PackageExtensionsLoaded,
>      r -> r.providedby = "mockpkg" and not IsBound(r.filename));
true
