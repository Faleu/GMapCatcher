:: Create an executable using py2exe then
:: Make the installer using NSIS

:: Prerequisites:
:: Python 2.7 must be installed in %SystemDrive%\PYTHON27
:: PyGTK all-in-one must be installed
:: Py2exe for Python 2.7 must be installed
:: NSIS installation builder must be installed in %SystemDrive%\Program Files (x86)\NSIS
:: Plugin AccessControl.dll for NSIS must be placed into %ProgramFiles%\NSIS\Plugins\x86-ansi
::
:: %SystemDrive% is usually C:
:: %ProgramFiles% is usually C:\Program Files (x86)

:: Tested with:
::  python-2.7.msi
::  gtk2-runtime-2.22.0-2010-10-21-ash.exe
::  gtk2-themes-2009-09-07-ash.exe
::  PIL-1.1.7.win32-py2.7.exe
::  py2exe-0.6.9.win32-py2.7.exe
::  pycairo-1.8.10.win32-py2.7.exe
::  pygobject-2.26.0.win32-py2.7.exe
::  pygtk-2.22.0.win32-py2.7.exe
::  nsis-2.46-setup.exe
::  AccessControl.zip

:: Check version
@for /f "tokens=3" %%f in ('find "VERSION = " ..\gmapcatcher\mapConst.py') do @set PrVersion=%%f 
@for /f "tokens=3" %%f in ('find "!define PRODUCT_VERSION" setup.nsi') do @set InstVersion=%%f 
@IF NOT %PrVersion% == %InstVersion% (
    @ECHO PrVersion=%PrVersion%
    @ECHO InstVersion=%InstVersion%
    @ECHO Version mismatch!
    @GOTO EndError
)

SET PrVersion = ..\gmapcatcher\mapConst.py

@COLOR 02
:: clean up before starting
@DEL *.exe
@CD ..
@DEL *.exe
@DEL *.pyc /s
@DEL *.bak /s
@RD dist /s /q
@RD build /s /q

@ECHO.
@ECHO.
@ECHO  CLEANING COMPLETE!   READY TO START?
@ECHO.
@PAUSE

:: Launch the PYTHON setup
@COPY installer\setup.* .
%SystemDrive%\PYTHON27\PYTHON.EXE setup.py py2exe
@IF NOT %ERRORLEVEL% == 0 GOTO EndError
:: Few seconds delay to show dependencies
@COLOR F0
@ECHO.
@PING 1.1 /n 2 /i 1 > NUL
@COLOR 03

:: Copy all the image files
@MD dist\images
@COPY images dist\images

:: Need to copy the [etc, lib, share] directories from your GTK+ install
::(not the pygtk install) to the "dist" dir py2exe created.
:: All the Required files should be in the "common" folder
@XCOPY /E common\* dist

:: Launch the NSIS setup
@COLOR 07
SET NSIS="%ProgramFiles%\NSIS\makensis.exe"
IF NOT EXIST %NSIS% SET NSIS="%ProgramFiles(x86)%\NSIS\makensis.exe"
CALL %NSIS% setup.nsi
@ECHO.

:: clean up at the end
@DEL *.pyc /s > NUL
@DEL setup.* /q
@RD build /s /q
@RD dist /s /q

@ECHO.
@ECHO.
@COLOR 0A
@MOVE *.exe installer
@GOTO End

:EndError
@COLOR C
@ECHO Fatal error.

:End
@ECHO.
@PAUSE
