#
# Makefile for wrapping the merged archive of GAP packages
#
# update: to test with the last release in the stable branch
# minor : to thest with the tip of the stable branch
# major : to test with the tip of the default branch
# integration : to test with the tip of the integration branch

pkg-update:
	./mergePackages tip fr=stable gpd=stable idrel=stable kan=stable rcwa=stable xmod=stable

pkg-minor:
	./mergePackages tip fr=stable gpd=stable idrel=stable kan=stable rcwa=stable xmod=stable

pkg-major:
	./mergePackages tip

pkg-integration:
	./mergePackages tip orb=no citrus=no
