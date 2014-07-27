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




//[SWF(backgroundColor="0x000000", frameRate="24", width="800", height="600")]

class Main extends MovieClip
{
	var testPublicVar;
	var testPrivateVar;
	var testProtectedVar;
	var testStaticVar=false;
	var testStaticConst=true;
	
	// getter,setter property
	var _sampleProperty;		  
			
	//Constructor
	function Main()
	{		 
		console.log("Main constructor");
		
		
		
		// const
		var testLocalConst=true;
		
		// var simple
		var testLocalVarBoolean=true;
		var testLocalVarString="test";
		var testLocalVarInt=1;
		var testLocalVarUInt=1;
		var testLocalVarNumber=1.1;
		var testLocalVarUntyped=[{prop:'value'}];
		
		// var object
		var testLocalVarObject={};
		
		// var array
		var testLocalVarArray=[];
		testLocalVarArray.push(1);
		
		// var vector
		var testLocalVarTypedVector=new Array();	
		testLocalVarTypedVector.push(1);
		var testLocalVarUntypedVector=new Array();			   
		
		// var assignment			
		testStaticVar=true;
		testPublicVar=true;
		testPrivateVar=true;
		testProtectedVar=true;				  
					
		try
		{
			// test try
		}
		catch(error)
		{
			// test catch
		}	  
		/*finally
		{   
			// the finally keyword is not available in Haxe
		}*/
		
		// test object value
		var o={};		
		o.bar=11;
		
		// the with keyword is not available in Haxe
		/*with(o)
		{
			foo=10;
		}*/
					   
		//  test iterate with for
		for(var i=0;i<testLocalVarArray.length;i++)
		{
			console.log('i:' + i);
		}
		for(var i=0;i<=testLocalVarArray.length;i++)
		{
			console.log('i:' + i);
		}
		
		// backward iteration not supported by haxe, use while
		/*for(var i=testLocalVarArray.length;i>0;i--)
		{
			console.log('i:' + i);
		} */
		
		// test iterate with while
		var n=0;
		while(n<10)
		{
			console.log('n:' + n);
			n++;
		}
		
		// test iterate with in  
		/*for(var p in o)
		{
			console.log(p);// prints 'bar'
		}
		for(var p2 in o)
		{
			console.log(p2);// prints 'bar'
		}*/
		
		if(o is int)
		{
			var casted=o ;
		}
		
		var s=String("1");
		var a=Number(s)+ Number("2");
		var b=int(a)+ int(1.1);
	}			
	
	//Getter/setter
	
	 function get_sampleProperty() 
	{
		return _sampleProperty;
	}

	function set_sampleProperty(value) 
	{
		_sampleProperty=value;
	}
	
	//Methods
	
	function testPrivateMethodWithParam(param)
	{
		switch(param)
		{
			case "a":
				console.log("a");
				//break;// haxe throws break outside a loop error!
			case "b":
				console.log("b");
				//break;// haxe throws break outside a loop error!
			default:
				console.log("Neither");
		}
	}	  
	
	function testPublicMethod()
	{
		return true;
	}
	
	function testPrivateMethod()
	{
		return true;
	}
	
	function testProtectedMethod()
	{
		return true;
	} 
	
	function testVoidMethod()
	{
	}
	
	function toClassString()
	{
		return "[MainString]";
	}
	
}