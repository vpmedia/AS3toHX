Tarwins AS3 to Haxe converter [![Build Status](https://travis-ci.org/haxe-community/AS3toHX.png?branch=master)](https://travis-ci.org/haxe-community/AS3toHX)
=============================
<img src="https://cloud.githubusercontent.com/assets/138324/5040646/cd167ff8-6b66-11e4-8282-504b7c7d6fcd.png" alt="AS3toHX Icon" align="right" />

A simple ActionScript 3 to Haxe 3 transcoder, which takes an AS3 source directory and converts all .as (AS3 classes) to .hx (Haxe classes).  

An additional installer shell script and execution script have been added to speed up installation and execution of the As3ToHaxe tool.

## Building

```
haxe build.hxml
```

## Usage

```
neko As3ToHaxe.n -from SOURCE/FOLDER -to TARGET/FOLDER -useSpaces false
```

## Alternative install script for Linux and OSX

```
./install.sh
```

Post install use

```
as3tohx <source> <destination>
```

or 

```
as3tohx -h
```

## Notes

Including experimental AS3 to JavaScript converter