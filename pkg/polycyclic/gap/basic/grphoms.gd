#############################################################################
##
#W  grphoms.gd                   Polycyc                         Bettina Eick
#W                                                              Werner Nickel
##

#############################################################################
##
#R  IsFromPcpGHBI( <map> )
#R  IsToPcpGHBI( <map> )
##
##  These declarations are a slight hack copied from the corresponding
##  See the corresponding code for fp-groups for further background.
##
DeclareRepresentation( "IsFromPcpGHBI",
      IsGroupGeneralMappingByImages
      and NewFilter("Extrarankfilter",11),
      [ "igs_gens_to_imgs" ] );

DeclareRepresentation( "IsToPcpGHBI",
      IsGroupGeneralMappingByImages
      and NewFilter("Extrarankfilter",11),
      [ "igs_imgs_to_gens" ] );
