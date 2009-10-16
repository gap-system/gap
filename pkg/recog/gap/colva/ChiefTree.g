DeclareGlobalFunction("ChiefTree");
DeclareGlobalFunction("OrderedTree");
DeclareInfoClass("ChiefTreeInfo");

InstallGlobalFunction( ChiefTree,
function(G)
  local nsm,ri;
  #construct the series of maps, see NSM.g
  nsm := NSM(G);
  # Use this to construct the first tree of normal subgroups, in evaluate.g
  ri := NormalTree(G,nsm,0);;
  # Now break down the soluble groups into elementary abelian ones, in refine.g
  ri := RefineSolubleLayers(ri);;
  # in refine.g
  ri := RefineElementaryAbelianLayers(ri);;
  # in refine.g
  ri := RemoveTrivialLayers(ri);;
  return ri;
end);

InstallGlobalFunction( OrderedTree,
function(G)
  local nsm,ri,ori;
  nsm := NSM(G);
  ri := NormalTree(G,nsm,0);;
  ri := RefineSolubleLayers(ri);;
  ri := RefineElementaryAbelianLayers(ri);;
  ri := RemoveTrivialLayers(ri);;
  ori := OrderTree(StructuralCopy(ri));;
  return ori;
end);
