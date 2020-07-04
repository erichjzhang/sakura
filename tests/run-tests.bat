@echo off
set platform=%1
set configuration=%2
set TEST_LAUNCHED=0
set ERROR_RESULT=0

if defined APPVEYOR (
	set FILTER_BAT=%~dp0test_result_filter_tell_AppVeyor.bat
)

set BUILDDIR=build\%platform%\%configuration%
set BINARY_DIR=%~dp0%BUILDDIR%\unittests

pushd %BINARY_DIR%
for /r %%i in (tests*.exe) do (
	set TEST_LAUNCHED=1

	call :RunTest %%i %%i-googletest-%platform%-%configuration%.xml || set ERROR_RESULT=1
)
popd

if "%TEST_LAUNCHED%" == "0" (
	@echo ERROR: no tests are available.
	exit /b 1
)

if "%ERROR_RESULT%" == "1" (
	@echo ERROR in some test(s^).
	exit /b 1
)
exit /b 0

:RunTest
set EXEPATH=%1
set XMLPATH=%2

if defined FILTER_BAT (
	@echo %EXEPATH% --gtest_output=xml:%XMLPATH% ^| "%FILTER_BAT%"
	      %EXEPATH% --gtest_output=xml:%XMLPATH%  | "%FILTER_BAT%"
) else (
	@echo %EXEPATH% --gtest_output=xml:%XMLPATH%
	      %EXEPATH% --gtest_output=xml:%XMLPATH%
)
exit /b %errorlevel%
