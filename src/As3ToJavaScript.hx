/*
 * Copyright (c) 2011, TouchMyPixel & contributors
 * Original author : Tarwin Stroh-Spijer <tarwin@touchmypixel.com>
 * Contributors: Tony Polinelli <tonyp@touchmypixel.com>       
 *               Andras Csizmadia <andras@vpmedia.eu>
 * Reference for further improvements: 
 * http://haxe.org/doc/start/flash/as3migration/part1 
 * http://www.haxenme.org/developers/documentation/actionscript-developers/
 * http://www.haxenme.org/api/  
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE TOUCH MY PIXEL & CONTRIBUTERS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE TOUCH MY PIXEL & CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

package;

import sys.FileSystem;
import neko.Lib;
//import neko.Sys;

using StringTools;
using As3ToJavaScript;

/**
 * Simple Program which iterates -from folder, finds .mtt templates and compiles them to the -to folder
 */
class As3ToJavaScript
{
    public static var keys = ["-from", "-to", "-remove", "-useSpaces"];
    
    var to:String;
    var from:String; 
    var useSpaces:String;
    var remove:String;
    var sysargs:Array<String>;
    
    var items:Array<String>;
    
    public static var basePackage:String = "away3d";
    
    private var nameSpaces:Map<String,Ns>;
    private var maxLoop:Int;
    
    static function main() 
    {
        new As3ToJavaScript();
    }
    
    public function new()
    {
        maxLoop = 1000;
        
        if (parseArgs())
        {
        
            // make sure that the to directory exists
            if (!FileSystem.exists(to)) FileSystem.createDirectory(to);
            
            // delete old files
            if (remove == "true")
                removeDirectory(to);
            
            items = [];
            // fill items
            recurse(from);

            // to remember namespaces
            nameSpaces = new Map();
            
            for (item in items)
            {
                // make sure we only work wtih AS fiels
                var ext = getExt(item);
                switch(ext)
                {
                    case "as": 
                        doConversion(item);
                }
            }
            
            // build namespace files
            buildNameSpaces();
        }
    }
    
    private function doConversion(file:String):Void
    {        
        var fromFile = file;
        var toFile = to + "/" + file.substr(from.length + 1, file.lastIndexOf(".") - (from.length)) + "js";
        
        var rF = "";
        var rC = "";
        
        var b = 0;
        
        /* -----------------------------------------------------------*/
        // create the folder if it doesn''t exist
        var dir = toFile.substr(0, toFile.lastIndexOf("/"));
        createFolder(dir);
        
        var s = sys.io.File.getContent(fromFile);
        
        /* -----------------------------------------------------------*/
        // space to tabs      
        s = quickRegR(s, "    ", "\t");
        
        // undent
        //s = quickRegR(s, "\t\t", "\t");
        
        /* -----------------------------------------------------------*/
        // some quick setup, finding what we''ve got
        var className = quickRegM(s, "public class([ ]*)([A-Z][a-zA-Z0-9_]*)", 2)[1];
        
        /* -----------------------------------------------------------*/
        // class
        s = quickRegR(s, "class ([a-zA-Z\\.0-9-_]*)([\n\r]*);", "", "gs");
        
        // import
        s = quickRegR(s, "import ([a-zA-Z\\.0-9-_]*)([\n\r]*);", "", "gs");
        
        // package with name
        s = quickRegR(s, "package ([a-zA-Z\\.0-9-_]*)([\n\r]*){", "", "gs");
        
        // package without name
        s = quickRegR(s, "package([\n\r]*){", "", "gs");
        
        // remove package close bracket 
        s = quickRegR(s, "\\}([\n\r\t ]*)\\}([\n\r\t ]*)$", "}", "gs");
        
        // comment out standard meta-data
        s = quickRegR(s, "\\[SWF\\(", "//[SWF("); 
        s = quickRegR(s, "\\[Bindable\\(", "//[Bindable("); 
        s = quickRegR(s, "\\[Embed\\(", "//[Embed(");
        s = quickRegR(s, "\\[Event\\(", "//[Event(");
        s = quickRegR(s, "\\[Frame\\(", "//[Frame(");
        
        /* -----------------------------------------------------------*/
        // trim properties to untyped
        s = quickRegR(s, "public ", "", "gs");
        s = quickRegR(s, "private ", "", "gs");
        s = quickRegR(s, "static ", "", "gs");
        s = quickRegR(s, "protected ", "", "gs");
        s = quickRegR(s, "interface ", "", "gs");
        s = quickRegR(s, "inline ", "", "gs");
        s = quickRegR(s, "final ", "", "gs");
        
        /* -----------------------------------------------------------*/
        // remove 'super();'
        s = quickRegR(s, "super\\(\\)\\;", "", "gs");
        
        /* -----------------------------------------------------------*/
        // trim extra indentation
        s = quickRegR(s, "\n\t", "\n");
           
        /* -----------------------------------------------------------*/
        // trim spaces 
        s = quickRegR(s, "([ ]*):([ ]*)", ":");
        s = quickRegR(s, "([ ]*);([ ]*)", ";");
        s = quickRegR(s, "([ ]*)=([ ]*)", "=");
        s = quickRegR(s, "([ ]*)<([ ]*)", "<"); 
        s = quickRegR(s, "([ ]*)>([ ]*)", ">"); 
        s = quickRegR(s, "([ ]*)<=([ ]*)", "<="); 
        s = quickRegR(s, "([ ]*)>=([ ]*)", ">=");
        s = quickRegR(s, "([ ]*)\\(([ ]*)", "(");
        s = quickRegR(s, "([ ]*)\\)([ ]*)", ")");
                  
        /* -----------------------------------------------------------*/
        // change logging to console
        s = quickRegR(s, "trace\\(", "console.log(", "gs");
        
        /* -----------------------------------------------------------*/
        // fix getter setter spaces
        s = quickRegR(s, " get ", " get_", "gs");
        s = quickRegR(s, " set ", " set_", "gs");
        
        /* -----------------------------------------------------------*/
        // change local const to var
        s = quickRegR(s, "const ", "var ");
                          
        /* -----------------------------------------------------------*/
        // vector to array mapping     
        s = quickRegR(s, "Vector([ ]*)\\.([ ]*)<([ ]*)([^>]*)([ ]*)>", "Array");
        s = quickRegR(s, "Vector([ ]*);", "Array");
                                      
        /* -----------------------------------------------------------*/    
        // simple typing
        s = quickRegR(s, ":void", "");
        s = quickRegR(s, ":Boolean", "");
        s = quickRegR(s, ":uint", ""); 
        s = quickRegR(s, ":int", "");
        s = quickRegR(s, ":Number", "");
        s = quickRegR(s, ":\\*", ""); 
        s = quickRegR(s, ":Object", ""); 
        s = quickRegR(s, ":Error", "");  
        s = quickRegR(s, ":String", "");   
        s = quickRegR(s, ":Array", "");   
        
        /* -----------------------------------------------------------*/  
        // no casting
        s = quickRegR(s, "as void", "");
        s = quickRegR(s, "as Boolean", "");
        s = quickRegR(s, "as uint", ""); 
        s = quickRegR(s, "as int", "");
        s = quickRegR(s, "as Number", "");
        s = quickRegR(s, "as \\*", ""); 
        s = quickRegR(s, "as Object", ""); 
        s = quickRegR(s, "as Error", "");  
        s = quickRegR(s, "as String", "");   
        s = quickRegR(s, "as Array", ""); 

        /* -----------------------------------------------------------*/
        
        // remap for in -> in
        // s = quickRegR(s, "for\\(var([ ]*)([a-zA-Z0-9_]*):([a-zA-Z0-9_]*)([ ]*)in([ ]*)([a-zA-Z0-9_]*)([ ]*)", "for($2 in $6");
        
        /* -----------------------------------------------------------*/
        
        // remap for; <; next;
        s = quickRegR(s, "for\\(var([ ]*)([a-zA-Z0-9_]*):([a-zA-Z0-9_]*)=([0-9]);([a-zA-Z0-9_]*)([<]*)([a-zA-Z0-9_.]*);([a-zA-Z0-9_.]*)([++]*)", "for($2 in $4...$7");
        // remap for; <=; next;
        s = quickRegR(s, "for\\(var([ ]*)([a-zA-Z0-9_]*):([a-zA-Z0-9_]*)=([0-9]);([a-zA-Z0-9_]*)([<=]*)([a-zA-Z0-9_.]*);([a-zA-Z0-9_.]*)([++]*)", "for($2 in $4...$7");
                       
        /* -----------------------------------------------------------*/
        
        // remap for each -> for
        s = quickRegR(s, "for each", "for");
                
        /* -----------------------------------------------------------*/
                
        // use spaces instead of tab
        if(useSpaces == "true")
        {
            s = quickRegR(s, "\t", "    ");
        }
        
        /* -----------------------------------------------------------*/
        
        var o = sys.io.File.write(toFile, true);
        o.writeString(s);
        o.close();
        
        /* -----------------------------------------------------------*/
        
        // use for testing on a single file
        //Sys.exit(1);
    }
    
    private function logLoopError(type:String, file:String)
    {
        trace("ERROR: " + type + " - " + file);
    }
    
    private function buildNameSpaces()
    {
        // build friend namespaces!
        //trace("NS: " + nameSpaces);
    }
    
    public static function quickRegR(str:String, reg:String, rep:String, ?regOpt:String = "g"):String
    {
        return new EReg(reg, regOpt).replace(str, rep);
    }
    
    public static function quickRegM(str:String, reg:String, ?numMatches:Int = 1, ?regOpt:String = "g"):Array<String>
    {
        var r = new EReg(reg, regOpt);
        var m = r.match(str);
        if (m) {
            var a = [];
            var i = 1;
            while (i <= numMatches) {
                a.push(r.matched(i));
                i++;
            }
            return a;
        }
        return [];
    }
    
    private function createFolder(path:String):Void
    {
        var parts = path.split("/");
        var folder = "";
        for (part in parts)
        {
            if (folder == "") folder += part;
            else folder += "/" + part;
            if (!FileSystem.exists(folder)) FileSystem.createDirectory(folder);
        }
    }
    
    private function parseArgs():Bool
    {
        // Parse args
        var args = Sys.args();
        for (i in 0...args.length)
            if (Lambda.has(keys, args[i]))
                Reflect.setField(this, args[i].substr(1), args[i + 1]);
            
        // Check to see if argument is missing
        if (to == null) { Lib.println("Missing argument '-to'"); return false; }
        if (from == null) { Lib.println("Missing argument '-from'"); return false; }
        
        return true;
    }
    
    public function recurse(path:String)
    {
        var dir = FileSystem.readDirectory(path);
        
        for (item in dir)
        {
            var s = path + "/" + item;
            if (FileSystem.isDirectory(s))
            {
                recurse(s);
            }
            else
            {
                var exts = ["as"];
                if(Lambda.has(exts, getExt(item)))
                    items.push(s);
            }
        }
    }
    
    public function getExt(s:String)
    {
        return s.substr(s.lastIndexOf(".") + 1).toLowerCase();
    }
    
    public function removeDirectory(d, p = null)
    {
        if (p == null) p = d;
        var dir = FileSystem.readDirectory(d);

        for (item in dir)
        {
            item = p + "/" + item;
            if (FileSystem.isDirectory(item)) {
                removeDirectory(item);
            }else{
                FileSystem.deleteFile(item);
            }
        }
        
        FileSystem.deleteDirectory(d);
    }
    
    public static function fUpper(s:String)
    {
        return s.charAt(0).toUpperCase() + s.substr(1);
    }
}

typedef Ns = {
    var name:String;
    var classDefs:Map<String,String>;
}