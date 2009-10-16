#############################################################################
##
#W  grphoms.gd                   Polycyc                         Bettina Eick
#W                                                              Werner Nickel
##

#############################################################################
##
#R  IsPcpGHBI( <map> )
#R  IsFromPcpGHBI( <map> )
#R  IsToPcpGHBI( <map> )
##
##  These declarations are a slight hack copied from the corresponding
##  See the corresponding code for fp-groups for further background.
##
DeclareRepresentation( "IsPcpGHBI",
      IsGroupGeneralMappingByImages 
      and NewFilter("Extrarankfilter",11),
      [ "generators", "genimages", "impcp", "prpcp" ] );

DeclareRepresentation( "IsFromPcpGHBI",
      IsGroupGeneralMappingByImages
      and NewFilter("Extrarankfilter",11),
      [ "generators", "genimages", "impcp", "prpcp" ] );

DeclareRepresentation( "IsToPcpGHBI",
      IsGroupGeneralMappingByImages
      and NewFilter("Extrarankfilter",11),
      [ "generators", "genimages", "impcp", "prpcp" ] );

