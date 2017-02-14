# 2012/10/26 (SL) 
# Fix a crash when a logfile opened with LogTo() is closed with LogInputTo()  
gap> LogTo( Filename( DirectoryTemporary(), "foo" ) );
gap> LogInputTo();
Error, InputLogTo: can not close the logfile
gap> LogTo();
