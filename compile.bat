@echo off
echo Compiling...
del bin\As3ToHaxe.n /Q
haxe -cp src -main As3ToHaxe -neko bin/As3ToHaxe.n
convert.bat