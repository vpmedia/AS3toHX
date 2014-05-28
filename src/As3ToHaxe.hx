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
using As3ToHaxe;

/**
 * Simple Program which iterates -from folder, finds .mtt templates and compiles them to the -to folder
 */
class As3ToHaxe
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
        new As3ToHaxe();
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
        var toFile = to + "/" + file.substr(from.length + 1, file.lastIndexOf(".") - (from.length)) + "hx";
        
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
        // package with name
        s = quickRegR(s, "package ([a-zA-Z\\.0-9-_]*)([\n\r]*){", "package $1;\n", "gs");
        
        // package without name
        s = quickRegR(s, "package([\n\r]*){", "package;\n", "gs");
        
        // remove package close bracket 
        s = quickRegR(s, "\\}([\n\r\t ]*)\\}([\n\r\t ]*)$", "}", "gs");

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
        // rename public class -> class
        s = quickRegR(s, "public class", "class");
                        
        /* -----------------------------------------------------------*/
        
        // remap public interface -> interface
        s = quickRegR(s, "public interface", "interface");   

        /* -----------------------------------------------------------*/
        // remap constructor <name> -> function new
        s = quickRegR(s, "function " + className, "function new");   
                        
        /* -----------------------------------------------------------*/
        
        // casting
        s = quickRegR(s, "\\(([a-zA-Z0-9_]*) is ([a-zA-Z0-9_]*)", "(Std.is($1, $2)");
        s = quickRegR(s, "=([a-zA-Z0-9_]*) as ([a-zA-Z0-9_]*)", "=cast($1, $2)");
        
        s = quickRegR(s, " int\\(([a-zA-Z0-9_]*)", " Std.int($1");
        s = quickRegR(s, " Number\\(([a-zA-Z0-9_]*)", " Std.parseFloat($1");
        s = quickRegR(s, " String\\(([a-zA-Z0-9_]*)", " Std.string($1");
        
        s = quickRegR(s, "=int\\(([a-zA-Z0-9_]*)", "=Std.int($1");
        s = quickRegR(s, "=Number\\(([a-zA-Z0-9_]*)", "=Std.parseFloat($1");
        s = quickRegR(s, "=String\\(([a-zA-Z0-9_]*)", "=Std.string($1");
        
        /* -----------------------------------------------------------*/
        // comment out standard metadata
        s = quickRegR(s, "\\[SWF\\(", "//[SWF("); 
        s = quickRegR(s, "\\[Bindable\\(", "//[Bindable("); 
        s = quickRegR(s, "\\[Embed\\(", "//[Embed(");
        s = quickRegR(s, "\\[Event\\(", "//[Event(");
        s = quickRegR(s, "\\[Frame\\(", "//[Frame(");
        
        /* -----------------------------------------------------------*/    
        // simple typing
        s = quickRegR(s, ":void", ":Void");
        s = quickRegR(s, ":Boolean", ":Bool");
        s = quickRegR(s, ":uint", ":Int"); // NME compatibility
        s = quickRegR(s, ":int", ":Int");
        s = quickRegR(s, ":Number", ":Float");
        s = quickRegR(s, ":\\*", ":Dynamic"); 
        s = quickRegR(s, ":Object", ":Dynamic"); 
        s = quickRegR(s, ":Error", ":Dynamic"); // NME compatibility 
        
        s = quickRegR(s, " void", " Void");
        s = quickRegR(s, " Boolean", " Bool");
        s = quickRegR(s, " uint", " Int"); // NME compatibility
        s = quickRegR(s, " int", " Int");
        s = quickRegR(s, " Number", " Float");
        s = quickRegR(s, " Object", " Dynamic"); 
        s = quickRegR(s, " Error", " Dynamic"); // NME compatibility
        
        s = quickRegR(s, "<Boolean>", "<Bool>");
        s = quickRegR(s, "<uint>", "<Int>"); // NME compatibility  
        s = quickRegR(s, "<int>", "<Int>");
        s = quickRegR(s, "<Number>", "<Float>");
        s = quickRegR(s, "<\\*>", "<Dynamic>");
        s = quickRegR(s, "<Object>", "<Dynamic>");
        s = quickRegR(s, "<Error>", "<Dynamic>"); // NME compatibility
        
        /* -----------------------------------------------------------*/
        // vector to array mapping     
        s = quickRegR(s, "Vector([ ]*)\\.([ ]*)<([ ]*)([^>]*)([ ]*)>", "Array<$3$4$5>");
        // new (including removing stupid spaces)
        s = quickRegR(s, "new Vector([ ]*)([ ]*)<([ ]*)([^>]*)([ ]*)>([ ]*)\\(([ ]*)\\)([ ]*)", "new Array()");
        
        // old version:
        /*              
        s = quickRegR(s, "Vector([ ]*)\\.([ ]*)<([ ]*)([^>]*)([ ]*)>", "Vector<$3$4$5>");
        // new (including removing stupid spaces)
        s = quickRegR(s, "new Vector([ ]*)([ ]*)<([ ]*)([^>]*)([ ]*)>([ ]*)\\(([ ]*)\\)([ ]*)", "new Vector()");  
        // and import if we have to
        var hasVectors = (quickRegM(s, "Vector([ ]*)\\.([ ]*)<([ ]*)([^>]*)([ ]*)>").length != 0);
        if (hasVectors) {
            s = quickRegR(s, "class([ ]*)(" + className + ")", "import flash.Vector;\n\nclass$1$2");
        } 
        */
                
        /* -----------------------------------------------------------*/
        
        // array
        s = quickRegR(s, "Array([ ]*);", "Array<Dynamic>;"); 
        s = quickRegR(s, "Array([ ]*)=", "Array<Dynamic>=");
                
        /* -----------------------------------------------------------*/
        
        // remap protected -> private & internal -> private
        s = quickRegR(s, "protected var", "private var");
        s = quickRegR(s, "internal var", "private var");
        s = quickRegR(s, "protected function", "private function");
        s = quickRegR(s, "internal function", "private function");  
        
        /* -----------------------------------------------------------*/
        
        //
        // Namespaces
        //
        
        // find which namespaces are used in this class
        var r = new EReg("([^#])use([ ]+)namespace([ ]+)([a-zA-Z-]+)([ ]*);", "g");
        b = 0;
        while (true) {
            b++; if (b > maxLoop) { logLoopError("namespaces find", file); break; }
            if (r.match(s)) {
                var ns:Ns = {
                    name : r.matched(4),
                    classDefs : new Map()
                };
                nameSpaces.set(ns.name, ns);
                s = r.replace(s, "//" + r.matched(0).replace("use", "#use") + "\nusing " + basePackage + ".namespace." + ns.name.fUpper() +  ";");
            }else {
                break;
            }
        }
        
        // collect all namespace definitions
        // replace them with private
        for (k in nameSpaces.keys()) {
            var n = nameSpaces.get(k);
            b = 0;
            while (true) {
                b++; if (b > maxLoop) { logLoopError("namespaces collect/replace var", file); break; }
                // vars
                var r = new EReg(n.name + "([ ]+)var([ ]+)", "g");
                s = r.replace(s, "private$1var$2");
                if (!r.match(s)) break;
            }
            b = 0;
            while (true) {
                b++; if (b > maxLoop) { logLoopError("namespaces collect/replace func", file); break; }
                // funcs
                var matched:Bool = false;
                var r = new EReg(n.name + "([ ]+)function([ ]+)", "g");
                if (r.match(s)) matched = true;
                s = r.replace(s, "private$1function$2");
                r = new EReg(n.name + "([ ]+)function([ ]+)get([ ]+)", "g");
                if (r.match(s)) matched = true;
                s = r.replace(s, "private$1function$2get$3");
                r = new EReg(n.name + "([ ]+)function([ ]+)set([ ]+)", "g");
                if (r.match(s)) matched = true;
                s = r.replace(s, "private$1function$2$3set");
                if (!matched) break;
            }
        }
        
        /* -----------------------------------------------------------*/
        // change const to inline statics
        s = quickRegR(s, "([\n\t ]+)(public|private)([ ]*)const([ ]+)([a-zA-Z0-9_]+)([ ]*):", "$1$2$3static inline var$4$5$6:");
        s = quickRegR(s, "([\n\t ]+)(public|private)([ ]*)(static)*([ ]+)const([ ]+)([a-zA-Z0-9_]+)([ ]*):", "$1$2$3$4$5inline var$6$7$8:");
        
        /* -----------------------------------------------------------*/
        // change local const to var
        s = quickRegR(s, "const ", "var ");
        
        /* -----------------------------------------------------------*/
        // move variables being set from var def to top of constructor
        // do NOT do this for const
        // if they're static, leave them there
        // TODO!
        
        /* -----------------------------------------------------------*/
        // Error > flash.Error
        // if " Error (" then add "import flash.Error" to head
        /*var r = new EReg("([ ]+)new([ ]+)Error([ ]*)\\(", "");
        if (r.match(s))
            s = quickRegR(s, "class([ ]*)(" + className + ")", "import flash.Error;\n\nclass$1$2");*/
        
        /* -----------------------------------------------------------*/

        // create getters and setters
        b = 0;
        while (true) {
            b++;
            var d = { get: null, set: null, type: null, ppg: null, pps: null, name: null };
            
            // get
            var r = new EReg("([\n\t ]+)([a-z]+)([ ]*)function([ ]*)get([ ]+)([a-zA-Z_][a-zA-Z0-9_]+)([ ]*)\\(([ ]*)\\)([ ]*):([ ]*)([A-Z][a-zA-Z0-9_]*)", "");
            var m = r.match(s);
            if (m) {
                d.ppg = r.matched(2);
                if (d.ppg == "") d.ppg = "public";
                d.name = r.matched(6);
                d.get = "get_" + d.name;
                d.type = r.matched(11);             
            }
            
            // set
            var r = new EReg("([\n\t ]+)([a-z]+)([ ]*)function([ ]*)set([ ]+)([a-zA-Z_][a-zA-Z0-9_]*)([ ]*)\\(([ ]*)([a-zA-Z][a-zA-Z0-9_]*)([ ]*):([ ]*)([a-zA-Z][a-zA-Z0-9_]*)", "");
            var m = r.match(s);
            if (m) {
                if (r.matched(6) == d.get || d.get == null)
                    if (d.name == null) d.name = r.matched(6);
                d.pps = r.matched(2);
                if (d.pps == "") d.pps = "public";
                d.set = "set_" + d.name;
                if (d.type == null) d.type = r.matched(12); 
            }
            
            // ERROR
            if (b > maxLoop) { logLoopError("getter/setter: " + d, file); break; }

            // replace get
            if (d.get != null)
                s = quickRegR(s, d.ppg + "([ ]+)function([ ]+)get([ ]+)" + d.name, "private function " + d.get);
            
            // replace set
            if (d.set != null)
                s = quickRegR(s, d.pps + "([ ]+)function([ ]+)set([ ]+)" + d.name, "private function " + d.set);
                                 
            // make haxe getter/setter OR finish
            if (d.get != null || d.set != null) {
                var gs = (d.ppg != null ? d.ppg : d.pps) + " var " + d.name + "(" + d.get + ", " + d.set + "):" + d.type + ";";
                s = quickRegR(s, "private function " + (d.get != null ? d.get : d.set), gs + "\n \tprivate function " + (d.get != null ? d.get : d.set));
                trace("Processing getter/setter: " + d);
            }else {
                break;
            }
        }

        /* -----------------------------------------------------------*/
        
        // for loops (?)
        // TODO!
        //s = quickRegR(s, "for([ ]*)\\(([ ]*)var([ ]*)([A-Z][a-zA-Z0-9_]*)([.^;]*);([.^;]*);([.^\\)]*)\\)", "");
        //var t = quickRegM(s, "for([ ]*)\\(([ ]*)var([ ]*)([a-zA-Z][a-zA-Z0-9_]*)([.^;]*)", 5);
        //trace(t);
        //for (var i : Int = 0; i < len; ++i)
        
        /* -----------------------------------------------------------*/
        
        // remap for in -> in
        s = quickRegR(s, "for\\(var([ ]*)([a-zA-Z0-9_]*):([a-zA-Z0-9_]*)([ ]*)in([ ]*)([a-zA-Z0-9_]*)([ ]*)", "for($2 in $6");
        
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