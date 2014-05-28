////////////////////////////////////////////////////////////////////////////////
//=BEGIN LICENSE MIT
//
// Copyright (c) 2012 Andras Csizmadia <andras@vpmedia.eu>
// 
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
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

package
{
    import flash.display.MovieClip;

    [SWF(backgroundColor="0x000000", frameRate="24", width="800", height="600")]

    public class Main extends MovieClip
    {
        public var testPublicVar:Boolean;
        private var testPrivateVar:Boolean;
        protected var testProtectedVar:Boolean;
        public static var testStaticVar:Boolean = false; 
        public static const testStaticConst:Boolean = true;
        
        // getter,setter property
        private var _sampleProperty:Object;          
                
        //Constructor
        public function Main()
        {         
            trace("Main constructor");
            
            super();
            
            // const
            const testLocalConst:Boolean = true;
            
            // var simple
            var testLocalVarBoolean:Boolean = true;
            var testLocalVarString:String = "test";
            var testLocalVarInt:uint = 1;
            var testLocalVarUInt:uint = 1; 
            var testLocalVarNumber:Number = 1.1;
            var testLocalVarUntyped:* = [{prop:'value'}];
            
            // var object
            var testLocalVarObject:Object = {};
            
            // var array
            var testLocalVarArray:Array = [];   
            testLocalVarArray.push(1);
            
            // var vector
            var testLocalVarTypedVector:Vector.<int> = new Vector.<int>();    
            testLocalVarTypedVector.push(1);
            var testLocalVarUntypedVector:Vector.<*> = new Vector.<*>();               
            
            // var assignment            
            testStaticVar = true;
            testPublicVar = true;
            testPrivateVar = true;
            testProtectedVar = true;                  
                        
            try
            {
                // test try
            }
            catch(error:Error)
            {
                // test catch
            }      
            /*finally
            {   
                // the finally keyword is not available in Haxe
            }*/
            
            // test object value
            var o:Object = {};        
            o.bar = 11; 
            
            // the with keyword is not available in Haxe
            /*with (o)
            {
                foo=10;
            }*/
                           
            //  test iterate with for
            for(var i:int = 0; i < testLocalVarArray.length; i++)
            {
                trace('i: ' + i);
            }
            for(var i:int = 0; i <= testLocalVarArray.length; i++)
            {
                trace('i: ' + i);
            }
            
            // backward iteration not supported by haxe, use while
            /*for(var i:int = testLocalVarArray.length; i > 0; i--)
            {
                trace('i: ' + i);
            } */
            
            // test iterate with while
            var n:int = 0;
            while(n < 10)
            {
                trace('n: ' + n);
                n++;
            }
            
            // test iterate with in  
            /*for(var p:String in o)
            {
                trace(p); // prints 'bar'
            }
            for ( var p2 : String in o)
            {
                trace(p2); // prints 'bar'
            }*/
            
            if(o is int)
            {
                var casted:int = o as int;
            }
            
            var s:String = String("1");
            var a:Number = Number(s) + Number("2");
            var b:int = int(a) + int(1.1);
        }            
        
        //Getter/setter
        
        public  function get sampleProperty(): Object 
        {
            return _sampleProperty;
        }

        public function set sampleProperty(value: Object):void 
        {
            _sampleProperty = value;
        }
        
        //Methods
        
        private function testPrivateMethodWithParam(param : String):void
        {
            switch (param)
            {
                case "a":
                    trace("a");
                    //break; // haxe throws break outside a loop error!
                case "b":
                    trace ("b");
                    //break; // haxe throws break outside a loop error!
                default:
                    trace ("Neither");
            }
        }      
        
        public function testPublicMethod():Boolean
        {
            return true;
        }
        
        private function testPrivateMethod() : Boolean
        {
            return true;
        }
        
        protected function testProtectedMethod(): Boolean
        {
            return true;
        } 
        
        protected function testVoidMethod(): void
        {
        }
        
        public function toClassString():String
        {
            return "[MainString]";
        }
        
    }
}