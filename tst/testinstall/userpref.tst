#############################################################################
##
##  This file tests the handling of user preferences
##
#@local data, oldsize
gap> START_TEST("userpref.tst");

# the descriptions shown by ShowUserPreferences are wrapped such that they
# fit onto the screen
gap> data := DataOfUserPreference("gap", "UseColorPrompt");;
gap> data <> fail;
true
gap> oldsize := SizeScreen();;
gap> SizeScreen([80,24]);;
gap> ForAll(SplitString(ShowStringUserPreference(data), "\n"),
>           l -> Length(l) <= 78);
true
gap> SizeScreen([50,24]);;
gap> ForAll(SplitString(ShowStringUserPreference(data), "\n"),
>           l -> Length(l) <= 48);
true

# the gap.ini file is written with a fixed width of 78 characters
gap> ForAll(SplitString(StringUserPreference(data, true), "\n"),
>           l -> Length(l) <= 78);
true
gap> SizeScreen(oldsize);;

#
gap> STOP_TEST("userpref.tst");
