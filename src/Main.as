package {
  import flash.display.*;

  public class Main extends Sprite {
    public function Main():void {
      var vo:TestVo = new TestVo();

      for (var i:* in vo) {
        trace(i, vo[i]);  
      }

      //Xmler.add('copydeck-en', init);
      
    }

    public function init(data:*):void {
      var footer:Object = Xmler.get('Footer');
      trace(footer.copyright);
    }
  }
}
