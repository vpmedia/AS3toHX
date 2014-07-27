package;

import format.png.*;
import haxe.Json;
import haxe.Utf8;
import haxe.io.Bytes;
import neko.Lib;
import sys.FileSystem;
import sys.io.File;

using StringTools;
using XML2JSON;

/**
 * TexturePacker XML to JSON translator (For Flash to HTML5 asset conversion).
 */
class XML2JSON
{
    public static var keys = ["-from", "-to", "-remove", "-format", "-verbose", "-autoImagePath", "-autoFrameName"];
    
    var to:String;
    var from:String; 
    var remove:String;
    var format:String;
    var verbose:String;
    var autoImagePath:String;
    var autoFrameName:String;
    
    var sysargs:Array<String>;    
    var items:Array<String>;
        
    private var maxLoop:Int;
    
    static function main() 
    {
        new XML2JSON();
    }
    
    public function new()
    {
        maxLoop = 1000;
        
        if (parseArgs())
        {
        
            // make sure that the to directory exists
            if (!FileSystem.exists(to)) FileSystem.createDirectory(to);
            
            // delete old files
            if (remove == "true") {
                removeDirectory(to);
            }
            
            items = [];
            // fill items
            recurse(from);
            
            for (item in items)
            {
                var ext = getExt(item);
                switch(ext)
                {
                    case "xml": 
                        doConversion(item);
                }
            }
        }
    }
    
    private function doConversion(file:String):Void
    {        
        var fromFile = file;
        var fileName = file.substr(from.length + 1, file.lastIndexOf(".") - (from.length + 1));
        var toFile = to + "/" + fileName + "." + "json";
        
        /* -----------------------------------------------------------*/
        // create the folder if it doesn"t exist
        var dir = toFile.substr(0, toFile.lastIndexOf("/"));
        createFolder(dir);
        
        var s = File.getContent(fromFile);
              
        if (verbose == "true") {
            Lib.println("Processing: " + file);
        }  
        if(!Utf8.validate(s)) {
            // Convert UTF-16 (UCS2) to UTF-8  
            var arr = s.split("");
            var filtered = "";
            var c = 0;
            for(p in arr) {
                /*if(c < 10) {
                    Lib.println(p + ": " + s.charCodeAt(c));                    
                }*/
                if(s.charCodeAt(c) > 0 && s.charCodeAt(c) < 254) {
                    filtered += p;
                }
                c++;
            }
            s = filtered;
        }
        if(s.indexOf("SubTexture") == -1) {           
            if (verbose == "true") {
                Lib.println("Ignoring ('SubTexture' not found): " + file);
                return;
            }
        }
        
        /* -----------------------------------------------------------*/
        // normalize the XML string
        if(s.indexOf("<TextureAtlas") > 0) {
            s = StringTools.replace(s, s.substr(0, s.indexOf("<TextureAtlas")), "");        
        }
        var si = 0;
        var ei = 1;
        while(si > -1 && ei > -1 && si != ei) { 
            //s = StringTools.trim(s);         
            si = s.indexOf("<!--");
            ei = s.indexOf("-->");   
            var part = s.substr(si, ei + 1);   
            if(part != null && part != "" && part.length > 1) {
                //Lib.println("Removing segment: " + "'" + part + "'" + " (size:" + part.length + ")"); 
                s = StringTools.replace(s, part, "");
            }            
        }
        s = StringTools.trim(s);
        var xml = Xml.parse(s);
        var project = xml.firstChild();
        var imagePath = project.get("imagePath");
        if(imagePath == null || imagePath == "") {                   
            if (verbose == "true") {
                Lib.println("Ignoring ('imagePath' not found): " + file);
            }
            return;
        }
        if(autoImagePath == "true") {
            imagePath = fileName + ".png";
        }
        // get png size
        var pngData = {"width": 0, "height": 0};
        var pngPath = from + "/" + imagePath;
        if(FileSystem.exists(pngPath)) {                  
            /*if (verbose == "true") {
                Lib.println("Reading PNG: " + pngPath);
            }*/
            pngData = readPNG(pngPath);        
        }
        
        /* -----------------------------------------------------------*/
        // create the json core structure
        var json = { 
            "frames": {},
            "meta": {
                "app": "TexturePacker",
                "version": "1.0",
                "image": imagePath,
                "format": "RGBA8888",
                "size": { "w": pngData.width, "h": pngData.height},
                "scale": 1
            } 
        };  
        
        // parse frames
        var frameCount = 0;
        for (node in project)
        {
            if (node.nodeType == Xml.Element)
            {
                var stN = node.get("name");
                stN = Std.string(stN).split(" ").join("_");
                if(autoFrameName == "true") {
                    stN = Std.string(frameCount);
                }
                var stX = Std.parseFloat(node.get("x"));
                var stY = Std.parseFloat(node.get("y"));
                var stW = Std.parseFloat(node.get("width"));
                var stH = Std.parseFloat(node.get("height"));
                var o = {
                    "frame": {"x": stX, "y": stY, "w": stW, "h": stH},
                    "rotated": false,
                    "trimmed": false,
                    "spriteSourceSize": {"x": 0, "y": 0, "w": stW, "h": stH},      
                    "sourceSize": {"w": stW, "h": stH},                 
                };
                Reflect.setField(json.frames, stN, o);
                frameCount++;
            }
        }
                  
        /* -----------------------------------------------------------*/
        // beautify output optionally
        if (format == "true") {
            s = Json.stringify(json, null, "  ");
        } else {
            s = Json.stringify(json);        
        }            
        
        /* -----------------------------------------------------------*/
        // write out file
        var o = File.write(toFile, true);
        o.writeString(s);
        o.close();
        
        /* -----------------------------------------------------------*/        
        // use for testing on a single file
        //Sys.exit(1);
    }
    
    private function readPNG(file:String):{data:Bytes, width:Int, height:Int} {
        var handle = File.read(file, true);
        var d = new Reader(handle).read();
        var hdr = Tools.getHeader(d);
        var ret = {
            data:Tools.extract32(d),
            width:hdr.width,
            height:hdr.height
        };
        handle.close();
        return ret;
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
                var exts = ["xml"];
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
        if (verbose == "true") {
            Lib.println("Removing folder: " + d);
        }
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
}
