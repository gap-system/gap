#############################################################################
##
##  The rest of this file implements the operations for IsDirectProductDomain
##  domains.
##
InstallGlobalFunction(DirectProductFamily,
function(args)
    if not IsDenseList(args) or not ForAll(args, IsCollectionFamily) then
        ErrorNoReturn("<args> must be a dense list of collection families");
    fi;
    return CollectionsFamily(
        DirectProductElementsFamily(List(args, ElementsFamily))
    );
end);


#############################################################################
##
InstallMethod(DirectProductDomain,
"for a dense list (of domains)",
[IsDenseList],
function(args)
    local directProductFamily, type;
    if not ForAll(args, IsDomain) then
        ErrorNoReturn("args must be a dense list of domains");
    fi;
    directProductFamily := DirectProductFamily(List(args, FamilyObj));
    type := NewType(directProductFamily,
                     IsDirectProductDomain and IsAttributeStoringRep);
    return ObjectifyWithAttributes(rec(), type,
                                    ComponentsOfDirectProductDomain, args);
end);

InstallOtherMethod(DirectProductDomain,
"for a domain and a nonnegative integer",
[IsDomain, IsInt],
function(dom, k)
    local directProductFamily, type;
    if k < 0 then
        ErrorNoReturn("<k> must be a nonnegative integer");
    fi;
    directProductFamily := DirectProductFamily(
        ListWithIdenticalEntries(k, FamilyObj(dom))
    );
    type := NewType(directProductFamily,
                     IsDirectProductDomain and IsAttributeStoringRep);
    return ObjectifyWithAttributes(rec(),
                                    type,
                                    ComponentsOfDirectProductDomain,
                                    ListWithIdenticalEntries(k, dom));
end);

InstallMethod(PrintObj,
"for an IsDirectProductDomain",
[IsDirectProductDomain],
function(dom)
    local components, i;
    Print("DirectProductDomain([ ");
    components := ComponentsOfDirectProductDomain(dom);
    for i in [1 .. Length(components)] do
        PrintObj(components[i]);
        if i < Length(components) then
            Print(", ");
        fi;
    od;
    Print(" ])");
end);

InstallMethod(Size,
"for an IsDirectProductDomain",
[IsDirectProductDomain],
function(dom)
    local size, comp;
    size := 1;
    for comp in ComponentsOfDirectProductDomain(dom) do
        size := Size(comp) * size;
    od;
    return size;
end);

InstallMethod(DimensionOfDirectProductDomain,
"for an IsDirectProductDomain",
[IsDirectProductDomain],
dom -> Length(ComponentsOfDirectProductDomain(dom)));

InstallMethod(\in,
"for an IsDirectProductDomain",
[IsDirectProductElement, IsDirectProductDomain],
function(elm, dom)
    local components, i;
    if Length(elm) <> DimensionOfDirectProductDomain(dom) then
        return false;
    fi;
    components := ComponentsOfDirectProductDomain(dom);
    for i in [1 .. Length(components)] do
        if not elm[i] in components[i] then
            return false;
        fi;
    od;
    return true;
end);
