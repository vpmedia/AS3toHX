::
:: Copyright 2012, Andras Csizmadia <andras@vpmedia.eu>.
::

:: Echo off and begin localisation of Environment Variables
@ECHO OFF & SETLOCAL

:: Prepare the Command Processor
VERIFY errors 2>nul
SETLOCAL ENABLEEXTENSIONS
IF ERRORLEVEL 1 ECHO Warning: Unable to enable extensions.
SETLOCAL ENABLEDELAYEDEXPANSION

:: Save base directory
PUSHD %CD%
::PUSHD %~dp0

:: Set title
TITLE %~n0

:: STARTUP
echo Compiling...
del bin\As3ToHaxe.n /Q
haxe -cp src -main As3ToHaxe -neko bin/As3ToHaxe.n
convert.bat