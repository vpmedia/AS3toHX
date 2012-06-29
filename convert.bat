@echo off
echo Converting...
del test\hx\Main.hx /Q
neko bin/As3ToHaxe.n -from test/as3 -to test/hx -useSpaces false