#
# Makefile for wrapping the GAP release
#
# update: bases on the tag of the last release in the stable branch
# minor : based on the tip of the stable branch
# major : based on the tip of the default branch

update:
	cp setvarupdate setvar
	./doit

minor:
	cp setvarminor setvar
	./doit

major:
	cp setvarmajor setvar
	./doit

clean:
	rm setvar
