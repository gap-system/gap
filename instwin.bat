@echo off
rem  Installation file for GAP4 under windows. ahulpke, 19-5-99
rem
if not exist lib\init.g goto err1
dir | find "Directory" > blubber.bat
echo set gdir=%%2> Directory.bat
call blubber
del blubber.bat
del Directory.bat
echo @echo off >bin\gap.bat
echo %gdir%\bin\gapw95.exe -m 14m -l %gdir%; %%1 %%2 %%3 %%4 %%5 %%6 %%7 %%8 >>bin\gap.bat
if not exist bin\gapw95.exe goto err1
if not exist bin\gap.bat goto err1
echo Installation completed.
echo (If your version of Windows uses a language other than English, you *must*
echo still edit the file `bin\gap.bat' as described in the INSTALL.WIN file.)
echo To start GAP 4 use the file `%gdir%\bin\gap.bat'.
echo Please remember to send an acknowledgment of the installation to 
echo `gap@dcs.st-and.ac.uk'.
goto end
:err1
echo Error, You have not extracted the `zoo' archive with the library or are
echo not calling this batch file from the main GAP directory!
echo ---------------------------------------------------
echo Information about the GAP installation > gaphlp.dbg
dir /v >>gaphlp.dbg
dir /v bin >>gaphlp.dbg
dir /v lib >>gaphlp.dbg
echo If you need help debugging please send the file `gaphlp.dbg' to
echo `gap-trouble@dcs.st-and.ac.uk'
:end
