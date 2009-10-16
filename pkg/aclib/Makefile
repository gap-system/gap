#########################################################################
##
#W  Makefile                  aclib                         Karel Dekimpe
#W                                                           Bettina Eick
##

default:
	@echo 'make aclib: create the archives for release'
	@echo 'make clean: remove archives and temporarily checked out copies'

aclib:
	rm -f aclib.zoo aclib.tgz aclib.tar
	tar cf aclib.tar aclib/
	gzip < aclib.tar > aclib.tgz
	find aclib/ -type f -exec zoo ah aclib.zoo "{}" ";"

clean:
	rm -f aclib.zoo aclib.tgz aclib.tar
