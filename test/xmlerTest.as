package  {

	import asunit.framework.TestCase;
  //import *;

	public class xmlerTest extends TestCase {
		private var xmler:Xmler;

		public function xmlerTest(methodName:String=null) {
			super(methodName)
		}

    public function testLoad():void {
      var x:Xmler = new Xmler();

      //Load a real XML file
      x.loadCopy('copydeck-en', function(data:*){});
      x.loadCallback = function(raw:*){
       assertTrue("Make sure that it returns xml", raw is XML);
      }

    }

    public function testBadLoad():void {
      var x:Xmler = new Xmler();
      Xmler.strict = false;

      // Load a nonexistent file
      x.loadCopy('deadfile', function(data:*){});
      x.loadCallback = function(raw:*){
       assertTrue("raw is an Error", (raw is XML) == false);
      }

    }

    public function testGetObject():void {
      var x:Xmler = new Xmler();

      //Load a real XML file
      x.loadCopy('copydeck-en', function(data:*){
        var footer:Object = x.get('Footer', 'copydeck-en');
        assertTrue("footer has copyright", footer.copyright != null);
      });
      
    }

    public function testGetBadObject():void {
      var x:Xmler = new Xmler();
      Xmler.strict = false;

      //Load a real XML file
      x.loadCopy('copydeck-en', function(data:*){
        var footer:Object = x.get('Foter', 'copydeck-en');
        assertTrue("Foter does not exist", footer == null);
      });
      
    }

    public function testVoMap():void {
      var vo:TestVo = new TestVo();
      var x:Xmler = new Xmler();

      //Load a real XML file
      x.loadCopy('copydeck-en', function(data:*){
        x.map(vo, "Footer", "copydeck-en");
        var footer:Object = x.get("Footer", 'copydeck-en');
        assertTrue("Footer vo has copyright", vo.copyright == footer.copyright);
      });
    }

	}
}
