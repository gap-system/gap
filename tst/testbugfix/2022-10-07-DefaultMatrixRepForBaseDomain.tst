# Make sure that 'DefaultMatrixRepForBaseDomain' works for
# the fields provided by the StandardFF package.
gap> if TestPackageAvailability( "StandardFF" ) <> fail and
>       LoadPackage( "StandardFF", false ) <> fail then
>      if DefaultMatrixRepForBaseDomain( FF( 3, 2 ) ) = Is8BitMatrixRep then
>        Error( "wrong DefaultMatrixRepForBaseDomain( FF( 3, 2 ) )" );
>      fi;
>    fi;
