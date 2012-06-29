////////////////////////////////////////////////////////////////////////////////
//=BEGIN LICENSE MIT
//
// Copyright(c)2012 Andras Csizmadia<andras@vpmedia.eu>
// 
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files(the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//  
//=END LICENSE MIT
////////////////////////////////////////////////////////////////////////////////

package;

import flash.display.MovieClip;

//[SWF(backgroundColor="0x000000", frameRate="24", width="800", height="600")]

class Main extends MovieClip
{
	public var testPublicVar:Bool;
	private var testPrivateVar:Bool;
	private var testProtectedVar:Bool;
	public static var testStaticVar:Bool=false;
	public static inline var testStaticConst:Bool=true;
	
	// getter,setter property
	private var _sampleProperty:Dynamic;		  
			
	//Constructor
	public function new()
	{		 
		trace("Main constructor");
		
		super();
		
		// const
		var testLocalConst:Bool=true;
		
		// var simple
		var testLocalVarBoolean:Bool=true;
		var testLocalVarString:String="test";
		var testLocalVarInt:Int=1;
		var testLocalVarUInt:Int=1;
		var testLocalVarNumber:Float=1.1;
		var testLocalVarUntyped:Dynamic=[{prop:'value'}];
		
		// var object
		var testLocalVarObject:Dynamic={};
		
		// var array
		var testLocalVarArray:Array<Dynamic>=[];
		testLocalVarArray.push(1);
		
		// var vector
		var testLocalVarTypedVector:Array<Int>=new Array<Int>();	
		testLocalVarTypedVector.push(1);
		var testLocalVarUntypedVector:Array<Dynamic>=new Array<Dynamic>();			   
		
		// var assignment			
		testStaticVar=true;
		testPublicVar=true;
		testPrivateVar=true;
		testProtectedVar=true;				  
					
		try
		{
			// test try
		}
		catch(error:Dynamic)
		{
			// test catch
		}	  
		/*finally
		{   
			// the finally keyword is not available in Haxe
		}*/
		
		// test object value
		var o:Dynamic={};		
		o.bar=11;
		
		// the with keyword is not available in Haxe
		/*with(o)
		{
			foo=10;
		}*/
					   
		//  test iterate with for
		for(i in 0...testLocalVarArray.length)
		{
			trace('i:' + i);
		}
		for(i in 0...testLocalVarArray.length)
		{
			trace('i:' + i);
		}
		
		// backward iteration not supported by haxe, use while
		/*for(var i:Int=testLocalVarArray.length;i>0;i--)
		{
			trace('i:' + i);
		} */
		
		// test iterate with while
		var n:Int=0;
		while(n<10)
		{
			trace('n:' + n);
			n++;
		}
		
		// test iterate with in  
		for(p in o)
		{
			trace(p);// prints 'bar'
		}
		for(p2 in o)
		{
			trace(p2);// prints 'bar'
		}
		
		if(Std.is(o, Int))
		{
			var casted:Int=cast(o, Int);
		}
		
		var s:String=Std.string("1");
		var a:Float=Std.parseFloat(s)+ Std.parseFloat("2");
		var b:Int=Std.int(a)+ Std.int(1.1);
	}			
	
	//Getter/setter
	
	public var sampleProperty(getSampleProperty, setSampleProperty):Dynamic;
 	private function getSampleProperty():Dynamic 
	{
		return _sampleProperty;
	}

	private function setSampleProperty(value:Dynamic):Void 
	{
		_sampleProperty=value;
	}
	
	//Methods
	
	private function testPrivateMethodWithParam(param:String):Void
	{
		switch(param)
		{
			case "a":
				trace("a");
				//break;// haxe throws break outside a loop error!
			case "b":
				trace("b");
				//break;// haxe throws break outside a loop error!
			default:
				trace("Neither");
		}
	}	  
	
	public function testPublicMethod():Bool
	{
		return true;
	}
	
	private function testPrivateMethod():Bool
	{
		return true;
	}
	
	private function testProtectedMethod():Bool
	{
		return true;
	} 
	
	private function testVoidMethod():Void
	{
	}
	
	public function toString():String
	{
		return "[MainString]";
	}
	
}