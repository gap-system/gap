#############################################################################
##
#W  nqlib.gi               Polycyc                              Werner Nickel
##

#############################################################################
##
#W NqExamples( n )
##
InstallGlobalFunction( NqExamples, function( n )
    local NqF, NqColl;

if n = 1 then 

NqF := FreeGroup( 24 );
NqColl := FromTheLeftCollector( NqF );
SetRelativeOrder( NqColl, 11, 5 );
SetRelativeOrder( NqColl, 12, 4 );
SetRelativeOrder( NqColl, 14, 5 );
SetRelativeOrder( NqColl, 15, 5 );
SetRelativeOrder( NqColl, 16, 4 );
SetRelativeOrder( NqColl, 18, 6 );
SetRelativeOrder( NqColl, 19, 5 );
SetRelativeOrder( NqColl, 20, 5 );
SetRelativeOrder( NqColl, 21, 4 );
SetRelativeOrder( NqColl, 23, 10 );
SetRelativeOrder( NqColl, 24, 6 );
SetPower( NqColl, 11, NqF.19^2*NqF.20^4*NqF.21^2*NqF.22^4*NqF.24^4 );
SetPower( NqColl, 12, NqF.13^2*NqF.15*NqF.16^3*NqF.17^-6*NqF.18^4*\
  NqF.19^3*NqF.21^3*NqF.22^12*NqF.23^8*NqF.24^4 );
SetPower( NqColl, 16, NqF.17^2*NqF.20*NqF.21^3*NqF.22^-6*NqF.24^4 );
SetPower( NqColl, 18, NqF.23*NqF.24^4 );
SetPower( NqColl, 21, NqF.22^2 );
SetPower( NqColl, 23, NqF.24^2 );
SetConjugate( NqColl, 2, 1, NqF.2*NqF.3 );
SetConjugate( NqColl, 2, -1, NqF.2*NqF.3^-1*NqF.4*NqF.5^-1*NqF.6*NqF.7*\
  NqF.8^-3*NqF.9^10*NqF.10^-1*NqF.11*NqF.13^5*NqF.14^4*NqF.15*NqF.16^2*NqF.17^-23*\
  NqF.18^5*NqF.19^2*NqF.20^2*NqF.21*NqF.22^54*NqF.23^5*NqF.24 );
SetConjugate( NqColl, -2, 1, NqF.2^-1*NqF.3^-1 );
SetConjugate( NqColl, -2, -1, NqF.2^-1*NqF.3*NqF.4^-1*NqF.5*NqF.6^-1*NqF.9^3*\
  NqF.11^2*NqF.12^2*NqF.13^-1*NqF.14^2*NqF.18^5*NqF.19*NqF.20^3*NqF.21^3*\
  NqF.22^-2 );
SetConjugate( NqColl, 3, 1, NqF.3*NqF.4 );
SetConjugate( NqColl, 3, -1, NqF.3*NqF.4^-1*NqF.5*NqF.6^-1*NqF.9^3*NqF.11^2*\
  NqF.12^2*NqF.13^-1*NqF.14^2*NqF.18^5*NqF.19*NqF.20^3*NqF.21^3*NqF.22^-2 );
SetConjugate( NqColl, -3, 1, NqF.3^-1*NqF.4^-1*NqF.7^-1*NqF.8^2*NqF.9^-7*\
  NqF.10*NqF.11^4*NqF.12*NqF.13^-6*NqF.14^3*NqF.16^2*NqF.17^19*NqF.19*NqF.20^3*\
  NqF.22^-50*NqF.23^4 );
SetConjugate( NqColl, -3, -1, NqF.3^-1*NqF.4*NqF.5^-1*NqF.6*NqF.7*NqF.8^-3*\
  NqF.9^10*NqF.10^-1*NqF.11*NqF.13^5*NqF.14^4*NqF.15*NqF.16^2*NqF.17^-23*\
  NqF.18^5*NqF.19^2*NqF.20^2*NqF.21*NqF.22^54*NqF.23^5*NqF.24 );
SetConjugate( NqColl, 3, 2, NqF.3 );
SetConjugate( NqColl, 3, -2, NqF.3 );
SetConjugate( NqColl, -3, 2, NqF.3^-1 );
SetConjugate( NqColl, -3, -2, NqF.3^-1 );
SetConjugate( NqColl, 4, 1, NqF.4*NqF.5 );
SetConjugate( NqColl, 4, -1, NqF.4*NqF.5^-1*NqF.6*NqF.14^3*NqF.21^2*NqF.22^-1 );
SetConjugate( NqColl, -4, 1, NqF.4^-1*NqF.5^-1*NqF.9^-3*NqF.12^2*NqF.13^-1*\
  NqF.14*NqF.15^4*NqF.16^3*NqF.17^3*NqF.18^3*NqF.19^4*NqF.20*NqF.21^2*NqF.22^-10*\
  NqF.24^5 );
SetConjugate( NqColl, -4, -1, NqF.4^-1*NqF.5*NqF.6^-1*NqF.9^3*NqF.11^2*\
  NqF.12^2*NqF.13^-1*NqF.14^2*NqF.18^5*NqF.19*NqF.20^3*NqF.21^3*NqF.22^-2 );
SetConjugate( NqColl, 4, 2, NqF.4*NqF.7*NqF.8^-2*NqF.9^7*NqF.10^-1*NqF.11*\
  NqF.13^4*NqF.14^2*NqF.15*NqF.16^2*NqF.17^-18*NqF.18^5*NqF.19*NqF.20*NqF.21*\
  NqF.22^42*NqF.23^5*NqF.24^2 );
SetConjugate( NqColl, 4, -2, NqF.4*NqF.7^-1*NqF.8^2*NqF.9^-7*NqF.10^2*\
  NqF.11^4*NqF.12*NqF.13^-6*NqF.14^3*NqF.15^3*NqF.16^3*NqF.17^20*NqF.18*NqF.20^3*\
  NqF.22^-52*NqF.24^4 );
SetConjugate( NqColl, -4, 2, NqF.4^-1*NqF.7^-1*NqF.8^2*NqF.9^-7*NqF.10*\
  NqF.11^4*NqF.12*NqF.13^-6*NqF.14^3*NqF.16^2*NqF.17^19*NqF.19*NqF.20^3*NqF.22^-50*\
  NqF.23^4 );
SetConjugate( NqColl, -4, -2, NqF.4^-1*NqF.7*NqF.8^-2*NqF.9^7*NqF.10^-2*\
  NqF.11*NqF.12^2*NqF.13^6*NqF.14^2*NqF.16^2*NqF.17^-21*NqF.18^2*NqF.19*NqF.20^2*\
  NqF.21^3*NqF.22^48*NqF.23^2*NqF.24^4 );
SetConjugate( NqColl, 4, 3, NqF.4*NqF.7^-1*NqF.8^2*NqF.9^-7*NqF.10^2*\
  NqF.11^4*NqF.12*NqF.13^-6*NqF.14^3*NqF.15^3*NqF.16^3*NqF.17^20*NqF.18*NqF.20^3*\
  NqF.22^-52*NqF.24^4 );
SetConjugate( NqColl, 4, -3, NqF.4*NqF.7*NqF.8^-2*NqF.9^7*NqF.10^-1*NqF.11*\
  NqF.13^4*NqF.14^2*NqF.15*NqF.16^2*NqF.17^-18*NqF.18^5*NqF.19*NqF.20*NqF.21*\
  NqF.22^42*NqF.23^5*NqF.24^2 );
SetConjugate( NqColl, -4, 3, NqF.4^-1*NqF.7*NqF.8^-2*NqF.9^7*NqF.10^-2*\
  NqF.11*NqF.12^2*NqF.13^6*NqF.14^2*NqF.16^2*NqF.17^-21*NqF.18^2*NqF.19*NqF.20^2*\
  NqF.21^3*NqF.22^48*NqF.23^2*NqF.24^4 );
SetConjugate( NqColl, -4, -3, NqF.4^-1*NqF.7^-1*NqF.8^2*NqF.9^-7*NqF.10*\
  NqF.11^4*NqF.12*NqF.13^-6*NqF.14^3*NqF.16^2*NqF.17^19*NqF.19*NqF.20^3*NqF.22^-50*\
  NqF.23^4 );
SetConjugate( NqColl, 5, 1, NqF.5*NqF.6 );
SetConjugate( NqColl, 5, -1, NqF.5*NqF.6^-1 );
SetConjugate( NqColl, -5, 1, NqF.5^-1*NqF.6^-1*NqF.14^2*NqF.21^2*NqF.22^-1 );
SetConjugate( NqColl, -5, -1, NqF.5^-1*NqF.6*NqF.14^3*NqF.21^2*NqF.22^-1 );
SetConjugate( NqColl, 5, 2, NqF.5*NqF.7 );
SetConjugate( NqColl, 5, -2, NqF.5*NqF.7^-1*NqF.10^3*NqF.12^2*NqF.13^-6*\
  NqF.15*NqF.16^3*NqF.17^12*NqF.18*NqF.20^2*NqF.21^2*NqF.22^-28*NqF.23^9 );
SetConjugate( NqColl, -5, 2, NqF.5^-1*NqF.7^-1*NqF.15^4*NqF.16^3*NqF.17^-3*\
  NqF.19^3*NqF.20*NqF.21*NqF.22^4*NqF.23^3 );
SetConjugate( NqColl, -5, -2, NqF.5^-1*NqF.7*NqF.10^-3*NqF.12^2*NqF.13^4*\
  NqF.15^4*NqF.16^3*NqF.17^-9*NqF.18*NqF.19^4*NqF.20^4*NqF.21*NqF.22^22*NqF.23^9*\
  NqF.24^4 );
SetConjugate( NqColl, 5, 3, NqF.5*NqF.8^-1*NqF.9^5*NqF.11^3*NqF.12^3*\
  NqF.13^-1*NqF.14^3*NqF.15*NqF.17^-4*NqF.18^4*NqF.19^4*NqF.22^8*NqF.23^9*\
  NqF.24^3 );
SetConjugate( NqColl, 5, -3, NqF.5*NqF.8*NqF.9^-5*NqF.11^2*NqF.12^2*NqF.13^-2*\
  NqF.14^2*NqF.15^2*NqF.16^3*NqF.17^10*NqF.18^3*NqF.19^4*NqF.20^3*NqF.21^3*\
  NqF.22^-28*NqF.23*NqF.24^3 );
SetConjugate( NqColl, -5, 3, NqF.5^-1*NqF.8*NqF.9^-5*NqF.11^2*NqF.12*NqF.13^-1*\
  NqF.14^2*NqF.15^3*NqF.16*NqF.17^8*NqF.18^4*NqF.19^2*NqF.20^2*NqF.21^3*NqF.22^-23*\
  NqF.23*NqF.24^3 );
SetConjugate( NqColl, -5, -3, NqF.5^-1*NqF.8^-1*NqF.9^5*NqF.11^3*NqF.12^2*\
  NqF.14^3*NqF.15^2*NqF.16^2*NqF.17^-8*NqF.18^5*NqF.20^4*NqF.21^3*NqF.22^15*\
  NqF.23^9*NqF.24^5 );
SetConjugate( NqColl, 5, 4, NqF.5*NqF.9^-3*NqF.12^2*NqF.13^-1*NqF.14*\
  NqF.15^4*NqF.16^3*NqF.17^3*NqF.18^3*NqF.19*NqF.20^2*NqF.21^3*NqF.22^-12*\
  NqF.24^5 );
SetConjugate( NqColl, 5, -4, NqF.5*NqF.9^3*NqF.12^2*NqF.13^-1*NqF.14^4*\
  NqF.16^2*NqF.17^-1*NqF.18^5*NqF.19^3*NqF.20^2*NqF.21*NqF.22^4*NqF.24^3 );
SetConjugate( NqColl, -5, 4, NqF.5^-1*NqF.9^3*NqF.12^2*NqF.13^-1*NqF.14^4*\
  NqF.16^2*NqF.17^-1*NqF.18^5*NqF.19*NqF.20*NqF.22^6*NqF.24^3 );
SetConjugate( NqColl, -5, -4, NqF.5^-1*NqF.9^-3*NqF.12^2*NqF.13^-1*NqF.14*\
  NqF.15^4*NqF.16^3*NqF.17^3*NqF.18^3*NqF.19^4*NqF.20*NqF.21^2*NqF.22^-10*\
  NqF.24^5 );
SetConjugate( NqColl, 6, 1, NqF.6 );
SetConjugate( NqColl, 6, -1, NqF.6 );
SetConjugate( NqColl, -6, 1, NqF.6^-1 );
SetConjugate( NqColl, -6, -1, NqF.6^-1 );
SetConjugate( NqColl, 6, 2, NqF.6*NqF.8^2*NqF.9^-7*NqF.10*NqF.11^4*NqF.13^-4*\
  NqF.14^3*NqF.15^4*NqF.16^2*NqF.17^16*NqF.18*NqF.19*NqF.20^3*NqF.22^-42*\
  NqF.23^4*NqF.24^2 );
SetConjugate( NqColl, 6, -2, NqF.6*NqF.8^-2*NqF.9^7*NqF.10*NqF.11*NqF.12*\
  NqF.14^2*NqF.15^3*NqF.17^-8*NqF.19^4*NqF.20*NqF.21^2*NqF.22^18*NqF.23^9*\
  NqF.24^4 );
SetConjugate( NqColl, -6, 2, NqF.6^-1*NqF.8^-2*NqF.9^7*NqF.10^-1*NqF.11*\
  NqF.13^4*NqF.14^2*NqF.15*NqF.16^2*NqF.17^-18*NqF.18^5*NqF.19^2*NqF.20^2*\
  NqF.21^3*NqF.22^40*NqF.23^5*NqF.24^2 );
SetConjugate( NqColl, -6, -2, NqF.6^-1*NqF.8^2*NqF.9^-7*NqF.10^-1*NqF.11^4*\
  NqF.12^3*NqF.13^-2*NqF.14^3*NqF.15*NqF.16*NqF.17^12*NqF.18^2*NqF.19*NqF.20^4*\
  NqF.21^2*NqF.22^-34*NqF.23^2 );
SetConjugate( NqColl, 6, 3, NqF.6*NqF.9^2*NqF.11^3*NqF.12^2*NqF.13^-1*\
  NqF.14^4*NqF.15*NqF.16*NqF.18^5*NqF.19^4*NqF.22^-2*NqF.23^7*NqF.24^5 );
SetConjugate( NqColl, 6, -3, NqF.6*NqF.9^-2*NqF.11^2*NqF.12^2*NqF.13^-1*\
  NqF.14*NqF.15*NqF.16^2*NqF.17^4*NqF.18^3*NqF.20*NqF.22^-12*NqF.23^4 );
SetConjugate( NqColl, -6, 3, NqF.6^-1*NqF.9^-2*NqF.11^2*NqF.12^2*NqF.13^-1*\
  NqF.14*NqF.15^3*NqF.17^4*NqF.18^3*NqF.19*NqF.22^-12*NqF.23^3*NqF.24 );
SetConjugate( NqColl, -6, -3, NqF.6^-1*NqF.9^2*NqF.11^3*NqF.12^2*NqF.13^-1*\
  NqF.14^4*NqF.15^3*NqF.16^3*NqF.17^-2*NqF.18^5*NqF.20^3*NqF.21*NqF.22^2*\
  NqF.23^6*NqF.24^2 );
SetConjugate( NqColl, 6, 4, NqF.6*NqF.11^2*NqF.14^3*NqF.16^2*NqF.17^-1*\
  NqF.19^3*NqF.21^3*NqF.22^-2*NqF.24^5 );
SetConjugate( NqColl, 6, -4, NqF.6*NqF.11^3*NqF.14^2*NqF.16^2*NqF.17^-1*\
  NqF.24^5 );
SetConjugate( NqColl, -6, 4, NqF.6^-1*NqF.11^3*NqF.14^2*NqF.16^2*NqF.17^-1*\
  NqF.24^5 );
SetConjugate( NqColl, -6, -4, NqF.6^-1*NqF.11^2*NqF.14^3*NqF.16^2*NqF.17^-1*\
  NqF.19^3*NqF.21^3*NqF.22^-2*NqF.24^5 );
SetConjugate( NqColl, 6, 5, NqF.6*NqF.14^2*NqF.21^2*NqF.22^-1 );
SetConjugate( NqColl, 6, -5, NqF.6*NqF.14^3*NqF.21^2*NqF.22^-1 );
SetConjugate( NqColl, -6, 5, NqF.6^-1*NqF.14^3*NqF.21^2*NqF.22^-1 );
SetConjugate( NqColl, -6, -5, NqF.6^-1*NqF.14^2*NqF.21^2*NqF.22^-1 );
SetConjugate( NqColl, 7, 1, NqF.7*NqF.8 );
SetConjugate( NqColl, 7, -1, NqF.7*NqF.8^-1*NqF.9*NqF.11^4*NqF.14*NqF.19^3*\
  NqF.20*NqF.21^2*NqF.22^-6*NqF.24^2 );
SetConjugate( NqColl, -7, 1, NqF.7^-1*NqF.8^-1 );
SetConjugate( NqColl, -7, -1, NqF.7^-1*NqF.8*NqF.9^-1*NqF.11*NqF.14^4 );
SetConjugate( NqColl, 7, 2, NqF.7*NqF.10^3*NqF.12^2*NqF.13^-6*NqF.15*\
  NqF.16^3*NqF.17^12*NqF.18^2*NqF.20^2*NqF.21^2*NqF.22^-28*NqF.23*NqF.24^4 );
SetConjugate( NqColl, 7, -2, NqF.7*NqF.10^-3*NqF.12^2*NqF.13^4*NqF.15^3*\
  NqF.16^2*NqF.17^-10*NqF.18*NqF.19^2*NqF.20*NqF.21*NqF.22^22*NqF.23^2*NqF.24^4 );
SetConjugate( NqColl, -7, 2, NqF.7^-1*NqF.10^-3*NqF.12^2*NqF.13^4*NqF.15^3*\
  NqF.16^2*NqF.17^-10*NqF.19^2*NqF.20*NqF.21*NqF.22^22*NqF.24^2 );
SetConjugate( NqColl, -7, -2, NqF.7^-1*NqF.10^3*NqF.12^2*NqF.13^-6*NqF.15*\
  NqF.16^3*NqF.17^12*NqF.18*NqF.20^2*NqF.21^2*NqF.22^-28*NqF.23^9 );
SetConjugate( NqColl, 7, 3, NqF.7*NqF.10^-1*NqF.12*NqF.13^2*NqF.15^4*\
  NqF.16^3*NqF.17^-6*NqF.18^3*NqF.19*NqF.21^3*NqF.22^12*NqF.23^7*NqF.24^4 );
SetConjugate( NqColl, 7, -3, NqF.7*NqF.10*NqF.12^3*NqF.13^-4*NqF.16^2*\
  NqF.17^8*NqF.19*NqF.20^3*NqF.22^-18*NqF.23^8*NqF.24^4 );
SetConjugate( NqColl, -7, 3, NqF.7^-1*NqF.10*NqF.12^3*NqF.13^-4*NqF.16^2*\
  NqF.17^8*NqF.18^5*NqF.19*NqF.20^3*NqF.22^-18*NqF.23^3*NqF.24^2 );
SetConjugate( NqColl, -7, -3, NqF.7^-1*NqF.10^-1*NqF.12*NqF.13^2*NqF.15^4*\
  NqF.16^3*NqF.17^-6*NqF.18^2*NqF.19*NqF.21^3*NqF.22^12*NqF.23^3 );
SetConjugate( NqColl, 7, 4, NqF.7*NqF.12*NqF.13^-2*NqF.15^3*NqF.17^3*\
  NqF.18^5*NqF.19^3*NqF.22^-8*NqF.23^4*NqF.24^2 );
SetConjugate( NqColl, 7, -4, NqF.7*NqF.12^3*NqF.15*NqF.16*NqF.17*NqF.18^3*\
  NqF.19^4*NqF.20^4*NqF.21^2*NqF.22^-2*NqF.23^6*NqF.24^2 );
SetConjugate( NqColl, -7, 4, NqF.7^-1*NqF.12^3*NqF.15*NqF.16*NqF.17*NqF.18^3*\
  NqF.19^4*NqF.20^4*NqF.21^2*NqF.22^-2*NqF.23^6*NqF.24^2 );
SetConjugate( NqColl, -7, -4, NqF.7^-1*NqF.12*NqF.13^-2*NqF.15^3*NqF.17^3*\
  NqF.18^5*NqF.19^3*NqF.22^-8*NqF.23^4*NqF.24^2 );
SetConjugate( NqColl, 7, 5, NqF.7*NqF.15^4*NqF.16^3*NqF.17^-3*NqF.19^3*\
  NqF.20*NqF.21*NqF.22^4*NqF.23^3 );
SetConjugate( NqColl, 7, -5, NqF.7*NqF.15*NqF.16*NqF.17*NqF.19^2*NqF.20^3*\
  NqF.23^7 );
SetConjugate( NqColl, -7, 5, NqF.7^-1*NqF.15*NqF.16*NqF.17*NqF.19^2*NqF.20^3*\
  NqF.23^7 );
SetConjugate( NqColl, -7, -5, NqF.7^-1*NqF.15^4*NqF.16^3*NqF.17^-3*NqF.19^3*\
  NqF.20*NqF.21*NqF.22^4*NqF.23^3 );
SetConjugate( NqColl, 7, 6, NqF.7*NqF.19*NqF.20*NqF.21^2*NqF.22^-2 );
SetConjugate( NqColl, 7, -6, NqF.7*NqF.19^4*NqF.20^4*NqF.21^2 );
SetConjugate( NqColl, -7, 6, NqF.7^-1*NqF.19^4*NqF.20^4*NqF.21^2 );
SetConjugate( NqColl, -7, -6, NqF.7^-1*NqF.19*NqF.20*NqF.21^2*NqF.22^-2 );
SetConjugate( NqColl, 8, 1, NqF.8*NqF.9 );
SetConjugate( NqColl, 8, -1, NqF.8*NqF.9^-1*NqF.11*NqF.14^4 );
SetConjugate( NqColl, -8, 1, NqF.8^-1*NqF.9^-1 );
SetConjugate( NqColl, -8, -1, NqF.8^-1*NqF.9*NqF.11^4*NqF.14*NqF.19^3*NqF.20*\
  NqF.21^2*NqF.22^-6*NqF.24^2 );
SetConjugate( NqColl, 8, 2, NqF.8*NqF.10 );
SetConjugate( NqColl, 8, -2, NqF.8*NqF.10^-1*NqF.18*NqF.23^7*NqF.24^2 );
SetConjugate( NqColl, -8, 2, NqF.8^-1*NqF.10^-1 );
SetConjugate( NqColl, -8, -2, NqF.8^-1*NqF.10*NqF.18^5*NqF.23^2*NqF.24^4 );
SetConjugate( NqColl, 8, 3, NqF.8*NqF.12^3*NqF.13^-1*NqF.17^4*NqF.18^3*\
  NqF.19*NqF.21^2*NqF.22^-10*NqF.24^4 );
SetConjugate( NqColl, 8, -3, NqF.8*NqF.12*NqF.13^-1*NqF.15^4*NqF.16*NqF.18^5*\
  NqF.19*NqF.20^4*NqF.23^2*NqF.24^5 );
SetConjugate( NqColl, -8, 3, NqF.8^-1*NqF.12*NqF.13^-1*NqF.15^4*NqF.16*\
  NqF.18^5*NqF.19*NqF.20^4*NqF.24^2 );
SetConjugate( NqColl, -8, -3, NqF.8^-1*NqF.12^3*NqF.13^-1*NqF.17^4*NqF.18^3*\
  NqF.19*NqF.21^2*NqF.22^-10*NqF.23^8*NqF.24^5 );
SetConjugate( NqColl, 8, 4, NqF.8*NqF.15*NqF.16^2*NqF.17^-1*NqF.19^3*\
  NqF.20^3*NqF.21^3*NqF.22^2*NqF.23^7*NqF.24^5 );
SetConjugate( NqColl, 8, -4, NqF.8*NqF.15^4*NqF.16^2*NqF.17^-1*NqF.19^2*\
  NqF.20*NqF.21^2*NqF.23^3*NqF.24 );
SetConjugate( NqColl, -8, 4, NqF.8^-1*NqF.15^4*NqF.16^2*NqF.17^-1*NqF.19^2*\
  NqF.20*NqF.21^2*NqF.23^3*NqF.24 );
SetConjugate( NqColl, -8, -4, NqF.8^-1*NqF.15*NqF.16^2*NqF.17^-1*NqF.19^3*\
  NqF.20^3*NqF.21^3*NqF.22^2*NqF.23^7*NqF.24^5 );
SetConjugate( NqColl, 8, 5, NqF.8*NqF.19^4*NqF.20^3*NqF.21*NqF.22^-1 );
SetConjugate( NqColl, 8, -5, NqF.8*NqF.19*NqF.20^2*NqF.21^3*NqF.22^-1 );
SetConjugate( NqColl, -8, 5, NqF.8^-1*NqF.19*NqF.20^2*NqF.21^3*NqF.22^-1 );
SetConjugate( NqColl, -8, -5, NqF.8^-1*NqF.19^4*NqF.20^3*NqF.21*NqF.22^-1 );
SetConjugate( NqColl, 9, 1, NqF.9*NqF.11 );
SetConjugate( NqColl, 9, -1, NqF.9*NqF.11^4*NqF.14*NqF.19^3*NqF.20*NqF.21^2*\
  NqF.22^-6*NqF.24^2 );
SetConjugate( NqColl, -9, 1, NqF.9^-1*NqF.11^4*NqF.19^3*NqF.20*NqF.21^2*\
  NqF.22^-6*NqF.24^2 );
SetConjugate( NqColl, -9, -1, NqF.9^-1*NqF.11*NqF.14^4 );
SetConjugate( NqColl, 9, 2, NqF.9*NqF.12 );
SetConjugate( NqColl, 9, -2, NqF.9*NqF.12^3*NqF.13^-2*NqF.15^4*NqF.16*\
  NqF.17^4*NqF.18^4*NqF.19^2*NqF.20^4*NqF.21^2*NqF.22^-10*NqF.23^3 );
SetConjugate( NqColl, -9, 2, NqF.9^-1*NqF.12^3*NqF.13^-2*NqF.15^4*NqF.16*\
  NqF.17^4*NqF.18^2*NqF.19^2*NqF.20^4*NqF.21^2*NqF.22^-10*NqF.23*NqF.24^4 );
SetConjugate( NqColl, -9, -2, NqF.9^-1*NqF.12*NqF.18^4*NqF.23^7*NqF.24^4 );
SetConjugate( NqColl, 9, 3, NqF.9*NqF.15^4*NqF.16*NqF.19*NqF.20^4*NqF.23^3*\
  NqF.24^2 );
SetConjugate( NqColl, 9, -3, NqF.9*NqF.15*NqF.16^3*NqF.17^-2*NqF.19^4*\
  NqF.21*NqF.22^4*NqF.23^7*NqF.24^4 );
SetConjugate( NqColl, -9, 3, NqF.9^-1*NqF.15*NqF.16^3*NqF.17^-2*NqF.19^4*\
  NqF.21*NqF.22^4*NqF.23^7*NqF.24^4 );
SetConjugate( NqColl, -9, -3, NqF.9^-1*NqF.15^4*NqF.16*NqF.19*NqF.20^4*\
  NqF.23^3*NqF.24^2 );
SetConjugate( NqColl, 9, 4, NqF.9*NqF.19*NqF.20^3*NqF.21 );
SetConjugate( NqColl, 9, -4, NqF.9*NqF.19^4*NqF.20^2*NqF.21^3*NqF.22^-2 );
SetConjugate( NqColl, -9, 4, NqF.9^-1*NqF.19^4*NqF.20^2*NqF.21^3*NqF.22^-2 );
SetConjugate( NqColl, -9, -4, NqF.9^-1*NqF.19*NqF.20^3*NqF.21 );
SetConjugate( NqColl, 10, 1, NqF.10*NqF.13 );
SetConjugate( NqColl, 10, -1, NqF.10*NqF.13^-1*NqF.17*NqF.22^-1 );
SetConjugate( NqColl, -10, 1, NqF.10^-1*NqF.13^-1 );
SetConjugate( NqColl, -10, -1, NqF.10^-1*NqF.13*NqF.17^-1*NqF.22 );
SetConjugate( NqColl, 10, 2, NqF.10*NqF.18*NqF.23^7*NqF.24^2 );
SetConjugate( NqColl, 10, -2, NqF.10*NqF.18^5*NqF.23^2*NqF.24^4 );
SetConjugate( NqColl, -10, 2, NqF.10^-1*NqF.18^5*NqF.23^2*NqF.24^4 );
SetConjugate( NqColl, -10, -2, NqF.10^-1*NqF.18*NqF.23^7*NqF.24^2 );
SetConjugate( NqColl, 10, 3, NqF.10*NqF.18^5*NqF.24^2 );
SetConjugate( NqColl, 10, -3, NqF.10*NqF.18*NqF.23^9*NqF.24^4 );
SetConjugate( NqColl, -10, 3, NqF.10^-1*NqF.18*NqF.23^9*NqF.24^4 );
SetConjugate( NqColl, -10, -3, NqF.10^-1*NqF.18^5*NqF.24^2 );
SetConjugate( NqColl, 10, 4, NqF.10*NqF.23*NqF.24^4 );
SetConjugate( NqColl, 10, -4, NqF.10*NqF.23^9 );
SetConjugate( NqColl, -10, 4, NqF.10^-1*NqF.23^9 );
SetConjugate( NqColl, -10, -4, NqF.10^-1*NqF.23*NqF.24^4 );
SetConjugate( NqColl, 11, 1, NqF.11*NqF.14 );
SetConjugate( NqColl, 11, -1, NqF.11*NqF.14^4 );
SetConjugate( NqColl, 11, 2, NqF.11*NqF.15 );
SetConjugate( NqColl, 11, -2, NqF.11*NqF.15^4*NqF.23^6 );
SetConjugate( NqColl, 11, 3, NqF.11*NqF.19^4*NqF.20 );
SetConjugate( NqColl, 11, -3, NqF.11*NqF.19*NqF.20^4 );
SetConjugate( NqColl, 12, 1, NqF.12*NqF.16 );
SetConjugate( NqColl, 12, -1, NqF.12*NqF.16^3*NqF.17^-2*NqF.20^4*NqF.21^2*\
  NqF.22^4*NqF.24^2 );
SetConjugate( NqColl, 12, 2, NqF.12*NqF.18^2*NqF.23^2*NqF.24^2 );
SetConjugate( NqColl, 12, -2, NqF.12*NqF.18^4*NqF.23^7*NqF.24^4 );
SetConjugate( NqColl, 12, 3, NqF.12*NqF.23^7*NqF.24^2 );
SetConjugate( NqColl, 12, -3, NqF.12*NqF.23^3*NqF.24^2 );
SetConjugate( NqColl, 13, 1, NqF.13*NqF.17 );
SetConjugate( NqColl, 13, -1, NqF.13*NqF.17^-1*NqF.22 );
SetConjugate( NqColl, -13, 1, NqF.13^-1*NqF.17^-1 );
SetConjugate( NqColl, -13, -1, NqF.13^-1*NqF.17*NqF.22^-1 );
SetConjugate( NqColl, 13, 2, NqF.13*NqF.18 );
SetConjugate( NqColl, 13, -2, NqF.13*NqF.18^5*NqF.23^9 );
SetConjugate( NqColl, -13, 2, NqF.13^-1*NqF.18^5*NqF.23^9 );
SetConjugate( NqColl, -13, -2, NqF.13^-1*NqF.18 );
SetConjugate( NqColl, 13, 3, NqF.13*NqF.23^9*NqF.24^5 );
SetConjugate( NqColl, 13, -3, NqF.13*NqF.23*NqF.24^5 );
SetConjugate( NqColl, -13, 3, NqF.13^-1*NqF.23*NqF.24^5 );
SetConjugate( NqColl, -13, -3, NqF.13^-1*NqF.23^9*NqF.24^5 );
SetConjugate( NqColl, 14, 1, NqF.14 );
SetConjugate( NqColl, 14, -1, NqF.14 );
SetConjugate( NqColl, 14, 2, NqF.14*NqF.19 );
SetConjugate( NqColl, 14, -2, NqF.14*NqF.19^4 );
SetConjugate( NqColl, 15, 1, NqF.15*NqF.20 );
SetConjugate( NqColl, 15, -1, NqF.15*NqF.20^4 );
SetConjugate( NqColl, 15, 2, NqF.15*NqF.23^6 );
SetConjugate( NqColl, 15, -2, NqF.15*NqF.23^4*NqF.24^4 );
SetConjugate( NqColl, 16, 1, NqF.16*NqF.21 );
SetConjugate( NqColl, 16, -1, NqF.16*NqF.21^3*NqF.22^-2 );
SetConjugate( NqColl, 16, 2, NqF.16*NqF.23^3*NqF.24^4 );
SetConjugate( NqColl, 16, -2, NqF.16*NqF.23^7 );
SetConjugate( NqColl, 17, 1, NqF.17*NqF.22 );
SetConjugate( NqColl, 17, -1, NqF.17*NqF.22^-1 );
SetConjugate( NqColl, -17, 1, NqF.17^-1*NqF.22^-1 );
SetConjugate( NqColl, -17, -1, NqF.17^-1*NqF.22 );
SetConjugate( NqColl, 17, 2, NqF.17*NqF.23 );
SetConjugate( NqColl, 17, -2, NqF.17*NqF.23^9*NqF.24^4 );
SetConjugate( NqColl, -17, 2, NqF.17^-1*NqF.23^9*NqF.24^4 );
SetConjugate( NqColl, -17, -2, NqF.17^-1*NqF.23 );
SetConjugate( NqColl, 18, 1, NqF.18*NqF.24 );
SetConjugate( NqColl, 18, -1, NqF.18*NqF.24^5 );
SetConjugate( NqColl, 18, 2, NqF.18 );
SetConjugate( NqColl, 18, -2, NqF.18 );

return PcpGroupByCollector( NqColl );

elif n = 2 then 

NqF := FreeGroup( 13 );
NqColl := FromTheLeftCollector( NqF );
SetRelativeOrder( NqColl, 11, 5 );
SetRelativeOrder( NqColl, 12, 4 );
SetPower( NqColl, 12, NqF.13^2 );
SetConjugate( NqColl, 2, 1, NqF.2*NqF.3 );
SetConjugate( NqColl, 2, -1, NqF.2*NqF.3^-1*NqF.4*NqF.5^-1*NqF.6*NqF.7*\
  NqF.8^-3*NqF.9^10*NqF.10^-1*NqF.11*NqF.13^5 );
SetConjugate( NqColl, -2, 1, NqF.2^-1*NqF.3^-1 );
SetConjugate( NqColl, -2, -1, NqF.2^-1*NqF.3*NqF.4^-1*NqF.5*NqF.6^-1*NqF.9^3*\
  NqF.11^2*NqF.12^2*NqF.13^-1 );
SetConjugate( NqColl, 3, 1, NqF.3*NqF.4 );
SetConjugate( NqColl, 3, -1, NqF.3*NqF.4^-1*NqF.5*NqF.6^-1*NqF.9^3*NqF.11^2*\
  NqF.12^2*NqF.13^-1 );
SetConjugate( NqColl, -3, 1, NqF.3^-1*NqF.4^-1*NqF.7^-1*NqF.8^2*NqF.9^-7*\
  NqF.10*NqF.11^4*NqF.12*NqF.13^-6 );
SetConjugate( NqColl, -3, -1, NqF.3^-1*NqF.4*NqF.5^-1*NqF.6*NqF.7*NqF.8^-3*\
  NqF.9^10*NqF.10^-1*NqF.11*NqF.13^5 );
SetConjugate( NqColl, 3, 2, NqF.3 );
SetConjugate( NqColl, 3, -2, NqF.3 );
SetConjugate( NqColl, -3, 2, NqF.3^-1 );
SetConjugate( NqColl, -3, -2, NqF.3^-1 );
SetConjugate( NqColl, 4, 1, NqF.4*NqF.5 );
SetConjugate( NqColl, 4, -1, NqF.4*NqF.5^-1*NqF.6 );
SetConjugate( NqColl, -4, 1, NqF.4^-1*NqF.5^-1*NqF.9^-3*NqF.12^2*NqF.13^-1 );
SetConjugate( NqColl, -4, -1, NqF.4^-1*NqF.5*NqF.6^-1*NqF.9^3*NqF.11^2*\
  NqF.12^2*NqF.13^-1 );
SetConjugate( NqColl, 4, 2, NqF.4*NqF.7*NqF.8^-2*NqF.9^7*NqF.10^-1*NqF.11*\
  NqF.13^4 );
SetConjugate( NqColl, 4, -2, NqF.4*NqF.7^-1*NqF.8^2*NqF.9^-7*NqF.10^2*\
  NqF.11^4*NqF.12*NqF.13^-6 );
SetConjugate( NqColl, -4, 2, NqF.4^-1*NqF.7^-1*NqF.8^2*NqF.9^-7*NqF.10*\
  NqF.11^4*NqF.12*NqF.13^-6 );
SetConjugate( NqColl, -4, -2, NqF.4^-1*NqF.7*NqF.8^-2*NqF.9^7*NqF.10^-2*\
  NqF.11*NqF.12^2*NqF.13^6 );
SetConjugate( NqColl, 4, 3, NqF.4*NqF.7^-1*NqF.8^2*NqF.9^-7*NqF.10^2*\
  NqF.11^4*NqF.12*NqF.13^-6 );
SetConjugate( NqColl, 4, -3, NqF.4*NqF.7*NqF.8^-2*NqF.9^7*NqF.10^-1*NqF.11*\
  NqF.13^4 );
SetConjugate( NqColl, -4, 3, NqF.4^-1*NqF.7*NqF.8^-2*NqF.9^7*NqF.10^-2*\
  NqF.11*NqF.12^2*NqF.13^6 );
SetConjugate( NqColl, -4, -3, NqF.4^-1*NqF.7^-1*NqF.8^2*NqF.9^-7*NqF.10*\
  NqF.11^4*NqF.12*NqF.13^-6 );
SetConjugate( NqColl, 5, 1, NqF.5*NqF.6 );
SetConjugate( NqColl, 5, -1, NqF.5*NqF.6^-1 );
SetConjugate( NqColl, -5, 1, NqF.5^-1*NqF.6^-1 );
SetConjugate( NqColl, -5, -1, NqF.5^-1*NqF.6 );
SetConjugate( NqColl, 5, 2, NqF.5*NqF.7 );
SetConjugate( NqColl, 5, -2, NqF.5*NqF.7^-1*NqF.10^3*NqF.12^2*NqF.13^-6 );
SetConjugate( NqColl, -5, 2, NqF.5^-1*NqF.7^-1 );
SetConjugate( NqColl, -5, -2, NqF.5^-1*NqF.7*NqF.10^-3*NqF.12^2*NqF.13^4 );
SetConjugate( NqColl, 5, 3, NqF.5*NqF.8^-1*NqF.9^5*NqF.11^3*NqF.12^3*\
  NqF.13^-1 );
SetConjugate( NqColl, 5, -3, NqF.5*NqF.8*NqF.9^-5*NqF.11^2*NqF.12^2*NqF.13^-2 );
SetConjugate( NqColl, -5, 3, NqF.5^-1*NqF.8*NqF.9^-5*NqF.11^2*NqF.12*NqF.13^-1 );
SetConjugate( NqColl, -5, -3, NqF.5^-1*NqF.8^-1*NqF.9^5*NqF.11^3*NqF.12^2 );
SetConjugate( NqColl, 5, 4, NqF.5*NqF.9^-3*NqF.12^2*NqF.13^-1 );
SetConjugate( NqColl, 5, -4, NqF.5*NqF.9^3*NqF.12^2*NqF.13^-1 );
SetConjugate( NqColl, -5, 4, NqF.5^-1*NqF.9^3*NqF.12^2*NqF.13^-1 );
SetConjugate( NqColl, -5, -4, NqF.5^-1*NqF.9^-3*NqF.12^2*NqF.13^-1 );
SetConjugate( NqColl, 6, 1, NqF.6 );
SetConjugate( NqColl, 6, -1, NqF.6 );
SetConjugate( NqColl, -6, 1, NqF.6^-1 );
SetConjugate( NqColl, -6, -1, NqF.6^-1 );
SetConjugate( NqColl, 6, 2, NqF.6*NqF.8^2*NqF.9^-7*NqF.10*NqF.11^4*NqF.13^-4 );
SetConjugate( NqColl, 6, -2, NqF.6*NqF.8^-2*NqF.9^7*NqF.10*NqF.11*NqF.12 );
SetConjugate( NqColl, -6, 2, NqF.6^-1*NqF.8^-2*NqF.9^7*NqF.10^-1*NqF.11*\
  NqF.13^4 );
SetConjugate( NqColl, -6, -2, NqF.6^-1*NqF.8^2*NqF.9^-7*NqF.10^-1*NqF.11^4*\
  NqF.12^3*NqF.13^-2 );
SetConjugate( NqColl, 6, 3, NqF.6*NqF.9^2*NqF.11^3*NqF.12^2*NqF.13^-1 );
SetConjugate( NqColl, 6, -3, NqF.6*NqF.9^-2*NqF.11^2*NqF.12^2*NqF.13^-1 );
SetConjugate( NqColl, -6, 3, NqF.6^-1*NqF.9^-2*NqF.11^2*NqF.12^2*NqF.13^-1 );
SetConjugate( NqColl, -6, -3, NqF.6^-1*NqF.9^2*NqF.11^3*NqF.12^2*NqF.13^-1 );
SetConjugate( NqColl, 6, 4, NqF.6*NqF.11^2 );
SetConjugate( NqColl, 6, -4, NqF.6*NqF.11^3 );
SetConjugate( NqColl, -6, 4, NqF.6^-1*NqF.11^3 );
SetConjugate( NqColl, -6, -4, NqF.6^-1*NqF.11^2 );
SetConjugate( NqColl, 7, 1, NqF.7*NqF.8 );
SetConjugate( NqColl, 7, -1, NqF.7*NqF.8^-1*NqF.9*NqF.11^4 );
SetConjugate( NqColl, -7, 1, NqF.7^-1*NqF.8^-1 );
SetConjugate( NqColl, -7, -1, NqF.7^-1*NqF.8*NqF.9^-1*NqF.11 );
SetConjugate( NqColl, 7, 2, NqF.7*NqF.10^3*NqF.12^2*NqF.13^-6 );
SetConjugate( NqColl, 7, -2, NqF.7*NqF.10^-3*NqF.12^2*NqF.13^4 );
SetConjugate( NqColl, -7, 2, NqF.7^-1*NqF.10^-3*NqF.12^2*NqF.13^4 );
SetConjugate( NqColl, -7, -2, NqF.7^-1*NqF.10^3*NqF.12^2*NqF.13^-6 );
SetConjugate( NqColl, 7, 3, NqF.7*NqF.10^-1*NqF.12*NqF.13^2 );
SetConjugate( NqColl, 7, -3, NqF.7*NqF.10*NqF.12^3*NqF.13^-4 );
SetConjugate( NqColl, -7, 3, NqF.7^-1*NqF.10*NqF.12^3*NqF.13^-4 );
SetConjugate( NqColl, -7, -3, NqF.7^-1*NqF.10^-1*NqF.12*NqF.13^2 );
SetConjugate( NqColl, 7, 4, NqF.7*NqF.12*NqF.13^-2 );
SetConjugate( NqColl, 7, -4, NqF.7*NqF.12^3 );
SetConjugate( NqColl, -7, 4, NqF.7^-1*NqF.12^3 );
SetConjugate( NqColl, -7, -4, NqF.7^-1*NqF.12*NqF.13^-2 );
SetConjugate( NqColl, 8, 1, NqF.8*NqF.9 );
SetConjugate( NqColl, 8, -1, NqF.8*NqF.9^-1*NqF.11 );
SetConjugate( NqColl, -8, 1, NqF.8^-1*NqF.9^-1 );
SetConjugate( NqColl, -8, -1, NqF.8^-1*NqF.9*NqF.11^4 );
SetConjugate( NqColl, 8, 2, NqF.8*NqF.10 );
SetConjugate( NqColl, 8, -2, NqF.8*NqF.10^-1 );
SetConjugate( NqColl, -8, 2, NqF.8^-1*NqF.10^-1 );
SetConjugate( NqColl, -8, -2, NqF.8^-1*NqF.10 );
SetConjugate( NqColl, 8, 3, NqF.8*NqF.12^3*NqF.13^-1 );
SetConjugate( NqColl, 8, -3, NqF.8*NqF.12*NqF.13^-1 );
SetConjugate( NqColl, -8, 3, NqF.8^-1*NqF.12*NqF.13^-1 );
SetConjugate( NqColl, -8, -3, NqF.8^-1*NqF.12^3*NqF.13^-1 );
SetConjugate( NqColl, 9, 1, NqF.9*NqF.11 );
SetConjugate( NqColl, 9, -1, NqF.9*NqF.11^4 );
SetConjugate( NqColl, -9, 1, NqF.9^-1*NqF.11^4 );
SetConjugate( NqColl, -9, -1, NqF.9^-1*NqF.11 );
SetConjugate( NqColl, 9, 2, NqF.9*NqF.12 );
SetConjugate( NqColl, 9, -2, NqF.9*NqF.12^3*NqF.13^-2 );
SetConjugate( NqColl, -9, 2, NqF.9^-1*NqF.12^3*NqF.13^-2 );
SetConjugate( NqColl, -9, -2, NqF.9^-1*NqF.12 );
SetConjugate( NqColl, 10, 1, NqF.10*NqF.13 );
SetConjugate( NqColl, 10, -1, NqF.10*NqF.13^-1 );
SetConjugate( NqColl, -10, 1, NqF.10^-1*NqF.13^-1 );
SetConjugate( NqColl, -10, -1, NqF.10^-1*NqF.13 );
SetConjugate( NqColl, 10, 2, NqF.10 );
SetConjugate( NqColl, 10, -2, NqF.10 );
SetConjugate( NqColl, -10, 2, NqF.10^-1 );
SetConjugate( NqColl, -10, -2, NqF.10^-1 );

return PcpGroupByCollector( NqColl );

elif n = 3 then 

NqF := FreeGroup( 17 );
NqColl := FromTheLeftCollector( NqF );
SetRelativeOrder( NqColl, 8, 2 );
SetRelativeOrder( NqColl, 10, 2 );
SetRelativeOrder( NqColl, 11, 2 );
SetRelativeOrder( NqColl, 14, 2 );
SetRelativeOrder( NqColl, 15, 2 );
SetRelativeOrder( NqColl, 17, 5 );
SetPower( NqColl, 8, NqF.9*NqF.10*NqF.11*NqF.12^-1*NqF.13^3*NqF.14*\
  NqF.16^-2*NqF.17 );
SetPower( NqColl, 10, NqF.12*NqF.15*NqF.16^3 );
SetPower( NqColl, 11, NqF.13*NqF.14*NqF.16^-2*NqF.17 );
SetPower( NqColl, 14, NqF.16^2 );
SetPower( NqColl, 15, NqF.16 );
SetConjugate( NqColl, 2, 1, NqF.2*NqF.3 );
SetConjugate( NqColl, 2, -1, NqF.2*NqF.3^-1 );
SetConjugate( NqColl, -2, 1, NqF.2^-1*NqF.3^-1*NqF.4*NqF.5^-1*NqF.6^-1*\
  NqF.7*NqF.8*NqF.9*NqF.10*NqF.11*NqF.13^-2*NqF.15*NqF.16^-2*NqF.17^3 );
SetConjugate( NqColl, -2, -1, NqF.2^-1*NqF.3*NqF.4^-1*NqF.5*NqF.7^-1*NqF.11*\
  NqF.13^-2*NqF.14*NqF.16*NqF.17^2 );
SetConjugate( NqColl, 3, 1, NqF.3 );
SetConjugate( NqColl, 3, -1, NqF.3 );
SetConjugate( NqColl, -3, 1, NqF.3^-1 );
SetConjugate( NqColl, -3, -1, NqF.3^-1 );
SetConjugate( NqColl, 3, 2, NqF.3*NqF.4 );
SetConjugate( NqColl, 3, -2, NqF.3*NqF.4^-1*NqF.5*NqF.7^-1*NqF.11*NqF.13^-2*\
  NqF.14*NqF.16*NqF.17^2 );
SetConjugate( NqColl, -3, 2, NqF.3^-1*NqF.4^-1*NqF.6*NqF.9^-1*NqF.10*NqF.12^-1*\
  NqF.15*NqF.16^-4 );
SetConjugate( NqColl, -3, -2, NqF.3^-1*NqF.4*NqF.5^-1*NqF.6^-1*NqF.7*NqF.8*\
  NqF.9*NqF.10*NqF.11*NqF.13^-2*NqF.15*NqF.16^-2*NqF.17^3 );
SetConjugate( NqColl, 4, 1, NqF.4*NqF.6*NqF.9^-1 );
SetConjugate( NqColl, 4, -1, NqF.4*NqF.6^-1*NqF.9*NqF.10*NqF.15*NqF.16^-2 );
SetConjugate( NqColl, -4, 1, NqF.4^-1*NqF.6^-1*NqF.9*NqF.15*NqF.16 );
SetConjugate( NqColl, -4, -1, NqF.4^-1*NqF.6*NqF.9^-1*NqF.10*NqF.12^-1*\
  NqF.15*NqF.16^-4 );
SetConjugate( NqColl, 4, 2, NqF.4*NqF.5 );
SetConjugate( NqColl, 4, -2, NqF.4*NqF.5^-1*NqF.7 );
SetConjugate( NqColl, -4, 2, NqF.4^-1*NqF.5^-1*NqF.11*NqF.13*NqF.16^-1*\
  NqF.17 );
SetConjugate( NqColl, -4, -2, NqF.4^-1*NqF.5*NqF.7^-1*NqF.11*NqF.13^-2*\
  NqF.14*NqF.16*NqF.17^2 );
SetConjugate( NqColl, 4, 3, NqF.4*NqF.6*NqF.9^-1 );
SetConjugate( NqColl, 4, -3, NqF.4*NqF.6^-1*NqF.9*NqF.10*NqF.15*NqF.16^-2 );
SetConjugate( NqColl, -4, 3, NqF.4^-1*NqF.6^-1*NqF.9*NqF.15*NqF.16 );
SetConjugate( NqColl, -4, -3, NqF.4^-1*NqF.6*NqF.9^-1*NqF.10*NqF.12^-1*\
  NqF.15*NqF.16^-4 );
SetConjugate( NqColl, 5, 1, NqF.5*NqF.6 );
SetConjugate( NqColl, 5, -1, NqF.5*NqF.6^-1*NqF.10*NqF.12*NqF.15*NqF.16^-2 );
SetConjugate( NqColl, -5, 1, NqF.5^-1*NqF.6^-1 );
SetConjugate( NqColl, -5, -1, NqF.5^-1*NqF.6*NqF.10*NqF.12^-2*NqF.16^-2 );
SetConjugate( NqColl, 5, 2, NqF.5*NqF.7 );
SetConjugate( NqColl, 5, -2, NqF.5*NqF.7^-1 );
SetConjugate( NqColl, -5, 2, NqF.5^-1*NqF.7^-1 );
SetConjugate( NqColl, -5, -2, NqF.5^-1*NqF.7 );
SetConjugate( NqColl, 5, 3, NqF.5*NqF.8*NqF.11*NqF.13^-3*NqF.14*NqF.15*\
  NqF.16^-1*NqF.17^3 );
SetConjugate( NqColl, 5, -3, NqF.5*NqF.8*NqF.9^-1*NqF.10*NqF.13^-1*NqF.15*\
  NqF.16^-3 );
SetConjugate( NqColl, -5, 3, NqF.5^-1*NqF.8*NqF.9^-1*NqF.10*NqF.13^-1*\
  NqF.14*NqF.16^-3 );
SetConjugate( NqColl, -5, -3, NqF.5^-1*NqF.8*NqF.11*NqF.13^-3*NqF.16*NqF.17^3 );
SetConjugate( NqColl, 5, 4, NqF.5*NqF.11*NqF.13*NqF.16^-1*NqF.17 );
SetConjugate( NqColl, 5, -4, NqF.5*NqF.11*NqF.13^-2*NqF.14*NqF.16*NqF.17^3 );
SetConjugate( NqColl, -5, 4, NqF.5^-1*NqF.11*NqF.13^-2*NqF.14*NqF.16*NqF.17^3 );
SetConjugate( NqColl, -5, -4, NqF.5^-1*NqF.11*NqF.13*NqF.16^-1*NqF.17 );
SetConjugate( NqColl, 6, 1, NqF.6*NqF.10*NqF.12*NqF.15*NqF.16^-2 );
SetConjugate( NqColl, 6, -1, NqF.6*NqF.10*NqF.12^-2*NqF.16^-2 );
SetConjugate( NqColl, -6, 1, NqF.6^-1*NqF.10*NqF.12^-2*NqF.16^-2 );
SetConjugate( NqColl, -6, -1, NqF.6^-1*NqF.10*NqF.12*NqF.15*NqF.16^-2 );
SetConjugate( NqColl, 6, 2, NqF.6*NqF.8 );
SetConjugate( NqColl, 6, -2, NqF.6*NqF.8*NqF.9^-1*NqF.10*NqF.13^-3*NqF.14*\
  NqF.15*NqF.16^-4*NqF.17 );
SetConjugate( NqColl, -6, 2, NqF.6^-1*NqF.8*NqF.9^-1*NqF.10*NqF.11*NqF.13^-4*\
  NqF.15*NqF.16^-2*NqF.17^3 );
SetConjugate( NqColl, -6, -2, NqF.6^-1*NqF.8*NqF.11*NqF.13^-1*NqF.14*NqF.17^2 );
SetConjugate( NqColl, 6, 3, NqF.6*NqF.10*NqF.15*NqF.16^-3 );
SetConjugate( NqColl, 6, -3, NqF.6*NqF.10*NqF.12^-1*NqF.16^-1 );
SetConjugate( NqColl, -6, 3, NqF.6^-1*NqF.10*NqF.12^-1*NqF.16^-1 );
SetConjugate( NqColl, -6, -3, NqF.6^-1*NqF.10*NqF.15*NqF.16^-3 );
SetConjugate( NqColl, 6, 4, NqF.6*NqF.15*NqF.16 );
SetConjugate( NqColl, 6, -4, NqF.6*NqF.15*NqF.16^-2 );
SetConjugate( NqColl, -6, 4, NqF.6^-1*NqF.15*NqF.16^-2 );
SetConjugate( NqColl, -6, -4, NqF.6^-1*NqF.15*NqF.16 );
SetConjugate( NqColl, 7, 1, NqF.7*NqF.9 );
SetConjugate( NqColl, 7, -1, NqF.7*NqF.9^-1*NqF.12 );
SetConjugate( NqColl, -7, 1, NqF.7^-1*NqF.9^-1 );
SetConjugate( NqColl, -7, -1, NqF.7^-1*NqF.9*NqF.12^-1 );
SetConjugate( NqColl, 7, 2, NqF.7 );
SetConjugate( NqColl, 7, -2, NqF.7 );
SetConjugate( NqColl, -7, 2, NqF.7^-1 );
SetConjugate( NqColl, -7, -2, NqF.7^-1 );
SetConjugate( NqColl, 7, 3, NqF.7*NqF.13^-1*NqF.16 );
SetConjugate( NqColl, 7, -3, NqF.7*NqF.13*NqF.16^-1 );
SetConjugate( NqColl, -7, 3, NqF.7^-1*NqF.13*NqF.16^-1 );
SetConjugate( NqColl, -7, -3, NqF.7^-1*NqF.13^-1*NqF.16 );
SetConjugate( NqColl, 7, 4, NqF.7*NqF.17^4 );
SetConjugate( NqColl, 7, -4, NqF.7*NqF.17 );
SetConjugate( NqColl, -7, 4, NqF.7^-1*NqF.17 );
SetConjugate( NqColl, -7, -4, NqF.7^-1*NqF.17^4 );
SetConjugate( NqColl, 8, 1, NqF.8*NqF.10 );
SetConjugate( NqColl, 8, -1, NqF.8*NqF.10*NqF.12^-1*NqF.15*NqF.16^-4 );
SetConjugate( NqColl, 8, 2, NqF.8*NqF.11 );
SetConjugate( NqColl, 8, -2, NqF.8*NqF.11*NqF.13^-1*NqF.14*NqF.17^2 );
SetConjugate( NqColl, 8, 3, NqF.8*NqF.14*NqF.15*NqF.16^-2 );
SetConjugate( NqColl, 8, -3, NqF.8*NqF.14*NqF.15*NqF.16^-1 );
SetConjugate( NqColl, 9, 1, NqF.9*NqF.12 );
SetConjugate( NqColl, 9, -1, NqF.9*NqF.12^-1 );
SetConjugate( NqColl, -9, 1, NqF.9^-1*NqF.12^-1 );
SetConjugate( NqColl, -9, -1, NqF.9^-1*NqF.12 );
SetConjugate( NqColl, 9, 2, NqF.9*NqF.13 );
SetConjugate( NqColl, 9, -2, NqF.9*NqF.13^-1*NqF.17 );
SetConjugate( NqColl, -9, 2, NqF.9^-1*NqF.13^-1 );
SetConjugate( NqColl, -9, -2, NqF.9^-1*NqF.13*NqF.17^4 );
SetConjugate( NqColl, 9, 3, NqF.9*NqF.16^-1 );
SetConjugate( NqColl, 9, -3, NqF.9*NqF.16 );
SetConjugate( NqColl, -9, 3, NqF.9^-1*NqF.16 );
SetConjugate( NqColl, -9, -3, NqF.9^-1*NqF.16^-1 );
SetConjugate( NqColl, 10, 1, NqF.10 );
SetConjugate( NqColl, 10, -1, NqF.10 );
SetConjugate( NqColl, 10, 2, NqF.10*NqF.14 );
SetConjugate( NqColl, 10, -2, NqF.10*NqF.14*NqF.16^-2 );
SetConjugate( NqColl, 11, 1, NqF.11*NqF.15 );
SetConjugate( NqColl, 11, -1, NqF.11*NqF.15*NqF.16^-1 );
SetConjugate( NqColl, 11, 2, NqF.11*NqF.17^3 );
SetConjugate( NqColl, 11, -2, NqF.11*NqF.17^2 );
SetConjugate( NqColl, 12, 1, NqF.12 );
SetConjugate( NqColl, 12, -1, NqF.12 );
SetConjugate( NqColl, -12, 1, NqF.12^-1 );
SetConjugate( NqColl, -12, -1, NqF.12^-1 );
SetConjugate( NqColl, 12, 2, NqF.12*NqF.16^2 );
SetConjugate( NqColl, 12, -2, NqF.12*NqF.16^-2 );
SetConjugate( NqColl, -12, 2, NqF.12^-1*NqF.16^-2 );
SetConjugate( NqColl, -12, -2, NqF.12^-1*NqF.16^2 );
SetConjugate( NqColl, 13, 1, NqF.13*NqF.16 );
SetConjugate( NqColl, 13, -1, NqF.13*NqF.16^-1 );
SetConjugate( NqColl, -13, 1, NqF.13^-1*NqF.16^-1 );
SetConjugate( NqColl, -13, -1, NqF.13^-1*NqF.16 );
SetConjugate( NqColl, 13, 2, NqF.13*NqF.17 );
SetConjugate( NqColl, 13, -2, NqF.13*NqF.17^4 );
SetConjugate( NqColl, -13, 2, NqF.13^-1*NqF.17^4 );
SetConjugate( NqColl, -13, -2, NqF.13^-1*NqF.17 );

return PcpGroupByCollector( NqColl );

fi;

return fail;

end);

